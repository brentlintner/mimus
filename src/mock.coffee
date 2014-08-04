sinon = require "sinon"
_ = require "underscore"
sandbox = []

register = (stub_or_spy) ->
  sandbox.push stub_or_spy
  stub_or_spy

stub = (obj, method, func) ->
  register sinon.stub obj, method, func

spy = (target, method) ->
  register sinon.spy target, method

reset = ->
  _.each sandbox, (stub_or_spy) ->
    stub_or_spy.reset()

restore = ->
  _.each sandbox, (stub) ->
    stub.restore() if stub.restore

module.exports =
  stub: stub
  spy: spy
  reset: reset
  restore: restore
