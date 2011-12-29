(function() {
  var clone, extend, _ref;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ref = require('underscore'), clone = _ref.clone, extend = _ref.extend;

  this.Base = (function() {

    Base.instance = function(methods) {
      if (this.__methods__class !== this) {
        this.__methods__class = this;
        this.__methods = this.__methods ? clone(this.__methods) : {};
      }
      extend(this.__methods, methods);
      return extend(this.prototype, methods);
    };

    Base.static = function(methods) {
      return extend(this.prototype, methods);
    };

    Base["class"] = function(methods) {
      return extend(this, methods);
    };

    function Base() {
      this.bindInstanceMethods = __bind(this.bindInstanceMethods, this);      this.bindInstanceMethods();
    }

    Base.prototype.bindInstanceMethods = function() {
      var func, name, _ref2, _results;
      if (!this.__methods__bound) {
        this.__methods__bound = true;
        _ref2 = this.constructor.__methods;
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
