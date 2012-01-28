# See http://stackoverflow.com/questions/1382107/whats-a-good-way-to-extend-error-in-javascript                                                                            
# Note that Object.prototype.toString may not return [object Error] in IE or Opera.                                                                                        
# console.log or other behavior may depend on Object.prototype.toString behavior.
if Error.captureStackTrace
  class @ErrorBase extends Error
    constructor: (@message) ->
      Error.captureStackTrace this, @constructor
      @name = @constructor.name

else
  class @ErrorBase extends Error
    constructor: ->
      e = super
      e.name = @constructor.name
      this.message = e.message
      Object.defineProperty this, 'stack', get: -> e.stack
