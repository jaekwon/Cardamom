(function() {
  var assert;

  assert = require('assert');

  this.Fn = function(syntax, fn) {
    var argParts, args, wrapFn, _ref;
    if (fn == null) fn = null;
    _ref = [[], syntax.trim().split(' ')], args = _ref[0], argParts = _ref[1];
    assert.ok(argParts.length > 0, 'Syntax for Fn should contain 1 or more args.');
    argParts.forEach(function(part) {
      var arg, fnParts;
      args.push((arg = {}));
      if (part[0] === '[') {
        assert.ok(part[part.length - 1] === ']', "Unclosed brackets []: " + part);
        part = part.slice(1, (part.length - 1));
        arg.optional = true;
      } else {
        arg.optional = false;
      }
      if (part[part.length - 1] === '?') {
        part = part.slice(0, (part.length - 1));
        arg.undefinedOk = true;
      } else {
        arg.undefinedOk = false;
      }
      if (part[0] === '{') {
        assert.ok(part[part.length - 1] === '}', "Unclosed brackets {}: " + part);
        part = part.slice(1, (part.length - 1));
        arg.type = 'object';
        return arg.name = part || void 0;
      } else if (part.indexOf('->') >= 0) {
        fnParts = part.split('->');
        assert.ok(fnParts.length === 2, "Unrecognized function syntax: " + part);
        arg.type = 'function';
        arg.name = fnParts[0] || void 0;
        return arg["return"] = fnParts[1];
      } else if (part[0] === '"' || part[0] === '\'') {
        assert.ok(part[part.length - 1] === part[0], "Unclosed string: " + part);
        part = part.slice(1, (part.length - 1));
        arg.type = 'string';
        return arg.name = part || void 0;
      } else {
        arg.type = void 0;
        return arg.name = part || void 0;
      }
    });
    wrapFn = function(fn) {
      return function() {
        var arg, argType, argumentIndex, expectedArg, expectedIndex, toPass;
        toPass = [];
        argumentIndex = 0;
        for (expectedIndex in args) {
          expectedArg = args[expectedIndex];
          arg = arguments[argumentIndex];
          argType = arg instanceof Array ? 'Array' : typeof arg;
          if (!(expectedArg.type != null) || expectedArg.type === argType) {
            toPass.push(arg);
            argumentIndex += 1;
          } else if (expectedArg.undefinedOk && argType === 'undefined') {
            toPass.push(arg);
            argumentIndex += 1;
          } else if (expectedArg.optional) {
            toPass.push(void 0);
          } else {
            if (argumentIndex >= arguments.length) {
              throw new Error("Fn expected arg of type " + expectedArg.type + " for argument #0+" + argumentIndex + ", but ran out of arguments.");
            } else {
              throw new Error("Fn expected arg of type " + expectedArg.type + " for argument #0+" + argumentIndex + ", but got type '" + argType + "': " + arg);
            }
          }
        }
        if (argumentIndex < arguments.length) {
          throw new Error("Fn received extra arguments from #0+" + argumentIndex + " (" + arguments.length + " total): " + arguments[argumentIndex]);
        }
        return fn.apply(null, toPass);
      };
    };
    if (fn != null) {
      return wrapFn(fn);
    } else {
      return wrapFn;
    }
  };

}).call(this);
