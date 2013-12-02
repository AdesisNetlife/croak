require! {
  suppose
  spawn: child_process.spawn
  expect: chai.expect
  version: '../package.json'.version
}

cwd = process.cwd!
node = process.execPath
croak = [ "#{__dirname}/../bin/croak" ]

exec = (type, args, callback) ->
  command = spawn node, croak ++ args
  if type is \close
    command.on type, callback
  else
    command.stdout.on type, ->
      callback it.to-string!

describe 'CLI', ->

  describe 'flags', (_) ->

    it 'should return the expected version', (done) ->
      exec \data, <[--version]>, ->
        expect it .to.match new RegExp "#{version}"
        done!

    it 'should show the help', (done) ->
      exec \close, <[--help]>, ->
        expect it .to.be.equal 0
        done!

  describe 'command', ->

    describe 'run', (_) ->

      before ->
        process.chdir "#{__dirname}/fixtures/project/src/"

      after ->
        process.chdir cwd

      it 'should run the "log" task', (done) ->
        exec \close, <[run log]>, ->
          expect it .to.be.equal 0
          done!

      it 'should run the "foo:bar" sub task', (done) ->
        exec \close, <[run log:bar]>, ->
          expect it .to.be.equal 0
          done!

      it 'should run croak test task', (done) ->
        exec \close, <[run croak_test]>, ->
          expect it .to.be.equal 0
          done!

      it 'should not run an inexistent task', (done) ->
        exec \close, <[run inexistent]>, ->
          expect it .to.be.equal 3
          done!

    describe 'grunt', (_) ->

      it 'should show the grunt help', (done) ->
        exec \close, <[grunt --help]>, ->
          expect it .to.be.equal 0
          done!

      it 'should show the grunt version', (done) ->
        exec \data, <[grunt --version]>, ->
          expect it .to.match /grunt/i
          done!
