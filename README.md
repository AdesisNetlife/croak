# Croak

<img align="right" height="280" src="http://oi44.tinypic.com/f3azc7.jpg" style="float: right" />

> Grunt automation made easy for large Web projects

### Why croak?

[Grunt][1] is an awesome utility well community adopted to automate stuff and simplify common tasks in Node.js related projects

## How it works

Croak is a wrapper for Grunt, allowing your to extend or override Grunt configuration in distributed projects...

### Grunt support

Croak only supports Grunt 0.4.x

## Installation

You should use the Croak CLI, so the best way is installing the package globally

```shell
$ npm install -g croak
```

Then, create the global config file for your projects
```
$ croak config -g create
```

Create a well-formed ini file called `.croakrc` in your `$HOME` or `%USERPROFILE%` directory

## Configuration file

Croak supports two configuration files: 

- Global configuration localted in `$HOME` or `%USERPROFILE%`
- Local configuration located in your project root directory

The Croak configuration file must called `.croakrc`

### Available configuration options

#### Global 

```
[global]
allow_register_tasks = false

[project super-project]
path = /home/me/projects/super-project/grunt-project
allow_register_tasks = true
```

- allow_register_tasks `boolean` Enable/disable register new Grunt tasks from local config

#### Local

- `project` Croak project alias
 
## Croakfile

Like Grunt, Croak has its own specific configuration file

```coffee
module.exports = (croak) ->

  registerTasks: (croak, grunt) ->
    grunt.registerTask 'js-minification', ['clean', 'uglify'] if croak.taskSupported 'uglify'

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

## Croak CLI
 
`TODO`

## Croak API

`TODO`

## Use Croak from existent Gruntfile.js

If you already have `Gruntfile.js` in each local repository of your project and you do not want to switch
radically to Croak, you can use the `grunt-croak` task to make a less impact with the same result

```
$ npm install grunt-croak --save-dev
```

For more information, see the [grunt-croak][2] documentation

[1]: http://gruntjs.com
[2]: https://github.com/h2non/grunt-croak
