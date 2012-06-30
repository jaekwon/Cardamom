(function() {
  var Set, clazz;

  clazz = require('cardamom/src/clazz').clazz;

  this.Set = Set = clazz('Set', function() {
    return {
      __init__: function(elements) {
        this.elements = elements;
      }
    };
  });

}).call(this);
