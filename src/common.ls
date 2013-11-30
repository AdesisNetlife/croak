require! <[ fs path ]>
require! _: 'prelude-ls'
env = process.env

module.exports = class Common

  @env = (key) ->
    env[key] or null

  @home = path.normalize env[(if process.platform is 'win32' then 'USERPROFILE' else 'HOME')] or ''

  @file-exists = (filepath = '', filename = '') ->
    fs.exists-sync path.join filepath, filename

  @is-directory = ->
    fs.lstat-sync(it).isDirectory!

  @file-read = -> 
    fs.read-file-sync it, 'utf8'

  @file-delete = ->
    fs.unlink-sync it

  @file-write = (filepath, data) -> fs.write-file-sync filepath, data, encoding: 'utf8'

  @grunt-file-exists = (filepath) ~>
    if /Gruntfile.(js|coffee)$/i.test filepath
      @file-exists filepath
    else
      @file-exists filepath, 'Gruntfile.js' or @file-exists filepath, 'Gruntfile.coffee'

  @extend = (target = {}, src) ->
    return target unless _.is-type 'Object', src
    for own prop, value of src when value?
      target[prop] = value
    target

  @clone = ~>
    @extend {}, it

  @echo = ->
    console.log ...
