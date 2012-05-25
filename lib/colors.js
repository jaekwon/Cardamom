(function() {
  var _wrap_with;

  _wrap_with = function(code) {
    return function(text, bold) {
      return "\x1b[" + (bold ? '1;' : '') + code + "m" + text + "\x1b[0m";
    };
  };

  this.black = _wrap_with('30');

  this.red = _wrap_with('31');

  this.green = _wrap_with('32');

  this.yellow = _wrap_with('33');

  this.blue = _wrap_with('34');

  this.magenta = _wrap_with('35');

  this.cyan = _wrap_with('36');

  this.white = _wrap_with('37');

  this.normal = function(text) {
    return text;
  };

}).call(this);