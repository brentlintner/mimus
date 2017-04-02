sinon = require "sinon"
_ = require "lodash"
sandbox = []

register = (type, obj, method, func) ->
  item = null

  try
    if type == "stub" && !_.isEmpty(func)
      item = sinon.stub(obj, method).callsFake(func)
    else
      item = sinon[type].apply(sinon, [ obj, method, func ])

    sandbox.push item
  catch e
    if /already wrapped/i.test e.message
      item = obj[method]
    else throw e

  item

stub = (obj, method, func) ->
  register 'stub', obj, method, func

spy = (obj, method) ->
  register 'spy', obj, method

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
