((root, factory) ->

    root.backboneext = factory(root, {})

)(window, (root, Ext) ->

    Base = NGS.instance.sandbox

    Renderer =

        render: (template, data) ->

            unless template
                Base.log.error "The template passed to the Renderer is not defined"
                return

            if Base.util.isFunction template
                return template data



    # Default base object that is gonna be used as the default object to be mixed
    # into other views
    BaseView =

        initialize: () ->
            Base.log.info "initialize del BaseView"

            Base.util.bindAll @, 'render',
                         'renderWrapper'

            if Base.util.isFunction @beforeRender
                Base.util.bindAll @, 'beforeRender'

            if Base.util.isFunction @afterRender
                Base.util.bindAll @, 'afterRender'

            @render = Base.util.wrap @render, @renderWrapper

        # Method to ensure that the data is always passed to the template in the same way
        serializeData : () ->

            data = {}

            if @model
                data = @model.toJSON()
            else if @collection
                # this way we normalize the property we'll use to iterate
                # the collection inside the hbs
                data = items : @collection.toJSON()

            # this will be helpfull in views which renders collections
            # and needs to display a customizable title on top
            if @title
                data.title = @title

            return data

        # Ensures that events are removed before the View is removed from the DOM
        destroy : () ->

            # unbind events
            @undelegateEvents()
            @$el.removeData().unbind() if @$el

            #Remove view from DOM
            @remove()
            Backbone.View::remove.call(this)

        # Wrapper to add "beforeRender" and "afterRender" methods.
        renderWrapper: (originalRender) ->
            @beforeRender() if Base.util.isFunction @beforeRender

            originalRender() if Base.util.isFunction originalRender

            @afterRender() if Base.util.isFunction @afterRender

            @

        render: () ->

            # as a rule, if the template is passed as a parameter for the module
            # this option will override the default template of the view
            if @model and @model.get('template')
                tpl = JST[@model.get('template')]
            else
                tpl = @template

            data = @serializeData()

            html = Renderer.render(tpl, data)

            @attachElContent html

            @

        attachElContent: (html) ->

            @$el.append(html)
  
            @



    # returns an object with the initialize method that will be used to
    # init the extension
    initialize : (app) ->

        Base.log.info "[ext] Backbone extension initialized"

        app.sandbox.mvc = () ->
            Base.log.info "Inicializada la componente de MVC"

        # this gives access to BaseView from the outside
        app.sandbox.mvc.BaseView = BaseView

        ###*
         * This method allows to mix a backbone view with an object
         * @author Francisco Ramini <francisco.ramini at globant.com>
         * @param  {[type]} view
         * @param  {[type]} mixin = BaseView
         * @return {[type]}
        ###
        app.sandbox.mvc.mixin = (view, mixin = BaseView) ->

            if mixin.initialize isnt 'undefined'
                oldInitialize = view::initialize

            Base.util.extend view::, mixin
            Base.util.defaults view::events, mixin.events

            if oldInitialize
                view::initialize = ->
                    mixin.initialize.apply this
                    oldInitialize.apply this

    name: 'Backbone Extension'

    # The exposed key name that could be used to pass options
    # to the extension.
    # This is gonna be used when instantiating the Core object.
    # Note: By convention we'll use the filename
    optionKey: 'backboneext'
)