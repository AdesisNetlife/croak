require! {
  path 
  ini
  _: './modules'.lodash
  defaults: './config-defaults'
}
{ CONFVAR, FILENAME } = require './constants'
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
    global-config-path = @global-file!
    local-config-path = @local-file it

    add-filepath-to-config = (config, filepath) ->
      if (config |> _.is-object) and filepath
        config <<< { $path: filepath }
        config <<< { $dirname: filepath |> path.dirname }

    if global = global-config-path |> @read |> config-transform
      @global = global if global |> has-data
      global-config-path |> add-filepath-to-config global, _
    if local = local-config-path |> @read |> config-transform
      if local |> has-data
        @local = local 
        local-config-path |> add-filepath-to-config local, _
    @apply!

  write: ->
    for key, value in <[global local]> when @[key] |> has-data
      (@[key] |> encode-config) |> file.write @["#{key}File"]!, _

  save: ->
    @write ...

  raw: ->
    config = {}
    <[ global local ]>forEach ~>
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

  get: (key) ->
    project = key

    if (key |> _.is-string)
      key := key.split '.'
      project := key[0]
      key := key[1]

    if project |> @config.has-own-property 
      project := @config[project]
      if key
        if value = project["_#{key}"]
          value
        else
          null
      else
        project |> get-template-values
    else
      null

  set: (data-obj, global = false) ->
    if data-obj |> _.is-object
      context = if global then 'global' else 'local'
      data-obj := data-obj |> config-transform
      if @[context] |> _.is-object
        data-obj |> _.extend @[context], _
      else
        @ <<< { (context): data-obj }

  set-key: (key, value, global = true) ->
    if (key |> _.is-string) and value?
      context = if global then 'global' else 'local'
      key := key.split '.'
      project = key[0]

      if project := @[context]?[project]
        if project |> _.is-object
          ({ (key[1]): value } |> config-transform) |> _.extend project, _
        else
          # global config values
          @[context][project] = value
        return yes
    no

  remove: (key) ->
    return no unless (key |> _.is-string)

    project = key
    key := key.split '.'
    project := key[0]
    key := key[1]

    if key and @config[project]
      @global?[project][key] &&= null
      @local?[project][key] &&= null
      @apply!
      !@config[project][key]?
    else
      @global?[project] &&= null
      @local?[project] &&= null
      @apply!
      !@config[project]?

  path: ->
    { global: @global?.$path, local: @local?.$path }

  exists: ->
    (@get ...)?

  section: ->
    @project ...

  global-file: ->
    if config-path = it or env CONFVAR
      config-path := config-path |> replace-vars |> path.normalize  
      if file.is-directory config-path
        config-path := config-path |> add-croakrc-file
      return config-path
    # defaults to user home directory
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
    if filepath |> is-global-file 
      # set to default
      filepath = @local-path # #path.join (filepath |> path.dirname), 'croak' |> add-croakrc-file 
    
    filepath

# accessor to customize the local .croakrc file path
Object.define-property config, 'localPath', do 
  enumerable: true
  get: -> local-path or (process.cwd! |> add-croakrc-file)
  set: -> local-path := it


apply-defaults = ->
  it |> extend (defaults |> clone), _

add-croakrc-file = ->
  unless (it |> new RegExp "#{CONFVAR}$" .test)
    it |> path.join _, FILENAME

is-global-config-value = ->
  values = <[ default project ]>
  values.index-of(it) isnt -1

is-not-template-value = ->
  /^\_/ isnt it and /^\$/ isnt it

get-template-values = ->
  obj = {}
  for own key, value of it when !(key |> is-not-template-value)
    obj <<< { (key.slice 1): value } if value?
  obj

replace-vars = ->
  if typeof it is 'string'
    it = it.replace /\$\{(.*)\}/g, (_, matched) ->
      matched = matched?.toUpperCase!
      if is-win32
        matched = 'USERPROFILE' if matched is 'HOME'
        matched = 'CD' if matched is 'PWD'
        matched = 'HOMEDRIVE' if matched is 'ROOT' or matched is 'DRIVE'
      else
        matched = '/' if matched is 'HOMEDRIVE' or matched is 'ROOT'
        matched = 'PWD' if matched is 'CD'
      env(matched?.toUpperCase!) or ''
  it

translate-paths = ->
  # todo: obtain relative path from .croakrc location
  unless it |> file.is-absolute 
    it = it |> path.join (config.path!local or process.cwd!), _
  it

process-value = (key, value) ->
  value = value |> replace-vars
  if <[ gruntfile npm tasks base ]>index-of(key) isnt -1
    value = value |> translate-paths
  value

# process config values and create new config with defaults per project
config-transform = ->
  return it unless it |> _.is-object
  
  for own key, value of it when key |> is-not-template-value 
    if value |> _.is-object
      value['$project'] = key unless value['$project']
      it[key] = value |> config-transform |> apply-defaults
    else
      # save the original value (required for templating and variables)
      it["_#{key}"] = value
      it[key] = value |> process-value key, _
  it

config-write-transform = ->
  data = {}

  set-global-config = (data, key, value) ->
    data <<< { (key): value }

  can-copy = (config, key, value, orig-value) ->
    if "_#{key}" |> config.has-own-property
      if (value isnt false  and value?) or value is orig-value
        yes

  for own project, options of it when options?
    # global config
    if options |> _.is-string
      if project |> is-global-config-value
        data |> set-global-config _, project, options
    # project config
    else if options |> _.is-object
      project = data[project] = {}
      for own key, value of options when key |> is-not-template-value
        orig-value = options["_#{key}"]
        if value |> can-copy options, key, _, orig-value
          project[key] = orig-value if orig-value?
  data

encode-config = ->
  it |> config-write-transform |> ini.stringify

has-data = ->
  if it |> _.is-object then Object.keys it .length >= 1 else no

get-first-member = ->
  if it? and it |> has-data 
    for own name, data of it when data |> has-data
      return data

