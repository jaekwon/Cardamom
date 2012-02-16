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


  # TESTS COMPLETE
  console.log "Tests ok!"
