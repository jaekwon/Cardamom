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
@clazz = (name, base, protoFn) ->
  [protoFn, base] = [base, undefined] if protoFn is undefined

  constructor = ->
    if @ instanceof constructor
      for name, method of @ when typeof method is 'function' and
        name[name.length-1] is '$' and name.length > 1
          @[name[...name.length-1]] = method.bind(@)
      if constructor.prototype.hasOwnProperty 'init'
        constructor.prototype.init.apply(@, arguments)
      return @_newOverride if @_newOverride isnt undefined
      return @
    else
      return new constructor arguments...
  constructor.name = name

  if base?
    suprCtor = ->
    suprCtor.prototype = base.prototype

    protoCtor = ->
      supr = undefined
      @constructor = constructor
      Object.defineProperty @, 'super', enumerable: false, configurable: true, get: ->
        if not supr?
          supr = new suprCtor()
          # allows for simple @super.foo() vs @super.foo.call(@)
          for name, method of base.prototype when typeof method is 'function' and
            name[name.length-1] is '$' and name.length > 1
              supr[name[...name.length-1]] = method.bind(@)
        return supr
      , set: (newValue) ->
        Object.defineProperty supr, name, value: newValue
      @ # needed
    protoCtor.prototype = base.prototype
    proto = new protoCtor()
    _.extend proto, protoFn.call(constructor, base.prototype)
    constructor.prototype = proto
  else
    proto = protoFn.call(constructor)
    constructor.prototype = proto

  return constructor
