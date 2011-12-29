# New-style Classes
# Benefits:
#  - Avoid the usage of 'name: =>' for bound-method declarations, which is inconsistent with the rest of CoffeeScript.
#  - Decorators work flawlessly with bound methods.
#  - Declarative syntax for methods, for more literate code.

{clone, extend} = require 'underscore'

# Base class for new-style classes.
class @Base

  @instance = (methods) ->
    # create a new @__methods for each subclass
    if @__methods__class != this
      @__methods__class = this
      @__methods = if @__methods then clone(@__methods) else {}
    extend @__methods, methods
    extend this::, methods

  @static = (methods) ->
    extend this::, methods

  @class = (methods) ->
    extend this, methods

  constructor: ->
    @bindInstanceMethods()

  bindInstanceMethods: =>
    if not @__methods__bound
      @__methods__bound = true
      for name, func of @constructor.__methods
        @[name] = func.bind @
