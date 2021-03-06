inject = require "./inject"
mock = require "./mock"

module.exports =
  require: inject.load
  set: inject.set
  get: inject.get
  stub: mock.stub
  spy: mock.spy
  reset: mock.reset
  restore: mock.restore
