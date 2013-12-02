module.exports = function (grunt) {
  
  grunt.initConfig({
    log: {
      foo: [1, 2, 3],
      bar: 'hello world',
      baz: false
    },
    read: {
      file: __dirname + '/file.json'
    },
    croak_test: {
      path: '<%= croak.cwd %>'
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