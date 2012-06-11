_ = require 'underscore'

# Is the value a property descriptor?
isPropertyDescriptor = (obj) ->
  typeof obj is 'object' and (obj.get or obj.set or obj.value)

# Syntactic helper for defining constructors.
ctor = (proto, fn) ->
  fn.prototype = proto
  fn

# This allows getters/setters defined on prototypes to
# also work on @super, as @super.this points to @.
SUPERKEY = {const:'SUPERKEY'} # just some singleton
_getThis = (obj) ->
  if obj.hasOwnProperty('__superKey__') and obj.__superKey__ is SUPERKEY
    return obj.this
  else
    return obj
_makeSuper = (baseProto, that) ->
  _super = new (ctor(baseProto, ->
    @__superKey__ = SUPERKEY
    @this = that
    @ # needed
  ))()
  return _super
  
# Bind methods to that, all functions which end in a '$' 
bindMethods = (that, proto) ->
  for name of proto when name[name.length-1] is '$' and name.length > 1
    value = that[name]
    name = name[...name.length-1]
    # bound function
    if typeof value is 'function'
      that[name] = value.bind that

# Extend a prototype object (bound to @) with key/values from protoProto.
# This is responsible for `$:` bindings for properties and functions,
# because they are set as properties on the clazz prototype.
extendProto = (protoProto) ->
  for name, value of protoProto then do (name, value) =>
    # Define properties directly on the prototype.
    if name[name.length-1] is '$' and name.length > 1
      name = name[...name.length-1]
      # a bound function
      if typeof value is 'function'
        desc =
          enumerable: yes
          configurable: yes
          get: ->
            boundFunc = value.bind _getThis(this)
            boundFunc._name = name
            return boundFunc
          set: (newValue) ->
            Object.defineProperty _getThis(this), name,
              writable:yes
              enumerable:yes
              configurable:yes
              value:newValue
        Object.defineProperty this, name, desc
      # getter/setter syntax
      else if isPropertyDescriptor value
        getter = value.get
        setter = value.set
        desc = value
        desc.enumerable ?= yes
        desc.configurable ?= yes
        if desc.value?
          desc.writable ?= yes
        else
          desc.get = ->
            getter.call(_getThis(this))
          desc.set = (newValue) ->
            if setter?
              setter.call(_getThis(this), newValue)
            else
              Object.defineProperty _getThis(this), name,
                writable:yes
                enumerable:yes
                configurable:yes
                value:newValue
        Object.defineProperty this, name, desc
    else
      value._name = name if typeof value is 'function'
      this[name] = value

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
    # all prototypes have these properties:
    Object.defineProperty this, 'constructor', value:constructor, writable:no, configurable:no, enumerable:no
    Object.defineProperty this, 'super', configurable:no, enumerable:no, get: -> _makeSuper(base.prototype, this)
    Object.defineProperty this, 'extend', value:extendProto, writable:yes, configurable:yes, enumerable:no
    @ # needed
  constructor.prototype = proto = new protoCtor()
  protoProto = protoFn.call(constructor, base.prototype)
  extendProto.call proto, protoProto

  clazzDefined = yes
  return constructor

# make this available for non-clazz classes.
@clazz.extend = (proto, protoProto) -> extendProto.call proto, protoProto
