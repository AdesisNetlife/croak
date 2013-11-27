fs = require 'fs'
path = require 'path'
ini = require 'ini'
{ extend } = require 'lodash'
{ CONF-VAR, FILENAME } = require './constants'
{ home, file-exist, env } = require './common'

module.exports = class Config

  config: {}

  (file = Config.globalFile) ->
    @file = file

  exists: ->
    fs.exists-sync @file

  read: (filepath = @file) ->
    return null unless fs.exists-sync filepath
    
    try
      config = ini.parse fs.read-file-sync filepath
    catch { message }
      console.error "Cannot parse #{FILENAME} as valid ini:", message
      return null

    config

  load: ->
    [ Config.globalFile, Config.localFile ]forEach (file) ~>
      if confData = @read file
        extend @config, confData

  get-project: (name) ->
    config = @read()

    if config?.projects?
      project = config.projects[name]
      if project?.path?
        project.path = path.normalize project.path

    project

  @globalFile = do ->
    config-path = do ->
      if config = env[CONF-VAR]
        if file-exist config = path.normalize config
          config

    config-path or path.join home, FILENAME

  @localFile = path.join process.cwd(), FILENAME