path = require "path"
rewire = require "rewire"
chai = require "chai"
sinon = require "sinon"
sinon_chai = require "./../fixtures/sinon_chai"
expect = chai.expect

mock = rewire "./../../lib/mock"

_ = null; sinon_chai (sandbox) -> _ = sandbox

describe "spying, and stubbing", ->
  it "uses a sinon stub", ->
    obj = method: ->
    stub_method = ->
    s = _.spy sinon, "stub"

    stub = mock.stub obj, "method", stub_method

    s.should.have.been.calledWith obj, "method", stub_method
    expect(stub).to.be.ok

  it "uses a sinon spy", ->
    called = false
    obj = method: ->
    old_spy = sinon.spy
    sinon.spy = -> called = true; "spy"

    spy = mock.spy obj, "method"

    expect(called).to.be.ok
    expect(spy).to.eql "spy"

    sinon.spy = old_spy
