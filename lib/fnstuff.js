(function() {
  var assert;

  assert = require('assert');

  this.Fn = function(syntax, fn) {
    var argParts, args, wrapFn, _ref;
    if (fn == null) fn = null;
    _ref = [[], syntax.trim().split(' ')], args = _ref[0], argParts = _ref[1];
    assert.ok(argParts.length > 0, 'Syntax for Fn should contain 1 or more args.');
    argParts.forEach(function(part, partIndex) {
      var arg, fnParts;
      args.push((arg = {}));
      if (part[0] === '[') {
        assert.ok(part[part.length - 1] === ']', "Unclosed brackets []: " + part);
        part = part.slice(1, (part.length - 1));
        arg.optional = true;
        arg.splat = false;
      } else if (part.slice(part.length - 3) === '...') {
        assert.equal(partIndex, argParts.length - 1, "Splat was not the last argument: " + part);
        part = part.slice(0, (part.length - 3));
        arg.optional = false;
        arg.splat = true;
      } else {
        arg.optional = false;
        arg.splat = false;
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
      var doesMatch, type;
      type = function(arg) {
        if (arg instanceof Array) {
          return 'Array';
        } else {
          return typeof arg;
        }
      };
      doesMatch = function(arg, expectedArg) {
        return !(expectedArg.type != null) || expectedArg.type === type(arg) || expectedArg.undefinedOk && type(arg) === 'undefined';
      };
      return function() {
        var arg, argumentIndex, expectedArg, expectedIndex, toPass;
        toPass = [];
        argumentIndex = 0;
        expectedIndex = 0;
        while (expectedIndex < args.length) {
          expectedArg = args[expectedIndex];
          arg = arguments[argumentIndex];
          if (doesMatch(arg, expectedArg)) {
            if (expectedArg.splat) {
              if (argumentIndex >= arguments.length) break;
              toPass.push(arg);
              argumentIndex += 1;
            } else {
              toPass.push(arg);
              argumentIndex += 1;
              expectedIndex += 1;
            }
          } else if (expectedArg.optional) {
            toPass.push(void 0);
            expectedIndex += 1;
          } else {
            if (argumentIndex >= arguments.length) {
              throw new Error("Fn expected arg of type " + expectedArg.type + " for argument #0+" + argumentIndex + ", but ran out of arguments.");
            } else {
              throw new Error("Fn expected arg of type " + expectedArg.type + " for argument #0+" + argumentIndex + ", but got type '" + (type(arg)) + "': " + arg);
            }
          }
        }
        if (argumentIndex < arguments.length) {
          throw new Error("Fn received extra arguments from #0+" + argumentIndex + " (" + arguments.length + " total): " + arguments[argumentIndex]);
        }
        return fn.apply(this, toPass);
      };
    };
    if (fn != null) {
      return wrapFn(fn);
    } else {
      return wrapFn;
    }
  };

}).call(this);
