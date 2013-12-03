require! {
  program: commander
  prompt: '../prompt'
  config: '../config'
}
{ echo, exit } = require '../common'

program
  .command 'config <action> [project] [key] [value]'
    ..description '\n  Read/write/update/remove croak config'
    ..usage '[create|list|remove|set|get]'
    ..on '--help', ->
      echo '''
            Usage examples:

              $ croak config list
              $ croak config create
              $ croak config remove project
              $ croak config set path /home/user/projects/my-project
              $ croak config get path -g -p project 
          
    '''
    ..action ->
      unless commands[it]
        "#{it} command not supported. Use --help to see the available commands" |> exit 1
      
      commands[it]apply null, (Array::slice.call &)slice 1

commands = 

  list: (project, key, value, options) ->
    
    { croakrc } = options.parent
    config.local-path = croakrc if croakrc
    
    { global, local } = config.raw!
    echo """
      ; global #{global.path}
      #{global.data}
    """ if global.data?
    echo """
      ; local #{local.path}
      #{local.data}
    """ if local.data?

  create: (project, key, value, options) ->
    'project name argument is required' |> exit 1 unless project

    if config.project project and not options.force
      "Project #{project} already exists" |> exit 1

    data = {}
    prompt "Gruntfile path (e.g: project/Gruntfile.js ):", validator: ->, ->
      data.gruntfile = it

  remove: (project, key, value, options) ->
    try 
      if config.delete project
        config.write!
        echo "Project '#{project}' deleted successfully"
      else 
        throw new Error 'cannot delete'
    catch { message }
      "Cannot delete #{project} due to an error: #{message}" |> exit 1
      

  set: (project, key, value, options) ->
    # todo

  get: (project, key, value, options) ->
    # todo

