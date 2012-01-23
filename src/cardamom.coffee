@Fn = require('./fnstuff').Fn
@Bnd = require('./bnd').Bnd
@Base = require('./base').Base
@local = (fn) -> fn()

EE = require('events').EventEmitter
@eventful = (obj, attach=true) ->
  emitter = new EE()
  obj.emitter = emitter if attach

  for own key, value of (EE::) then do (key) ->
    obj[key] = ->
      emitter[key](arguments...)
