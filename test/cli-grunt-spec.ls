{
  cwd
  mkdirp
  rm
  chdir
  expect
  suppose
  read
  exec
} = require './lib/helper'

describe 'CLI grunt', (_) ->

  it 'should show the grunt help', (done) ->
    exec 'close', <[grunt --help]>, ->
      expect it .to.be.equal 0
      done!

  it 'should show the grunt version', (done) ->
    exec 'data', <[grunt --version]>, ->
      expect it .to.match /grunt/i
      done!

  describe 'run task with existent Gruntfile in cwd', (_) ->

    before ->
      process.chdir "#{__dirname}/fixtures/project/grunt/"

    after ->
      process.chdir cwd

    it 'should run the "log" task', (done) ->
      exec 'data', <[grunt log]>, ->
        expect it .to.match /hello croak/i
        done!

    it 'should run the default task', (done) ->
      exec 'data', <[grunt]>, ->
        expect it .to.match /hello croak/i
        done!

  describe 'run task with existent Gruntile passing flags', (_) ->

    before ->
      process.chdir "#{__dirname}/fixtures/project/"

    after ->
      process.chdir cwd

    it 'should run the default task using --gruntfile flag', (done) ->
      exec 'data', <[grunt --gruntfile grunt/Gruntfile.js ]>, ->
        expect it .to.match /hello croak/i
        done!