module.exports = (croak) ->
  croak.initConfig
    log:
      foo: {}
      bar: "hello croak"

    read:
      file: __dirname + "/file.json"

    croak_test:
      path: "#{__dirname}"
      version: "<%= grunt.version %>"

  croak.registerMultiTask "log", "Log stuff.", ->
    croak.log.writeln @target + ": " + @data

  croak.registerMultiTask "read", "Read file.", ->
    croak.log.writeln @target + ": " + @data

  croak.registerMultiTask "croak_test", "Croak test task", ->
    croak.log.writeln @target + ": " + @data

  croak.registerTask "default", ["log"]
