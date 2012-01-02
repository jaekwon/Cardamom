assert = require 'assert'

# Allows the declaration of argument structure.
# -   X      : any type. X is a placeholder for the argument name (not used)
# -  {X}     : object type
# -  "X"     : string type
# -  X->     : function type
# -     ?    : arg can be 'undefined'
# - [     ]  : arg is optional (can be left out)
# -     ...  : splat
#
# e.g. myfunc = Fn ' "name" [{options}?] callback-> ', (name, options, callback) ->
#
# The name can be missing from the argument syntax, so the above is
# the same as...
#      myfunc = Fn ' "" [{}?] -> ', (foo, options, cb) ->
#
# Missing arguments are always passed in as 'undefined'.
#      myfunc = Fn ' foo bar ', (foo, bar) -> console.log "#{foo} #{bar}"
#      myfunc('hello')
#      > 'hello undefined'
#
# Extra arguments throw an error unless the last argument is a splat.
#      myfunc = Fn ' foo bar... ', (foo, bar...) -> ...
#
# Be careful with splats... and [optional] args. They can get confusing.
#
@Fn = (syntax, fn=null) ->

  # parse syntax and validate
  [args, argParts] = [[], syntax.trim().split(' ')]
  assert.ok argParts.length > 0, 'Syntax for Fn should contain 1 or more args.'
  argParts.forEach (part, partIndex) ->
    args.push( (arg = {}) )

    # optional?
    if part[0] == '['
      assert.ok part[part.length-1] == ']', "Unclosed brackets []: #{part}"
      part = part[1...part.length-1]
      arg.optional = true
      arg.splat = false
    else if part[part.length-3...] == '...'
      assert.equal partIndex, argParts.length-1, "Splat was not the last argument: #{part}"
      part = part[...part.length-3]
      arg.optional = false
      arg.splat = true
    else
      arg.optional = false
      arg.splat = false

    # undefined ok?
    if part[part.length-1] == '?'
      part = part[...part.length-1]
      arg.undefinedOk = true
    else
      arg.undefinedOk = false

    # object?
    if part[0] == '{'
      assert.ok part[part.length-1] == '}', "Unclosed brackets {}: #{part}"
      part = part[1...part.length-1]
      arg.type = 'object'
      arg.name = part or undefined

    # function?
    else if part.indexOf('->') >= 0
      fnParts = part.split('->')
      assert.ok fnParts.length == 2, "Unrecognized function syntax: #{part}"
      arg.type = 'function'
      arg.name = fnParts[0] or undefined
      arg.return = fnParts[1] # not used.

    # string?
    else if part[0] == '"' or part[0] == '\''
      assert.ok part[part.length-1] == part[0], "Unclosed string: #{part}"
      part = part[1...part.length-1]
      arg.type = 'string'
      arg.name = part or undefined

    # other
    else
      arg.type = undefined
      arg.name = part or undefined

  # Generator, returned function will check args and call fn when called.
  wrapFn = (fn) ->
    type = (arg) ->
      if arg instanceof Array then 'Array' else typeof arg
    doesMatch = (arg, expectedArg) ->
      not expectedArg.type? or
        expectedArg.type == type(arg) or
        expectedArg.undefinedOk and type(arg) == 'undefined'
    return ->
      toPass = []
      argumentIndex = 0
      expectedIndex = 0
      # Iterate over declared arguments...
      while expectedIndex < args.length
        expectedArg = args[expectedIndex]
        arg = arguments[argumentIndex]
        # Arg matches expectedArg...
        if doesMatch arg, expectedArg
          if expectedArg.splat
            if argumentIndex >= arguments.length
              break
            toPass.push arg
            argumentIndex += 1
          else
            toPass.push arg
            argumentIndex += 1
            expectedIndex += 1
        # or, expectedArg was optional...
        else if expectedArg.optional
          toPass.push undefined
          expectedIndex += 1
        # or, fail!
        else
          if argumentIndex >= arguments.length
            throw new Error "Fn expected arg of type #{expectedArg.type} for argument #0+#{argumentIndex}, but ran out of arguments."
          else
            throw new Error "Fn expected arg of type #{expectedArg.type} for argument #0+#{argumentIndex}, but got type '#{type(arg)}': #{arg}"

      # Extra arguments throw an error... they can cause confusion.
      # (Use an explicit splat if you want a variadic function.)
      if argumentIndex < arguments.length
        throw new Error "Fn received extra arguments from #0+#{argumentIndex} (#{arguments.length} total): #{arguments[argumentIndex]}"

      # Call fn with collected args.
      return fn.apply(this, toPass)

  return if fn? then wrapFn(fn) else wrapFn
