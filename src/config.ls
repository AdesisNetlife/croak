fs = require 'fs'
path = require 'path'
{ home } = require './common'

module.exports =
  file: path.join home, '.croakrc'

  read: ->
    return no unless fs.existsSync @file
    
    try
      config = JSON.parse fs.readFileSync @file
    catch { message }
      console.error 'Cannot parse .croakrc as JSON:', message
      return no

    config

  getProject: (name) ->
    config = @read()

    if config?.projects?
      project = config.projects[name]
      if project?.path?
        project.path = path.normalize project.path

    project
