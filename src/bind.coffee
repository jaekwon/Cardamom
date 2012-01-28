assert = require 'assert'

@B = (fn) ->
  fn.bindMethod = true
  fn

@B.ind = (cls) ->
  for own name, value of (cls::) when typeof value is 'function' and value.bindMethod then do (name, value) =>
    Object.defineProperty (cls::), name, enumerable: false, configurable: true, get: ->
      if @ is @.constructor.prototype
        return value
      else
        return @[name] = value.bind @
    , set: (newValue) ->
        Object.defineProperty @, name, value: newValue
