require! {
  grunt
  './config'
  _: lodash
  version: '../package.json'.version
}

module.exports =

  version: version
  grunt-version: grunt.version

  config: config
  grunt: grunt

  load: ->
    it |> config.load

  init: (project, options) ->
    # extends options with project config
    options := (options |> _.extend {}, project, _) |> map-options
    # init grunt with project options
    options |> @init-grunt

  run: ->
    @init ...

  init-grunt: (options = {}) ->
    # omit unsupported grunt options
    options := options |> omit-options
    # wrap grunt.initConfig method
    grunt.init-config = init-config!
    # extend croak API to provide it from Grunt
    grunt.croak = { options.base, options.tasks, options.npm } |> _.defaults croak, _
    # remove croak first argument
    grunt.cli.tasks.splice 0, 1 if grunt.cli.tasks
    # force to override process.argv, it was taken
    # by the Grunt module instance and has precedence
    options |> _.extend grunt.cli.options, _
    # init grunt with inherited options
    options |> grunt.cli


# expose this object croak as config
croak =
  root: config.path!local or process.cwd!
  cwd: config.path!local or process.cwd!
  version: version

set-grunt-croak-config = ->
  # add specific options avaliable from config
  grunt.config.set 'croak', croak unless grunt.config.get 'croak'

init-config = ->
  { init-config } = grunt

  (config) ->
    init-config config
    set-grunt-croak-config!

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
    when value? and value isnt false and (key |> grunt-args.index-of) isnt -1
    then options <<< (key): value

  options

map-options = ->
  map =
    'package': 'gruntfile'

  for own origin, target of map
    when (origin := it[origin])? and not it[target]?
    then it <<< (target): origin
  it
