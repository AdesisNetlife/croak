require! {
  fs
  sinon
  join: path.join
  expect: chai.expect
  croak: '../lib/croak'
}
{ FILENAME, CONFVAR } = require '../lib/constants'

home-var = if process.platform is 'win32' then 'USERPROFILE' else 'HOME'
cwd = process.cwd!

describe 'Croak', ->

  describe 'API', ->

    describe 'public properties', (_) ->

      it 'should expose the version property', ->
        expect croak.version .to.be.a 'string'

      it 'should expose the gruntVersion property', ->
        expect croak.grunt-version .to.be.a 'string'

      it 'should expose the grunt object', ->
        expect croak.grunt .to.be.an 'object'

      it 'grunt object should have the cli() method', ->
        expect croak.grunt.cli .to.be.a 'function'

      it 'should expose the croak config object', ->
        expect croak.config .to.be.an 'object'


    describe 'public methods', (_) ->
      
      it 'should expose the init() method', ->
        expect croak.run .to.be.an 'function'

      it 'should expose the run() method', ->
        expect croak.run .to.be.an 'function'

      it 'should expose the run-grunt() method', ->
        expect croak.run .to.be.an 'function'


  describe 'run()', (_) ->
    spy = project = options = null

    before ->
      project := 
        extend: false
        $name: 'croak'
        gruntfile: "#{__dirname}/fixtures/project/grunt/Gruntfile.js"
    
    before ->
      options :=
        base: "#{__dirname}/fixtures/project/src"
        force: true
        invalid: null

    before ->
      croak.grunt.cli = -> spy ...

    before ->
      spy := sinon.spy!
    
    it 'should call run() method', ->
      croak.run project, options

    it 'should call grunt.cli()', ->
      expect spy.called .to.be.true

    it 'should be called with the proper object', ->
      expect spy.get-call(0)args[0] .to.deep.equal do
        gruntfile: "#{__dirname}/fixtures/project/grunt/Gruntfile.js"
        base: "#{__dirname}/fixtures/project/src"
        force: true


  describe 'runGrunt()', (_) ->
    spy = options = null
   
    before ->
      options :=
        gruntfile: "#{__dirname}/fixtures/project/grunt/Gruntfile.js"
        base: "#{__dirname}/fixtures/project/src"
        npm: "custom-tasks"
        force: true
        invalid: 'invalid property'

    before ->
      croak.grunt.cli = -> spy ...

    before ->
      spy := sinon.spy!
    
    it 'should call run() method', ->
      croak.run-grunt options

    it 'should call grunt.cli()', ->
      expect spy.called .to.be.true

    it 'should be called with the proper object', ->
      expect spy.get-call(0)args[0] .to.deep.equal do
        gruntfile: "#{__dirname}/fixtures/project/grunt/Gruntfile.js"
        base: "#{__dirname}/fixtures/project/src"
        npm: "custom-tasks"
        force: true


