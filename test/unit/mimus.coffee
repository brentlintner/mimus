_ = require "underscore"
chai = require "chai"
sinon = require "sinon"
mimus = require "./../../lib/mimus"
mock = require "./../../lib/mock"
inject = require "./../../lib/inject"
sinon_chai = require "./../fixtures/sinon_chai"
expect = chai.expect

maps = (mods) ->
  matches = true
  _.each mods, (method, name) ->
    matches = false if mimus[name] != method
  matches

it "exposes these methods", ->
  all = maps
    require: inject.load
    get: inject.get
    set: inject.set
    stub: mock.stub
    spy: mock.spy
    reset: mock.reset
    restore: mock.restore

  expect(all, "not all methods are listed").to.eql true
