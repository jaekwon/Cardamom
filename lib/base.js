(function() {
  var Base, clone, extend, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ref = require('underscore'), clone = _ref.clone, extend = _ref.extend;

  this.Base = Base = (function() {

    Base.name = 'Base';

    Base.instance = Base.i = function(methods) {
      if (arguments.length > 1) {
        methods = {};
        methods[arguments[0]] = arguments[1];
      }
      if (this.__Base__class !== this) {
        this.__Base__class = this;
        this.__Base__instanceMethods = this.__Base__instanceMethods ? clone(this.__Base__instanceMethods) : {};
      }
      extend(this.__Base__instanceMethods, methods);
      return extend(this.prototype, methods);
    };

    Base.static = Base.s = function(methods) {
      if (arguments.length > 1) {
        methods = {};
        methods[arguments[0]] = arguments[1];
      }
      return extend(this.prototype, methods);
    };

    Base["class"] = Base.c = function(methods) {
      if (arguments.length > 1) {
        methods = {};
        methods[arguments[0]] = arguments[1];
      }
      return extend(this, methods);
    };

    function Base() {
      this.bindInstanceMethods = __bind(this.bindInstanceMethods, this);
      this.bindInstanceMethods();
    }

    Base.prototype.bindInstanceMethods = function() {
      var func, name, _ref2, _results;
      if (!this.__Base__bound) {
        this.__Base__bound = true;
        _ref2 = this.constructor.__Base__instanceMethods;
        _results = [];
        for (name in _ref2) {
          func = _ref2[name];
          _results.push(this[name] = func.bind(this));
        }
        return _results;
      }
    };

    return Base;

  })();

}).call(this);
