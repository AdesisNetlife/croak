fs = require 'fs'
path = require 'path'
{ CONF-VAR } = require './constants'
{ home, file-exist, env } = require './common'

module.exports =

  file: do ->
    config-path! or path.join home, '.croakrc'

  read: ->
    return no unless fs.existsSync @file
    
    try
      config = JSON.parse fs.readFileSync @file
    catch { message }
      console.error 'Cannot parse .croakrc as JSON:', message
      return no

    config

  get-project: (name) ->
    config = @read()

    if config?.projects?
      project = config.projects[name]
      if project?.path?
        project.path = path.normalize project.path

    project

config-path = ->
  if config = env[CONF-VAR]
    if file-exist config = path.normalize config
      config