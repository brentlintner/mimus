path = require "path"
chai = require "chai"
rewire = require "rewire"
sinon = require "sinon"
resolve = require "resolve"
sinon_chai = require "./../fixtures/sinon_chai"
expect = chai.expect

inject = rewire "../../lib/inject"

_ = undefined
sinon_chai (sandbox) -> _ = sandbox

describe "requiring a module", ->
  p = "./../fixtures/basic_module"
  abs_path = path.resolve __dirname, "../fixtures/basic_module.js"

  beforeEach ->

  it "rewires the module", ->
    stub_rewire = _.stub()
    _.stub resolve, "sync"
      .returns abs_path

    inject.__set__ "rewire", stub_rewire
    rewired_module = inject.load p, __dirname, []

    stub_rewire.should.have.been.calledWith abs_path

describe "setting a modules inner variable", ->
  it "uses rewire __set__", ->
    rewired_module = __set__: _.stub()
    inject.set rewired_module, "foo", "bar"
    rewired_module.__set__.should.have.been.calledWith "foo", "bar"

describe "getting a modules inner variable", ->
  it "uses rewire __get__", ->
    rewired_module = __get__: _.stub()
    inject.get rewired_module, "foo"
    rewired_module.__get__.should.have.been.calledWith "foo"
