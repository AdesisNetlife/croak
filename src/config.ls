require! {
  ini
  path
  requireg
  _: 'lodash'
  defaults: './config-defaults'
}
{ CONFVAR, FILENAME } = require './constants'
{ file }:util = require './common'

const global-options = <[ $default ]>
local-path = null

module.exports = config =

  # config store
  config: {}
  global: null
  local: null

  clean: ->
    @global = null
    @local = null
    @config = {}

  apply: ->
    @config
    |> _.extend _, @global
    |> _.extend _, @local

  load: (local-path) ->
    global-config-path = @global-file!
    local-config-path = local-path |> @local-file

    add-filepath-to-config = (config, filepath) ->
      if (config |> _.is-object) and filepath
        config <<< { $path: filepath }
        config <<< { $dirname: filepath |> path.dirname }

    if global = global-config-path |> read-config-file
      @global = global if global |> has-data
      global-config-path |> add-filepath-to-config global, _ |> config-transform _
    if local = local-config-path |> read-config-file
      if local |> has-data
        @local = local
        local-config-path |> add-filepath-to-config local, _ |> config-transform _, 'local'
    @apply!

  write: (local-path) ->
    for type in <[ global local ]>
      when @[type] |> has-data
      then
        (@[type] |> encode-config)
          |> file.write (@[type].$path or @["#{type}File"] local-path), _

  save: ->
    @write ...

  raw: ->
    config = {}
    <[ global local ]>forEach ~>
      data = config[it] = {}
      data <<< path: @["#{it}File"]!
      data <<< data: data.path |> file.read if data.path |> file.exists
    config

  get-default: ->
    if @local?.$default |> @exists
      @local.$default |> @get
    else if @global?.$default |> @exists
      @global.$default |> @get
    else if @local |> has-data
      @local |> get-first-member
    else
      null

  get-default-project: ->
    @get-default ...

  update: (project, data, local = false) ->
    if @config[project] and data |> has-data
      context = if local then 'local' else 'global'
      @[context] ?= {}
      data := @[context][project] |> _.extend _, (data |> config-transform)
      @apply!
    data

  get: (key) ->
    return @config |> _.clone-deep unless key |> _.is-string

    [ project, key ] = key.split '.'
    if project := @config[project]
      if key
        if "_#{key}" |> project.has-own-property
          project["_#{key}"]
        else
          null
      else
        project |> get-config-tmpl-values
    else
      null

  set: (key, value, local = false) ->
    context = if local then 'local' else 'global'
    { set-object, set-value } = context |> set-config @, _

    if key |> _.is-plain-object
      key |> set-object
      value := key
    else if key |> _.is-string
      value |> set-value key, _
    else
      value := null

    @apply!
    value

  set-local: (key, value) ->
    value |> @set key, _, true

  value: (key, value, local = false) ->
    if value?
      @set ...
    else
      @get ...

  remove: (key) ->
    return no unless (key |> _.is-string)
    [ project, option ] = key.split '.'

    if option?
      if @global?[project]?[option]?
        value = key |> @set _, null
      else if @local?[project]?[option]?
        value = key |> @set _, null, true
      @apply!
      not value?
    else
      @global?[project] &&= null
      @local?[project] &&= null
      @apply!
      not @config[project]?

  path: ->
    global: @global?.$path or @global-file!
    local: @local?.$path or @local-file!

  dirname: ->
    global: @global?.$dirname or (@global-file! |> path.dirname)
    local: @local?.$dirname or (@local-file! |> path.dirname)

  exists: ->
    it |> @config.has-own-property

  has-data: ->
    (@config |> Object.keys)length >= 1

  global-file: ->
    if config-path = it or util.env CONFVAR
      config-path := config-path |> replace-vars |> path.normalize
      if file.is-directory config-path
        config-path := config-path |> add-croakrc-file
      return config-path
    # defaults to user home directory
    util.user-home! |> add-croakrc-file

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

    # tries to discover .croakrc in the cwd
    # fall back to higher directories
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


#
# pure functions helpers
# todo: isolate them in separate modules
#

read-config-file = ->
  return null unless it |> file.exists
  it |> file.read |> ini.parse

apply-defaults = ->
  it |> _.extend (defaults |> _.clone), _

add-croakrc-file = ->
  unless (it |> new RegExp "#{CONFVAR}$" .test)
    it |> path.join _, FILENAME

is-global-config-value = ->
  it? and (it |> global-options.index-of) isnt -1 and not (it |> _.is-object)

is-not-template-value = ->
  /^\_/ isnt it and /^\$/ isnt it

get-config-tmpl-values = ->
  obj = {}
  for own key, value of it
    when not (key |> is-not-template-value)
    then obj <<< (key.slice 1): value if value?
  obj

get-config-dirname-path = ->
  config.dirname!local or config.dirname!global or process.cwd!

replace-vars = ->
  if typeof it is 'string'
    it = it.replace /\$\{(.*)\}/g, (_, variable) ->
      variable = variable?.to-upper-case!

      translate = ->
        if util.is-win32
          it = 'USERPROFILE' if it is 'HOME'
          it = 'CD' if it is 'PWD'
          it = 'HOMEDRIVE' if it is 'ROOT' or it is 'DRIVE'
        else
          it = '/' if it is 'HOMEDRIVE' or it is 'ROOT'
          it = 'PWD' if it is 'CD'
        it

      replace = ->
        it = it.to-lower-case!
        switch it
          when 'CROAKRC_PATH' then
            it = get-config-dirname-path!
          default
            it = it |> util.env
        it or ''

      variable |> translate |> replace
  it

translate-paths = ->
  # todo: support for global and local files paths
  unless it |> file.is-absolute
    it := it |> path.join get-config-dirname-path!, _
  it

resolve-node-package = ->
  # support to package path definition
  it := it |> translate-paths if /\//.test it
  # resolve node module path
  (it |> requireg.resolve) or it

# resolve for Gruntfile via package location
find-gruntfile-in-package = ->
  return null unless it
  gruntpath = null

  unless it |> util.gruntfile-match
    # search the Gruntfile in the package root directory
    # and fall back to higher directories
    [1 to 5]reduce ->
      unless gruntpath
        if filepath = it |> util.gruntfile-path
          gruntpath := filepath
        it |> path.join _, '../'
    , it

  gruntpath

process-config-value = (key, value) ->
  value := value |> replace-vars

  is-path-like-value = ->
    <[ gruntfile npm tasks base ]>index-of(it) isnt -1

  if (key |> is-path-like-value) and (value |> _.is-string)
    value := value |> translate-paths
  else if key is 'package'
    # resolve node package and discover gruntfile
    value := value |> resolve-node-package |> find-gruntfile-in-package

  value

set-config = (obj, context) ->

  set-object: ->
    if it |> has-data
      # extend or overwrite?
      obj <<< (context): it |> _.clone-deep |> config-transform
    else
      null

  set-value: (key, value) ->
    [ project, option ] = key.split '.'
    obj[context] = {} unless obj[context] |> _.is-plain-object
    value := value |> _.clone-deep if value |> _.is-object

    if project |> is-global-config-value
      obj[context] <<< (project): value
    else if not option?
      obj[context] <<< (project): value |> config-transform
    else if (project := obj[context][project])? and (project |> _.is-plain-object)
      if value |> _.is-plain-object
        value := value |> config-transform
      ((option): value) |> config-transform |> _.extend project, _
    else
      null

filter-unsupported-options = ->
  config = {}

  for own key, value of it
    when (key := key.to-lower-case!) |> defaults.has-own-property
    then config <<< (key): value

  config

# process config values as template and creates a new one with default options
config-transform = (it, type = 'global') ->
  return it unless it |> _.is-plain-object

  # process config object and adds croak internal config
  # for a better decoupling when use it
  set-object-properties = (obj, key, value) ->
    value := value |> filter-unsupported-options
    # add croak internal useful properties
    value <<< { obj.$path } unless value.$path
    value <<< { obj.$dirname } unless value.$dirname
    value <<< $project: key unless value.$project
    value <<< $type: type unless value.$type
    obj <<< (key): value |> config-transform _, type |> apply-defaults

  # save the original value (required for templating and variables)
  set-primitive-property = (obj, key, value) ->
    obj <<< "_#{key}": value
    obj <<< (key): value |> process-config-value key, _

  for own key, value of it
    when key |> is-not-template-value
    then
      if value |> _.is-object
        it |> set-object-properties _, key, value
      else
        it |> set-primitive-property _, key, value
  it

config-write-transform = ->
  data = {}

  can-write = (config, key, value, orig-value) ->
    if "_#{key}" |> config.has-own-property
      # write if the option if it is same than the original or it is not null
      if value is orig-value or (value isnt false and config["_#{key}"]?)
        yes

  set-global-config = (data, key, value) ->
    data <<< (key): value

  copy-project-config = (options) ->
    for own key, value of options
      when key |> is-not-template-value
      then
        orig-value = options["_#{key}"]
        if value |> can-write options, key, _, orig-value
          project <<< (key): orig-value if orig-value?

  for own project, options of it
    when options?
    then
      # global config
      if options |> _.is-string
        if project |> is-global-config-value
          data |> set-global-config _, project, options
      # project specific config
      else if options |> _.is-object
        project = data[project] = {}
        options |> copy-project-config

  data

encode-config = ->
  it |> config-write-transform |> ini.stringify

has-data = ->
  if it |> _.is-object then Object.keys it .length >= 1 else no

get-first-member = ->
  if it? and it |> has-data
    for own name, data of it
      when data |> has-data
      then return data

