FS = require 'q-io/fs'
_ = require 'underscore'

module.exports = class DB
  @load: (fn) ->
    db = new DB
    db.loadFromFile(fn).then -> db

  loadFromFile: (fn) ->
    FS.read(@filename = fn)
      .then(
        (json) => @loadFromJSON(json)
        => @climbs = [] # file does not exist, start with empty set
      )

  loadFromJSON: (json) ->
    @climbs = JSON.parse json

  merge: (incoming) ->
    existingKeys = {}
    @climbs.forEach (climb) -> existingKeys[climb.id] = true
    incoming.forEach (climb) =>
      @climbs.push climb unless climb.id of existingKeys

  save: ->
    FS.write(@filename, JSON.stringify @climbs)

  unignored: -> @climbs.filter (climb) -> climb.ignore
  ignored: -> @climbs.filter (climb) -> ! climb.ignore

  ignore: (args...) ->
    _.flatten(args).forEach (id) -> @climbs(id).ignore = true

  unignore: (args...) ->
    _.flatten(args).forEach (id) -> @climbs(id).ignore = false


