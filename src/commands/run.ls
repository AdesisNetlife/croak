require! {
  program: commander
  croak: '../croak'
  util: '../common'
  config: '../config'
}
{ echo, exit } = require '../common'

program
  .command 'run <task>'
    ..description '\n  Run Grunt tasks'.cyan
    ..usage 'my-project test'.cyan
    ..option '-p, --project <path>', 'Specifies the project to run'.cyan
    ..option '-c, --croakrc <path>', 'Use a custom .croakrc file path'.cyan
    ..option '-x, --gruntfile <path>', 'Specifies the Gruntfile path'.cyan
    ..option '-b, --base <path>', 'Specify an alternate base path. By default, all file paths are relative to the Gruntfile'.cyan
    ..option '-f, --force', 'A way to force your way past warnings'.cyan
    ..option '-d, --debug', 'Enable debugging mode for tasks that support it'.cyan
    ..option '-v, --verbose', 'Verbose mode. A lot more information output'.cyan
    ..option '--no-color', 'Disable colored output'.cyan
    ..option '--stack', 'Print a stack trace when exiting with a warning or fatal error'.cyan
    ..option '-t, --tasks <path>', 'Additional directory paths to scan for task and "extra" files'.cyan
    ..option '-n, --npm <path>', 'Npm-installed grunt plugins to scan for task and "extra" files'.cyan
    ..option '-s, --no-write', 'Disable writing files (dry run)'.cyan
    ..option '--completion', 'Output shell auto-completion rules'.cyan
    ..on '--help', ->
      echo '''
            Usage examples:

              $ croak run build
              $ croak run test my-project
              $ croak run test -x path/to/Gruntfile.js
          
      '''
    ..action -> run ...
    
run = (task, options) ->

  { croakrc, gruntfile, base } = options
  project = options.project if options.project

  try
    config.load croakrc
  catch { message } 
    exit 1, "Cannot read .croakrc: #{message}".red

  unless gruntfile
    unless project
      unless project := config.project-resolve!
        exit 1, "Missing required 'project' argument".red
    else
      unless project := config.get project
        exit 1, "Project not found. Have you actually configured it?".red

  if project
    { gruntfile } = project

  unless gruntfile
    exit 2, "Cannot find the Gruntfile. Missing required 'gruntfile' config option".red
  
  unless util.grunt-file-exists gruntfile
    exit 2, "Cannot run task. Gruntfile not found. Looking in:\n#{gruntfile}".red

  croak.init project, options

  