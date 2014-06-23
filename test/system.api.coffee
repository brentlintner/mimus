rewire = require 'rewire'
mimus = require './../lib'

describe 'blackbox testing', ->
  it 'rewires a module', ->
    basic = mimus.require './fixtures/basic.module', __dirname, 
