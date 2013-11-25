path = require 'path'
config = require './config'
{ gruntFileExists } = require './common'
cwd = process.cwd()

exports.parse = ->
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
