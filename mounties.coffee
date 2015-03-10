#!/usr/bin/env coffee

mounties = require './lib/mounties.coffee'
DB = require './lib/db.coffee'
question = require './lib/question.coffee'
Q = require 'q'
path = require 'path'
child_process = require 'child_process'

MOUNTIES_DB = path.resolve __dirname, 'mounties.json'

cmd = process.argv[2]
if cmd == 'pull'
  Q.spread([
    DB.load(MOUNTIES_DB),
    mounties.qAllFromSite()
  ], (db, newClimbs) ->
    db.merge(newClimbs)
    db.save()
  ).done()
else if cmd == 'process'
  DB.load(MOUNTIES_DB).then (db) ->
    i = 0
    if process.argv[3] == 'kept'
      climbs = db.kept()
    else
      climbs = db.unseen()
    # TODO use q-flow.map etc here and in mounties.coffee
    keepGoing = ->
      climb = climbs[i]
      console.log JSON.stringify climb, null, 2
      question.question('keep/ignore/leave as-is/view in browser? (k/i/l/v) ').then (line) ->
        if line[0] == 'v'
          child_process.exec "google-chrome #{climb.link}"
        else
          i += 1
          db.ignore(climb.id)  if line[0] == 'i'
          db.keep(climb.id)  if line[0] == 'k'
          db.save()
        keepGoing() if climbs[i]
    keepGoing() if climbs[i]
  .done()
else if cmd == 'show'
  DB.load(MOUNTIES_DB).then (db) ->
    subcmd = process.argv[3]
    if subcmd == 'ignored' || subcmd == 'kept' || subcmd == 'unseen'
      climbs = db[subcmd].call(db)
    else
      climbs = db.climbs
    console.log JSON.stringify climbs, null, 2

else
  console.log "unknown command: #{cmd}"
  console.log 'available commands:'
  console.log '  pull'
  console.log '  show (kept, ignored, unseen, all)'
  console.log '  process'

    # TODO: alerts for 'kept' ones that have registration open dates coming up



