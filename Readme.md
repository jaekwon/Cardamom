Things are still changing. Fast.

### Bnd

todo: doc

### Fn

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
