(function() {
  var bindMethods, ctor, extendProto, _;

  _ = require('underscore');

  /*
  
  This is another attempt to implement classes as a DSL.
  
  ## The difference:
  
  1. super is @super (or supr, in the class body)
  2. use init, not constructor
  2. Method binding looks like this: boundMethod$: -> @ != GLOBAL
  
  ## The benefits:
  
  1. You don't have to call super for instance method binding to work.
  2. Super no longer depends on lexical scope -- you can use @super anywhere,
     as long as you specify the method name (as in Python). 
  3. Metaprogramming is easier, for example dynamically creating bound methods
     is as easy as appending a '$' to the method name.
  
  ## Declare a class Foo
  
  Foo = clazz 'Foo', null, (supr) ->
    @myStaticMethod = -> # is set on Foo
  
    init: ->
      console.log "Foo initializer"
  
    foo$: -> # a bound method
      console.log "@", @, "@barProp", @barProp, "instanceof Foo?", @ instanceof Foo
  
    myClassMethod: => # this is bound to the class
      
  ## Extending Foo:
  
  Bar = clazz 'Bar', Foo, (supr) ->
    barProp: 'barProp!'
  
    init: (@bar='init:bar') ->
      @super.init()
      console.log "Bar initializer"
  
    moo$: ->
      console.log "@", @, "@constructor", @constructor, "@super", @super
    boo: -> # an unbound method
      console.log "@", @, "@constructor", @constructor, "@super", @super
  */

  bindMethods = function(that, proto) {
    var method, name, _results;
    _results = [];
    for (name in proto) {
      method = proto[name];
      if (typeof method === 'function' && name[name.length - 1] === '$' && name.length > 1) {
        _results.push(that[name.slice(0, (name.length - 1))] = method.bind(that));
      }
    }
    return _results;
  };

  extendProto = function(baseProto, childProtoTmpl) {
    var method, name, _results;
    _results = [];
    for (name in childProtoTmpl) {
      method = childProtoTmpl[name];
      baseProto[name] = method;
      if (typeof method === 'function' && name[name.length - 1] !== '$' && typeof baseProto[name + '$'] === 'function') {
        _results.push(baseProto[name + '$'] = null);
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
    var constructor, protoCtor, suprCtor, _ref, _ref2;
    if (typeof name !== 'string') {
      _ref = [void 0, name, base], name = _ref[0], base = _ref[1], protoFn = _ref[2];
    }
    if (protoFn === void 0) {
      _ref2 = [name, void 0, base], name = _ref2[0], base = _ref2[1], protoFn = _ref2[2];
    }
    if (!(name != null)) {
      constructor = function() {
        var proto;
        if (this instanceof constructor) {
          proto = constructor.prototype;
          bindMethods(this, proto);
          if (proto.hasOwnProperty('init')) proto.init.apply(this, arguments);
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
      constructor = eval("function " + name + "() {\n  var proto;\n  if (this instanceof constructor) {\n    proto = constructor.prototype;\n    bindMethods(this, proto);\n    if (proto.hasOwnProperty('init')) proto.init.apply(this, arguments);\n    if (this._newOverride !== void 0) return this._newOverride;\n    return this;\n  } else {\n    return (function(func, args, ctor) {\n      ctor.prototype = func.prototype;\n      var child = new ctor, result = func.apply(child, args);\n      return typeof result === \"object\" ? result : child;\n    })(constructor, arguments, function() {});\n  }\n}; " + name);
    }
    if (base != null) {
      suprCtor = ctor(base.prototype, function() {});
      protoCtor = ctor(base.prototype, function() {
        this.constructor = constructor;
        Object.defineProperty(this, 'super', {
          enumerable: false,
          configurable: true,
          get: function() {
            var supr;
            supr = new suprCtor();
            bindMethods(supr, base.prototype);
            return this["super"] = supr;
          },
          set: function(newValue) {
            return Object.defineProperty(this, 'super', {
              value: newValue
            });
          }
        });
        return this;
      });
      constructor.prototype = new protoCtor();
      extendProto(constructor.prototype, protoFn.call(constructor, base.prototype));
    } else {
      constructor.prototype = protoFn.call(constructor);
    }
    return constructor;
  };

}).call(this);
