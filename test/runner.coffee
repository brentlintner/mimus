path = require "path"
wrench = require "wrench"
Mocha = require "mocha"
tests = __dirname

by_js_extension = (filepath) -> /\.js$/.test filepath

into_abs_path = (specs) -> (relpath) -> path.join specs, relpath

run = (type) ->
  runner = new Mocha
    ui: "bdd"
    reporter: "dot"

  specs = path.join tests, type

  runner.files = wrench
    .readdirSyncRecursive specs
    .filter by_js_extension
    .map into_abs_path specs

  runner.run process.exit

module.exports =
  run: run
