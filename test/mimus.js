var
  mimus = require('./../lib'),
  rewire = require('rewire'),
  chai = require('chai'),
  sinon = require('sinon'),
  sinon_chai = require('./fixtures/sinon.chai'),
  expect = chai.expect, _

sinon_chai(function (sandbox) { _ = sandbox })

xdescribe('requiring a module', function () {
  it('rewires the module', function () {
  })

  it('rewires all modules within the module', function () {
  })

  it('stubs all functions of each internal module', function () {
  })
})

xdescribe('unmocking a module\'s inner variable', function () {
  it('resets it via a cached pointer, using rewire __set__', function () {
  })
})

xdescribe('setting a modules inner variable', function () {
  it('uses rewire __set__', function () {
  })
})

xdescribe('getting a modules inner variable', function () {
  it('uses rewire __get__', function () {
  })
})

xdescribe('spying, and stubbing', function () {
  it('makes use of sinon, chai, and sinon-chai syntax sugaring', function () {
    expect(mimus.stub).to.eql(sinon.stub)
    expect(mimus.spy).to.eql(sinon.spy)
  })
})

xdescribe('resetting every spy/stub', function () {
  it('resets every module and inner module methods', function () {
  })
})
