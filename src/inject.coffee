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
      name: name
      path: mod_loc

internal_modules = (ast, base, list) ->
  list = [] unless list

  return list if not ast or not ast.body

  _.each ast.body, (node) ->
    if_variable_declaration node, base, list
    if_assignment_statement node, base, list
    internal_modules node, base, list

  list

abs_path = (loc, base) ->
  resolve.sync loc, basedir: base || ""

each_sub_mod = (file) ->
  base = path.dirname file
  mods = null

  if fs.existsSync file
    data = fs.readFileSync file, "utf-8"

    if data
      ast = esprima.parse data
      mods = internal_modules ast, base

  mods || []

matches_module = (mod, base) -> (compare) -> compare is mod.path

parse_private_modules = (module_path, wired, accept) ->
  each_sub_mod module_path
    .forEach (mod) ->
      return unless accept.some matches_module mod, module_path

      obj = get wired, mod.name

      _.each Object.keys(obj), (key) ->
        return unless typeof obj[key] is "function"
        obj[key] = mock.stub obj, key

      if typeof obj == "function"
        set wired, mod.name, _.extend mock.stub(), obj

load = (module_path, base, accept=[]) ->
  full_path = abs_path module_path, base
  wired = rewire full_path
  parse_private_modules full_path, wired, accept
  wired

module.exports =
  set: set
  get: get
  load: load
