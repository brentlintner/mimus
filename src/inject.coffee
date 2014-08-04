path = require "path"
resolve = require "resolve"
fs = require "fs"
rewire = require "rewire"
_ = require "underscore"
esprima = require "esprima"
mock = require "./mock"

# can use revert for part of undo = myModule.__set__(...)
set = (wired, path, value) -> wired.__set__ path, value

get = (wired, path) -> wired.__get__ path

if_variable_declaration = (node, base, list) ->
  return if !node || node.type != "VariableDeclaration"

  _.each node.declarations, (declare) ->
    statement = declare &&
                declare.type == "VariableDeclarator" &&
                declare.init

    return if not statement

    if statement.callee && statement.callee.name == "require"
      statement_args = statement.arguments && statement.arguments.length > 0
      mod_loc = if statement_args then statement.arguments[0].value

      list.push
        name: if declare.id then declare.id.name
        path: mod_loc
        abs_path: resolve.sync mod_loc, basedir: base

if_assignment_statement = (node, base, list) ->
  exp = node && node.type == "ExpressionStatement" && node.expression

  if exp.type == "AssignmentExpression" &&
     exp.right && exp.left &&
     exp.right.type == "CallExpression" &&
     exp.right.callee.name == "require"

    name = switch
      when exp.left.type == "Identifier" then exp.left.name
      else name = exp.left.object.name + "." + exp.left.property.name

    right_args = exp.right.arguments && exp.right.arguments.length > 0
    mod_loc = if right_args then exp.right.arguments[0].value

    list.push
      name: name,
      path: mod_loc
      abs_path: resolve.sync mod_loc, basedir: base

internal_modules = (ast, base, list) ->
  list = [] unless list

  return list if not ast or not ast.body

  _.each ast.body, (node) ->
    if_variable_declaration node, base, list
    if_assignment_statement node, base, list
    internal_modules node, base, list

  list

each_sub_mod = (module_path, base) ->
  file_path = resolve.sync module_path, basedir: base
  file_dirname = path.dirname file_path
  mods = []

  if fs.existsSync file_path
    file_data = fs.readFileSync file_path, "utf-8"

    if file_data
      ast = esprima.parse file_data
      mods = internal_modules ast, file_dirname

  mods

matches_module = (mod, base_path) ->
  (compare_path) ->
    abs_compare_path = path.resolve base_path, compare_path + ".js"
    abs_compare_path == mod.abs_path or compare_path == mod.path

parse_private_modules = (module_path, base_path, wired, accept) ->
  each_sub_mod(module_path, base_path).forEach (mod) ->
    return unless accept.some matches_module mod, module_path

    obj = get wired, mod.name

    _.each Object.keys(obj), (key) ->
      return unless typeof obj[key] is "function"
      obj[key] = mock.stub obj, key

    if typeof obj == "function"
      set wired, mod.name, _.extend mock.stub(), obj

load = (module_path, base_path, accept) ->
  wired = rewire resolve.sync module_path, basedir: base_path
  parse_private_modules module_path, base_path, wired, accept
  wired

module.exports =
  set: set
  get: get
  load: load
