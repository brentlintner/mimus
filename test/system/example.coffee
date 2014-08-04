chai = require "chai"
rewire = require "rewire"
sinon = require "sinon"
sinon_chai = require "./../fixtures/sinon_chai"
expect = chai.expect

example = "./../fixtures/complex_module"
mimus = require "./../../lib/mimus"
_ = null; sinon_chai (sandbox) -> _ = sandbox

describe "blackbox testing", ->
  mod = null

  beforeEach ->
    mimus.restore()
    mod = mimus.require example, __dirname, [
      "./basic_module",
      "./method_module"
    ]

  it "can stub a method", ->
    mimus.stub mod, "method"
    expect -> mod.method "foo"
      .not.to.throw()
    mod.method.should.have.been.calledWith "foo"

  it "auto stubs an internal module", ->
    basic = mimus.get mod, "basic"

    expect -> basic.method "foo"
      .not.to.throw()

    basic.method.should.have.been.called

  it "spys and resets", ->
    mimus.spy mod, "empty_method"
    mod.empty_method()
    mimus.reset()
    mod.empty_method()
    mod.empty_method.should.have.been.calledOnce

  it "restores everything", ->
    mimus.stub mod, "method"
    mimus.spy() # adds a spy/stub without .restore method
    mimus.restore()
    expect -> mod.method "foo"
      .to.throw()
