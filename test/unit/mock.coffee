path = require "path"
rewire = require "rewire"
chai = require "chai"
sinon = require "sinon"
sinon_chai = require "./../fixtures/sinon_chai"
expect = chai.expect

mock = rewire "./../../lib/mock"

_ = null; sinon_chai (sandbox) -> _ = sandbox

describe "spying, and stubbing", ->
  it "uses a sinon stub without a method", ->
    obj = method: ->
    s = _.spy sinon, "stub"

    stub = mock.stub obj, "method"

    s.should.have.been.calledWith obj, "method"

    expect(stub).to.be.ok

  it "uses a sinon stub with a method", ->
    obj = method: ->
    stub_method = _.stub()
    s = _.spy sinon, "stub"

    stub = mock.stub obj, "method", stub_method

    s.should.have.been.calledWith obj, "method"

    expect(stub).to.be.ok

    obj.method("a")

    stub_method.should.have.been.calledWith "a"

    stub.reset()


  it "uses a sinon spy", ->
    called = false
    obj = method: ->
    old_spy = sinon.spy
    sinon.spy = -> called = true; "spy"

    spy = mock.spy obj, "method"

    expect(called).to.be.ok
    expect(spy).to.eql "spy"

    sinon.spy = old_spy

  it "re-throws any errors that is not about already wrapped stubs/spies", ->
    _.stub sinon, "stub"
      .throws new Error "something that is about something else"

    expect ->
      mock.stub()
    .to.throw()
