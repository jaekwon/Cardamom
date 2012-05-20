# Clazz

Yet another attempt to implement classes as a DSL.

### The difference:

1. super is @super (or supr, in the class body)
2. use `init`, not `constructor`
2. Method binding looks like this: boundMethod$: -> @ != GLOBAL

### The benefits:

1. You don't have to call super for instance method binding to work.
2. Super no longer depends on lexical scope -- you can use @super anywhere,
   as long as you specify the method name (as in Python). 
3. Metaprogramming is easier, for example dynamically creating bound methods
   is as easy as appending a '$' to the method name.
4. Convenient getter/setter syntax.

### Declare a class Foo

```coffeescript
Foo = clazz 'Foo', null, (supr) ->
  @myStaticMethod = -> # is set on Foo

  init: ->
    console.log "Foo initializer"

  foo$: -> # a bound method
    console.log "@", @, "@barProp", @barProp, "instanceof Foo?", @ instanceof Foo

  bar$: get: -> "bar property getter" # a property

  myClassMethod: => # this is bound to the class
```

### Extending Foo:

```coffeescript
Bar = clazz 'Bar', Foo, (supr) ->
  barProp: 'barProp!'

  init: (@bar='init:bar') ->
    @super.init()
    console.log "Bar initializer"

  moo$: ->
    console.log "@", @, "@constructor", @constructor, "@super", @super
  boo: -> # an unbound method
    console.log "@", @, "@constructor", @constructor, "@super", @super

```
Note: Unlike methods bound with $:, properties bound with $: arent own properties of objects, but they are own properties of the prototype.

# Fn - experimental

Allows the declaration of argument structure.

    -   X      : any type. X is a placeholder for the argument name (not used)
    -  {X}     : object type
    -  "X"     : string type
    -  X->     : function type
    -     ?    : arg can be 'undefined'
    - [    ]   : arg is optional (can be left out)
    -      ... : splat

e.g.:

```coffeescript
myfunc = Fn ' "name" [{options}?] callback-> ', (name, options, callback) ->
```

The name can be missing from the argument syntax, so the above is
the same as...

```coffeescript
myfunc = Fn ' "" [{}?] -> ', (foo, options, cb) ->
```

Missing arguments are always passed in as 'undefined'.

```coffeescript
myfunc = Fn ' foo bar ', (foo, bar) -> console.log "#{foo} #{bar}"
myfunc('hello') # hello undefined
```

Extra arguments throw an error, unless the last argument is a splat.

```coffeescript
myfunc = Fn ' foo bar ', (foo, bar) -> console.log "#{foo} #{bar}"
myfunc('hello', 'coffee', 'donut') # throws error
myfunc = Fn ' foo bar... ', (foo, bar...) -> ...
myfunc('hello', 'coffee', 'donut') # OK
```
