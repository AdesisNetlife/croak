require! {
  path
  grunt
  version: '../package.json'.version
  _: './import'.lodash
}

module.exports = 

  grunt-version: grunt.version
  
  init: (project, options) ->
    # extend options, temporary!
    options := _.extend {}, project, options |> omit-options 
    # wrap grunt.initConfig method
    grunt.init-config = init-config!
    # init grunt with project options
    @grunt options

  grunt: (options = {}) ->
    # extend croak API to Grunt (todo)
    grunt.croak = _.defaults croak, { options.base, options.tasks, options.npm }
    # clean croak args
    grunt.cli.tasks.splice 0, 1
    # force to override process.argv, it was taken 
    # by the Grunt module instance and has precedence
    _.extend grunt.cli.options, options
    # init grunt with inherited options
    grunt.cli options

# todo: define API and use paths from config file
croak = 
  base: path.normalize process.cwd!
  cwd: path.normalize process.cwd!
  version: version

set-croak-config = ->
  # add specific options avaliable from config
  grunt.config.set 'croak', croak unless grunt.config.get 'croak'

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
