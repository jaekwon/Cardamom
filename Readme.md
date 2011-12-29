Things are still changing. Fast.

### Base

New-style Classes for CoffeeScript

Benefits:

*  Avoid the usage of 'name: =>' for bound-method declarations, which is inconsistent with the rest of CoffeeScript.
*  Decorators work flawlessly with bound methods.
*  Declarative syntax for methods, for more literate code.

Example:

```coffeescript
class Foo extends Base

  @instance
    info:     -> "Foo.info:#{this}"
    toString: -> "<Foo>"
    clazz:    => "clazz:#{this}"  # fat arrow now binds to Foo.

  @class
    toString: -> "[class:Foo]"

  @static
    static:   -> "static:#{this}" # depends on how the function is invoked

class Bar extends Foo

  @instance
    info:     decorator -> "Bar.info:#{this}" # binding works even with decorators
    toString: -> "<Bar>"

  @class
    toString: -> "[class:Bar]"
    
f = new Foo()
f_info = f.info
f_static = f.static
console.log f.info()    # Foo.info:<Foo>
console.log f_info()    # Foo.info:<Foo>
console.log f.clazz()   # clazz:[class:Foo]
console.log f.static()  # static:<Foo>
console.log f_static()  # static:[object global]

b = new Bar()
b_info = b.info
console.log b.info()    # Bar.info:<Bar>
console.log b_info()    # Bar.info:<Bar>
console.log b.clazz()   # clazz:[class:Foo]
```

### Fn

Allows the declaration of argument structure.

    -   X     : any type. X is a placeholder for the argument name (not used)
    -  {X}    : object type
    -  "X"    : string type
    -  X->    : function type
    -     ?   : arg can be 'undefined'
    - [    ]  : arg is optional (can be left out)

e.g.:

     myfunc = Fn ' "name" [{options}?] callback-> ', (name, options, callback) ->

The name can be missing from the argument syntax, so the above is
the same as...

     myfunc = Fn ' "" [{}?] -> ', (foo, options, cb) ->

Missing arguments are always passed in as 'undefined'.

     myfunc = Fn ' foo bar ', (foo, bar) -> console.log "#{foo} #{bar}"
     myfunc('hello')
     > 'hello undefined'

Extra arguments throw an error.

     myfunc = Fn ' foo bar ', (foo, bar) -> console.log "#{foo} #{bar}"
     myfunc('hello', 'coffee', 'donut') # throws error
