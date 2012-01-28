(function() {
  var assert,
    __hasProp = Object.prototype.hasOwnProperty;

  assert = require('assert');

  this.B = function(fn) {
    fn.bindMethod = true;
    return fn;
  };

  this.B.ind = function(cls) {
    var name, value, _ref, _results,
      _this = this;
    _ref = cls.prototype;
    _results = [];
    for (name in _ref) {
      if (!__hasProp.call(_ref, name)) continue;
      value = _ref[name];
      if (typeof value === 'function' && value.bindMethod) {
        _results.push((function(name, value) {
          return Object.defineProperty(cls.prototype, name, {
            enumerable: false,
            configurable: true,
            get: function() {
              if (this === this.constructor.prototype) {
                return value;
              } else {
                return this[name] = value.bind(this);
              }
            },
            set: function(newValue) {
              return Object.defineProperty(this, name, {
                value: newValue
              });
            }
          });
        })(name, value));
      }
    }
    return _results;
  };

}).call(this);
