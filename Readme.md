Things are still changing. Fast.

### Base

New-style Classes for CoffeeScript

Benefits:
 - Avoid the usage of 'name: =>' for bound-method declarations, which is inconsistent with the rest of CoffeeScript.
 - Decorators work flawlessly with bound methods.
 - Declarative syntax for methods, for more literate code.

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
