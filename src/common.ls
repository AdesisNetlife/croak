require! {
  fs
  path
  './file'
  _: 'lodash'
  exit: './modules'.exit
}

{ env, platform } = process

module.exports = class common

  @file = file

  @extend = _.extend

  @clone = _.clone

  @clone-deep = _.clone-deep

  @env = (key) -> env[key] or null

  @is-win32 = platform is 'win32'

  @is-darwin = platform is 'darwin'

  @is-linux = platform is 'linux'

  @user-home = ~>
    path.normalize env[(if @is-win32 then 'USERPROFILE' else 'HOME')] or ''

  @gruntfile-match = ->
    it |> /Gruntfile.(js|coffee)$/i.test

  @gruntfile-path = (filepath) ~>
    add-gruntfile = (ext) ->
      filepath := "Gruntfile.#{ext}" |> path.join filepath, _

    is-not-path = -> it |> /^Gruntfile/i.test

    filepath := filepath |> @file.make-absolute
    if filepath |> @gruntfile-match
      filepath := "./#{filepath}" if filepath |> is-not-path
      if filepath |> @file.exists
        filepath
    else
      if ('js' |> add-gruntfile |> @file.exists) or ('coffee' |> add-gruntfile |> @file.exists)
        filepath

  @gruntfile-exists = ~> (it |> @gruntile-path)?

  @echo = -> console.log ...

  @exit = (code) ~>
    if code is 0 or not code
      code |> exit
    # if exit code is not 0, return a partial function
    (message) ~>
      if message?
        message = message.red if String::red?
        message |> @echo
      code |> exit

