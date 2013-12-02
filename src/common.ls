require! {
  fs
  path
  grunt
  _: './import'.lodash
}

env = process.env

module.exports = class Common

  @env = (key) ->
    env[key] or null

  @is-win32 = process.platform is 'win32'

  @home = path.normalize env[(if Common.is-win32 then 'USERPROFILE' else 'HOME')] or ''

  @grunt-file-exists = (filepath) ~>
    if /Gruntfile.(js|coffee)$/i.test filepath
      filepath = "./#{filepath}" if /^Gruntfile/i.test filepath
      @file.exists filepath
    else
      @file.exists filepath, 'Gruntfile.js' or @file.exists filepath, 'Gruntfile.coffee'

  @extend = (target = {}, src) ->
    return target unless _.is-object src
    for own prop, value of src
      target[prop] = value
    target

  @clone = ~>
    @extend {}, it

  @echo = ->
    console.log ...

  @exit = ~>
    @echo &1 if &1?
    process.exit it or 0

  @file =
    exists: (filepath, filename = '') ->
      if filepath? and _.is-string filepath
        fs.exists-sync path.join filepath, filename
      else
        no

    is-directory: ->
      fs.lstat-sync(it).isDirectory!

    read: ->
      if @exists it and not @is-directory it
        fs.read-file-sync it
      else
        ''

    delete: ->
      fs.unlink-sync it

    write: (filepath, data) -> 
      if @is-directory path.dirname filepath
        fs.write-file-sync filepath, data

    is-absolute: grunt.file.is-path-absolute

