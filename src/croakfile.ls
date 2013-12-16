require! {
  grunt
  _: 'lodash'
  './modules'
  './constants'.CROAKFILE
}
{ file }:util = require './common'
coffee = modules['coffee-script']

module.exports = croakfile =

  read: ->
    filepath = it |> find-croakfile
    if filepath
      if /\.coffee$/.test filepath
        (filepath |> file.read) |> coffee.eval _, bare: true
      else
        filepath |> require

  exists: ->
    (it |> find-croakfile)?

  load: (options, basepath) ->
    croak-fn = basepath |> @read
    if typeof croak-fn is 'function'
      options |> @croak-api |> croak-fn

  # temporal implementation
  croak-api: (options) ->
    { extend, overwrite, register_tasks } = options

    do-merge = -> it |> _.merge grunt.config!, _

    do-extend = -> it |> _.extend grunt.config!, _

    # config wrapper
    config = (config) ->
      # todo: check if the task exists
      if extend
        config |> do-merge |> grunt.config.init
      else if overwrite
        config |> do-extend |> grunt.config.init

    config.set = (key, value) ->
      if extend or overwrite
        grunt.config.set ...

    config.get = grunt.config.get
    config.get-raw = grunt.config.get-raw
    config.process = grunt.config.process

    # task wrapper
    task = ->
      grunt.task.register-task ... if register_tasks
    task.register-task = ->
      grunt.task.register-task ... if register_tasks
    task.register-multi-task = ->
      grunt.task.register-multi-task ... if register_tasks
    task.rename-task = ->
      grunt.task.rename-task ... if register_tasks
    task.load-tasks = ->
      grunt.task.load-tasks ... if register_tasks
    task.load-npm-tasks = ->
      grunt.task.load-npm-tasks ... if register_tasks
    task.exists = ->
      try
        grunt.task.rename-task it, it
        yes
      catch
        no

    # Croakfile API
    croak =
      grunt: grunt
      options: options
      config: config
      init-config: config
      extend-config: config
      task: task
      register-task: task.register-task
      register-multi-task: task.register-multi-task
      rename-task: task.rename-task
      load-npm-tasks: task.load-npm-tasks
      load-tasks: task.load-tasks

    <[ file log util ]>for-each ->
      Object.define-property croak, it,
        get: -> grunt[it]


find-croakfile = (basepath = process.cwd!) ->
  find-in-inner-directories = ->
    [ filepath ] = grunt.file.expand "#{basepath}/*/*/#{CROAKFILE}.{js,coffee}"
    filepath

  find-in-higher-directories = ->
    filepath = null
    [1..5]reduce ->
      unless filepath

    filepath

  unless filepath = find-in-inner-directories!
    unless filepath = find-in-higher-directories!

  filepath
