require! {
  path 
  ini
  _: './import'.lodash
  defaults: './config-defaults'
}
{ CONF-VAR, FILENAME } = require './constants'
{ file, env, extend, clone, is-win32 }:common = require './common'

module.exports = config =

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

  raw: ->
    config = {}
    [ 'global', 'local' ]forEach ~>
      data = config[it] = {}
      data.path = @["#{it}File"]!
      data.data = file.read data.path if file.exists data.path
    config

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

  project-resolve: ->
    local = @local
    if local? and has-data local
      get-first-project local
    else
      null

  update: (project, data, local = false) ->
    if @config[project] and has-data data
      context = if local then 'local' else 'global'
      @[context] ?= {}
      data := extend @[context][project], data |> config-transform 
      @apply!
    data

  get: (project, key) ->
    if @config.hasOwnProperty project
      console.log 'Found!!!!'
      project := @config[project]
      console.log project
      if key
        project[key]
      else
        project
    else
      null

  exists: ->
    (@get ...)?

  section: ->
    @project ...

  global-file: ->
    if config-path = it or env CONF-VAR
      config-path := config-path |> replace-vars |> path.normalize  
      if file.is-directory config-path
        config-path := path.join config-path, FILENAME
      return config-path
    
    path.join common.home, FILENAME

  local-file: (filepath = process.cwd!) ->
    exists = false
    global-file = @global-file!
    filepath := filepath |> replace-vars |> path.normalize

    is-global-file = ->
      it is global-file

    has-filename = ->
      filepath.index-of(FILENAME) isnt -1

    croak-path = ->
      path.join it, FILENAME

    if has-filename!
      filepath := path.dirname filepath

    [1 to 4]reduce ->
      unless exists
        if file.exists new-filepath = croak-path it 
          filepath := new-filepath
          exists := true
      path.join it, '../'
    , filepath

    unless exists
      filepath = croak-path process.cwd! 
    # be sure the resolve process do not find the global file
    if is-global-file filepath
      filepath = path.join path.dirname(filepath), croak-path 'croak' 
    
    filepath


apply-defaults = ->
  extend clone(defaults), it

is-not-template-value = ->
  /^\_/ isnt it and /^\$/ isnt it

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
  # todo: obtain relative path from .croakrc location
  unless file.is-absolute it
    it = path.join process.cwd!, it
  it

process-value = (key, value) ->
  value = value |> replace-vars
  if <[ gruntfile npm tasks base ]>index-of(key) isnt -1
    value = value |> translate-paths
  value

config-transform = ->
  return it unless _.is-object it
  
  for own key, value of it
    if _.is-object value
      value['$name'] = key unless value['$name']
      it[key] = value |> config-transform |> apply-defaults 
    else
      if is-not-template-value key
        it["_#{key}"] = value
        it[key] = process-value key, value
  it

config-write-transform = ->
  data = {}

  has-variables = (value, orig-value) -> 
    _.is-string value and /\$\{.*\}/ is orig-value

  for own project, config of it when config?
    project = data[project] = {}
    for own key, value of config when is-not-template-value key
      orig-value = config["_#{key}"]
      if has-variables value, orig-value
        value = orig-value
      if config.hasOwnProperty "_#{key}" and (value isnt false or value is orig-value)
        project[key] = value
  data

encode-config = ->
  ini.stringify config-write-transform it

has-data = ->
  if _.is-object it then Object.keys it .length >= 1 else no

get-first-project = ->
  if it? and has-data it
    for own name, data of it when has-data data
      return data

