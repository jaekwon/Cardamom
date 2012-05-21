(function() {
  var bindMethods, ctor, extendProto, isPropertyDescriptor, _,
    __hasProp = Object.prototype.hasOwnProperty;

  _ = require('underscore');

  bindMethods = function(that, proto) {
    var name, value, _results;
    _results = [];
    for (name in proto) {
      if (!(name[name.length - 1] === '$' && name.length > 1)) continue;
      value = that[name];
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
        if (value.enumerable == null) value.enumerable = true;
        if (value.configurable == null) value.configurable = true;
        if (value.value != null) {
          if (value.writable == null) value.writable = true;
        } else if (value.configurable) {
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
    var clazzDefined, constructor, key, proto, protoCtor, value, _ref, _ref2;
    if (typeof name !== 'string') {
      _ref = [void 0, name, base], name = _ref[0], base = _ref[1], protoFn = _ref[2];
    }
    if (protoFn === void 0) {
      _ref2 = [name, void 0, base], name = _ref2[0], base = _ref2[1], protoFn = _ref2[2];
    }
    protoFn || (protoFn = (function() {}));
    clazzDefined = false;
    proto = void 0;
    if (!(name != null)) {
      constructor = function() {
        var _ref3;
        if (!clazzDefined) {
          throw new Error("Can't create " + name + " clazz instances in the clazz body.");
        }
        if (this instanceof constructor) {
          bindMethods(this, proto);
          if ((_ref3 = proto.init) != null) _ref3.apply(this, arguments);
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
      constructor = eval("function " + name + "() {\n  if (!clazzDefined) throw new Error(\"Can't create " + name + " clazz instances in the clazz body.\");\n  if (this instanceof constructor) {\n    bindMethods(this, proto);\n    if (typeof proto.init !== 'undefined' && proto.init !== null) proto.init.apply(this, arguments);\n    if (this._newOverride !== void 0) return this._newOverride;\n    return this;\n  } else {\n    return (function(func, args, ctor) {\n      ctor.prototype = proto;\n      var child = new ctor, result = func.apply(child, args);\n      return typeof result === \"object\" ? result : child;\n    })(constructor, arguments, function() {});\n  }\n}; " + name);
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
    constructor.prototype = proto = new protoCtor();
    extendProto(proto, protoFn.call(constructor, base.prototype));
    clazzDefined = true;
    return constructor;
  };

}).call(this);
