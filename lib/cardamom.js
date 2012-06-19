(function() {
  var EE, clazz,
    __hasProp = Object.prototype.hasOwnProperty;

  this.Fn = require('./fnstuff').Fn;

  this.B = require('./bind').B;

  this.local = function(fn) {
    return fn();
  };

  this.ErrorBase = require('./errors').ErrorBase;

  this.clazz = clazz = require('./clazz').clazz;

  this.colors = require('./colors');

  this.bisect = require('./bisect');

  this.collections = require('./collections');

  EE = require('events').EventEmitter;

  this.eventful = function(obj) {
    var key, value, _ref, _results;
    _ref = EE.prototype;
    _results = [];
    for (key in _ref) {
      if (!__hasProp.call(_ref, key)) continue;
      value = _ref[key];
      _results.push((function(key) {
        return obj[key] = value;
      })(key));
    }
    return _results;
  };

}).call(this);
