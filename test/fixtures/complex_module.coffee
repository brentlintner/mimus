# basic VariableAssignment
fs = require "fs"
basic = require "./basic_module"
func = require "./method_module"

# for VariableAssignment via objects
deps = {}
deps.path = require "path"

# to test VariableDeclaration AST type
# CS always compiles to VariableAssignment
`var vdec = require("util");`

method = (a) -> throw new Error "should not throw"

empty_method = ->

module.exports =
  method: method
  empty_method: empty_method
