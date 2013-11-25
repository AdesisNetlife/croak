'use strict'

module.exports = (grunt) ->

  _ = grunt.util._
  path = require 'path'

  # load all grunt tasks
  (require 'matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    clean: ['lib', 'test/**/*.js', 'test/tmp/**/*']

    livescript:
      options:
        bare: true
      src:
        expand: true
        cwd: 'src/'
        src: ['**/*.ls']
        dest: 'lib/'
        ext: '.js'
      test:
        expand: true
        cwd: 'test/'
        src: ['**/*.ls']
        dest: 'test/'
        ext: '.js'

    mochacli:
      options:
        require: ['chai']
        compilers: ['ls:LiveScript']
        timeout: 5000
        ignoreLeaks: false
        ui: 'bdd'
        reporter: 'spec'
      all:
        src: [
          'test/**/*.ls'
        ]

    watch:
      options:
        spawn: false
      src:
        files: ['src/**/*.ls']
        tasks: ['livescript:src', 'simplemocha']
      test:
        files: ['test/**/*.ls']
        tasks: ['livescript:test', 'simplemocha']

  grunt.event.on 'watch', (action, files, target)->
    grunt.log.writeln "#{target}: #{files} has #{action}"

    # coffee
    lsData = grunt.config ['livescript', target]
    files = [files] if _.isString files
    files = files.map (file)-> path.relative lsData.cwd, file
    lsData.src = files

    grunt.config ['livescript', target], lsData


  grunt.registerTask 'compile', [
    'clean'
    'livescript'
  ]

  grunt.registerTask 'test', [
    'compile',
    'mochacli'
  ]

  grunt.registerTask 'publish', [
    'test'
    'release'
  ]

  grunt.registerTask 'default', [
    'compile'
    'test'
  ]

