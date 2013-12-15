require! {
  path
  program: commander
  croak: './croak'
  echo: './common'.echo
}

exports.parse = (args) -> program.parse args

program
  .version "croak #{croak.version}\ngrunt #{croak.grunt-version}"

program.on 'grunt', ->
  croak.init-grunt!

program.on '--help', help = ->
  echo '''
      Usage examples:

        $ croak init [name]
        $ croak add [name]
        $ croak config [create|list|get|set|remove]
        $ croak run task -p project
        $ croak grunt task

      Command specific help:

        $ croak <command> --help

      Grunt help:

        $ croak grunt --help

  '''

program.command 'help' .action help

# load commands
module <- <[ config run init add ]>forEach
require "./commands/#{module}"
