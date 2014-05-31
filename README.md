mimus
=====

A stubbing library with a focus on having:

* A simple API.
* Dependency injection and auto stubbing.
* A decoupled relationship with test runners.

## Installation

    npm install mimus

## Usage

```javascript
  var mimus = require('mimus')
```

### mimus.require

This is the main method that you will use. It will require only the module
you want to test against, while stubbing any specified inner dependencies
that can be retrieved with other methods.

Require a stubbed `db` module and also stub the `mongodb` and `zlib` module.

```javascript
  var db = mimus.require('./lib/db', __dirname, ['mongodb', 'zlib'])
```
Why the whitelist approach?

This way, unexpected clashes with mocking low level modules can be controlled by the user.

### mimus.get

Get an internal variable.

Uses `rewire.__get__`.

```javascript
  mimus.get(required_module, 'internal_var_name')
```

### mimus.set

Set an internal variable.

Uses `rewire.__set__`.

```javascript
  mimus.set(required_module, 'internal_var_name', 'value')
```

### mimus.stub

Create a (Sinon.JS) stub.

```javascript
  var stub = mimus.stub()
  stub.returns...
```

### mimus.spy

Create a (Sinon.JS) spy.

```javascript
  var spy = mimus.spy()
```

### mimus.reset

Resets all stubs and spies.

```javascript
  mimus.reset()
```

### mimus.undo - Not Implemented

Undoes the stubbing of a module.

```javascript
  mimus.undo(required_module, 'internal_var_name')
```
## Examples

See [Example Folder](https://github.com/brentlintner/mimus/blob/master/example).

## Architectural Notes

The top level API's main goal is to be a one method level interface with the object
returned via `mimus.require` being passed around by reference. This keeps api methods off
of the main object, and also provides a more functional way to interact with mimus.

## Kudos!

* [Sinon.JS](http://sinonjs.org) is currently used underneath.
* For dependency injection, [Rewire](https://www.npmjs.org/package/rewire) is used.
* Inspiration could not have happened with seeing [Jest](http://facebook.github.io/jest/) in action.

Also, see all other [deps](https://github.com/brentlintner/mimus/blob/master/package.json).

## TODO

* Version 0.1.x.
* Version 1.x.x.

* Treat same path relative module requires as the same?
* Switch out Sinon for a custom control flow API implementation.
* Tighten and flush out private module lookups.
* Rewrite to use ES6 syntaxes.
* Add mocking API.
* Heuristical auto mocking (based on methods used).
* Set level of stubbing deepness > 1
* mimus.undo
