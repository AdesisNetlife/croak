{
  cwd
  mkdirp
  rm
  chdir
  expect
  suppose
  version
  exist
  read
  exec
  home-var
  home
  env
} = require './lib/helper'

describe 'CLI general flags', (_) ->

  it 'should return the expected version', (done) ->
    exec 'data', <[--version]>, ->
      expect it .to.match new RegExp "#{version}"
      done!

  it 'should show the help', (done) ->
    exec 'close', <[--help]>, ->
      expect it .to.be.equal 0
      done!

describe 'CLI run', (_) ->

  before ->
    chdir "#{__dirname}/fixtures/project/src/"
    env[home-var] = "#{__dirname}/fixtures/project/src/folder/subfolder"

  after ->
    chdir cwd
    env[home-var] = ''

  it 'should run the "log" task', (done) ->
    exec 'close', <[run log]>, ->
      expect it .to.be.equal 0
      done!

  it 'should run the "foo:bar" sub task', (done) ->
    exec 'close', <[run log:bar]>, ->
      expect it .to.be.equal 0
      done!

  it 'should run croak test task', (done) ->
    exec 'close', <[run croak_test]>, ->
      expect it .to.be.equal 0
      done!

  it 'should not run an inexistent task', (done) ->
    exec 'close', <[run inexistent]>, ->
      expect it .to.be.equal 3
      done!

  describe 'flags', (_) ->

    before ->
      chdir "#{__dirname}/fixtures/empty/"

    after ->
      chdir cwd

    it '--help', (done) ->
      exec 'close', <[run --help]>, ->
        expect it .to.be.equal 0
        done!

    describe '--gruntfile', (_) ->

      it 'valid Gruntfile path with existent task', (done) ->
        exec 'close', <[run log --gruntfile]> ++ ["#{__dirname}/fixtures/project/grunt/Gruntfile.js"], ->
          expect it .to.be.equal 0
          done!

      it 'valid Gruntfile path with nonexistent task', (done) ->
        exec 'close', <[run notexistent --gruntfile]> ++ ["#{__dirname}/fixtures/project/grunt/Gruntfile.js"], ->
          expect it .to.be.equal 3
          done!

      it 'valid Gruntfile path without filename', (done) ->
        exec 'close', <[run log --gruntfile]> ++ ["#{__dirname}/fixtures/project/grunt/"], ->
          expect it .to.be.equal 0
          done!

      it 'invalid path', (done) ->
        exec 'close', <[run notexistent --gruntfile]> ++ ["#{__dirname}/fixtures/empty/Gruntfile.js"], ->
          expect it .to.be.equal 2
          done!

    describe '--base', (_) ->

      before ->
        chdir "#{__dirname}/fixtures/project/src/"

      # todo, relative paths and --croakrc path
      it 'should use a valid base path', (done) ->
        exec 'close', <[run log --base]> ++ ["#{__dirname}/fixtures/empty"], ->
          expect it .to.be.equal 0
          done!
