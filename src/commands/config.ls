require! {
  './init'
  '../prompt'
  '../croak'
  '../modules'.async
  program: commander
}
{ echo, exit } = require '../common'

program
  .command 'config <action> [key] [value]'
    ..description '\n  Read/write/update/remove croak config'
    ..option '--force', 'Force the command execution'
    ..option '-p, --project', 'Specifies the project to run'
    ..option '-x, --gruntfile <path>', 'Specifies the Gruntfile path'
    ..option '-z, --pkg <name>', 'Specifies the build node package to use'
    ..option '-g, --global [path]', 'Use the global config file'
    ..option '-c, --croakrc [path]', 'Use a custom .croakrc file path'
    ..usage '[create|list|remove|set|get]'
    ..on '--help', ->
      echo '''
            Usage examples:

              $ croak config list
              $ croak config create
              $ croak config remove project
              $ croak config get -g project.gruntfile
              $ croak config set project.gruntfile ${HOME}/builder/Gruntfile.js

      '''
    ..action ->
      unless commands[it]
        "#{it} command not supported. Use --help to see the available commands" |> exit 1

      commands[it]apply commands, (Array::slice.call &)slice 1

const commands =

  list: (key, value, options) ->
    { croakrc, global } = options
    global-flag = global
    croak.config.local-path = croakrc if croakrc

    { global, local } = croak.config.raw!
    echo """
      ; global #{global.path}
      #{global.data}
    """ if global.data?
    echo """
      ; local #{local.path}
      #{local.data}
    """ if local.data? and not global-flag

  show: -> @list ...

  raw: -> @list ...

  create: (name, value, options) ->
    name |> init _, { sample: true, options.global }

  add: -> @create ...

  remove: (key, value, options) ->
    "Missing required 'key' argument" |> exit 1 unless key

    { croakrc } = options
    croakrc |> load-config

    try
      croak.config.remove key
      croak.config.write!
      "'#{key}' was removed successfully from config" |> echo
    catch { message }
      "Cannot delete '#{key}' due to an error: #{message}" |> exit 1

  delete: -> @remove ...

  get: (key, value, options) ->
    "Missing required 'key' argument" |> exit 1 unless key

    { croakrc } = options
    croakrc |> load-config

    if value := croak.config.get key.to-lower-case!
      if typeof value is 'string'
        value |> echo
      else
        for own prop, data of value
          then "#{prop}: #{data}" |> echo
    else
      "Config '#{key}' value do not exists" |> exit 1

  set: (key, value, options) ->
    "Missing required 'key' argument" |> exit 1 unless key
    "Missing required 'value' argument" |> exit 1 unless value

    { croakrc, global } = options
    croakrc |> load-config

    if value := croak.config.set key, value, not global
      try
        croak.config.write!
      catch { message }
        "Cannot save config due to an error: #{message}" |> exit 1

      "Value '#{key}' updated successfully" |> echo
    else
      "Cannot set '#{key}'. Project '#{key.split('.')[0]}' do not exists or it is an invalid option" |> exit 1

load-config = ->
  try
    croak.config.load it
  catch { message }
    "Cannot read .croakrc: #{message}" |> exit 1
