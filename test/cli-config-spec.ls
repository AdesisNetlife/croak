{
  cwd
  mkdirp
  rm
  chdir
  expect
  read
  exec
  env
  home-var
  home
} = require './lib/helper'

describe 'CLI config', (_) ->

  before ->
    chdir "#{__dirname}/fixtures/config/local"

  after ->
    chdir cwd

  it 'should show the help', (done) ->
    exec 'data', <[config --help]>, ->
      expect it .to.match /\$ croak config/
      done!

  it 'should list the existent config', (done) ->
    exec 'data', <[config list]>, ->
      expect it .to.match /\; local/i
      done!

  describe '--croakrc', (_) ->

    it 'should use a custom .croakrc path location', (done) ->
      exec 'data', <[config list --croakrc]> ++ ["#{__dirname}/fixtures/config/local/.croakrc"], ->
        expect it .to.match /\[local-project\]/i
        done!

  describe 'create', ->
    dir = "#{__dirname}/fixtures/.tmp/cli/create"

    describe 'local', (_) ->

      before ->
        rm dir
        mkdirp dir
        chdir dir

      after ->
        chdir cwd

      it 'should create a new .croakrc', (done) ->
        exec 'close', <[ config create sample ]>, ->
          expect it .to.be.equal 0
          done!

      it 'should exists the created project in .croakrc', ->
        expect read "#{dir}/.croakrc" .to.match /\[sample\]/
        expect read "#{dir}/.croakrc" .to.match /Gruntfile\.js/

    describe 'global', (_) ->

      before ->
        rm dir
        mkdirp dir
        chdir dir

      before ->
        env[home-var] = dir

      after ->
        chdir cwd

      after ->
        env[home-var] = home

      it 'should create a new .croakrc', (done) ->
        exec 'close', <[ config create global-sample -g ]>, ->
          expect it .to.be.equal 0
          done!

      it 'should exists the created project in .croakrc', ->
        expect read "#{dir}/.croakrc" .to.match /\[global-sample\]/
        expect read "#{dir}/.croakrc" .to.match /Gruntfile\.js/


  describe 'set', (_) ->
    dir = "#{__dirname}/fixtures/.tmp/cli/set"

    before ->
      rm dir
      mkdirp dir
      chdir dir

    after ->
      chdir cwd

    it 'should create a new .croakrc', (done) ->
      exec 'close', <[ config create sample ]>, ->
        expect it .to.be.equal 0
        done!

    it 'should set a new option to the existent project', (done) ->
      exec 'close', <[ config set sample.gruntfile ./new/path/to/Gruntfile.js ]>, ->
        expect it .to.be.equal 0
        done!

    it 'should change the option properly', ->
      expect read "#{dir}/.croakrc" .to.match /\/new\/path\/to\/Gruntfile/

  describe 'get', (_) ->
    dir = "#{__dirname}/fixtures/.tmp/cli/get"

    before ->
      rm dir
      mkdirp dir
      chdir dir

    after ->
      chdir cwd

    it 'should create a new .croakrc', (done) ->
      exec 'close', <[ config create sample ]>, ->
        expect it .to.be.equal 0
        done!

    it 'should get an existent project option', (done) ->
      exec 'data', <[ config get sample.gruntfile ]>, ->
        expect it .to.be.equal '../path/to/Gruntfile.js\n'
        done!

    it 'should return the proper exit code if the option do not exist', (done) ->
      exec 'close', <[ config get sample.nonexistent ]>, ->
        expect it .to.be.equal 1
        done!

  describe 'remove', (_) ->
    dir = "#{__dirname}/fixtures/.tmp/cli/remove"

    before ->
      rm dir
      mkdirp dir
      chdir dir

    after ->
      chdir cwd

    it 'should create a new .croakrc', (done) ->
      exec 'close', <[ config create sample ]>, ->
        expect it .to.be.equal 0
        done!

    it 'should remove an existent project option', (done) ->
      exec 'close', <[ config remove sample.gruntfile ]>, ->
        expect it .to.be.equal 0
        done!

    it 'should not exist the removed project option', (done) ->
      exec 'close', <[ config get sample.gruntfile ]>,  ->
        expect it .to.be.equal 1
        done!

    it 'should remove an non-existent project option', (done) ->
      exec 'close', <[ config remove sample.non-existent ]>, ->
        expect it .to.be.equal 0
        done!

    it 'should remove a project', (done) ->
      exec 'close', <[ config remove sample ]>, ->
        expect it .to.be.equal 0
        done!

    it 'should not exist the project', (done) ->
      exec 'close', <[ config get sample ]>, ->
        expect it .to.be.equal 1
        done!
