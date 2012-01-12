(function() {

  this.Fn = require('./fnstuff').Fn;

  this.Bnd = require('./bnd').Bnd;

  this.Base = require('./base').Base;

  this.local = function(fn) {
    return fn();
  };

}).call(this);
