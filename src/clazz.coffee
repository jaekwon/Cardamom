_ = require 'underscore'

# Bind methods to that, all functions which end in a '$' 
bindMethods = (that, proto) ->
  for name of proto when name[name.length-1] is '$' and name.length > 1
    value = that[name]
    name = name[...name.length-1]
    # bound function
    if typeof value is 'function'
      that[name] = value.bind that

# Is the value a property descriptor?
isPropertyDescriptor = (obj) ->
  typeof obj is 'object' and (obj.get or obj.set or obj.value)

# Extend a prototype object with key/values from childProtoProto.
extendProto = (baseProto, childProtoProto) ->
  # Occlude functions ending in '$' from base if
  # child defines the same function without a '$'.
  # This allows subclasses to declare unbound methods where
  # previously a baseclass declared a bound method -- the
  # instance will have an unbound method from the subclass, as expected.
  for name, method of childProtoProto
    baseProto[name] = method
    if typeof method is 'function' and name[name.length-1] isnt '$' and
      typeof baseProto[name+'$'] is 'function'
        baseProto[name+'$'] = null
  # Define properties directly on the prototype.
  for name, value of childProtoProto when name[name.length-1] is '$' and name.length > 1
    name = name[...name.length-1]
    # getter/setter syntax
    if isPropertyDescriptor value
      value.enumerable ?= yes
      value.configurable ?= yes
      if value.value?
        value.writable ?= yes
      else if value.configurable
        value.set ?= (newValue) ->
          Object.defineProperty this, name, {writable:yes, enumerable:yes, configurable:yes, value:newValue}
      Object.defineProperty baseProto, name, value

ctor = (proto, fn) ->
  fn.prototype = proto
  fn

# protoFn:  The class body, a function that returns an object.
#           The result is merged into the actual prototype.
@clazz = (name, base, protoFn) ->
  [name, base, protoFn] = [undefined, name, base] if typeof name isnt 'string'
  [name, base, protoFn] = [name, undefined, base] if protoFn is undefined
  protoFn ||= (->)

  clazzDefined = no         # Ensure that clazz instantiation happens after
                            #  the clazz prototype is completely defined.
  proto        = undefined  # The clazz prototype

  if not name?
    constructor = ->
      throw new Error "Can't create #{name} clazz instances in the clazz body." unless clazzDefined
      if @ instanceof constructor
        bindMethods @, proto
        proto.init?.apply(@, arguments)
        return @_newOverride if @_newOverride isnt undefined
        return @
      else
        return new constructor arguments...
  else
    constructor = eval """
      function #{name}() {
        if (!clazzDefined) throw new Error("Can't create #{name} clazz instances in the clazz body.");
        if (this instanceof constructor) {
          bindMethods(this, proto);
          if (typeof proto.init !== 'undefined' && proto.init !== null) proto.init.apply(this, arguments);
          if (this._newOverride !== void 0) return this._newOverride;
          return this;
        } else {
          return (function(func, args, ctor) {
            ctor.prototype = proto;
            var child = new ctor, result = func.apply(child, args);
            return typeof result === "object" ? result : child;
          })(constructor, arguments, function() {});
        }
      }; #{name}
    """

  if base?
    constructor[key] = value for own key, value of base
  else
    base = Object

  protoCtor = ctor base.prototype, ->
    # creating the prototype...
    @constructor = constructor
    @super = base.prototype
    @ # needed
  constructor.prototype = proto = new protoCtor()
  extendProto proto, protoFn.call(constructor, base.prototype)
  clazzDefined = yes

  return constructor
