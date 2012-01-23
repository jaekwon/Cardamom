# New-style Classes
#
# Benefits:
#
# -  Avoid the usage of 'name: =>' for bound-method declarations, which is inconsistent with the rest of CoffeeScript.
# -  Decorators work flawlessly with bound methods.
# -  Declarative syntax for methods, for more literate code.
#
# Usage:
#
#     class Foo extends Base
#
#       @instance
#         info:     -> "Foo.info:#{this}"
#         toString: -> "<Foo>"
#
#       @class
#         toString: -> "[class:Foo]"
#
#       @static
#         static:   -> "static:#{this}" # depends on how the function is invoked
#
#    f = new Foo()
#    f_info = f.info
#    f_static = f.static
#    console.log f.info()    # Foo.info:<Foo>
#    console.log f_info()    # Foo.info:<Foo>
#    console.log f.clazz()   # clazz:[class:Foo]
#    console.log f.static()  # static:<Foo>
#    console.log f_static()  # static:[object global]

{clone, extend} = require 'underscore'
  
# Base class for new-style classes.
@Base = class Base

  @instance = @i = (methods) ->
    if arguments.length > 1
      methods = {}
      methods[arguments[0]] = arguments[1]
    if @__Base__class != this
      @__Base__class = this
      @__Base__instanceMethods = if @__Base__instanceMethods then clone(@__Base__instanceMethods) else {}
    extend @__Base__instanceMethods, methods
    extend this::, methods

  @static = @s = (methods) ->
    if arguments.length > 1
      methods = {}
      methods[arguments[0]] = arguments[1]
    extend this::, methods

  @class = @c = (methods) ->
    if arguments.length > 1
      methods = {}
      methods[arguments[0]] = arguments[1]
    extend this, methods

  constructor: ->
    @bindInstanceMethods()

  bindInstanceMethods: =>
    if not @__Base__bound
      @__Base__bound = true
      for name, func of @constructor.__Base__instanceMethods
        @[name] = func.bind @
