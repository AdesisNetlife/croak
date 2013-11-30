require! {
  mkdirp
  fs
  join: path.join
  expect: chai.expect
  common: '../lib/common'
  config: '../lib/config'
}
{ FILENAME, CONF-VAR } = require '../lib/constants'

describe 'Config', ->

  home-var = if process.platform is 'win32' then 'USERPROFILE' else 'HOME'

  before ->
    mkdirp.sync "#{__dirname}/fixtures/temp/config/global"
    mkdirp.sync "#{__dirname}/fixtures/temp/config/local"

  describe 'file location', (_) ->

    it 'should be expect config global path', ->
      expect(config.global-file!).to.be.equal join common.home, FILENAME

    it 'should be expect config local path', ->
      expect(config.local-file!).to.be.equal join process.cwd!, FILENAME

    describe 'custom environment variable path', (_) ->

      before ->
        process.env[CONF-VAR] = "#{__dirname}/fixtures/config/global/.croakrc"

      after ->
        process.env[CONF-VAR] = ''
  
      it 'should have the expeted path', ->
        expect(config.global-file!).to.be.equal "#{__dirname}/fixtures/config/global/.croakrc"


  describe 'read', ->

    describe 'bad formed or missing config files', (_) ->

      it 'bad formed ini file', ->

    describe 'global config', (_) ->
    
      before ->
        common.home = "#{__dirname}/fixtures/config/global"

      before ->
        config.load!

      after ->
        common.home = home-var

      it 'should read the config properly', ->
        expect(config.global).to.be.an 'object'
        expect(config.local).to.be.null
        expect(config.project 'global-project').to.be.an 'object'
        
    describe 'local config', (_) ->

      before ->
        common.home = "#{__dirname}/fixtures"

      before ->
        config.clean!
        config.load "#{__dirname}/fixtures/config/local"

      it 'should not exist global config', ->
        expect(config.global).to.be.null

      it 'should get the local config', ->
        expect(config.local).to.be.an 'object'
      
      it 'should get the local project config data', ->
        expect(config.project 'local-project').to.be.an 'object'

    describe 'global and local config', (_) ->

      before ->
        process.env[CONF-VAR] = "#{__dirname}/fixtures/config/global/.croakrc"

      before ->
        config.load "#{__dirname}/fixtures/config/local"

      after ->
        process.env[CONF-VAR] = ''

      it 'should load the config properly', ->
        expect(config.global).to.be.an 'object'
        expect(config.local).to.be.an 'object'
        expect(config.project 'global-project').to.be.an 'object'
        expect(config.project 'local-project').to.be.an 'object'


  describe 'write', (_) ->

    before ->
      process.env[CONF-VAR] = "#{__dirname}/fixtures/temp/config/global/"
      process.chdir "#{__dirname}/fixtures/temp/config/local"

    before ->
      config.clean!

    it 'should read non-existent files', ->
      expect(config.global).to.be.null
      expect(config.local).to.be.null

    describe 'global file', (_) ->

      it 'should add config options to global config', ->
        global-project = 
          grunt_path: "${HOME}/grunt/global-project/Gruntfile.js"
          register_tasks: false

        expect(config.project 'global-project', global-project).to.deep.equal global-project

      it 'should write global config', ->
        config.write!
        expect(fs.existsSync "#{process.env[CONF-VAR]}/#{FILENAME}").to.be.true
      
      it 'should clean and read config from disk', ->
        config.clean!
        config.load!

      it 'should read the config data from disk', ->
        expect(config.project 'global-project').to.be.an 'object'
        expect config.project 'global-project'
          ..to.have.property 'register_tasks'
          ..that.is.a 'boolean'

    describe 'local file', (_) ->

      it 'should add config options to local config', ->
        local-project = 
          grunt_path: "${HOME}/grunt/local-project/Gruntfile.js"
          register_tasks: false

        expect(config.project 'local-project', local-project, true).to.deep.equal local-project

      it 'should write local config', ->
        config.write!
        expect(fs.existsSync "#{__dirname}/fixtures/temp/config/local/#{FILENAME}").to.be.true
      
      it 'should clean and read config from disk', ->
        config.clean!
        config.load!

      it 'should read the config data from disk', ->
        expect(config.project 'local-project').to.be.an 'object'
        expect config.project 'local-project' 
          ..to.have.property 'register_tasks'
          ..that.is.a 'boolean'

  describe 'update', ->

    before ->
      config.clean!

    before ->
      process.env[CONF-VAR] = "#{__dirname}/fixtures/temp/config/global/"

    before ->
      project = 
        grunt_path: "${HOME}/project/Gruntfile.js"
        register_tasks: false

      config.project 'project', project
      config.write!

    describe 'existent project', (_) -> 

      it 'should update grunt_path option', ->
        project-data = 
          grunt_path: "${HOME}/new-project/Gruntfile.js"

        expect config.update 'project', project-data
          ..to.have.property 'grunt_path'
          ..that.match /new-project/

      it 'should update register_tasks option', ->
        project-data = 
          register_tasks: true

        expect(config.update 'project', project-data)
          ..to.have.property 'register_tasks'
          ..that.be.equal true

      it 'it should write and load changes from disk', ->
        config.write!
        config.clean!
        config.load!

      it 'should project exists', -> 
        expect(config.project 'project').to.be.an 'object'

      it 'project should have the expected options', -> 
        expect config.project 'project'
          ..to.have.property 'grunt_path'
          ..that.match /new-project/
        expect config.project 'project'
          ..to.have.property 'register_tasks'
          ..that.be.equal true

    describe 'non-existent project', (_) -> 

      it 'should update grunt_path option', ->
        project-data = 
          grunt_path: "${HOME}/new-project/Gruntfile.js"

        expect config.update 'new-project', project-data
          ..to.have.property 'grunt_path'
          ..that.match /new-project/

      it 'should update register_tasks option', ->
        project-data = 
          register_tasks: true

        expect config.update 'new-project', project-data
          ..to.have.property 'register_tasks'
          ..that.be.equal true

      it 'it should write and load changes from disk', ->
        config.write!
        config.clean!
        config.load!

      it 'should project exists', -> 
        expect(config.project 'project').to.be.an 'object'


  describe 'remove', (_) ->

    before ->
      config.clean!

    before ->
      process.env[CONF-VAR] = "#{__dirname}/fixtures/temp/config/global/"

    before ->
      project = 
        grunt_path: "${HOME}/project/Gruntfile.js"
        register_tasks: false

      config.project 'project', project
      config.write!  

    it 'should remove existent project', ->
      expect config.remove 'project'
        ..to.be.equal true

    it 'should remove non-existent project', ->
      expect config.remove 'non-existent'
        ..to.be.equal true


