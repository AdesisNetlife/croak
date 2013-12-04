require! {
  program: commander
  prompt: '../prompt'
  config: '../config'
  util: '../common'
  async: '../import'.async
}
{ echo, exit } = require '../common'

program
  .command 'config <action> [key] [value]'
    ..description '\n  Read/write/update/remove croak config'
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
              $ croak config set project.gruntfile /home/user/projects/my-project
              $ croak config get -g project.gruntfile
          
    '''
    ..action ->
      unless commands[it]
        "#{it} command not supported. Use --help to see the available commands" |> exit 1
      
      commands[it]apply commands, (Array::slice.call &)slice 1

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

    if global and croakrc?
      croakrc := config.global-file!

    try
      config.load croakrc
    catch { message }
      "Cannot read .croakrc: #{message}" |> exit 1

    data = {}
    project = null

    enter-project = (done) ->
      prompt "Enter the project name:", (err, it) ->
        project := data[it] = {}
        if (it |> config.project) and not force
          "Project '#{project}' already exists. Use --force to override it" |> exit 1
        done!

    enter-gruntfile = (done) ->
      prompt "Enter the Gruntfile path (e.g: ${HOME}/project/Gruntfile.js):", (err, it) ->
        project.gruntfile = it
        done!

    enter-override = (done) ->
      return done! unless global
      prompt "Enable overwriting tasks? [Y/n]:", 'confirm', (err, it) ->
        project.overwrite = it
        done!

    enter-extend = (done) ->
      return done! unless global
      prompt "Enable extending tasks? [Y/n]:", 'confirm', (err, it) ->
        project.extend = it
        done!
    
    save = ->
      type = if global then 'global' else 'local'

      data |> config.set _, type
      try 
        config.write!
        config.load!
      catch { message }
        "Cannot create the file: #{message}" |> exit 1

      echo ".croakrc created successfully in:\n#{config.path![type]}"

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
    try 
      if config.delete project
        config.write!
        echo "Project '#{project}' deleted successfully"
      else 
        throw new Error 'cannot delete'
    catch { message }
      "Cannot delete #{project} due to an error: #{message}" |> exit 1
      

  set: (key, value, options) ->
    # todo

  get: (key, value, options) ->
    # todo

