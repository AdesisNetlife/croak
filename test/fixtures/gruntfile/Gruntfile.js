module.exports = function (grunt) {
  
  grunt.initConfig({
    log: {
      foo: {},
      bar: 'hello croak'
    },
    read: {
      file: __dirname + '/file.json'
    },
    croak_test: {
      path: '<%= croak.cwd %>',
      version: '<%= croak.version %>'
    }
  })

  grunt.registerMultiTask('log', 'Log stuff.', function() {
    grunt.log.writeln(this.target + ': ' + this.data)
  })

  grunt.registerMultiTask('read', 'Read file.', function() {
    grunt.log.writeln(this.target + ': ' + this.data)
  })

  grunt.registerMultiTask('croak_test', 'Croak test task', function() {
    grunt.log.writeln(this.target + ': ' + this.data)
  })

}