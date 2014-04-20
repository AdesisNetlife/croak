{
  cwd
  chdir
  expect
  home-var
  home
  env
  join
} = require './lib/helper'

require! {
  '../lib/config'
}
{ FILENAME, CONFVAR } = require '../lib/constants'

describe 'Config package', ->
  
  describe 'resolve package by name', ->
  
    describe 'local module', (_) ->
      dir = "#{__dirname}/fixtures/package/local/"
    
      before ->
        env[home-var] = dir
        chdir dir

      before ->
        config.clean!
        config.load!

      after ->
        env[home-var] = home
        chdir cwd

      it 'should resolve and find the Gruntfile.js', ->
        expect config.config.sample['package'] 
          ..to.be.equal join dir, "node_modules/builder/Gruntfile.js"

    describe 'global module', (_) ->
      dir = "#{__dirname}/fixtures/package/global"

      before ->
        env['NODE_PATH'] = "#{dir}/global_modules"
        env[home-var] = dir
        chdir dir

      before ->
        config.clean!
        config.load!

      after ->
        env['NODE_PATH'] = ''
        env[home-var] = home
        chdir cwd

      it 'should resolve and find the Gruntfile.js', ->
        expect config.config.sample['package'] 
          ..to.be.equal join dir, 'global_modules', "node_modules/builder/Gruntfile.js"

    describe 'non-existent module', (_) ->
      dir = "#{__dirname}/fixtures/package/non-existent"

      before ->
        env[home-var] = dir
        chdir dir

      before ->
        config.clean!
        config.load!

      after ->
        env[home-var] = home
        chdir cwd

      it 'should resolve and find the Gruntfile.js', ->
        expect config.config.sample .to.be.an 'object'
        expect config.config.sample['package'] .to.be.null

  describe 'resolve package by path', (_) ->
    dir = "#{__dirname}/fixtures/package/path/"
  
    before ->
      env[home-var] = dir
      chdir dir

    before ->
      config.clean!
      config.load!

    after ->
      env[home-var] = home
      chdir cwd

    it 'should resolve and find the Gruntfile.js', ->
      expect config.config.sample['package'] 
        ..to.be.equal join dir, "builder/Gruntfile.js"
