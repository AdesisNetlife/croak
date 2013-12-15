require! {
  fs
  mkdirp
  path.join
  chai.expect
  '../lib/common'
  '../lib/config'
}
{ FILENAME, CONFVAR } = require '../lib/constants'

home-var = if process.platform is 'win32' then 'USERPROFILE' else 'HOME'
home = common.user-home
cwd = process.cwd!

describe 'Config', ->

  before ->
    mkdirp.sync "#{__dirname}/fixtures/.tmp/config/global"
    mkdirp.sync "#{__dirname}/fixtures/.tmp/config/local"

  describe 'file location', (_) ->

    it 'should expect config global path', ->
      expect config.global-file! .to.be.equal join home, FILENAME

    it 'should expect config local path', ->
      expect config.local-file "#{__dirname}/fixtures/config/local"
        ..to.be.equal join "#{__dirname}/fixtures/config/local", FILENAME

    describe 'custom environment variable path', (_) ->

      before ->
        process.env[CONFVAR] = "#{__dirname}/fixtures/config/global/#{FILENAME}"

      after ->
        process.env[CONFVAR] = ''

      it 'should have the expeted path', ->
        expect config.global-file! .to.be.equal "#{__dirname}/fixtures/config/global/#{FILENAME}"


  describe 'read', (_) ->

    describe 'file discovery with invalid paths', (_) ->

      before ->
        process.env[CONFVAR] = "#{__dirname}/fixtures/.tmp/config/global/"
        process.chdir "#{__dirname}/fixtures/.tmp/config/local"

      before ->
        config.clean!

      after ->
        process.env[CONFVAR] = ''
        process.chdir cwd

      it 'should read non-existent files', ->
        expect config.global .to.be.null
        expect config.local .to.be.null

    describe 'API', ->

      describe 'get()', (_) ->

        before-each ->
          config.config =
            project:
              _gruntfile: "#{__dirname}/fixtures/config"
              _force: false
              _stack: true

        it 'should get the whole config object', ->
          expect config.get!
            ..to.have.property 'project'
            ..that.is.an 'object'

        it 'should get the project object', ->
          expect config.get 'project'
            ..to.have.property 'gruntfile'
            ..that.is.a 'string'

        it 'should get a config property', ->
          expect config.get 'project.force' .to.be.false

        it 'should get null if the project do not exists', ->
          expect config.get 'nonexistent' .to.be.null

        it 'should get null if the property do not exists', ->
          expect config.get 'nonexistent.invalid' .to.be.null

        describe 'evil testing', (_) ->

          it 'should return the proper value if the type is not a string', ->
            expect config.get null .to.be.an 'object'
            expect config.get undefined .to.be.an 'object'
            expect config.get [] .to.be.an 'object'

    describe 'E2E', ->

      describe 'global config', (_) ->
        home = process.env[home-var]

        before ->
          common.user-home = "#{__dirname}/fixtures/config/global"
          process.chdir "#{__dirname}/fixtures/config"

        before ->
          config.load!

        after ->
          common.user-home = home
          process.chdir cwd

        it 'should exist the global config', ->
          expect config.global .to.be.an 'object'

        it 'should not exists a local config', ->
          expect config.local .to.be.null

        it 'should exist the global project', ->
          expect config.get 'global-project' .to.be.an 'object'

      describe 'local config', (_) ->

        before ->
          common.user-home = "#{__dirname}/fixtures"

        before ->
          config.clean!
          config.load "#{__dirname}/fixtures/config/local"

        it 'should not exist global config', ->
          expect config.global .to.be.null

        it 'should get the local config', ->
          expect config.local .to.be.an 'object'

        it 'should get the local project config data', ->
          expect config.get 'local-project' .to.be.an 'object'

      describe 'global and local config', (_) ->

        before ->
          process.env[CONFVAR] = "#{__dirname}/fixtures/config/global/.croakrc"

        before ->
          config.load "#{__dirname}/fixtures/config/local"

        after ->
          process.env[CONFVAR] = ''

        it 'should load the config properly', ->
          expect config.global .to.be.an 'object'
          expect config.local .to.be.an 'object'
          expect config.get 'global-project' .to.be.an 'object'
          expect config.get 'local-project' .to.be.an 'object'

      describe 'discovering local file', (_) ->

        it 'should discover the file', ->
          expect config.local-file "#{__dirname}/fixtures/config/local/folder/sub-folder"
            ..to.be.equal "#{__dirname}/fixtures/config/local/#{FILENAME}"

        it 'should not discover the file', ->
          folder = "#{__dirname}/fixtures/config/local/folder/sub/nested/sub-nested/ultra-nested"
          expect config.local-file folder
            ..to.be.equal join process.cwd!, FILENAME


  describe 'write', (_) ->

    before ->
      process.env[CONFVAR] = "#{__dirname}/fixtures/.tmp/config/global/"
      process.chdir "#{__dirname}/fixtures/.tmp/config/local"

    before ->
      config.clean!

    it 'should read non-existent files', ->
      expect config.global .to.be.null
      expect config.local .to.be.null

    describe 'API', ->

      describe 'set()', (_) ->

        before-each ->
          config.clean!

        it 'should add create a new global project', ->
          projectConf =
            gruntfile: "#{__dirname}/fixtures/config/"
            force: true
            stack: true

          expect config.set 'project', projectConf .to.be.equal projectConf
          expect config.get 'project' .to.be.an 'object'
          expect config.global .to.be.an 'object'

        it 'should add create a new local project', ->
          projectConf =
            gruntfile: "#{__dirname}/fixtures/config/"
            force: true
            stack: true

          expect config.set 'local-project', projectConf, true .to.be.equal projectConf
          expect config.get 'local-project' .to.be.an 'object'
          expect config.local .to.be.an 'object'

        describe 'evil testing: bad types', (_) ->

          it 'should not create a new project', ->
            expect config.set undefined, [], true .to.be.null
            expect config.get 'undefined' .to.be.null
            expect config.local .to.be.null

    describe 'E2E', ->

      describe 'global file', (_) ->

        it 'should add config options to global config', ->
          global-project =
            gruntfile: "${HOME}/grunt/global-project/Gruntfile.js"
            register_tasks: false

          expect config.set 'global-project', global-project .to.deep.equal global-project

        it 'should write global config', ->
          config.write!
          expect fs.existsSync "#{process.env[CONFVAR]}/#{FILENAME}" .to.be.true

        it 'should clean and read config from disk', ->
          config.clean!
          config.load!

        it 'should read the config data from disk', ->
          expect config.get 'global-project' .to.be.an 'object'
          expect config.get 'global-project'
            ..to.have.property 'register_tasks'
            ..that.is.a 'boolean'

      describe 'local file', (_) ->

        it 'should add config options to local config', ->
          local-project =
            gruntfile: "${HOME}/grunt/local-project/Gruntfile.js"
            register_tasks: false

          expect config.set 'local-project', local-project, true .to.deep.equal local-project

        it 'should write local config', ->
          config.write!
          expect fs.existsSync "#{__dirname}/fixtures/.tmp/config/local/#{FILENAME}" .to.be.true

        it 'should clean and read config from disk', ->
          config.clean!
          config.load!

        it 'should read the config data from disk', ->
          expect config.get 'local-project' .to.be.an 'object'
          expect config.get 'local-project'
            ..to.have.property 'register_tasks'
            ..that.is.a 'boolean'

  describe 'update', ->

    before ->
      config.clean!

    before ->
      process.env[CONFVAR] = "#{__dirname}/fixtures/.tmp/config/global/"

    before ->
      project =
        gruntfile: "${HOME}/project/Gruntfile.js"
        register_tasks: false

      config.set 'project', project
      config.write!

    describe 'existent project', (_) ->

      it 'should update gruntfile option', ->
        project-data =
          gruntfile: "${HOME}/new-project/Gruntfile.js"

        expect config.update 'project', project-data
          ..to.have.property 'gruntfile'
          ..that.match /new-project/

      it 'should update register_tasks option', ->
        project-data =
          register_tasks: true

        expect config.update 'project', project-data
          ..to.have.property 'register_tasks'
          ..that.be.equal true

      it 'should write and load changes from disk', ->
        config.write!
        config.clean!
        config.load!

      it 'should project exists', ->
        expect config.get 'project' .to.be.an 'object'

      it 'project should have the expected options', ->
        expect config.get 'project'
          ..to.have.property 'gruntfile'
          ..that.match /new-project/
        expect config.get 'project'
          ..to.have.property 'register_tasks'
          ..that.be.equal true

    describe 'non-existent project', (_) ->

      it 'should update gruntfile option', ->
        project-data =
          gruntfile: "${HOME}/new-project/Gruntfile.js"

        expect config.update 'new-project', project-data
          ..to.have.property 'gruntfile'
          ..that.match /new-project/

      it 'should update register_tasks option', ->
        project-data =
          register_tasks: true

        expect config.update 'new-project', project-data
          ..to.have.property 'register_tasks'
          ..that.be.equal true

      it 'should write and load changes from disk', ->
        config.write!
        config.clean!
        config.load!

      it 'should project exists', ->
        expect config.get 'project' .to.be.an 'object'


  describe 'remove', (_) ->

    before ->
      config.clean!

    before ->
      process.env[CONFVAR] = "#{__dirname}/fixtures/.tmp/config/global/"

    before ->
      project =
        gruntfile: "${HOME}/project/Gruntfile.js"
        stack: true
        register_tasks: false

      config.set 'project', project
      config.write!

    it 'should remove an option', ->
      expect config.remove 'project.stack' .to.be.equal true

    it 'should not exists the removed option', ->
      expect config.get 'project.stack' .to.be.null

    it 'should remove existent project', ->
      expect config.remove 'project' .to.be.true

    it 'should remove non-existent project', ->
      expect config.remove 'non-existent' .to.be.equal true

    it 'should write and load changes from disk', ->
      config.write!
      config.clean!
      config.load!

    it 'should not exist the project', ->
      expect config.get 'project' .to.be.null


