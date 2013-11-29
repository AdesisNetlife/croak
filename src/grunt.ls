grunt = require 'grunt'

module.exports =

  croak-options:
    base: path.normalize process.cwd()
    cwd: path.normalize cwd
  
  set-croak-config: ->
    # add specific options avaliable from config
    grunt.config.set 'croak', @croak-options unless grunt.config.get 'croak'

  init-config: ->
    { init-config } = grunt
    (object) ->
      init-config object
      set-croak-config!

  init: (grunt-path) ->
    # grunt-path
    @grunt-path = grunt-path
    # wrap grunt.initConfig method
    grunt.init-config = init-config!
    # change current working directory
    process.chdir @grunt-path
    # remove croak-specific arguments
    process.argv.splice 2, 1
    # init grunt
    grunt.cli!
