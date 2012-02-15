@Fn = require('./fnstuff').Fn
@B = require('./bind').B
@local = (fn) -> fn()
@ErrorBase = require('./errors').ErrorBase
@clazz = require('./clazz').clazz

EE = require('events').EventEmitter
@eventful = (obj) ->
  for own key, value of (EE::) then do (key) ->
    obj[key] = value
