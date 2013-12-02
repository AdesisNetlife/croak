require! {
  program: commander
  prompt: '../prompt'
  config: '../config'
}
{ echo, exit } = require '../common'

program
  .command 'config <action> [project] [key] [value]'
    ..description '\n  Read/write/update/delete croak config'.cyan
    ..usage '[create|list|delete|set|get]'.cyan
    ..on '--help', ->
      echo '''
            Usage examples:

              $ croak config list
              $ croak config create
              $ croak config remove project
              $ croak config set path /home/user/projects/my-project
              $ croak config get path -p project -g
          
    '''
    ..action ->
      unless commands[it]
        exit 1, "#{it} command not supported. Use --help to see the available commands"
      
      commands[it]apply null, (Array::slice.call &)slice 1

commands = 

  list: ->
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
    exit 1, 'project name argument is required' unless project

    if config.project project and not options.force
      exit 1, "Project #{project} already exists"

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
      echo "Cannot delete #{project} due to an error: #{message}"
      exit 1

  set: (project, key, value, options) ->
    # todo

  get: (project, key, value, options) ->
    # todo

