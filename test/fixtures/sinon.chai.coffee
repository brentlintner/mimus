sinon = require('sinon')
chai = require('chai')
sinonChai = require('sinon-chai')

chai.use sinonChai
    .use chai.should
    .should()

sandbox = (callback) ->
  session = undefined

  beforeEach ->
    session = sinon.sandbox.create()
    session.match = sinon.match
    callback session

  afterEach ->
    session.verifyAndRestore()

module.exports = sandbox
