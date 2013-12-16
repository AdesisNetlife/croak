require! {
  path
  grunt
  _: 'lodash'
  './modules'
  './constants'.CROAKFILE
}
{ file }:util = require './common'
coffee = modules['coffee-script']

module.exports = croakfile =

  path: null
  dirname: null

  read: ->
    filepath = it |> find-croakfile
    if filepath
      @path = filepath
      @dirname = filepath |> path.dirname

      if /\.coffee$/.test filepath
        (filepath |> file.read) |> coffee.eval _, bare: true
      else
        filepath |> require

  exists: ->
    (it |> find-croakfile)?

  load: (options, basepath = process.cwd!) ->
    croak-fn = basepath |> @read
    options |> @croak-api |> croak-fn if croak-fn |> _.is-function

  # temporal implementation
  croak-api: (options) ->
    { extend, overwrite, register_tasks } = options

    inherit-grunt-members-api = (croak) ->
      <[ file log util event fail option template ]>for-each (member) ->
        Object.define-property croak, member,
          get: -> grunt[member]
          enumerable: yes

    # grunt API task wrapper
    wrap-grunt-task-api = (croak) ->
      task = {}

      # native Grunt task methods
      grunt.task |> _.functions |> _.each _, (member) ->
        task <<< (member): -> grunt.task[member] ... if register_tasks

      # first level API task methods
      <[  registerTask
          registerMultiTask
          renameTask
          loadNpmTasks
          loadTasks
      ]>for-each (member) ->
        croak <<< (member): -> grunt.task[member] ... if register_tasks

      # Croak-specific addon methods
      task.exists = ->
      try
        grunt.task.rename-task it, it
        yes
      catch
        no

      croak.task = task

    wrap-grunt-config-api = (croak) ->

      # config extend helpers
      do-merge = -> it |> _.merge grunt.config!, _
      do-extend = -> it |> _.extend grunt.config!, _

      # config wrapper
      config = (config) ->
        # todo: check if the task exists
        if overwrite
          config |> do-extend |> grunt.config.init
        else if extend
          config |> do-merge |> grunt.config.init

      # expose grunt config API
      grunt.config |> _.extend config, _

      config.set = (key, value) ->
        if extend or overwrite
          grunt.config.set ...

      croak <<< config: config
      croak <<< init-config: config
      croak <<< extend-config: config

    # build the Croakfile API
    croak =
      # expose Grunt native API
      grunt: grunt
      # expose Croak run options
      options: options

    # add API method wrappers
    croak |> wrap-grunt-task-api
    croak |> wrap-grunt-config-api
    croak |> inherit-grunt-members-api

    croak


find-croakfile = (basepath = process.cwd!) ->
  filepath = null

  find-in-inner-directories = (basepath) ->
    [ path ] = "#{basepath}/*/*/#{CROAKFILE}.{js,coffee}" |> grunt.file.expand
    path

  find-in-higher-directories = (basepath) ->
    croakfile = null
    [1 to 5]reduce ->
      unless croakfile
        [ file ] = "#{it}/#{CROAKFILE}.{js,coffee}" |> grunt.file.expand
        croakfile := file if file
      it |> path.join _, '../'
    , basepath
    croakfile

  unless filepath := basepath |> find-in-inner-directories
    filepath := basepath |> find-in-higher-directories

  filepath
