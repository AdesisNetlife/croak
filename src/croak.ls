require! {
  path
  grunt
  _: './import'.lodash
}

module.exports = croak = 

  init: (project, options) ->
    # extend options, temporary!
    options := _.extend {}, project, options |> omit-options 
    # wrap grunt.initConfig method
    grunt.init-config = init-config!
    # clean croak args
    grunt.cli.tasks.splice 0, 1
    # remove croak-specific arguments
    # init grunt
    grunt.cli options

options = 
  base: path.normalize process.cwd!
  cwd: path.normalize process.cwd!
  $name: 'croak'

set-croak-config = ->
  # add specific options avaliable from config
  grunt.config.set 'croak', options unless grunt.config.get 'croak'

init-config = ->
  { init-config } = grunt
  (config) ->
    init-config config
    set-croak-config!

omit-options = ->
  options = {}
  # supported grunt options
  grunt-args = <[
    no-color
    base
    gruntfile
    debug
    stack
    force
    tasks
    npm
    no-write
    verbose
  ]>

  for own key, value of it 
    when grunt-args.index-of(key) isnt -1 and value isnt false and value?
      options[key] = value

  options
