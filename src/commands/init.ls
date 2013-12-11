require! {
  path
  grunt
  '../constants'.FILENAME
  program: commander
}
{ echo, exit, file } = require '../common'

program
  .command 'init [directory]'
    ..description '\n  Run Grunt tasks'
    ..usage '[options]'
    ..option '--force', 'Force command execution'
    ..on '--help', ->
      echo '''
            Usage examples:

              $ croak init

      '''
    ..action -> init ...

init = (directory = process.cwd!, options) ->

  { force } = options.parent

  croakrc-tmpl = '''
  default = project-id

  [my-project-id]
  gruntfile = ../path/to/Gruntfile
  extend = true
  overwrite = true
  register_tasks = false
  debug = false
  '''

  create-directory = ->
    it |> grunt.file.mkdir unless it |> grunt.file.exists

  write-file = ->
    it |> file.write (FILENAME |> path.join directory, _), _

  try
    # todo: ask the user about the options
    create-directory directory
    write-file croakrc-tmpl
  catch { message }
    "Cannot create the file: #{message}" |> exit 1

  "#{FILENAME} created successfully in: #{directory}" |> echo
