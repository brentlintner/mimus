path = require "path"
fs = require "fs"

method = () -> throw new Error "do not throw"

module.exports =
  method: method
  property: 5
