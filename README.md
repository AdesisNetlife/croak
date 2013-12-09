# Croak [![Build Status](https://secure.travis-ci.org/AdesisNetlife/croak.png?branch=master)](http://travis-ci.org/AdesisNetlife/croak) [![Dependency Status](https://gemnasium.com/adesisnetlife/croak.png)](https://gemnasium.com/adesisnetlife/croak)

> Grunt automation made easy for large projects. Save time and health with Croak

`WORK IN PROCESS!`

## About

<img align="right" height="280" src="http://oi44.tinypic.com/f3azc7.jpg" style="float: right" />

[Grunt][1] is an awesome task runner and build automation tool largely adopted for [node.js][7]

Croak is just a simple, but featured wrapper for Grunt that aims to help you to manage 
and orchestrate Grunt tasks configuration (aka Gruntfile) in large and distributed projects, 
helping you to avoid redundancy, saving time and reducing dramatically changes impact 
during the project life-cycle

Croak arises from the need to create an specific solution to abstract all the automation 
configuration stuff and allowing you to delegate responsibilities in a proper way
in your project and to the developers, without losing the desired level of control and centralization

### Features

- Centralizes your project build and automation tasks configuration
- Easily manage and orchestrates different configuration for multiple projects
- Abstract and provides more more control of your project build and automation tasks
- Extends or overwrites Grunt global tasks configuration from local config
- Provides the same Grunt API and CLI (things do not gonna change)
- Customizes Grunt options run mode from the config file (future `.gruntrc`)
- Keeps clean your repository without Grunt node packages (in front end projects cases)

### When do I NOT need it (probably)?

- When you only have one or two repositories in your project
- When you have an ultra specific grunt config on each project repository
- When you or your team do not want to spend time updating/syncronizing automation stuff across repositories
- When you do not need to centralize and (consequently) do not need to take the control
- When you have a lot of free time and you enjoy doing redudant and not too much interesting tasks
- When developers of your project... (at least one):
  - are an ultra skilled and responsible guys
  - have a lot of time to maintain its own automation tasks configuration
  - need to take full control of the automation tasks configuration

### When do I need it?

- When you want to centralize and take the control of the project build and automation configuration
- When you want to reduce the build configuration change time and impact in your project
- When your project have a considerable number of repositories (more than 3, probably)
- When your project build configuration are equal or very similar across different repositories
- When you want to keep clean each repository form node packages (that is mean of Grunt npm tasks)
- When you do NOT want to spend time doing redundant and not too much funny stuff
- When you do not want to spend mush time providing support to developers about build configuration stuff
- Or whatever is not on the 'When do I not need' list...

## Installation

It is recommended you install Croak as global package:

```shell
$ npm install -g croak
```

Then configure it:

```
$ croak config create -g
```

The process above will create a `.croakrc` file in your user home directory, like global shared config. 
See the [configuration file](#configuration-file) section for more details

## Table of Contents

- [Introduction](#introduction)
  - [How it works](#how-it-works)
  - [Example use case scenario](#example-use-case-scenario)
  - [Abstraction can be dangerous?](#abstraction-can-be-dangerous)
- [Current stage](#current-stage)
  - [Grunt support](#grunt-support)
- [Using Croak](#using-croak)
  - [Configuration file](#configuration-file)
    - [Global config](#global-config)
    - [Local config](#local-config)
    - [Available config options](#available-configuration-options)
      - [Global options](#global-options)
      - [Croak-specific](#croak-specific)
      - [Grunt-specific](#grunt-specific)
  - [Switching to Croak](#switching-to-croak)
    - [Adapting your existent Gruntfile](#adapting-your-existent-gruntfile)
    - [Use Croak from an existent Gruntfile](#use-croak-from-an-existent-gruntfile)
  - [Croakfile](#croakfile)
  - [Command-line interface](#command-line-interface)
    - [Running tasks](#running-grunt-tasks)
    - [Configuration](#configuration) 
  - [API](#api)
- [FAQ](#faq)
- [Development](#development)
- [Contributing](#contributing)
- [To Do/Wish list](#to-do-with-list)
- [Authors](#authors)
- [License](#license)

## Introduction

### How it works

In a few words, Croak allows you to have a multiple `Gruntfile` in global locations and running them using a simple project identifier, also allowing you to define a pre-configured options to pass to Grunt in a simple configuration file

Croak also allows your to extend or overwrite Gruntfile configurations. This feature is useful when you think that your developers are not bad people, so you can provide a way to customize tasks configuration

### Example use case scenario

A representative scenario could be, for example, that your project has a relevant 
number of repositories. Each repository needs its automation configuration 
for development, testing or building stuff.

Usually, this configuration tends to grow when your repository has an amount of different tasks and 
this configuration also tends to be very similar or redundant 
across different repositories in your project

Continuous changing and improvement is a constant in any software project, so using Croak you can 
reduce dramatically your project automation configuration changing time by centralizing it

You can see a complete example project structure using Croak [here][6]

### Abstraction can be dangerous?

Abstraction is not always the best choice and some people can hate it.
Basically, an abstraction in software development tries to reduce notably the complexity, 
underlying details and gives more control

With Croak you can provide an ideal level of abstraction to developers without losing the control and
aditionally, providing a way freedom to developers who need specific configuration to his needs

## Current stage

Croak is an initial version ready to use, however is under active (re-)designing process 
and important changes can be applied in a near future version (but minor versions, do not worry about it)

#### Grunt support

Croak supports Grunt `~0.4.0`

## Using Croak

### Configuration file

Croak uses disk files to persistent store the configuration
The Croak configuration file must called `.croakrc`

Croak supports two types of configuration files 

#### Global config

A global file can store the configuration of your projects and this configuration will be used in each Croak execution

By default it will be located in `$HOME` or `%USERPROFILE%` directories, but you can define an environment variables called `CROAKRC` to specify a custom global file location

#### Local config

Local file can be located in any path, but it is recommended that you create it in your project or repository root folder

Usually, a local file should have only one project configured. Any local configuration will overwrite a global configuration (for example, if you have the same project configured in both files)

Croak implements a similar file discovery algorithm like the one Grunt uses to discover the Gruntfile

### Available configuration options

#### Global config

| Name           | Type      | Default     | Description                                    |
| -------------- | --------- | ----------- | ---------------------------------------------- |
| default        | `string`  | undefined   | Default project to use when no project is defined |
| project        | `string`  | undefined   | Alias to `default`, just for a semantic association |

#### Per-project config

##### Croak-specific

| Name           | Type      | Default     | Description                                    |
| -------------- | --------- | ----------- | ---------------------------------------------- |
| package        | `string`  | undefined   | Node package which contains the Gruntfile, it will be resolved locally and globally. It is a recommended alternative to the `gruntfile` option |
| extend         | `boolean` | false       | Enable extend existent tasks from Croakfile |
| overwrite      | `boolean` | false       | Enable overwrite existent tasks from Croakfile |
| register_tasks | `boolean` | false       | Enable register/create new tasks from Croakfile |
| cwd            | `string`  | ${PWD}      | Working directory to pass to Grunfile. Default to ${PWD} or local `.croakrc` path. Don't use this option unless you know what you are doing |

##### Grunt-specific

The following options will be (probably) available in Grunt on future versions in `.gruntrc` file,
however Croak now supports them

| Name           | Type      | Default     | Description                                    |
| -------------- | --------- | ----------- | ---------------------------------------------- |
| gruntfile      | `string`  | undefined   | Path to your build Gruntfile. It can be a relative path. You should define this option in all of your projects |
| base           | `string`  | undefined   | Specify an alternate base path. By default, all file paths are relative to the Gruntfile |
| no_color       | `boolean` | false       | Disable colored output |
| debug          | `boolean` | false       | Enable debugging mode for tasks that support it |
| stack          | `boolean` | false       | Print a stack trace when exiting with a warning or fatal error |
| force          | `boolean` | false       | A way to force your way past warnings. Do not use this option, fix your code |
| tasks          | `string`  | undefined   | Additional directory paths to scan for task and "extra" files |
| npm            | `string`  | undefined   | Npm-installed grunt plugins to scan for task and "extra" files |
| no_write       | `boolean` | false       | Disable writing files (dry run) |
| verbose        | `boolean` | false       | Verbose mode. A lot more information output |


You can use any of the config options also as command line flag. See the Grunt CLI [documentation][1]

##### Example file configuration

A multi-project `.croakrc` configuration file

```ini
default = super-project

[super-project]
extend = true
gruntfile = ${HOME}/projects/super-project/build/Gruntfile.coffee
debug = true
stack = true

[my-project]
extend = true
overwrite = true
register_tasks = true
;; grunt-specific
gruntfile = ${HOME}/projects/my-project/build/Gruntfile.js
base = ${HOME}/projects/my-project/my-package/
no_color = false
no_write = false
debug = false
verbose = false
force = true
stack = true
tasks = ../custom-tasks/
npm = mytask
```

You can use environment variables config values, using the `${VARIABLE_NAME}` notation

##### Note aboute cross-OS variables

In order to use the same config values across diferent OS, Croak will transparently translate
common environment variables to the specific running OS

For example, if your use `${HOME}`, Croak will translate it into `%USERPROFILE%` under Windows.
The same case is applied for `${PWD}` and `%HOMEDRIVE%`, translating this last one into `/` under Unix-like OS

##### Built-in Croak variables

Aditionally, Croak introduces support for an easy way to use relative paths from Croak-specific files locations, 
like the `.croakrc` config file path or `Croakfile`

| Variable       | Value |      
| -------------- | ------------------------------------------------- |
| CROAKRC_PATH   | Absolute path to the `.croakrc` local file. If it not exists, ${PWD} will be used instead |
| CROAKFILE_PATH | Absolute path to the used `Croakfile`. If it not exists, ${PWD} will be used instead |
| GRUNTFILE_PATH | Absolute path to the used `Gruntfile`. If it not exists, ${PWD} will be used instead |

## Switching to Croak

### Adapting your existent Gruntfile

Croak will automatically exposes the croak object in Gruntfile, so you can use this 
configuration like template values in your tasks config

This is really useful because, in much cases, you need to use absolute paths in your Gruntfile

**Croak grunt object**

The following properties will be available:

- cwd `Absolute path to the user working directory when Croak is called`
- root `Alias to cwd`
- version `Current Croak version`
- base `Grunt base path configured` [optional]
- npm `Grunt npm load packages` [optional]
- tasks `Grunt tasks load path` [optional]

The above properties will be also available from `grunt.croak`

**Example Gruntfile**

```js
module.exports = function (grunt) {
  if (grunt.croak) {
    console.log('Running Grunt from Croak', grunt.croak.version);
  }

  grunt.initConfig({
    clean: {
      options: {
        force: true
      },
      views: '<%= croak.cwd %>/tmpl/'
      tmp: '<%= croak.cwd %>/.tmp/'
    },
    jshint: {
      options: {
        jshintrc: '.jshintrc'
      },
      all: [
        '<%= croak.cwd %>/src/scripts/{,*/}*.js'
        '<%= croak.cwd %>/demo/{,*/}*.js'
        '!<%= croak.cwd %>/src/scripts/vendor/*.js'
      ] 
    },
    connect: {
      server: {
        options: {
          port: 9001,
          base: '<%= croak.cwd %>'
        }
      }
    }
  });
};
```

#### Use Croak from an existent Gruntfile

If you already have `Gruntfile.js` in each local repository of your project and you do not want to switch
radically to Croak, you can use the `grunt-croak` task to make a less configuration impact
with the same result

##### Install the task

```
$ npm install grunt-croak --save-dev
```

##### Configute it in Gruntfile

```
grunt.loadNpmTasks('grunt-croak')

grunt.initConfig({
  croak: {
    my_project: {
      options: {
        gruntfile: 'path/to/Gruntfile.js',
        verbose: true
      }
    }
  } 
})
```

For more information, see the [grunt-croak][2] documentation

### Croakfile

Like Grunt, Croak has its own specific configuration file

`Currently under designing process...`

```coffee
module.exports = (croak) ->
  
  if croak.taskSupported 'uglify'
    croak.registerTask 'js-minification', [ 'clean', 'uglify' ] 

  config: (croak, grunt) ->
    croak.extend 'uglify', {
      options: 
        sourceMaps: true
      minify: 
        files: 
          src: ['**/*.js']
          dest: '<%= croak.cwd %>/test'
    }

    croak.set 'jshint', {
      options: 
        node: true
      sources: 
        files: 
          src: ['**/*.js']
          dest: '<%= croak.cwd %>/test'
    }

```

#### Croakfile API

`TODO`

### Command-line interface
 
```
Usage: croak [options] [command]

Commands:

  config <action> [project] [key] [value] 
    Read/write/update/delete croak config
  run [options] <task>   
    Run Grunt tasks

Options:

  -h, --help           output usage information
  -V, --version        output the version number
  -g, --global <path>  Use the global config file
  -f, --force          Force command execution. Also will be passed to Grunt

Usage examples:

  $ croak config create -g /home/user/conf/.croakrc
  $ croak run test -p my-project

Command specific help:

  $ croak <command> --help

```

#### Running Grunt tasks

```
$ croak run task -p my-project
```
You need to pass the `-p` flag if there not exist a `.croakrc` local config file

You can configure the default project to use from a local config file, like this:
```ini
default = my-project
```
Then you can simply run:
```
$ croak run task
```

#### Configuration

Show the current existent config
```
$ croak config list
```

Create a config file (add `-g` flag to create it globally)
```
$ croak config create
```

You can CRUD config values easily from CLI
```
$ croak config [set|get|remove] <key> [value] [-g, -p <project>]
```

### API

`TODO`

## FAQ

**Do I need to have Grunt already installed?**

No, Croak will do it for you. And also 
`grunt-cli` will be replaced by Croak CLI

**Can I use the Grunt CLI**

Of course, it is avaliable using the `grunt` command

```
$ croak grunt --help
```

**Do I need to have a Gruntfile in my repository?**

No. An already existent Gruntfile is not required.

You only need to specify the global Gruntfile you want to use 
and optionally you can use a Croakfile to overwrite or extend global configuration

**Can I use both Croak and Grunt at the same time?**

Yes. You must specify a global Gruntfile and also have your own repository Gruntfile.

You can run both like this:

```
$ croak run task -p project
```
```
$ croak grunt localtask
```

## Development

Only node.js is reguired for development

1. Clone/fork this repository
```
$ git clone git@github.com:adesisnetlife/croak.git && cd croak
```

2. Install package dependencies
```
$ npm install 
```

3. Run tests
```
$ npm test
```

## Contributing

Croak is completely written in LiveScript language.
Take a look to the language [documentation][4] if you are new with it.
Please, follow the LiveScript language conventions and [coding style][4]

You must add new test cases for any feature or refactor you do, 
also keep in mind to follow the same design/code patterns that already exist

## To Do/Wish list

- Support for relative paths on `.croakrc` based on its file location
- More test cases scenarios and destructive/evil testing
- More deep CLI test cases
- Support for extending/overriding Grunt configuration
- Support for multiple Gruntfile in the same project?
- Grunt croak task to configure it from local Gruntfile
- Support to use an installed node package instead of using a path for the Gruntfile

## Authors

- [Tomás Aparicio](https://github.com/h2non)

## License

Copyright (c) 2013 Adesis Netlife S.L

Released under the [MIT][5] license

[1]: http://gruntjs.com
[2]: https://github.com/h2non/grunt-croak
[3]: http://livescript.net
[4]: https://github.com/gkz/LiveScript-style-guide
[5]: https://github.com/adesisnetlive/croak/blob/master/LICENSE
[6]: https://gist.github.com/h2non/7787640
[7]: http://nodejs.org
