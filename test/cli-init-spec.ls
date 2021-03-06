{
  cwd
  mkdirp
  rm
  chdir
  expect
  suppose
  read
  exec
  exists
  home-var
  home
  env
  createWriteStream
} = require './lib/helper'

describe 'CLI init', (_) ->
  dir = "#{__dirname}/fixtures/.tmp/cli/init"

  init-before = ->
    rm dir
    mkdirp dir
    chdir dir

  init-after = ->
    rm dir
    chdir cwd

  read-file = ->
    read "#{dir}/.croakrc"

  describe 'setup process', ->

    describe 'local config', (_) ->

      before init-before
      after init-after

      it 'should create .croakrc', (done) ->
        suppose(<[ init ]>)
          #.debug(createWriteStream "#{__dirname}/cli.log")
          .on(/Enter the project name/).respond('local-project\n')
          .on(/The project has a node.js build package/).respond('y\n')
          .on(/Enter the package name/).respond('builder\n')
          .on(/project by default/).respond('y\n')
        .error (err) ->
          throw new Error err
        .end (code) ->
          expect code .to.be.equal 0
          expect exists "#{dir}/.croakrc" .to.be.true
          done!

      it 'should exists the created project in .croakrc', ->
        expect read-file! .to.match /\[local-project\]/

      it 'should have the expected package option value', ->
        expect read-file! .to.match /package = builder/

      it 'should have the default project', ->
        expect read-file! .to.match /\$default = local-project/

      describe 'using the add command alias', (_) ->

        before init-before
        after init-after

        it 'should create .croakrc', (done) ->
          suppose(<[ add ]>)
            .on(/Enter the project name/).respond('local-project\n')
            .on(/The project has a node.js build package/).respond('y\n')
            .on(/Enter the package name/).respond('builder\n')
            .on(/project by default/).respond('y\n')
          .error (err) ->
            throw new Error err
          .end (code) ->
            expect code .to.be.equal 0
            expect exists "#{dir}/.croakrc" .to.be.true
            done!

        it 'should exists the created project in .croakrc', ->
          expect read-file! .to.match /\[local-project\]/

        it 'should have the expected package option value', ->
          expect read-file! .to.match /package = builder/

        it 'should have the default project', ->
          expect read-file! .to.match /\$default = local-project/


    describe 'global config', (_) ->

      before init-before
      after init-after

      before ->
        env[home-var] = dir

      after ->
        env[home-var] = home

      it 'should create .croakrc', (done) ->
        suppose(<[ init -g ]>)
          .on(/Enter the project name/).respond('global-project\n')
          .on(/The project has a node.js build package/).respond('y\n')
          .on(/Enter the package name/).respond('builder\n')
          .on(/Enable overwrite tasks/).respond('y\n')
          .on(/Enable extend tasks/).respond('y\n')
          .on(/Enable task registering/).respond('y\n')
          .on(/project by default/).respond('y\n')
        .error (err) ->
          throw new Error err
        .end (code) ->
          expect code .to.be.equal 0
          expect exists "#{dir}/.croakrc" .to.be.true
          done!

      it 'should exists the created project in .croakrc', ->
        expect read-file! .to.match /\[global-project\]/

      it 'should have the expected package option value', ->
        expect read-file! .to.match /package = builder/

      it 'should have the extend option to true', ->
        expect read-file! .to.match /extend = true/

      it 'should have the extend task registering to true', ->
        expect read-file! .to.match /register_tasks = true/

      it 'should have the default project', ->
        expect read-file! .to.match /\$default = global-project/

  describe 'sample project', (_) ->

    before init-before
    after init-after

    before ->
      env[home-var] = dir

    after ->
      env[home-var] = home

    it 'should create a new .croakrc global file', (done) ->
      suppose(<[ init sample-project --sample ]>)
      .error (err) ->
        throw new Error err
      .end (code) ->
        expect code .to.be.equal 0
        expect exists "#{dir}/.croakrc" .to.be.true
        done!

    it 'should exists the created project in .croakrc', ->
      expect read-file! .to.match /\[sample-project\]/
      expect read-file! .to.match /Gruntfile\.js/

  describe 'flags --gruntfile', (_) ->

    before init-before
    after init-after

    before ->
      env[home-var] = dir

    after ->
      env[home-var] = home

    it 'should create a new .croakrc global file', (done) ->
      suppose(<[ init custom-project --gruntfile ../path/to/Gruntfile.js ]>)
      .error (err) ->
        throw new Error err
      .end (code) ->
        expect code .to.be.equal 0
        expect exists "#{dir}/.croakrc" .to.be.true
        done!

    it 'should exists the created project in .croakrc', ->
      expect read-file! .to.match /\[custom-project\]/
      expect read-file! .to.match /path\/to\/Gruntfile\.js/

  describe 'flags --pkg', (_) ->

    before init-before
    after init-after

    before ->
      env[home-var] = dir

    after ->
      env[home-var] = home

    it 'should create a new .croakrc global file', (done) ->
      suppose(<[ init custom-project --pkg builder ]>)
      .error (err) ->
        throw new Error err
      .end (code) ->
        expect code .to.be.equal 0
        expect exists "#{dir}/.croakrc" .to.be.true
        done!

    it 'should exists the created project in .croakrc', ->
      expect read-file! .to.match /\[custom-project\]/
      expect read-file! .to.match /package = builder/

  describe 'flags --usedef', (_) ->

    before init-before
    after init-after

    before ->
      env[home-var] = dir

    after ->
      env[home-var] = home

    it 'should create a new .croakrc global file', (done) ->
      suppose(<[ init custom-project --pkg builder --usedef ]>)
      .error (err) ->
        throw new Error err
      .end (code) ->
        expect code .to.be.equal 0
        expect exists "#{dir}/.croakrc" .to.be.true
        done!

    it 'should exists the created project in .croakrc', ->
      expect read-file! .to.match /\[custom-project\]/

    it 'should exists the defualt project to use in .croakrc', ->
      expect read-file! .to.match /\$default = custom-project/

