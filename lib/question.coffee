Q = require 'q'
readline = require 'readline'

module.exports =
  question: (query) ->
    Q.Promise (resolve) ->
      rl = readline.createInterface(process.stdin, process.stdout)
      rl.question query, (result) ->
        rl.close()
        resolve(result)

