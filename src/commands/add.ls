require! {
  './init'
  program: commander
}
{ echo, exit, file } = require '../common'

# alias to the init command
program
  .command 'add [name]'
    ..description '\n  Add new projects in .croakrc'
    ..usage '[options]'
    ..option '--force', 'Force command execution'
    ..option '-x, --gruntfile <path>', 'Specifies the Gruntfile path'
    ..option '-z, --pkg <name>', 'Specifies the build node package to use'
    ..option '-g, --global', 'Creates a global config file'
    ..option '-s, --sample', 'Creates a file with a sample project config'
    ..on '--help', ->
      echo '''
            Usage examples:

              $ croak add
              $ croak add -g
              $ croak add project --sample
              $ croak add my-project -x ../path/to/Gruntfile.js
              $ croak add -p my-project -z build-pkg -g

      '''
    ..action -> init ...
