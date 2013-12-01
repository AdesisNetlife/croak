require! {
  suppose
  spawn: child_process.spawn
  expect: chai.expect
  version: '../package.json'.version
}

cwd = process.cwd!
node = process.execPath
croak = [ "#{__dirname}/../bin/croak" ]

describe 'CLI', ->

  describe 'flags', (_) ->

    it 'should return the expected version', (done) ->
      spawn node, croak ++ ['--version']
        ..stdout.on 'data', ->
          expect(it.to-string 'utf-8').to.match new RegExp "#{version}"
          done!

  describe 'command', ->

    describe 'run', (_) ->

      before ->
        process.chdir "#{__dirname}/fixtures/project/grunt/src/"

      after ->
        process.chdir cwd

      it 'should load the default config', (done) ->
        spawn node, croak ++ ['run', 'server']
          ..stdout.on 'data', ->
            expect(it.to-string 'utf-8').to.match new RegExp "#{version}"
            done!

