path = require 'path'
fs = require 'fs'

method = () ->
  return fs.statSync(path.join __dirname, 'complex.module.js')

module.exports =
  method: method
