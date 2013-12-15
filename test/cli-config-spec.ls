{
  cwd
  mkdirp
  rm
  chdir
  expect
  suppose
  version
  exists
  read
  exec
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
  /*
  describe 'create', (_) ->
    dir = "#{__dirname}/fixtures/.tmp/cli/create"

    before-each ->
      rm dir
      mkdirp dir

    before-each ->
      chdir dir

    after-each ->
      chdir cwd

    describe 'local', (_) ->

      it 'should create a new .croakrc local file', (done) ->
        suppose(<[ create ]>)
          #.debug(util.createWriteStream 'cli.log')
          .on(/project name:/).respond('sample\n')
          .on(/Gruntfile path \(/).respond('../../gruntfile/Gruntfile.js\n')
          .on(/overwrite tasks\?/).respond('n\n')
          .on(/extend tasks\?/).respond('y\n')
        .error (err) ->
          throw new Error err
        .end (code) ->
          expect code .to.be.equal 0
          expect exists "#{dir}/.croakrc" .to.be.true
          done!

      it 'should exists the created project in .croakrc', ->
        expect read "#{dir}/.croakrc" .to.match /\[sample\]/
        expect read "#{dir}/.croakrc" .to.match /Gruntfile\.js/

    describe 'global', (_) ->

      it 'should create a new .croakrc global file', (done) ->
        suppose(<[ create -g ]>)
          #.debug(util.createWriteStream 'cli.log')
          .on(/project name:/).respond('sample\n')
          .on(/Gruntfile path \(/).respond('../../gruntfile/Gruntfile.js\n')
          .on(/overwrite tasks\?/).respond('n\n')
          .on(/extend tasks\?/).respond('y\n')
        .error (err) ->
          throw new Error err
        .end (code) ->
          expect code .to.be.equal 0
          expect exists "#{dir}/.croakrc" .to.be.true
          done!

      it 'should exists the created project in .croakrc', ->
        expect read "#{dir}/.croakrc" .to.match /\[sample\]/
        expect read "#{dir}/.croakrc" .to.match /Gruntfile\.js/
  */
