cheerio = require "cheerio"
fs = require 'fs'
_ = require 'underscore'
Q = require 'q'
HTTP = require 'q-io/http'

mounties = module.exports =
  parse: (body) ->
    $ = cheerio.load body
    # HELPER METHODS
    strip = (elem) ->
      $(elem).text().trim().replace /\s+/, ' '

    # DO IT
    _.map $('div.result-item'), (div) ->
      find = $(div).find.bind $(div)

      {
        availP: strip(find('.result-availability span')[0]),
        availL: strip(find('.result-availability span')[1]),
        reg: strip(find('.result-reg')),
        title: strip(find('.result-title')),
        link: find('.result-title a').attr('href'),
        difficulty: strip(find('.result-difficulty')),
        id: "#{_.last find('.result-title a').attr('href').split('/')}-#{strip(find('.result-date')).replace(/\ /g, '_')}",
        date: strip(find('.result-date'))
      }

  fromFile: (fn) ->
    @parse fs.readFileSync fn

  qFromSite: (start) ->
    uri = "https://www.mountaineers.org/explore/activities/@@faceted_query?b_start%5B%5D=#{start}&c4%5B%5D=Climbing"
    HTTP.request(uri: uri).then (response) > @parse response.body
      
    


# GET THE HTML
console.log JSON.stringify mounties.fromFile "temp.html"



