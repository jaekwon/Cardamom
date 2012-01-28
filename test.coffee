{B, Fn} = require 'cardamom'
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

  console.log "Tests ok!"


  # Test B(ind)
  do ->
    class Foo

      foo:B -> "#{@}"

      toString: -> '<Foo>'

      B.ind @

    f = new Foo
    f_foo = f.foo
    assert.equal f_foo(), f.foo()
