var
  dirty = require('dirty'),
  logger = require('./logger')

function open(name, callback) {
  var
    db = dirty(name),
    log =  logger.create('db')

  db.on('load', function () {
    log.info('loaded -> ' + name)
    callback(db)
  })

  db.on('drain', function () {
    log.info('flushing records to disk -> ' + name)
  })
}

module.exports = {
  open: open
}
