require! {
  program: commander
  prompt: '../prompt'
  config: '../config'
  util: '../common'
  async: '../modules'.async
}
{ echo, exit } = require '../common'

program
  .command 'config <action> [key] [value]'
    ..description '\n  Read/write/update/remove croak config'
    ..option '--force', 'Force the command execution'
    ..option '-p, --project', 'Specifies the project to run'
    ..option '-x, --gruntfile <path>', 'Specifies the Gruntfile path'
    ..option '-g, --global [path]', 'Use the global config file'
    ..option '-c, --croakrc [path]', 'Use a custom .croakrc file path'
    ..usage '[create|list|remove|set|get]'
    ..on '--help', ->
      echo '''
            Usage examples:

              $ croak config list
              $ croak config create
              $ croak config remove project
              $ croak config remove project.force
              $ croak config set project.gruntfile /home/user/projects/my-project
              $ croak config get -g project.gruntfile
          
    '''
    ..action ->
      unless commands[it]
        "#{it} command not supported. Use --help to see the available commands" |> exit 1
      
      commands[it]apply commands, (Array::slice.call &)slice 1

# alias to config create
program
  .command 'create [key] [value]'
    ..description '\n  Creates a new .croakrc file'
    ..option '--force', 'Force the command execution'
    ..option '-p, --project', 'Specifies the project to run'
    ..option '-x, --gruntfile <path>', 'Specifies the Gruntfile path'
    ..option '-g, --global [path]', 'Use the global config file'
    ..option '-c, --croakrc [path]', 'Use a custom .croakrc file path'
    ..on '--help', ->
      echo '''
            Usage examples:

              $ croak config create
              $ croak config create -g -p my-project --gruntfile path/to/Gruntfile.js
          
    '''
    ..action ->
      commands.create.apply commands, &

commands = 

  list: (key, value, options) ->
    { croakrc, global } = options.parent
    global-flag = global
    config.local-path = croakrc if croakrc
    
    { global, local } = config.raw!
    echo """
      ; global #{global.path}
      #{global.data}
    """ if global.data?
    echo """
      ; local #{local.path}
      #{local.data}
    """ if local.data? and not global-flag

  show: -> @list ...

  create: (key, value, options) ->
    { gruntfile, project, parent } = options
    { global, croakrc, force } = parent

    type = if global then 'global' else 'local'

    try
      config.load croakrc
    catch { message }
      "Cannot read .croakrc: #{message}" |> exit 1

    data = {}
    project = null

    croakrc := config["#{type}File"]! unless croakrc

    unless croakrc |> util.file.exists
      ".croakrc will be created in: #{croakrc}" |> echo

    # prompt stepts
    enter-project = (done) ->
      prompt "Enter the project name:", (err, it) ->
        project := data[it] = {}
        if (it |> config.project) and not force
          "Project '#{it}' already exists. Use --force to override it" |> exit 1
        done!

    enter-gruntfile = (done) ->
      prompt "Enter the Gruntfile path (e.g: ${HOME}/project/Gruntfile.js):", (err, it) ->
        project.gruntfile = it
        done!

    enter-override = (done) ->
      return done! if global
      prompt "Enable overwriting tasks? [Y/n]:", 'confirm', (err, it) ->
        project.overwrite = it
        done!

    enter-extend = (done) ->
      return done! if global
      prompt "Enable extending tasks? [Y/n]:", 'confirm', (err, it) ->
        project.extend = it
        done!
    
    save = ->
      data |> config.set _, global

      try 
        config.write!
        config.load!
      catch { message }
        "Cannot create the file: #{message}" |> exit 1

      echo ".croakrc created successfully"
      exit 1

    if gruntfile and project
      project := data[it] = {}
      project <<< { gruntfile }
      save!
    else
      async.series [
        enter-project
        enter-gruntfile
        enter-override
        enter-extend
        save
      ]

  add: -> @create ...

  remove: (key, value, options) ->
    "Missing required 'key' argument" |> exit 1 unless key
    { global, croakrc } = options.parent
    
    try 
      config.load croakrc
      if config.remove key
        config.write!
        "Config '#{key}' value removed successfully" |> echo
      else 
        throw new Error 'value do not exists'
    catch { message }
      "Cannot delete '#{key}' due to an error: #{message}" |> exit 1

  get: (key, value, options) ->
    "Missing required 'key' argument" |> exit 1 unless key

    { croakrc } = options.parent

    try
      config.load croakrc
    catch { message }
      "Cannot read .croakrc: #{message}" |> exit 1

    if value := config.get key.to-lower-case!
      if typeof value is 'string'
        value |> echo
      else
        for own prop, data of value
          "#{prop}: #{data}" |> echo
    else
      "Config '#{key}' value not exists" |> exit 1

  set: (key, value, options) ->
    "Missing required 'key' argument" |> exit 1 unless key
    "Missing required 'value' argument" |> exit 1 unless value

    { croakrc, global } = options.parent

    try
      config.load croakrc
    catch { message }
      "Cannot read .croakrc: #{message}" |> exit 1

    if value := config.set-key key, value, global
      try 
        config.write!
      catch { message }
        "Cannot save config due to an error: #{message}" |> exit 1
      
      "Value '#{key}' updated successfully" |> echo
    else
      "Cannot set '#{key}' value. Project '#{key.split('.')[0]}' do not exists" |> exit 1

