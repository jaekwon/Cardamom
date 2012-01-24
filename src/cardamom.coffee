@Fn = require('./fnstuff').Fn
@Bnd = require('./bnd').Bnd
@Base = require('./base').Base
@local = (fn) -> fn()

EE = require('events').EventEmitter
@eventful = (obj) ->
  for own key, value of (EE::) then do (key) ->
    obj[key] = value
