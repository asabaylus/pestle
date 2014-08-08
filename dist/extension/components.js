(function() {
  (function(root, factory) {
    return module.exports = factory(root, {});
  })(window, function(root, Ext) {
    var Base, Component;
    Base = require('./../base.coffee');
    Component = (function() {
      function Component() {}

      /**
       * [startAll description]
       * @author Francisco Ramini <francisco.ramini at globant.com>
       * @param  {[type]} selector = 'body'. CSS selector to tell the app where to look for components
       * @return {[type]}
      */


      Component.startAll = function(selector) {
        var components;
        if (selector == null) {
          selector = 'body';
        }
        components = Component.parseList(selector);
        console.log("ESTAS SERIAN LAS COMPONENTES PARSEADAS");
        return console.log(components);
      };

      Component.parseList = function(selector) {
        var cssSelector, list, namespace;
        list = [];
        namespace = "lodges";
        cssSelector = ["[data-lodges-component]"];
        $(selector).find(cssSelector.join(',')).each(function(i, comp) {
          var options;
          options = Component.parseComponentOptions(this, "lodges");
          return list.push({
            name: options.name,
            options: options
          });
        });
        return list;
      };

      Component.parseComponentOptions = function(el, namespace, opts) {
        var data, name, options;
        options = _.clone(opts || {});
        options.el = el;
        data = $(el).data();
        name = '';
        $.each(data, function(k, v) {
          k = k.replace(new RegExp("^" + namespace), "");
          k = k.charAt(0).toLowerCase() + k.slice(1);
          if (k !== "component") {
            return options[k] = v;
          } else {
            return name = v;
          }
        });
        return Component.buildOptionsObject(name, options);
      };

      Component.buildOptionsObject = function(name, options) {
        options.name = name;
        return options;
      };

      return Component;

    })();
    return {
      initialize: function(app) {
        console.log("Inicializada la componente de Componentes");
        return app.sandbox.startComponents = function(list) {
          return Component.startAll();
        };
      },
      afterAppStarted: function(app) {
        console.log("Llamando al afterAppStarted");
        return app.sandbox.startComponents();
      }
    };
  });

}).call(this);
