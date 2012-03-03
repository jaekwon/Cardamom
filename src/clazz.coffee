_ = require 'underscore'

###

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
4. Convenient getter/setter syntax.

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

###

# Bind methods to that, all functions which end in a '$' 
bindMethods = (that, proto) ->
  for name, value of proto when name[name.length-1] is '$' and name.length > 1
    name = name[...name.length-1]
    # bound function
    if typeof value is 'function'
      that[name] = value.bind that
    # getter/setter syntax
    else if typeof value is 'object'
      if value and (value.get or value.set or value.value)
        value.enumerable = value.enum if value.enum?
        value.configurable = value.conf if value.conf?
        Object.defineProperty that, name, value

# Extend a prototype object with key/values from the childProtoTmpl.
# In addition, occlude functions ending in '$' from base if
# child defines the same function without a '$'.
# This allows subclasses to declare unbound methods where
# previously a baseclass declared a bound method -- the
# instance will have an unbound method from the subclass, as expected.
extendProto = (baseProto, childProtoTmpl) ->
  for name, method of childProtoTmpl
    baseProto[name] = method
    if typeof method is 'function' and name[name.length-1] isnt '$' and
      typeof baseProto[name+'$'] is 'function'
        baseProto[name+'$'] = null

ctor = (proto, fn) ->
  fn.prototype = proto
  fn

@clazz = (name, base, protoFn) ->
  [target, name] = name                           if name instanceof Array # TODO change Array to some escaped code syntax.
  [name, base, protoFn] = [undefined, name, base] if typeof name isnt 'string'
  [name, base, protoFn] = [name, undefined, base] if protoFn is undefined
  protoFn ||= (->)

  if not name?
    constructor = ->
      if @ instanceof constructor
        proto = constructor.prototype
        bindMethods @, proto
        if proto.hasOwnProperty 'init'
          proto.init.apply(@, arguments)
        return @_newOverride if @_newOverride isnt undefined
        return @
      else
        return new constructor arguments...
  else
    constructor = eval """
      function #{name}() {
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
      }; #{name}
    """

  if base?
    constructor[key] = value for own key, value of base
    suprCtor =  ctor base.prototype, ->
    protoCtor = ctor base.prototype, ->
      @constructor = constructor
      Object.defineProperty @, 'super', enumerable: false, configurable: true, get: ->
        supr = new suprCtor()
        bindMethods supr, base.prototype
        return @super = supr
      , set: (newValue) ->
        Object.defineProperty @, 'super', value: newValue
      @ # needed
    constructor.prototype = new protoCtor()
    extendProto constructor.prototype, protoFn.call(constructor, base.prototype)
  else
    constructor.prototype = protoFn.call constructor

  if target?
    target[name] = constructor

  return constructor
