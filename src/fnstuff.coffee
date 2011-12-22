assert = require 'assert'

# Allows the declaration of argument structure.
# -   X     : any type. X is a placeholder for the argument name (not used)
# -  {X}    : object type
# -  "X"    : string type
# -  X->    : function type
# -     ?   : arg can be 'undefined'
# - [    ]  : arg is optional (can be left out)
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
# Extra arguments throw an error.
#      myfunc = Fn ' foo bar ', (foo, bar) -> console.log "#{foo} #{bar}"
#      myfunc('hello', 'coffee', 'donut') # throws error
#
@Fn = (syntax, fn=null) ->

  # parse syntax and validate
  [args, argParts] = [[], syntax.trim().split(' ')]
  assert.ok argParts.length > 0, 'Syntax for Fn should contain 1 or more args.'
  argParts.forEach (part) ->
    args.push( (arg = {}) )

    # optional?
    if part[0] == '['
      assert.ok part[part.length-1] == ']', "Unclosed brackets []: #{part}"
      part = part[1...part.length-1]
      arg.optional = true
    else
      arg.optional = false

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
    return ->
      toPass = []
      argumentIndex = 0
      # Iterate over declared arguments...
      for expectedIndex, expectedArg of args
        arg = arguments[argumentIndex]
        argType = if arg instanceof Array then 'Array' else typeof arg
        # Arg matches expectedArg...
        if not expectedArg.type? or expectedArg.type == argType
          toPass.push arg
          argumentIndex += 1
        # or, arg is undefined and expectedArg can be undefined
        else if expectedArg.undefinedOk and argType == 'undefined'
          toPass.push arg
          argumentIndex += 1
        # or, expectedArg was optional...
        else if expectedArg.optional
          toPass.push undefined
        # or, fail!
        else
          if argumentIndex >= arguments.length
            throw new Error "Fn expected arg of type #{expectedArg.type} for argument #0+#{argumentIndex}, but ran out of arguments."
          else
            throw new Error "Fn expected arg of type #{expectedArg.type} for argument #0+#{argumentIndex}, but got type '#{argType}': #{arg}"

      # Extra arguments throw an error... they can cause confusion.
      if argumentIndex < arguments.length
        throw new Error "Fn received extra arguments from #0+#{argumentIndex} (#{arguments.length} total): #{arguments[argumentIndex]}"

      # Call fn with collected args.
      return fn(toPass...)

  return if fn? then wrapFn(fn) else wrapFn
