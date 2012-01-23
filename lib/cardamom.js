(function() {
  var EE,
    __hasProp = Object.prototype.hasOwnProperty;

  this.Fn = require('./fnstuff').Fn;

  this.Bnd = require('./bnd').Bnd;

  this.Base = require('./base').Base;

  this.local = function(fn) {
    return fn();
  };

  EE = require('events').EventEmitter;

  this.eventful = function(obj, attach) {
    var emitter, key, value, _ref, _results;
    if (attach == null) attach = true;
    emitter = new EE();
    if (attach) obj.emitter = emitter;
    _ref = EE.prototype;
    _results = [];
    for (key in _ref) {
      if (!__hasProp.call(_ref, key)) continue;
      value = _ref[key];
      _results.push((function(key) {
        return obj[key] = function() {
          return emitter[key].apply(emitter, arguments);
        };
      })(key));
    }
    return _results;
  };

}).call(this);
