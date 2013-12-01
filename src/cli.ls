require! {
  path
  grunt
  program: commander
  pkg: '../package.json'
  echo: './common'.echo
}

exports.parse = (args) -> program.parse args

program
  .version "Croak: #{pkg.version}\nGrunt: #{grunt.version}"
    ..option '-g, --global', 'Use the global config file'.cyan
    ..option '-c, --config', 'Use a custom .croakrc file path'.cyan
    ..option '-f, --force', 'Force command execution. Also will be passed to Grunt'.cyan

program.on 'grunt', ->
  grunt.cli!

program.on '--help', ->
  echo '''
      Usage examples:
    
        $ croak create --config /home/user/conf/.croakrc
        $ croak add

      Command specific help:

        $ croak <command> --help

  '''

module <- <[ config run ]>forEach
require "./commands/#{module}"

test = ->

  projectId = process.argv[2]
  process.argv.splice 2, 1

  unless projectId
    console.error 'First argument with project identifier is required'
    process.exit 1

  try
    grunt = require 'grunt'
  catch 
    console.error 'Unable to find grunt', 99
    process.exit 99

  project = config.getProject(projectId)

  unless project
    console.error "Project #{projectId} not configured"
    process.exit 99

  unless gruntFileExists project.path
    console.error "Gruntfile not found in project path: #{project.path}"
    process.exit 99

  # change current working directory
  process.chdir project.path

  # mixin grunt object with croak
  grunt.croak = 
    base: path.normalize process.cwd!
    cwd: path.normalize cwd

  # add specific options avaliable from config
  grunt.config.set 'croak', do
    base: path.normalize process.cwd! 
    cwd: path.normalize cwd

  # init grunt
  grunt.cli!
