
  this.Fn = require('./fnstuff').Fn;

  this.Base = require('./base').Base;

  this.local = function(fn) {
    return fn();
  };
