require! {
  suppose
  spawn: child_process.spawn
  expect: chai.expect
  version: '../package.json'.version
}

node-binary = "#{process.execPath}"
croak-binary = [ "#{__dirname}/../bin/croak" ]

describe 'CLI', ->

  describe 'flags', (_) ->

    it 'should return the expected version', (done) ->
      spawn node-binary, croak-binary ++ ['--version']
        ..stdout.on 'data', ->
          expect(it.to-string 'utf-8').to.match new RegExp "#{version}"
          done!

  describe 'run command', (_) ->

    it 'should return the expected value', ->
      