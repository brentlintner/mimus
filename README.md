mimus
=====

[![NPM version](https://badge.fury.io/js/mimus.svg)](http://badge.fury.io/js/mimus)

[![Build Status](https://drone.io/github.com/brentlintner/mimus/status.png)](https://drone.io/github.com/brentlintner/mimus/latest)

[![Coverage Status](https://img.shields.io/coveralls/brentlintner/mimus.svg)](https://coveralls.io/r/brentlintner/mimus)

[![Dependency Status](https://david-dm.org/brentlintner/mimus.svg)](https://david-dm.org/brentlintner/mimus)

A stubbing library with a focus on having:

* A simple API.
* Dependency injection and auto stubbing.
* A decoupled relationship with test runners.

Note: Currently this project is using [Sinon](http://sinonjs.org) and
[Rewire](https://www.npmjs.org/package/rewire). Check them out!

## Installation

    npm install mimus

## Usage

```javascript
  var mimus = require('mimus')
```

### mimus.require

This is the main method that you will use. It will require only the module
you want to test against, while stubbing any specified internal modules,
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

Calls reset on every (Sinon.JS) stub/spy.

```javascript
  mimus.reset()
```

### mimus.restore

Calls restore on every (Sinon.JS) stub.

```javascript
  mimus.restore()
```

## Examples

See the [system tests](test/system/example.coffee).

## Contributing

Current list of [contributors](https://github.com/brentlintner/mimus/graphs/contributors).

Any contributions are welcome. Please consider tests and code quality before submitting.

### Code Of Conduct

See [bantik's contributor covenant](https://github.com/Bantik/contributor_covenant/blob/master/CODE_OF_CONDUCT.md)!

### Issues

Current issue tracker is on [github](https://github.com/brentlintner/mimus/issues).

Please read any docs available before opening an issue.

## Hacking

    git clone git@github.com:brentlintner/mimus.git
    cd mimus
    npm install

### Testing

    npm run test
    npm run test-cov

### Code Quality

    npm run lint
    npm run lint-cov

### Auto Compiling CoffeeScript

    npm run dev &

## Architectural Notes

The top level API's main goal is to be a one method level interface with the object
returned via `mimus.require` being passed around by reference. This keeps api methods off
of the main object, and also provides a more functional way to interact with mimus.

## Versioning

This project ascribes to [semantic versioning](http://semver.org).

## Kudos!

* [Sinon](http://sinonjs.org) is currently used underneath.
* For dependency injection, [Rewire](https://www.npmjs.org/package/rewire) is used.
* Inspiration could not have happened with seeing [Jest](http://facebook.github.io/jest/) in action.

Also, see all other [deps](package.json).
