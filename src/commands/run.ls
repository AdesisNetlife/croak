require! {
  program: commander
  config: '../config'
}
{ echo, exit } = require '../common'

program
  .command 'run <task>'
    ..description '\n  Run Grunt tasks'.cyan
    ..usage 'my-project test'.cyan
    ..option '-p, --project', 'Specifies the project to run'.cyan
    ..option '-c, --croakrc <path>', 'Use a custom .croakrc file path'.cyan
    ..option '-x, --grunt', 'Specifies the Gruntfile path'.cyan
    ..on '--help', ->
      echo '''
            Usage examples:

              $ croak run build
              $ croak run test -p my-project
              $ croak run test -x /path/to/Gruntfile.js
          
      '''
    ..action -> run ...
    
run = (task, options) ->
  { croakrc } = options

  config.load croakrc
  

