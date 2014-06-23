rewire = require 'rewire'
mimus = rewire './../lib'
chai = require 'chai'
sinon = require 'sinon'
sinon_chai = require './fixtures/sinon.chai'
expect = chai.expect
_ = undefined

sinon_chai -> sandbox -> _ = sandbox

describe 'requiring a module', ->
  it 'rewires the module', ->

  it 'rewires all modules within the module', ->

  it 'stubs all functions of each internal module', ->

describe 'unmocking a module\'s inner variable', ->
  it 'resets it via a cached pointer, using rewire __set__', ->

describe 'setting a modules inner variable', ->
  it 'uses rewire __set__', ->

describe 'getting a modules inner variable', ->
  it 'uses rewire __get__', ->

describe 'spying, and stubbing', ->
  it 'makes use of sinon, chai, and sinon-chai syntax sugaring', ->

describe 'resetting every spy/stub', ->
  it 'resets every module and inner module methods', ->
