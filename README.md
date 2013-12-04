# Croak [![Build Status](https://secure.travis-ci.org/AdesisNetlife/croak.png?branch=master)](http://travis-ci.org/AdesisNetlife/croak) [![Dependency Status](https://gemnasium.com/adesisnetlife/croak.png)](https://gemnasium.com/adesisnetlife/croak)

> Grunt automation made easy for large projects. Save time and health with Croak

`WORK IN PROCESS!`

## About

<img align="right" height="280" src="http://oi44.tinypic.com/f3azc7.jpg" style="float: right" />

[Grunt][1] is a fantastic utility largely adopted by the community made to automate tasks and simplify development time under node.js based projects

Croak is just a simple, but featured wrapper for Grunt that aims to help you to manage and orchestrate Grunt tasks and configuration across large and distributed projects, helping you to avoid redundancy, saving time and dramatically reducing changes impact

Croak arises from the need to create an specific solution to abstract all the automation 
configuration stuff and allowing you to delegate responsibilities in a proper way and sense
in your project and developers, without losing control

### Features

- Centralizes your project build tasks configuration
- Easily manage and orchestrates different configuration for multiple projects
- Abstract and provides more more control of your project automation tasks
- Extends or overwrites Grunt global tasks configuration from local
- Provides the same Grunt API and CLI
- Customizes Grunt options run mode from the config file (future `.gruntrc`)
- Keeps clean your repository without Grunt node packages (in front end projects cases)

## Installation

Installation of Croak as global package is recommended

```shell
$ npm install -g croak
```

### Configure it

After you install it properly, you should configure croak
```
$ croak config create -g
```

The process above will create a ini file named `.croakrc` in your `$HOME` or `%USERPROFILE%` directory

See the [configuration file](#configuration-file) section for more details

### How it works

In a few words, Croak allows you to have a multiple `Gruntfile.js` in global locations, and running them using a simple project identifier, also allowing you to define a pre-configured options to pass to Grunt from a ini configuration file

Croak also allows your to extend or overwrite Gruntfile configurations. This feature is useful when you think that your developers are not bad people, so you can provide a way to customize tasks configuration

### Example scenario

A representative scenario could be, for example, that your project has a relevant 
number of repositories. Each repository needs its automation configuration 
for development, testing or building stuff.

Usually, this configuration tends to grow when your repository has an amount of different tasks and this configuration also tends to be very similar or redundant 
across different repositories in your project

Continuous changing and improvement is a constant in any software project, so using Croak you can reduce dramatically your project automation configuration changing time by centralizing it

### Do I really need Croak?

Abstraction is not always the best choice and some people hate it.
Basically, an abstraction in software development tries to reduce notably the complexity  underlying details.

With Croak you can provide an ideal level of abstraction for developers and, at the same time,
you can offer the possibility to pass part of the abstraction, providing the desired level of responsibility to 
the developer

#### Stage

Croak is an initial version ready to use, however is under active (re-)designing process 
and important changes can be applied in a near future

**Grunt support**

Croak supports Grunt `~0.4.0`

## Using Croak

### Configuration file

Croak uses disk files to persistent store the configuration
The Croak configuration file must called `.croakrc`

Croak supports two types of configuration files 

#### Global file

A global file can store the configuration of your projects and this configuration will be used in each Croak execution

By default it will be located in `$HOME` or `%USERPROFILE%` directories, but you can define an environment variables called `CROAKRC` to specify a custom global file location

#### Local file

Local file can be located in any path, but it is recommended that you create it in your project or repository root folder

Usually, a local file should have only one project configured. Any local configuration will overwrite a global configuration (for example, if you have the same project configured in both files)

Croak implements a similar file discovery algorithm like the one Grunt uses to discover the Gruntfile

### Available configuration options

Example project configuration

```ini
[my-project]
extend = true
overwrite = true
register_tasks = true
;; grunt-specific
gruntfile = ${HOME}/projects/my-project/Gruntfile.coffee
base = ${HOME}/projects/my-project/data/
no_color = false
no_write = false
debug = false
verbose = false
force = false
stack = false
tasks = ../custom-tasks/
npm = mytask
```
 
### Adapt your existent Gruntfile

Croak automatically exposes the croak config object in your Gruntfile, so you can use this 
configuration like template values in your tasks config

This is really useful because, in much cases, you need to use absolute paths in your Gruntfile

**Croak grunt object**

The following properties will be available:

- cwd `User working directory when Croak is called`
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

### Croakfile

Like Grunt, Croak has its own specific configuration file.

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

#### Configuring Croak from CLI

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

### Croak API

`TODO`

### Use Croak from existent Gruntfile.js

If you already have `Gruntfile.js` in each local repository of your project and you do not want to switch
radically to Croak, you can use the `grunt-croak` task to make less impact with the same result

```
$ npm install grunt-croak --save-dev
```

For more information, see the [grunt-croak][2] documentation

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

Only Node.js is reguired for development

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

## TODO/WISH list

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
