basic = require './basic.module'

other_method = () -> null

module.exports =
  method: basic.method
  other_method: other_method
