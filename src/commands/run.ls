require! {
  '../croak'
  util: '../common'
  program: commander
}
{ echo, exit } = require '../common'

program
  .command 'run [task]'
    ..description '\n  Run Grunt tasks'
    ..usage '<task> [options]'
    ..option '-p, --project <path>', 'Specifies the project to run'
    ..option '-c, --croakrc <path>', 'Use a custom .croakrc file path'
    ..option '-x, --gruntfile <path>', 'Specifies the Gruntfile path'
    ..option '-z, --pkg <name>', 'Specifies the build node package to use'
    ..option '-b, --base <path>', 'Specify an alternate base path'
    ..option '-f, --force', 'A way to force your way past warnings'
    ..option '-d, --debug', 'Enable debugging mode for tasks that support it'
    ..option '-v, --verbose', 'Verbose mode. A lot more information output'
    ..option '-t, --tasks <path>', 'Additional directory paths to scan for task and "extra" files'
    ..option '-n, --npm <path>', 'Npm-installed grunt plugins to scan for task and "extra" files'
    ..option '-w, --no-write', 'Disable writing files (dry run)'
    ..option '--no-color', 'Disable colored output'
    ..option '--stack', 'Print a stack trace when exiting with a warning or fatal error'
    ..option '--completion', 'Output shell auto-completion rules'
    ..on '--help', ->
      echo '''
            Usage examples:

              $ croak run
              $ croak run task -p my-project
              $ croak run task --verbose --force --stack
              $ croak run task --gruntfile path/to/Gruntfile.js
              $ croak run task --base path/to/base/dir/

      '''
    ..action -> run ...

run = (task, options) ->

  { gruntfile, base, debug, verbose, parent, project, croakrc } = options

  echo-debug = ->
    echo.apply null, ['>>'.green] ++ (Array::slice.call &) ++ ['\n'] if debug or verbose

  'Croak started in verbose mode'.green |> echo-debug

  try
    croak.load croakrc
  catch { message }
    "Cannot read .croakrc: #{message}" |> exit 1

  unless gruntfile
    unless project
      'Project argument not specified, trying to resolve project from croak.config...' |> echo-debug
      unless project := croak.config.get-default!
        '''
        Cannot resolve a default project, you must specify the project. Use:
        $ croak run task -p project
        ''' |> exit 1
      else
        "Config file found, using the default project '#{project.$project}'..." |> echo-debug
    else
      unless project := project |> croak.config.get
        'Project not found. Have you actually configured it?' |> exit 2

  if project and not gruntfile
    { gruntfile } = project

  unless gruntfile
    "Cannot find the Gruntfile. Missing required 'gruntfile' option" |> exit 2

  "Looking for the Gruntfile in:\n#{gruntfile}" |> echo-debug
  unless gruntfile := util.gruntfile-path gruntfile
    'Gruntfile not found. Cannot run the task' |> exit 2

  "Running project '#{project.$project}'..." |> echo-debug if project
  "Gruntfile loaded:\n#{gruntfile}" |> echo-debug

  "Running #{task or 'default'} task...".cyan |> echo-debug

  options <<< { croakrc, gruntfile, base, debug, verbose }

  project |> croak.init options, _
