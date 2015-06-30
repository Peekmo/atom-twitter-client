_ = require "underscore"
Logger = require "./logger"
Promise = require "bluebird"
request = require "request"

module.exports =
class TwitterRestClient
  log: new Logger("TwitterRestClient")

  constructor: (@oauth, @options) ->

  createFavorite: (id) ->
    @post "/favorites/create.json?id=#{id}"

  destroyFavorite: (id) ->
    @post "/favorites/destroy.json?id=#{id}"

  updateStatus: (status) ->
    @post "/statuses/update.json?status=#{encodeURIComponent status}"

  getConfiguration: ->
    @get "/help/configuration.json"

  get: (endpoint) ->
    @log.info "request to #{endpoint}"

    new Promise (resolve, reject) =>
      buffer = ""
      request
      .get @_getParams endpoint
      .on "response", (response) -> reject response.statusMessage unless response.statusCode is 200
      .on "data", (data) ->
        buffer += data.toString("utf8")
      .on "end", ->
        try
          resolve JSON.parse buffer
        catch error
          reject error
      .on "error", (err) -> reject err

  post: (endpoint) ->
    @log.info "request to #{endpoint}"

    new Promise (resolve, reject) =>
      buffer = ""
      request
      .post @_getParams endpoint
      .on "response", (response) -> reject response.statusMessage unless response.statusCode is 200
      .on "data", (data) ->
        buffer += data.toString("utf8")
      .on "end", ->
        try
          resolve JSON.parse buffer
        catch error
          reject error
      .on "error", (err) -> reject err

  _getParams: (endpoint) ->
    _.extend { url: "https://api.twitter.com/1.1#{endpoint}", oauth: @oauth }, @options
