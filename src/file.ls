require! {
  fs
  path
  grunt
  _: lodash
}

module.exports = _.extend {}, grunt.file,

  is-absolute: grunt.file.is-path-absolute

  exists: (filepath, filename = '') ->
    if filepath? and (filepath |> _.is-string)
      (filename |> path.join filepath, _) |> fs.exists-sync
    else
      no

  is-directory: -> fs.lstat-sync(it).isDirectory!

  delete: -> it |> fs.unlink-sync

  read: ->
    if @exists it and not @is-directory it
      fs.read-file-sync it, if is-node8 then 'utf8' else encoding: 'utf8'
    else
      ''

  write: (filepath, data) ->
    if filepath |> path.dirname |> @is-directory
      data |> fs.write-file-sync filepath, _, if is-node8 then 'utf8' else encoding: 'utf8'

  absolute-path: (relative, absolute = process.cwd!) ->
    relative |> path.join absolute, _

  make-absolute: ->
    return it unless it
    if it |> @is-absolute
      it
    else
      @absolute-path ...

is-node8 = not not (/^0\.8\./ is process.versions.node)
