(function() {
  var __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  if (Error.captureStackTrace) {
    this.ErrorBase = (function(_super) {

      __extends(ErrorBase, _super);

      ErrorBase.name = 'ErrorBase';

      function ErrorBase(message) {
        this.message = message;
        Error.captureStackTrace(this, this.constructor);
        this.name = this.constructor.name;
      }

      return ErrorBase;

    })(Error);
  } else {
    this.ErrorBase = (function(_super) {

      __extends(ErrorBase, _super);

      ErrorBase.name = 'ErrorBase';

      function ErrorBase() {
        var e;
        e = ErrorBase.__super__.constructor.apply(this, arguments);
        e.name = this.constructor.name;
        this.message = e.message;
        Object.defineProperty(this, 'stack', {
          get: function() {
            return e.stack;
          }
        });
      }

      return ErrorBase;

    })(Error);
  }

}).call(this);
