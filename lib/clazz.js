(function() {
  var _;

  _ = require('underscore');

  /*
  # Sample usage:
  Foo = clazz 'Foo', null, (supr) ->
    @myStaticMethod = -> # is set on Foo
  
    init: ->
      console.log "Foo initializer"
  
    foo$: -> # a bound method
      console.log "@", @, "@barProp", @barProp, "instanceof Foo?", @ instanceof Foo
  
    myClassMethod: => # this is bound to the class
      
  # Extending Foo:
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

  this.clazz = function(name, base, protoFn) {
    var constructor, proto, protoCtor, suprCtor, _ref;
    if (protoFn === void 0) {
      _ref = [base, void 0], protoFn = _ref[0], base = _ref[1];
    }
    constructor = function() {
      var method, name;
      if (this instanceof constructor) {
        for (name in this) {
          method = this[name];
          if (typeof method === 'function' && name[name.length - 1] === '$' && name.length > 1) {
            this[name.slice(0, (name.length - 1))] = method.bind(this);
          }
        }
        if (constructor.prototype.hasOwnProperty('init')) {
          constructor.prototype.init.apply(this, arguments);
        }
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
    constructor.name = name;
    if (base != null) {
      suprCtor = function() {};
      suprCtor.prototype = base.prototype;
      protoCtor = function() {
        var supr;
        supr = void 0;
        this.constructor = constructor;
        Object.defineProperty(this, 'super', {
          enumerable: false,
          configurable: true,
          get: function() {
            var method, name, _ref2;
            if (!(supr != null)) {
              supr = new suprCtor();
              _ref2 = base.prototype;
              for (name in _ref2) {
                method = _ref2[name];
                if (typeof method === 'function' && name[name.length - 1] === '$' && name.length > 1) {
                  supr[name.slice(0, (name.length - 1))] = method.bind(this);
                }
              }
            }
            return supr;
          },
          set: function(newValue) {
            return Object.defineProperty(supr, name, {
              value: newValue
            });
          }
        });
        return this;
      };
      protoCtor.prototype = base.prototype;
      proto = new protoCtor();
      _.extend(proto, protoFn.call(constructor, base.prototype));
      constructor.prototype = proto;
    } else {
      proto = protoFn.call(constructor);
      constructor.prototype = proto;
    }
    return constructor;
  };

}).call(this);
