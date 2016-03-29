describe 'util: clock', ->

  beforeEach ->
    @clock = require 'util/clock'

  it 'should add functions to clock and run the functions after 10 seconds', ->
    fn1 = jasmine.createSpy 'fn1'
    fn2 = jasmine.createSpy 'fn2'
    id1 = '1'
    id2 = '2'

    @clock.add(id1, fn1)
    @clock.add(id2, fn2)

    jasmine.clock().tick(10000)

    expect(fn1).toHaveBeenCalled()
    expect(fn2).toHaveBeenCalled()

  it 'should remove functions from clock', ->
    fn1 = jasmine.createSpy 'fn1'
    fn2 = jasmine.createSpy 'fn2'
    id1 = '1'
    id2 = '2'

    @clock.add(id1, fn1)
    @clock.add(id2, fn2)

    @clock.remove(id1)

    jasmine.clock().tick(10000)

    expect(fn1).not.toHaveBeenCalled()
    expect(fn2).toHaveBeenCalled()

    fn1.calls.reset()
    fn2.calls.reset()

    @clock.remove(id2)

    jasmine.clock().tick(10000)

    expect(fn1).not.toHaveBeenCalled()
    expect(fn2).not.toHaveBeenCalled()
