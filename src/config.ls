require! {
  path 
  ini
  _: './import'.lodash
  defaults: './config-defaults'
}
{ CONF-VAR, FILENAME } = require './constants'
{ file, env, extend, clone, is-win32 }:common = require './common'

local-path = null

module.exports = config =

  config: {}
  global: null
  local: null

  read: ->
    return null unless it |> file.exists 
    it |> file.read |> ini.parse

  clean: ->
    @global = null
    @local = null
    @config = {}

  apply: ->
    @config 
    |> extend _, @global
    |> extend _, @local

  load: ->
    if global = @global-file! |> @read |> config-transform
      @global = global if global |> has-data 
    if local = @local-file it |> @read |> config-transform 
      @local = local if local |> has-data
    @apply!

  write: ->
    encode-config @global |> file.write @global-file!, _
    encode-config @local |> file.write @local-file(it), _

  save: ->
    @write ...

  remove: ->
    @global?[it] &&= null
    @local?[it] &&= null
    @apply!
    !@config[it]?

  raw: ->
    config = {}
    [ 'global', 'local' ]forEach ~>
      data = config[it] = {}
      data.path = @["#{it}File"]!
      data.data = data.path |> file.read if data.path |> file.exists 
    config

  project: (project, data, local = false) ->
    if project and data |> has-data
      context = if local then 'local' else 'global'
      @[context] ?= {}
      @[context][project] = data |> config-transform 
      @apply!

    if project := @config[project]
      if project.grunt_path?
        project.grunt_path = project.grunt_path |> path.normalize
    else
      project = null
    project

  project-resolve: ->
    project = null
    unless @local
      if @global? and project := @global.default?
        @global.default
    else if @local? and project := @local.default |> @get
      project
    else if @local? and @local |> has-data
      @local |> get-first-member 
    else
      project

  update: (project, data, local = false) ->
    if @config[project] and has-data data
      context = if local then 'local' else 'global'
      @[context] ?= {}
      data := @[context][project] |> extend _, (data |> config-transform)
      @apply!
    data

  get: (project, key) ->
    if project |> @config.hasOwnProperty 
      project := @config[project]
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
        config-path := config-path |> add-croakrc-file
      return config-path
    
    common.home |> add-croakrc-file

  local-file: (filepath = @local-path) ->
    exists = false
    global-file = @global-file!
    filepath := filepath |> replace-vars |> path.normalize |> file.make-absolute

    is-global-file = ->
      it is global-file

    has-filename = ->
      filepath.index-of(FILENAME) isnt -1

    if has-filename!
      filepath := filepath |> path.dirname 

    # tries to discover .croakrc in cwd and fall back to higher directories
    [1 to 5]reduce ->
      unless exists
        if file.exists new-filepath = (it |> add-croakrc-file)
          filepath := new-filepath
          exists := true
      it |> path.join _, '../'
    , filepath

    unless exists
      filepath = process.cwd! |> add-croakrc-file
    # prevent the local file discovery process do not resolve the global file
    if is-global-file filepath
      filepath = path.join (filepath |> path.dirname), 'croak' |> add-croakrc-file 
    
    filepath

# accessor for customize the .croakrc file path lookup
Object.define-property config, 'localPath', do 
  enumerable: true
  get: -> local-path or process.cwd!
  set: -> local-path := it


apply-defaults = ->
  it |> extend (defaults |> clone), _

add-croakrc-file = ->
  it |> path.join _, FILENAME

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
  unless it |> file.is-absolute 
    it = it |> path.join process.cwd!, _
  it

process-value = (key, value) ->
  value = value |> replace-vars
  if <[ gruntfile npm tasks base ]>index-of(key) isnt -1
    value = value |> translate-paths
  value

# process config values and create new config with defaults per project
config-transform = ->
  return it unless it |> _.is-object 
  
  for own key, value of it
    if value |> _.is-object 
      value['$name'] = key unless value['$name']
      it[key] = value |> config-transform |> apply-defaults 
    else
      if key |> is-not-template-value 
        # support for global config options
        if key isnt 'default' and key isnt 'project'
          # save the original value (required for templating and variables)
          it["_#{key}"] = value
        it[key] = process-value key, value
  it

config-write-transform = ->
  data = {}

  has-variables = (value, orig-value) -> 
    (value |> _.is-string) and /\$\{.*\}/ is orig-value

  set-global-config = (obj, key, value) ->
    obj[key] = value

  can-copy = (key, value, orig-value) ->
    if "_#{key}" |> config.has-own-property
      if value isnt false or value is orig-value 
        yes

  for own project, config of it when config?
    project = data[project] = {}
    unless config |> _.is-object 
      set-global-config data, project, value
    else
      for own key, value of config when key |> is-not-template-value 
        orig-value = config["_#{key}"]
        if value |> has-variables _, orig-value
          value = orig-value
        if can-copy key, value, orig-value
          project[key] = value
  data

encode-config = ->
  it |> config-write-transform |> ini.stringify 

has-data = ->
  if it |> _.is-object then Object.keys it .length >= 1 else no

get-first-member = ->
  if it? and it |> has-data 
    for own name, data of it when data |> has-data
      return data

