path = require 'path'
program = require 'commander'

config = require './config'
{ grunt-file-exists, echo } = require './common'
{ version }:pkg = require '../package.json'

cwd = process.cwd()

exports.parse = (args) -> program.parse args

program
  .version(version)

program.on 'implementation', ->
  echo 'node'

program.on '--help', ->
  echo '''
      Usage examples:
    
        $ croak create --path /home/user/
        $ croak add

      Command specific help:

        $ croak <command> --help

  '''

program
  .command('config <action> [project] [key] [value]')
  .description('\n  Read/write croak config files'.cyan)
  .usage('[create|list|delete|set|get]'.cyan)
  .option('-g, --global', 'Edit the global file located in user $HOME'.cyan)
  .on('--help', ->
    echo '''
          Usage examples:

            $ croak config list
            $ croak config delete myProject
            $ croak config set my-project path /home/user/projects/my-project
            $ croak config get my-project path
        
    '''
  )
  .action (action, project, key, value, options) ->
    console.log arguments
    exit 0

program
  .command('run <task>')
  .description('\n  Read files'.cyan)
  .usage('[list|delete|set|get]'.cyan)
  .option('-p, --project', 'Specifies the project to run'.cyan)
  .on('--help', ->
    echo '''
          Usage examples:

            $ croak run server
            $ croak run test -p myProject
        
    '''
  )
  .action (task, options) ->
    console.log task
    exit 0

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
  process.chdir(project.path)

  # mixin grunt object with croak
  grunt.croak = 
    base: path.normalize(process.cwd())
    cwd: path.normalize(cwd)

  # add specific options avaliable from config
  grunt.config.set('croak', {
    base: path.normalize(process.cwd()),
    cwd: path.normalize(cwd)
  })

  # init grunt
  grunt.cli()
