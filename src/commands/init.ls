require! {
  fs
  FILENAME: '../constants'
  program: commander
}
{ echo, exit } = require '../common'

program
  .command 'init'
    ..description '\n  Run Grunt tasks'
    ..usage '[options]'
    ..option '--force', 'Force command execution'
    ..on '--help', ->
      echo '''
            Usage examples:

              $ croak init
          
      '''
    ..action -> init ...
    
init = (croakfile = FILENAME, options) ->

  { force } = options.parent
  croakfile := croakfile 

  try
    fs
  catch { message }
    "Cannot create : #{message}" |> exit 1

  "Running project '#{project.$name}'..." |> echo
