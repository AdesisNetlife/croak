# Croak [![Build Status](https://secure.travis-ci.org/adesisnetlife/croak.png?branch=master)](http://travis-ci.org/adesisnetlife/croak) [![Dependency Status](https://gemnasium.com/adesisnetlife/croak.png)](https://gemnasium.com/adesisnetlife/croak)

> Grunt automation made easy for large projects

`WORK IN PROCESS!`

## Why Croak?

<img align="right" height="280" src="http://oi44.tinypic.com/f3azc7.jpg" style="float: right" />

[Grunt][1] is an awesome utility well community adopted to automate tasks and simplify development life time under node.js based projects

Croak is just a simple, but featured wrapper for Grunt, that aims to help you to manage and orquestate 
Grunt tasks and configuration across large and distributed projects, 
always thinking about saving time and reducing changes impact

Croak borns from the need to create an specific solution to abstract all the automation 
configuration stuff, allowing you to delegate responsabilities in a proper way and sense
in your project and developers

## Installation

It's recommended you to install Croak as global package

```shell
$ npm install -g croak
```

**I need to have Grunt already installed?**

No, Croak will do it for you. 
`grunt-cli` will be replaced by Croak CLI

**Can I use the Grunt CLI**

Of course, it will be avaiable using the `grunt` command

```
$ croak grunt --help
```

### Configure it

After you install it properly, you should configure croak
```
$ croak config -g create
```

The process above will create a ini file named `.croakrc` in your `$HOME` or `%USERPROFILE%` directory

See the [configuration file](#configuration-file) section for more details

### How it works

In a few words, Croak allows you to have a multiple `Gruntfile.js` in a global locations, and running them 
using a simple alias

Croak allows your to extend or override Grunt configuration in distributed projects, this feature is useful
when you think the developers are not evil guys, providing a way to extend or override tasks

### Example scenario

A representative scenario will be, for example, if your project have a relevant 
number of repositories. Each repository need its automation configuration 
for development, testing or building stuff.
The Node-related software design is local focused, 
Usually, this configuration tends to be complex when your project uses different technologies

when you are in large project scenarios, and you have a lot of repositories

### I do really need Croak?

Abstraction is not always the best choice and some people can hate it.
Basically, an abstraction, in software development, tries to reduce notably complexity 
hiding underlying details.

With Croak you can provide an ideal level of abstraction to developers and at the same time,
you can offer the possibility to pass part of the abstraction, providing more responsability to 
the developer

#### Stage

Croak is a initial version ready to use, however is under active (re-)designing process 
and important changes can be applied in a few future

#### Grunt support

Croak supports Grunt 0.4.x

## Features

- Centralize your project build tasks configuration
- Orquestate different tasks configuration
- Extend or override Grunt global tasks configuration from local
- Provides the same Grunt API and CLI
- Customize Grunt run mode from the config file (future `.gruntrc`)
- Keep clean your repository without Grunt node packages (in front end projects cases)

## Using Croak

### Configuration file

Croak supports two configuration files: 

- Global configuration localted in `$HOME` or `%USERPROFILE%`
- Local configuration located in your project root directory

The Croak configuration file must called `.croakrc`

### Available configuration options

#### Global 

```
[super-project]
gruntfile = /home/me/projects/super-project/grunt-project
allow_register_tasks = true
```

##### Supported options per project

```ini
[my-project]
override = true
register_tasks = true
;package = build-package
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

- allow_register_tasks `boolean` Enable/disable register new Grunt tasks from local config
 
### Croakfile

Like Grunt, Croak has its own specific configuration file

```coffee
module.exports = (croak) ->

  registerTasks: (croak, grunt) ->
    croak.registerTask 'js-minification', ['clean', 'uglify'] if croak.taskSupported 'uglify'

  config: (croak, grunt) ->
    croak.set 'uglify', {
      options: 
        sourceMaps: true

      minify: 
        files: 
          src: ['**/*.js']
          dest: '<% croak.cwd %>/test'
    }

```

### Gruntfile configuration

Croak will automatically create a specific task, called `croak` which will be avaiable from Grunt config object.
That's really useful for templating and configure absolute paths for your local projects

### Croak CLI
 
`TODO`

### Croak API

`TODO`

### Use Croak from existent Gruntfile.js

If you already have `Gruntfile.js` in each local repository of your project and you do not want to switch
radically to Croak, you can use the `grunt-croak` task to make a less impact with the same result

```
$ npm install grunt-croak --save-dev
```

For more information, see the [grunt-croak][2] documentation

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
also take in mind follow the same design/code patterns already existing

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
