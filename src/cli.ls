require! {
  path
  program: commander
  croak: './croak'
  echo: './common'.echo
}

exports.parse = (args) -> program.parse args

program
  .version "croak #{croak.version}\ngrunt #{croak.grunt-version}"
    ..option '-g, --global', 'Use the global config file'
    ..option '-c, --croakrc [path]', 'Use a custom .croakrc file path'
    ..option '-f, --force', 'Force command execution. Also will be passed to Grunt'

program.on 'grunt', ->
  croak.init-grunt!

program.on '--help', help = ->
  echo '''
      Usage examples:

        $ croak init [name]
        $ croak config [create|list|get|set|remove]
        $ croak run task -p project
        $ croak grunt task

      Command specific help:

        $ croak <command> --help

      Grunt help:

        $ croak grunt --help

  '''

program.command 'help' .action help

module <- <[ config run init ]>forEach
require "./commands/#{module}"
