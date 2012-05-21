(function() {
  var bindMethods, ctor, extendProto, isPropertyDescriptor, _,
    __hasProp = Object.prototype.hasOwnProperty;

  _ = require('underscore');

  bindMethods = function(that, proto) {
    var name, value, _results;
    _results = [];
    for (name in proto) {
      value = proto[name];
      if (!(name[name.length - 1] === '$' && name.length > 1)) continue;
      name = name.slice(0, (name.length - 1));
      if (typeof value === 'function') {
        _results.push(that[name] = value.bind(that));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  isPropertyDescriptor = function(obj) {
    return typeof obj === 'object' && (obj.get || obj.set || obj.value);
  };

  extendProto = function(baseProto, childProtoProto) {
    var method, name, value, _results;
    for (name in childProtoProto) {
      method = childProtoProto[name];
      baseProto[name] = method;
      if (typeof method === 'function' && name[name.length - 1] !== '$' && typeof baseProto[name + '$'] === 'function') {
        baseProto[name + '$'] = null;
      }
    }
    _results = [];
    for (name in childProtoProto) {
      value = childProtoProto[name];
      if (!(name[name.length - 1] === '$' && name.length > 1)) continue;
      name = name.slice(0, (name.length - 1));
      if (isPropertyDescriptor(value)) {
        if (value.value != null) {
          if (value.writable == null) value.writable = true;
        } else {
          if (value.enumerable == null) value.enumerable = true;
          if (value.configurable == null) value.configurable = true;
          if (value.configurable) {
            if (value.set == null) {
              value.set = function(newValue) {
                return Object.defineProperty(this, name, {
                  writable: true,
                  enumerable: true,
                  configurable: true,
                  value: newValue
                });
              };
            }
          }
        }
        _results.push(Object.defineProperty(baseProto, name, value));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  ctor = function(proto, fn) {
    fn.prototype = proto;
    return fn;
  };

  this.clazz = function(name, base, protoFn) {
    var constructor, key, protoCtor, target, value, _ref, _ref2, _ref3;
    if (name instanceof Array) _ref = name, target = _ref[0], name = _ref[1];
    if (typeof name !== 'string') {
      _ref2 = [void 0, name, base], name = _ref2[0], base = _ref2[1], protoFn = _ref2[2];
    }
    if (protoFn === void 0) {
      _ref3 = [name, void 0, base], name = _ref3[0], base = _ref3[1], protoFn = _ref3[2];
    }
    protoFn || (protoFn = (function() {}));
    if (!(name != null)) {
      constructor = function() {
        var proto, _ref4;
        if (this instanceof constructor) {
          proto = constructor.prototype;
          bindMethods(this, proto);
          if ((_ref4 = proto.init) != null) _ref4.apply(this, arguments);
          if (this._newOverride !== void 0) return this._newOverride;
          return this;
        } else {
          return (function(func, args, ctor) {
            ctor.prototype = func.prototype;
            var child = new ctor, result = func.apply(child, args);
            return typeof result === "object" ? result : child;
          })(constructor, arguments, function() {});
        }
      };
    } else {
      constructor = eval("function " + name + "() {\n  var proto;\n  if (this instanceof constructor) {\n    proto = constructor.prototype;\n    bindMethods(this, proto);\n    if (typeof proto.init !== 'undefined' && proto.init !== null) proto.init.apply(this, arguments);\n    if (this._newOverride !== void 0) return this._newOverride;\n    return this;\n  } else {\n    return (function(func, args, ctor) {\n      ctor.prototype = func.prototype;\n      var child = new ctor, result = func.apply(child, args);\n      return typeof result === \"object\" ? result : child;\n    })(constructor, arguments, function() {});\n  }\n}; " + name);
    }
    if (base != null) {
      for (key in base) {
        if (!__hasProp.call(base, key)) continue;
        value = base[key];
        constructor[key] = value;
      }
    } else {
      base = Object;
    }
    protoCtor = ctor(base.prototype, function() {
      this.constructor = constructor;
      this["super"] = base.prototype;
      return this;
    });
    constructor.prototype = new protoCtor();
    extendProto(constructor.prototype, protoFn.call(constructor, base.prototype));
    if (target != null) target[name] = constructor;
    return constructor;
  };

}).call(this);
