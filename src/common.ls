path = require 'path'
fs = require 'fs'

module.exports = 
  home: path.normalize process.env[(if (process.platform is 'win32') then 'USERPROFILE' else 'HOME')] or ''

  gruntFileExists: (dir) ->
    fs.existsSync path.join dir, 'Gruntfile.js' or fs.existsSync path.join dir, 'Gruntfile.coffee'