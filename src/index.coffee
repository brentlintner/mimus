path = require("path")
fs = require("fs")
_ = require("underscore")
esprima = require("esprima")
resolve = require("resolve")
sinon = require("sinon")
rewire = require("rewire")
sandbox = []

set = (wired, path, value) -> wired.__set__ path, value

get = (wired, path) -> wired.__get__ path

stub = (obj, method, func) ->
  sandbox.push sinon.stub(obj, method, func)
  _.last sandbox

spy = (target, method) ->
  sandbox.push(sinon.spy target, method)
  _.last sandbox

undo = (wired, path) -> throw message: 'Method Not Implemented'

reset = -> _.each sandbox, (stub) -> stub.reset()

rewire_module_path = (module_path) ->
  wired = null

  try wired = rewire(module_path)
  catch e
    throw e if e.code != "MODULE_NOT_FOUND"
    module_path = path.join(path.dirname(module_path),
                            "node_modules",
                            path.basename(module_path))
    wired = rewire(module_path)

  wired

abs_module_path = (name, base) ->
  base = "" unless base

  if fs.existsSync(path.join(base, name + ".js"))
    abs_path = path.join(base, name + ".js")
  else if fs.existsSync(path.join(base, name, "index.js"))
    abs_path = path.join(base, name, "index.js")
  else
    try abs_path = resolve.sync(name, {basedir: base})
    catch e
      console.error "mimus", e

  abs_path

if_variable_declaration = (node, base, list) ->
  return if not (node || node.type == "VariableDeclaration")

  _.each node.declarations, (declare) ->
    statement = declare &&
                declare.type == "VariableDeclarator" &&
                declare.init

    if statement.callee && statement.callee.name == "require"
      full_path = switch
        when statement.arguments && statement.arguments.length > 0
        then statement.arguments[0].value
        else "__empty__"

      list.push
        name: (if declare.id then declare.id.name else "__anon__")
        path: full_path
        abs_path: abs_module_path(full_path, base)

if_assignment_statement = (node, base, list) ->
  exp = node && node.type == "ExpressionStatement" && node.expression

  if exp.type == "AssignmentExpression" &&
     exp.right && exp.left &&
     exp.right.type == "CallExpression" &&
     exp.right.callee.name == "require"

    name = switch
      when exp.left.type == "Identifier" then exp.left.name
      else name = exp.left.object.name + "." + exp.left.property.name

    full_path = switch
      when exp.right.arguments && exp.right.arguments.length > 0
      then exp.right.arguments[0].value
      else "__empty__"

    list.push
      name: name,
      path: full_path
      abs_path: abs_module_path(full_path, base)

internal_modules = (ast, base, list) ->
  list = []  unless list

  return list if not ast or not ast.body

  _.each ast.body, (node) ->
    if_variable_declaration node, base, list
    if_assignment_statement node, base, list
    internal_modules node, base, list

  list

stub_method = (object) ->
  ignored_methods = /__(set|get)__/

  (property) ->
    return unless typeof object[property] == "function"
    return if ignored_methods.test property

    try object[property] = stub object, property
    catch e
      console.error "mimus", e

each_sub_mod = (module_path, base) ->
  file_path = abs_module_path(module_path, base)
  file_dirname = path.dirname(file_path)
  file_base = if file_dirname == "." then undefined else file_dirname
  file_data = fs.readFileSync(file_path, "utf-8") if fs.existsSync(file_path)
  internal_modules esprima.parse(file_data), file_base if file_data

matches_module = (mod, base_path) ->
  (compare_path) ->
    abs_compare_path = path.resolve(base_path, compare_path + ".js")
    abs_compare_path == mod.abs_path or compare_path == mod.path

parse_private_modules = (module_path, base_path, wired, accept) ->
  each_sub_mod(module_path, base_path).forEach (mod) ->
    return unless accept.some(matches_module(mod, module_path))
    wired_mod = get(wired, mod.name)
    _.each Object.keys(wired_mod), stub_method(wired_mod)
    if typeof wired_mod == "function"
      set wired, mod.name, _.extend(stub(), wired_mod)

mimus_require = (module_path, base_path, accept) ->
  wired = rewire_module_path(path.resolve(base_path, module_path))
  parse_private_modules module_path, base_path, wired, accept
  wired

module.exports =
  require: mimus_require
  set: set
  get: get
  stub: stub
  spy: spy
  reset: reset
  undo: undo
