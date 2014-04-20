{
  cwd
  chdir
  expect
  grunt
} = require './lib/helper'

require! {
  '../lib/croakfile'
}

describe 'Croakfile', ->

  describe 'load', ->

    describe 'javascript', (_) ->
      dir = "#{__dirname}/fixtures/croakfile/js/"

      before -> chdir dir
      after -> chdir cwd

      it 'should exist the Croakfile', ->
        expect croakfile.exists! .to.be.true

      it 'should read the Croakfile', ->
        expect croakfile.read! .to.be.a 'function'

      it 'should load the Croakfile', ->
        options = { extend: true, overwrite: true, register_tasks: true }
        expect -> croakfile.load options .to.not.throw!

    describe 'coffeescript', (_) ->
      dir = "#{__dirname}/fixtures/croakfile/coffee/"

      before -> chdir dir
      after -> chdir cwd

      it 'should exist the Croakfile', ->
        expect croakfile.exists! .to.be.true

      it 'should read the Croakfile', ->
        expect croakfile.read! .to.be.a 'function'

      it 'should load the Croakfile', ->
        options = { extend: true, overwrite: true, register_tasks: true }
        expect -> croakfile.load options .to.not.throw!


  describe 'config', (_) ->
    dir = "#{__dirname}/fixtures/croakfile/js/"
    sky = null

    before -> chdir dir
    after -> chdir cwd

    before ->
      grunt.config.init {}

    before-each ->
      "#{__dirname}/fixtures/croakfile/grunt/tasks.js" |> require

    it 'should the "log" tasks exist', ->
      expect grunt.config 'log' .to.be.an 'object'

    it 'should the "write" tasks exist', ->
      expect grunt.config 'write' .to.be.an 'object'

    it 'should the "parse" tasks exist', ->
      expect grunt.config 'parse' .to.be.an 'object'

    describe 'no options', (_) ->

      before ->
        options = {}
        croakfile.load options

      it 'should have the "write" task config', ->
        expect grunt.config 'write' .to.be.an 'object'

      it 'should not have the "read" task config', ->
        expect grunt.config 'read' .to.be.undefined

    describe 'extend', (_) ->

      before ->
        options = extend: true
        croakfile.load options

      it 'should have the "write" task config', ->
        expect grunt.config 'write' .to.be.an 'object'

      it 'should have the "read" task config', ->
        expect grunt.config 'read' .to.be.an 'object'

      it 'should not exist the "croak_test" task', ->
        expect (-> grunt.task.rename-task 'croak_test', 'croak_test') .to.throw TypeError

    describe 'overwrite', (_) ->

      before ->
        grunt.config 'read', undefined

      before ->
        options = overwrite: true
        croakfile.load options

      it 'should have the "write" task config', ->
        expect grunt.config 'write' .to.be.an 'object'

      it 'should have the "read" task config', ->
        expect grunt.config 'read' .to.be.an 'object'

      it 'should not exist the "croak_test" task', ->
        expect (-> grunt.task.rename-task 'croak_test', 'croak_test') .to.throw TypeError

    describe 'register_tasks', (_) ->

      before ->
        grunt.config 'read', undefined

      before ->
        options = register_tasks: true
        croakfile.load options

      it 'should have the "write" task config', ->
        expect grunt.config 'write' .to.be.an 'object'

      it 'should exist the "read" task', ->
        expect (-> grunt.task.rename-task 'read', 'read') .to.not.throw!

      it 'should exist the "croak_test" task', ->
        expect (-> grunt.task.rename-task 'croak_test', 'croak_test') .to.not.throw!


  describe 'discovery', (_) ->
    dir = "#{__dirname}/fixtures/croakfile/js/dir/subdir/"

    before ->
      grunt.config.init {}

    before ->
      chdir dir
      croakfile.load overwrite: true

    after ->
      chdir cwd

    it 'should find the Crokfile in looking in higher directories', ->
      expect croakfile.path .to.be.equal "#{__dirname}/fixtures/croakfile/js/Croakfile.js"

    it 'should have the "read" task config', ->
      expect grunt.config 'read' .to.be.an 'object'

