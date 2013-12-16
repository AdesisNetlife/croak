module.exports = function (croak) {

  croak.initConfig({
    log: {
      foo: {},
      bar: 'hello croak'
    },
    read: {
      file: __dirname + '/file.json'
    },
    croak_test: {
      path: __dirname,
      version: '<%= grunt.version %>'
    }
  })

  croak.registerMultiTask('log', 'Log stuff.', function() {
    grunt.log.writeln(this.target + ': ' + this.data)
  })

  croak.registerMultiTask('read', 'Read file.', function() {
    grunt.log.writeln(this.target + ': ' + this.data)
  })

  croak.registerMultiTask('croak_test', 'Croak test task', function() {
    grunt.log.writeln(this.target + ': ' + this.data)
  })

  croak.registerTask('default', ['log'])

}
