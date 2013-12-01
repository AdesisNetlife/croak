require! {
  path 
  ini
  is-type: 'prelude-ls'.is-type
  defaults: './config-defaults'
}
{ CONF-VAR, FILENAME } = require './constants'
{ file, env, extend, clone, is-win32 }:common = require './common'

module.exports =

  config: {}
  global: null
  local: null

  read: ->
    return null unless file.exists it
    ini.parse file.read it

  clean: ->
    @global = null
    @local = null
    @config = {}

  apply: ->
    @config 
    |> extend _, @global
    |> extend _, @local

  load: ->
    if global = config-transform @read @global-file!
      @global = global if has-data global
    if local = config-transform @read @local-file it
      @local = local if has-data local
    @apply!

  raw: ->
    config = {}
    [ 'global', 'local' ]forEach ~>
      data = config[it] = {}
      data.path = @["#{it}File"]!
      data.data = file.read data.path if file.exists data.path
    config

  write: ->
    file.write @global-file!, encode-config @global
    file.write @local-file(it), encode-config @local

  save: ->
    @write ...

  remove: ->
    @global?[it] &&= null
    @local?[it] &&= null
    @apply!
    !@config[it]?

  delete: ->
    @remove ...

  project: (project, data, local = false) ->
    if project and has-data data
      context = if local then 'local' else 'global'
      @[context] ?= {}
      @[context][project] = config-transform data
      @apply!

    if project := @config[project]
      if project.grunt_path?
        project.grunt_path = path.normalize project.grunt_path
    else
      project = null

    project

  update: (project, data, local = false) ->
    if @config[project] and has-data data
      context = if local then 'local' else 'global'
      @[context] ?= {}
      data := extend @[context][project], config-transform data
      @apply!
    data

  get: (project, option) ->
    if project := @config[project]
      if key
        project[option]
      else
        project

  exists: ->
    (@get ...)?

  section: ->
    @project ...

  global-file: ->
    if config-path = it or env CONF-VAR
      config-path = path.normalize replace-vars config-path
      if file.is-directory config-path
        config-path = path.join config-path, FILENAME
      return config-path
    
    path.join common.home, FILENAME

  local-file: (filepath = process.cwd!) ->
    exists = false
    global-file = @global-file!
    filepath := path.normalize replace-vars filepath

    console.log 'LOCAL FILE!'

    is-global-file = ->
      it is global-file

    if filepath.indexOf(FILENAME) isnt -1
      filepath = path.dirname filepath

    [1 to 4]reduce ->
      unless exists
        if file.exists exists-file = path.join it, FILENAME
          unless is-global-file exists-file
            filepath := exists-file
            exists := true
      path.join it, '../'
    , filepath

    unless exists
      filepath = path.join process.cwd!, FILENAME 
    if is-global-file filepath
      filepath = path.join path.dirname(filepath), 'croak', FILENAME 
    
    console.log 'FINAL PATH->', filepath
    filepath


apply-defaults = ->
  extend clone(defaults), it

replace-vars = ->
  if typeof it is 'string'
    it = it.replace /\$\{(.*)\}/g, (_, matched) ->
      if is-win32
        matched = 'USERPROFILE' if matched is 'HOME'
        matched = 'CD' if matched is 'PWD'
        matched = 'HOMEDRIVE' if matched is 'ROOT' or matched is 'DRIVE'
      else
        matched = '/' if matched is 'HOMEDRIVE' or matched is 'ROOT' 
      env(matched?.toUpperCase!) or ''
  it

translate-paths = ->
  # todo: get path from local file path location
  unless file.is-absolute it
    it = path.join process.cwd!, it
  it

process-value = (key, value) ->
  if <[ gruntfile npm tasks base ]>indexOf(key) isnt -1
    value = value |> translate-paths
  value |> replace-vars

config-transform = ->
  return it unless is-type 'Object', it
  
  for own key, value of it
    if is-type 'Object', value
      it[key] = value |> config-transform |> apply-defaults 
    else
      it["_#{key}"] = value
      it[key] = process-value key, value
  it

config-write-transform = ->
  data = {}

  is-not-template = ->
    /^\_/ isnt it

  has-variables = (value, orig-value) -> 
    is-type 'String', value and /\$\{.*\}/ is orig-value

  for own project, config of it when config?
    project = data[project] = {}
    for own key, value of config when is-not-template key
      orig-value = config["_#{key}"]
      if has-variables value, orig-value
        value = orig-value
      if config.hasOwnProperty "_#{key}" and (value isnt false or value is orig-value)
        project[key] = value
  data

encode-config = ->
  ini.stringify config-write-transform it

has-data = ->
  if it?
    Object.keys(it)length >= 1
  else
    no
