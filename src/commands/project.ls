require! {
  program: commander
  prompt: '../prompt'
  config: '../config'
}
{ echo, exit } = require '../common'

program
  .command 'project <action>'
    ..description '\n  Create/remove projects in .croakrc files'
    ..usage '[create|remove]'
    ..on '--help', ->
      echo '''
            Usage examples:

              $ croak project create
              $ croak project remove
              $ croak project create -g
          
    '''
    ..action ->
      unless commands[it]
        "#{it} command not supported. Use --help to see the available commands" |> exit 1
      
      commands[it]apply null, (Array::slice.call &)slice 1

commands =
  # todo
  create: (action, options) -> 
  
  remove: (action, options) -> 
