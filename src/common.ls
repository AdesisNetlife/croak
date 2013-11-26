path = require 'path'
fs = require 'fs'
env = process.env

module.exports = class Common

  @env = (key) ->
    env[key] or null

  @home = do ->
    path.normalize env[(if process.platform is 'win32' then 'USERPROFILE' else 'HOME')] or ''

  @file-exists = (filepath, filename = '') ->
    fs.existsSync path.join filepath, filename

  @grunt-file-exists = (filepath) ->
    if /Gruntfile.(js|coffee)$/i.test filepath
      @file-exists filepath
    else
      @file-exists filepath, 'Gruntfile.js' or @file-exists filepath, 'Gruntfile.coffee'
 