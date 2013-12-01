require! {
  path 
  ini
  is-type: 'prelude-ls'.is-type
  defaults: './config-defaults'
}
{ CONF-VAR, FILENAME } = require './constants'
{ file, env, extend, clone }:common = require './common'

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
      config-path = config-path |> path.normalize 
      if file.is-directory config-path
        return path.join config-path, FILENAME
    
    path.join common.home, FILENAME

  local-file: (filepath = process.cwd!) ->
    local-file = null
    global-file = @global-file!

    if filepath.indexOf(FILENAME) isnt -1
      filepath := path.dirname filepath
 
    [1 to 4]reduce ->
      unless local-file
        if file.exists exists-file = path.join it, FILENAME
          if exists-file isnt global-file
            local-file := exists-file
      path.join it, '../'
    , filepath

    local-file


apply-defaults = ->
  extend clone(defaults), it

replace-vars = ->
  if is-type 'String', it
    it = it.replace /\$\{(.*)\}/g, ->
      if &1 is 'HOME' and process.platform is 'win32'
        &1 = 'USERPROFILE'
      return env &1?.toUpperCase! or ''
  it

config-transform = ->
  return it unless is-type 'Object', it
  
  for own key, value of it
    if is-type 'Object', value
      it[key] = apply-defaults config-transform value
    else
      it["_#{key}"] = value
      it[key] = replace-vars value
  it

config-write-transform = ->
  data = {}

  is-not-template = ->
    /^\_/ isnt it

  has-variables = (value, orig-value) -> 
    is-type 'String', value and /\$\{.*\}/ is orig-value

  for own project, config of it when config?
    project = data[project] = {}
    for own key, value of config when isNotTemplate key
      orig-value = config["_#{key}"]
      if has-variables value, orig-value
        value = orig-value
      project[key] = value
  
  data

encode-config = ->
  ini.stringify config-write-transform it

has-data = ->
  if it?
    Object.keys(it)length >= 1
  else
    no
