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

  ignored: -> @climbs.filter (climb) -> climb.status == 'ignore'
  kept: -> @climbs.filter (climb) -> climb.status == 'keep'
  unseen: -> @climbs.filter (climb) -> ! climb.status

  findById: (id) ->
    _.find @climbs, (climb) -> climb.id == id

  ignore: (args...) ->
    _.flatten(args).forEach (id) => @findById(id).status = 'ignore'
  keep: (args...) ->
    _.flatten(args).forEach (id) => @findById(id).status = 'keep'
  unsee: (args...) ->
    _.flatten(args).forEach (id) => delete @findById(id).status

