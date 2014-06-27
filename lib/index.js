var
  path = require("path"),
  fs = require("fs"),
  _ = require("underscore"),
  esprima = require("esprima"),
  resolve = require("resolve"),
  sinon = require("sinon"),
  rewire = require("rewire"),
  sandbox = [] // TODO: sandbox leaks

function set(wired, path, value) {
  wired.__set__(path, value)
}

function get(wired, path) {
  return wired.__get__(path)
}

function stub(obj, method, func) {
  return sandbox.push(sinon.stub(obj, method, func)),
         _.last(sandbox)
}

function spy(target, method) {
  return sandbox.push(sinon.spy(target, method)),
         _.last(sandbox)
}

// TODO
function undo(wired, path) { throw "Not Implemented" }

function reset() {
  _.each(sandbox, function (stub) {
    stub.reset()
  })
}

function rewire_module_path(module_path) {
  var wired

  try {
    wired = rewire(module_path)
  } catch (e) {
    if (e.code != "MODULE_NOT_FOUND") throw e
    module_path = path.join(path.dirname(module_path),
                         "node_modules",
                         path.basename(module_path))
    wired = rewire(module_path)
  }

  return wired
}

function abs_module_path(name, base) {
  if (!base) base = ''

  if (fs.existsSync(path.join(base, name + ".js"))) {
    return path.join(base, name + ".js")
  } else if (fs.existsSync(path.join(base, name, "index.js"))) {
    return path.join(base, name, "index.js")
  } else {
    try {
      return resolve.sync(name, {basedir: base})
    } catch (e) { console.error("mimus", e) }
  }
}

function if_variable_declaration(node, base, list) {
  if (node && node.type == 'VariableDeclaration') {
    _.each(node.declarations, function (declare) {
      var statement = declare &&
                      declare.type == 'VariableDeclarator' &&
                      declare.init

      if (statement.callee && statement.callee.name == "require") {
        var full_path = statement.arguments &&
                statement.arguments.length > 0 ?
                  statement.arguments[0].value : '__empty__'

        list.push({
          name: declare.id ? declare.id.name : '__anon__',
          path: full_path,
          abs_path: abs_module_path(full_path, base)
        })
      }
    })
  }
}

function if_assignment_statement(node, base, list) {
  var exp = node && node.type == 'ExpressionStatement' && node.expression

  if (exp.type == 'AssignmentExpression' &&
     exp.right && exp.left &&
     exp.right.type == "CallExpression" &&
     exp.right.callee.name == "require") {

    var name = exp.left.type == 'Identifier' ?
                 exp.left.name :
                   exp.left.object.name + '.' +
                   exp.left.property.name

    var full_path = exp.right.arguments &&
            exp.right.arguments.length > 0 ?
              exp.right.arguments[0].value :
              '__empty__'

    list.push({
      name: name || '__anon__',
      path: full_path,
      abs_path: abs_module_path(full_path, base)
    })
  }
}

function internal_modules(ast, base, list) {
  if (!list) list = []
  if (!ast || !ast.body) return list

  _.each(ast.body, function (node) {
    if_variable_declaration(node, base, list)
    if_assignment_statement(node, base, list)
    internal_modules(node, base, list)
  })

  return list
}

function stub_method(obj) {
  var ignored_methods = /__(set|get)__/

  return function (prop) {
    if (typeof obj[prop] != "function") return
    if (ignored_methods.test(prop)) return
    try { obj[prop] = stub(obj, prop) }
    catch (e) { console.error('mimus', e) }
  }
}

function each_sub_mod(module_path, base) {
  var
    file_path = abs_module_path(module_path, base),
    file_base = path.dirname(file_path)

  return internal_modules(
           fs.existsSync(file_path) ?
           esprima.parse(fs.readFileSync(file_path, "utf-8")) : undefined,
           file_base == "." ? undefined : file_base)
}

function matches_mod(mod, base_path) {
  return function (compare_path) {
    return path.resolve(base_path, compare_path + '.js') == mod.abs_path ||
           compare_path == mod.path
  }
}

function parse_private_modules(module_path, base_path, wired, accept) {
  each_sub_mod(module_path, base_path).forEach(function (mod) {
    if (!accept.some(matches_mod(mod, module_path))) return
    var wired_mod = get(wired, mod.name)
    _.each(Object.keys(wired_mod), stub_method(wired_mod))
    if (typeof wired_mod == "function")
      set(wired, mod.name, _.extend(stub(), wired_mod))
  })
}

function mimus_require(module_path, base_path, accept) {
  var wired = rewire_module_path(path.resolve(base_path, module_path))
  parse_private_modules(module_path, base_path, wired, accept)
  return wired
}

module.exports = {
  require: mimus_require,
  set: set,
  get: get,
  stub: stub,
  spy: spy,
  reset: reset,
  undo: undo
}
