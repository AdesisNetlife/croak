require! {
  path
  program: commander
  croak: './croak'
  echo: './common'.echo
}

exports.parse = (args) -> program.parse args

program
  .version "croak #{croak.version}\ngrunt #{croak.grunt-version}"
    ..option '-g, --global [path]', 'Use the global config file'
    ..option '-c, --croakrc [path]', 'Use a custom .croakrc file path'
    ..option '-f, --force', 'Force command execution. Also will be passed to Grunt'

program.on 'grunt', ->
  croak.run-grunt!

program.on '--help', help = ->
  echo '''
      Usage examples:

        $ croak config create -g /home/user/conf/.croakrc
        $ croak run test -p my-project

      Command specific help:

        $ croak <command> --help

      Grunt help:

        $ croak grunt --help

  '''

program.command 'help' .action help

module <- <[ config run ]>forEach
require "./commands/#{module}"
