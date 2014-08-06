sinon = require "sinon"
_ = require "underscore"
sandbox = []

register = (type, args...) ->
  item = null

  try
    item = sinon[type].apply(sinon, args)
    sandbox.push item
  catch e
    if /already wrapped/i.test e.message
      obj = args[0]; method = args[1]
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
