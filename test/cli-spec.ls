require! {
  fs
  suppose
  mkdirp
  rimraf
  spawn: child_process.spawn
  expect: chai.expect
  version: '../package.json'.version
}

cwd = process.cwd!
node = process.execPath
croak = "#{__dirname}/../bin/croak"

exists = ->
  fs.exists-sync it

read = ->
  fs.read-file-sync it

exec = (type, args, callback) ->
  command = spawn node, [ croak ] ++ args, cwd: process.cwd!
  if type is 'close'
    command.on type, callback
  else
    data = ''
    command.stdout.on type, -> data += it.to-string!
    command.on 'close', -> data |> callback _, it

describe 'CLI', ->

  describe 'flags', (_) ->

    it 'should return the expected version', (done) ->
      exec 'data', <[--version]>, ->
        expect it .to.match new RegExp "#{version}"
        done!

    it 'should show the help', (done) ->
      exec 'close', <[--help]>, ->
        expect it .to.be.equal 0
        done!

  describe 'grunt', (_) ->

    it 'should show the grunt help', (done) ->
      exec 'close', <[grunt --help]>, ->
        expect it .to.be.equal 0
        done!

    it 'should show the grunt version', (done) ->
      exec 'data', <[grunt --version]>, ->
        expect it .to.match /grunt/i
        done!

    describe 'run task directly using grunt', (_) ->

      before ->
        process.chdir "#{__dirname}/fixtures/project/grunt/"

      after ->
        process.chdir cwd

      it 'should run the "log" task', (done) ->
        exec 'data', <[grunt log]>, ->
          expect it .to.match /hello croak/i
          done!

  describe 'command', ->

    before ->
      process.chdir "#{__dirname}/fixtures/project/src/"

    after ->
      process.chdir cwd

    describe 'run', (_) ->

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
          process.chdir "#{__dirname}/fixtures/empty/"

        after ->
          process.chdir cwd

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
            process.chdir "#{__dirname}/fixtures/project/src/"

          # todo, relative paths and --croakrc path
          it 'should use a valid base path', (done) ->
            exec 'close', <[run log --base]> ++ ["#{__dirname}/fixtures/empty"], ->
              expect it .to.be.equal 0
              done!

    describe 'config', (_) ->

      before ->
        process.chdir "#{__dirname}/fixtures/config/local"

      after ->
        process.chdir cwd

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


      describe 'create', (_) ->


    describe 'create', (_) ->
      dir = "#{__dirname}/fixtures/temp/cli/create"

      before ->
        rimraf.sync dir
        mkdirp.sync dir

      before ->
        process.chdir dir

      after ->
        process.chdir cwd

      it 'should create a new .croakrc local file', (done) ->
        suppose(croak, ['create'])
          .debug(fs.createWriteStream('cli.log'))
          .on(/project name:/).respond('sample\n')
          .on(/Gruntfile path \(/).respond('../../gruntfile/Gruntfile.js\n')
          .on(/overwriting tasks\?/).respond('n\n')
          .on(/extending tasks\?/).respond('y\n')
        .error (err) ->
          throw new Error err
        .end (code) ->
          expect code .to.be.equal 0
          expect exists "#{dir}/.croakrc" .to.be.true
          done!

      it 'should exists the created project', ->
        expect read "#{dir}/.croakrc" .to.match /\[sample\]/


