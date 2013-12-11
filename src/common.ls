require! {
  fs
  path
  grunt
  _: './modules'.lodash
}

{ env } = process

module.exports = class Common

  @env = (key) ->
    env[key] or null

  @is-win32 = process.platform is 'win32'

  @home = path.normalize env[(if Common.is-win32 then 'USERPROFILE' else 'HOME')] or ''

  @gruntfile-path = (filepath) ~>
    add-gruntfile = (ext) ->
      filepath := "Gruntfile.#{ext}" |> join filepath, _

    is-not-path = ->
      /^Gruntfile/i.test it

    filepath := filepath |> @file.make-absolute
    if /Gruntfile.(js|coffee)$/i.test filepath
      filepath := "./#{filepath}" if filepath |> is-not-path
      if filepath |> @file.exists
        filepath
    else
      if ('js' |> add-gruntfile |> @file.exists) or ('coffee' |> add-gruntfile |> @file.exists)
        filepath

  @gruntfile-exists = ~>
    (it |> @gruntile-path)?

  @extend = (target = {}, src) ->
    return target unless src |> _.is-object
    for own prop, value of src
      target <<< { (prop): value }
    target

  @clone = ~>
    it |> @extend {}, _

  @echo = ->
    console.log ...

  @exit = (code) ~>
    exit = -> code |> process.exit
    if code is 0 or not code
      process.exit 0
    # if not 0, returns the partial function
    (message) ~>
      @echo (message).red if message? and code isnt 0
      exit!

  @file =
    exists: (filepath, filename = '') ->
      if filepath? and (filepath |> _.is-string)
        fs.exists-sync (filename |> join filepath, _)
      else
        no

    is-directory: ->
      fs.lstat-sync(it).isDirectory!

    read: ->
      if @exists it and not @is-directory it
        fs.read-file-sync it, if is-node8 then 'utf8' else encoding: 'utf8'
      else
        ''

    delete: ->
      it |> fs.unlink-sync

    write: (filepath, data) ->
      if filepath |> path.dirname |> @is-directory
        data |> fs.write-file-sync filepath, _, if is-node8 then 'utf8' else encoding: 'utf8'

    is-absolute: grunt.file.is-path-absolute

    absolute-path: (relative, absolute = process.cwd!) ->
      relative |> join absolute, _

    make-absolute: ->
      return it unless it
      if it |> @is-absolute
        it
      else
        @absolute-path ...


is-node8 = ->
  /^0\.8\./.test process.versions.node

join = ->
  path.join ...
