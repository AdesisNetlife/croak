require! {
  colors
  './croak'
  './common'.echo
  program: commander
}

const version = "croak #{croak.version}\ngrunt #{croak.grunt-version}"

exports.parse = (args) -> program.parse args

program
  .version version

program.on 'grunt', ->
  croak.init-grunt ...

program.on '--help', help = ->
  echo '''
    Usage examples:

      $ croak init [name]
      $ croak add [name]
      $ croak config [create|list|get|set|remove]
      $ croak run task
      $ croak grunt task

    Command specific help:

      $ croak <command> --help

    Grunt help:

      $ croak grunt --help
  .
  '''

program.command 'help' .action help
  ..description '\n  Output the usage information'

program.command 'version' .action (-> version |> echo)
  ..description '\n  Output the version information'

# load CLI commands
module <- <[ config run init add ]>for-each
require "./commands/#{module}"
