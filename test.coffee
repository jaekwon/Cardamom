{B, Fn, clazz} = require 'cardamom'
assert = require 'assert'

@run = ->
  fn = Fn 'foo {options} cb->', (foo, options, cb) -> "#{foo} #{options} #{typeof cb}"
  do ->
    assert.equal  (   fn 1, happy: yes, -> 'a fn'),      '1 [object Object] function'
    assert.throws (-> fn 1, happy: yes),                 'cb-> required'
    assert.throws (-> fn 1, undefined, -> 'a fn'),       'undefined not allowed for {options}'
    assert.throws (-> fn 1, undefined, undefined),       'function was undefined'
    assert.throws (-> fn 1, undefined),                  'function was undefined'
    assert.throws (-> fn 1, -> 'a fn'),                  'options should exist'
    assert.throws (-> fn 1),                             'options should exist'

  fn = Fn 'foo {options}? cb->', (foo, options, cb) -> "#{foo} #{options} #{typeof cb}"
  do ->
    assert.equal  (   fn 1, happy: yes, -> 'a fn'),      '1 [object Object] function'
    assert.throws (-> fn 1, happy: yes),                 'function was undefined'
    assert.equal  (   fn 1, undefined, -> 'a fn'),       '1 undefined function'
    assert.throws (-> fn 1, undefined, undefined),       'function was undefined'
    assert.throws (-> fn 1, undefined),                  'function was undefined'
    assert.throws (-> fn 1, -> 'a fn'),                  'options should exist or be undefined'
    assert.throws (-> fn 1),                             'options should exist'

  fn = Fn 'foo {options}? cb->?', (foo, options, cb) -> "#{foo} #{options} #{typeof cb}"
  do ->
    assert.equal  (   fn 1, happy: yes, -> 'a fn'),      '1 [object Object] function'
    assert.equal  (   fn 1, happy: yes),                 '1 [object Object] undefined'
    assert.equal  (   fn 1, undefined, -> 'a fn'),       '1 undefined function'
    assert.equal  (   fn 1, undefined, undefined),       '1 undefined undefined'
    assert.equal  (   fn 1, undefined),                  '1 undefined undefined'
    assert.throws (-> fn 1, -> 'a fn'),                  'options should exist or be undefined'
    assert.equal  (   fn 1),                             '1 undefined undefined'

  fn = Fn 'foo [{options}] [cb->]', (foo, options, cb) -> "#{foo} #{options} #{typeof cb}"
  do ->
    assert.equal  (   fn 1, happy: yes, -> 'a fn'),      '1 [object Object] function'
    assert.equal  (   fn 1, happy: yes),                 '1 [object Object] undefined'
    assert.throws (-> fn 1, undefined, -> 'a fn'),       'options did not match -- results in extra arguments'
    assert.throws (-> fn 1, undefined, undefined),       'options did not match -- results in extra arguments'
    assert.throws (-> fn 1, undefined),                  'options did not match -- results in extra arguments'
    assert.equal  (   fn 1, -> 'a fn'),                  '1 undefined function'
    assert.equal  (   fn 1),                             '1 undefined undefined'

  fn = Fn 'foo [{options}?] [cb->?]', (foo, options, cb) -> "#{foo} #{options} #{typeof cb}"
  do ->
    assert.equal  (   fn 1, happy: yes, -> 'a fn'),      '1 [object Object] function'
    assert.equal  (   fn 1, happy: yes),                 '1 [object Object] undefined'
    assert.equal  (   fn 1, undefined, -> 'a fn'),       '1 undefined function'
    assert.equal  (   fn 1, undefined, undefined),       '1 undefined undefined'
    assert.equal  (   fn 1, undefined),                  '1 undefined undefined'
    assert.equal  (   fn 1, -> 'a fn'),                  '1 undefined function'
    assert.equal  (   fn 1),                             '1 undefined undefined'

  # SPLATS
  do ->
    assert.throws (-> Fn 'foo bar... baz', ->),          'Splat must be the last argument'

  fn = Fn 'foo bar baz...', (foo, bar, baz...) -> "#{foo} #{bar} #{baz instanceof Array} #{baz}"
  do ->
    assert.equal  (   fn 1, 2, 3, 4),                    '1 2 true 3,4'
    assert.equal  (   fn 1, 2, 3),                       '1 2 true 3'
    assert.equal  (   fn 1, 2),                          '1 2 true '
    assert.equal  (   fn 1, 2, undefined, undefined),    '1 2 true ,'

  # Test B(ind)
  do ->
    class Foo

      foo:B -> "#{@}"

      toString: -> '<Foo>'

      B.ind @

    f = new Foo
    f_foo = f.foo
    assert.equal f_foo(), f.foo()

  # Test clazz
  do ->
    initCalled = false

    Foo = clazz 'Foo', ->
      init: ->
        initCalled = true
      sayHi$: ->
        "Hi, I am #{this}"
      toString: -> "Foo"
    f = new Foo()

    assert.ok Foo.name is 'Foo'
    assert.ok initCalled
    assert.ok f instanceof Foo
    assert.ok f.sayHi() is "Hi, I am Foo"
    f_sayHi = f.sayHi
    assert.ok f_sayHi() is "Hi, I am Foo"

    Bar = clazz 'Bar', Foo, ->
      init: ->
        @super.init()
        initCalled = 'heck yeah'
      toString: -> "Bar"
    b = new Bar()

    assert.ok Bar.name is 'Bar'
    assert.ok b.sayHi() is "Hi, I am Bar"
    assert.ok initCalled, 'heck yeah'

  # Test clazz subclazz overriding a bound method
  do ->
    GLOBAL.toString = -> '[GLOBAL]'

    Foo = clazz 'Foo', ->
      foo$: -> "foo" + @
      toString: -> 'Foo'

    Bar = clazz 'Bar', Foo, ->
      foo: -> "bar" + @
      toString: -> 'Bar'

    f = new Foo()
    b = new Bar()
    assert.equal f.foo(), 'fooFoo'
    assert.equal b.foo(), 'barBar'
    b_foo = b.foo
    assert.equal b_foo(), 'bar[GLOBAL]'

  # Test clazz anonymous
  do ->
    Foo = clazz ->
      @bar = 'bar'
      toString: -> 'Foo'

    f = new Foo()
    assert.equal Boolean(Foo.name), false
    assert.equal Foo.bar, 'bar'
    assert.equal ''+f, 'Foo'

  # Test clazz level properties
  do ->
    hoop = []
    Assist = clazz ->
      @ball = '0'
    Player = clazz Assist, ->
      hoop.push @ball

    assert.equal hoop[0], '0'
      
  # Test clazz getter/setter
  do ->
    Foo1 = clazz 'Foo1', ->
      init: (@bar) ->
      bar$:
        get: -> @_bar
        set: (@_bar) ->
    f1 = Foo1("blah1")
    assert.equal f1.bar, "blah1"
    f1.bar = "blah2"
    assert.equal f1.bar, "blah2"

    Foo2 = clazz 'Foo2', Foo1, ->
      init: ->
      bar$:
        get: -> "blah3"
    f2 = Foo2()
    assert.equal f2.bar, "blah3"
    f2.bar = "blah4"
    assert.equal f2.bar, "blah4"

  # Test clazz inheritance
  do ->
    Foo = clazz 'Foo', ->
      init: (@bar) ->
      toString: -> "#{@constructor.name}#{@bar}"
    f = Foo("Bar")
    assert.equal ''+f, 'FooBar'

    Foo2 = clazz 'Foo2', Foo, ->
      dontcare: ->
    f2 = Foo2("Bar2")
    assert.equal ''+f2, 'Foo2Bar2'

    Foo3 = clazz 'Foo3', Foo2, ->
      init: (bar) -> @bar = "(#{bar})"
    f2 = Foo3("Bar3")
    assert.equal ''+f2, 'Foo3(Bar3)'

  # Test clazz extensions
  do ->
    Foo = clazz 'Foo', ->
      init: ({@bar}) ->
    f = new Foo(bar:'BAR')
    assert.equal f.bar, 'BAR'
    # extend!
    Foo::extend
      baz: 'BAZ'
      bak$: get: -> 'BAK'
    assert.equal f.baz, 'BAZ'
    assert.equal f.bak, 'BAK'

  # TESTS COMPLETE
  console.log "Tests ok!"
