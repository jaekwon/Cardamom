assert = require 'assert'

@Bnd = (cls) ->

  bnd = (obj) ->
    if typeof obj is 'function'
      obj.__Bnd__bind = true
    else
      assert.ok cls, 'To use Bnd with {key:value} objects, pass the class to the Bnd() constructor.'
      for own key, value of obj
        cls::[key] = value
        if typeof value is 'function'
          value.__Bnd__bind = true
    obj

  bnd.to = (self) ->
    for own key, value of (self.constructor::) when value?.__Bnd__bind
      self[key] = value.bind(self)

  return bnd
