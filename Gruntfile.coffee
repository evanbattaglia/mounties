# Not used yet...

module.exports = (grunt) ->
  require('load-grunt-tasks') grunt

  grunt.initConfig
    # For running mocha tests
    mochaTest:
      options:
        reporter: 'spec'
        clearRequireCache: true
        require: [
          'coffee-script/register'
          should = require('chai').should()
          ->
            process.env.NODE_ENV = 'test'
        ]
      src: 'test/**/*.coffee'

