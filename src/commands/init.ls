require! {
  '../croak'
  '../prompt'
  '../modules'.async
  '../constants'.FILENAME
  program: commander
}
{ echo, exit, file } = require '../common'

program
  .command 'init [name]'
    ..description '\n  Create new projects in .croakrc'
    ..usage '[options]'
    ..option '--force', 'Force command execution'
    ..option '-x, --gruntfile <path>', 'Specifies the Gruntfile path'
    ..option '-z, --pkg <name>', 'Specifies the build node package to use'
    ..option '-g, --global', 'Creates a global config file'
    ..option '-s, --sample', 'Creates a file with a sample project config'
    ..option '-d, --usedef', 'Set the project to use by default'
    ..on '--help', ->
      echo '''
            Usage examples:

              $ croak init
              $ croak init -g
              $ croak init project --sample
              $ croak init my-project -x ../path/to/Gruntfile.js
              $ croak init -p my-project -z build-pkg -g

      '''
    ..action -> init ...

module.exports = init = (name, options) ->

  { pkg, sample, gruntfile, parent, global, force, usedef } = options

  croak.config.load!

  set-default = (name, local) ->
    name |> croak.config.set '$default', _, local

  set-config-project = (project, data, global) ->
    local = not global
    data |> croak.config.set project, _, local
    project |> set-default _, local if usedef

  get-config-path = ->
    croak.config.dirname![if global then 'global' else 'local']

  success-message = ->
    """

    #{FILENAME} created successfully in: #{get-config-path!}

    To start using Grunt via Croak, simply run:
    $ croak run task -p my-project

    Thank you for using Croak!
    """ |> echo

  write-config = ->
    try
      croak.config.write!
      success-message!
    catch { message }
      "Cannot create the file: #{message}" |> exit 1

  create-project-with-package = (project, pkg) ->
    data = {} <<< 'package': pkg
    data |> set-config-project project, _, global
    write-config!
    exit 0

  create-project-with-gruntfile = (project, gruntfile) ->
    data = {} <<< { gruntfile }
    data |> set-config-project project, _, global
    write-config!
    exit 0

  create-sample-project = ->
    create-default = ->
      project-name = name or 'name'
      data =
        gruntfile: '../path/to/Gruntfile.js'
        extend: true
        overwrite: false
        register_tasks: false
        debug: false
        stack: true
      data |> set-config-project project-name, _, global

    create-default!
    write-config!
    exit 0

  prompt-creation-process = ->
    data = {}
    project = null

    enter-project = (done) ->
      return done! if project := name
      prompt "Enter the project name:", (err, name) ->
        if (name |> croak.config.get) isnt null and not force
          "Project '#{name}' already exists. Use --force to override it" |> exit 1
        project := name
        done!

    enter-has-package = (done) ->
      prompt "The project has a node.js build package? [Y/n]:", 'confirm', (err, it) ->
        return done! unless it
        prompt "Enter the package name:", (err, it) ->
          data <<< 'package': it
          done!

    enter-gruntfile = (done) ->
      return done! if data.package
      prompt "Enter the Gruntfile path (e.g: ${HOME}/build/Gruntfile.js):", (err, it) ->
        data <<< gruntfile: it
        done!

    enter-extend = (done) ->
      return done! unless global
      prompt "Enable extend tasks? [Y/n]:", 'confirm', (err, it) ->
        data <<< extend: it
        done!

    enter-override = (done) ->
      return done! unless global
      prompt "Enable overwrite tasks? [Y/n]:", 'confirm', (err, it) ->
        data <<< overwrite: it
        done!

    enter-register-tasks = (done) ->
      return done! unless global
      prompt "Enable task registering? [Y/n]:", 'confirm', (err, it) ->
        data <<< register_tasks: it
        done!

    enter-set-default-project = (done) ->
      return done! if usedef
      prompt "Use the '#{project}' project by default? [Y/n]:", 'confirm', (err, it) ->
        usedef := it
        done!

    save = ->
      data |> set-config-project project, _, global
      write-config!
      exit 0

    async.series [
      enter-project
      enter-has-package
      enter-gruntfile
      enter-override
      enter-extend
      enter-register-tasks
      enter-set-default-project
      save
    ]

  if gruntfile and name
    name |> create-project-with-gruntfile _, gruntfile
  else if pkg and name
    name |> create-project-with-package _, pkg
  else if sample
    create-sample-project!
  else
    prompt-creation-process!
