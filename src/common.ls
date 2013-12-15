require! {
  fs
  path
  './file'
  _: 'lodash'
  exit: './modules'.exit
}

{ env } = process

module.exports = class common

  @env = (key) ->
    env[key] or null

  @is-win32 = process.platform is 'win32'

  @user-home = ~>
    path.normalize env[(if @is-win32 then 'USERPROFILE' else 'HOME')] or ''

  @gruntfile-match = ->
    /Gruntfile.(js|coffee)$/i.test it

  @gruntfile-path = (filepath) ~>
    add-gruntfile = (ext) ->
      filepath := "Gruntfile.#{ext}" |> path.join filepath, _

    is-not-path = ->
      /^Gruntfile/i.test it

    filepath := filepath |> @file.make-absolute
    if filepath |> @gruntfile-match
      filepath := "./#{filepath}" if filepath |> is-not-path
      if filepath |> @file.exists
        filepath
    else
      if ('js' |> add-gruntfile |> @file.exists) or ('coffee' |> add-gruntfile |> @file.exists)
        filepath

  @gruntfile-exists = ~>
    (it |> @gruntile-path)?

  @extend = _.extend

  @clone = _.clone

  @echo = ->
    console.log ...

  @exit = (code) ~>
    if code is 0 or not code
      code |> exit
    # if code is not 0, returns a partial function
    (message) ~>
      @echo (message).red if message? and code isnt 0
      code |> exit

  @file = file

