module.exports = class Cybozu
  constructor: (@config) ->
  getEvents: (callback)->
    setTimeout ->
      callback '佐藤'
    , 10

class Event
  constructor: (@id) ->
