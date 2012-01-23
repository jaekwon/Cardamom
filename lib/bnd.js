(function() {
  var assert,
    __hasProp = Object.prototype.hasOwnProperty;

  assert = require('assert');

  this.Bnd = function(cls) {
    var bnd;
    bnd = function(obj) {
      var key, value;
      if (typeof obj === 'function') {
        obj.__Bnd__bind = true;
      } else {
        assert.ok(cls, 'To use Bnd with {key:value} objects, pass the class to the Bnd() constructor.');
        for (key in obj) {
          if (!__hasProp.call(obj, key)) continue;
          value = obj[key];
          cls.prototype[key] = value;
          if (typeof value === 'function') value.__Bnd__bind = true;
        }
      }
      return obj;
    };
    bnd.to = function(self) {
      var key, value, _ref, _results;
      _ref = self.constructor.prototype;
      _results = [];
      for (key in _ref) {
        if (!__hasProp.call(_ref, key)) continue;
        value = _ref[key];
        if (value != null ? value.__Bnd__bind : void 0) {
          _results.push(self[key] = value.bind(self));
        }
      }
      return _results;
    };
    return bnd;
  };

}).call(this);
