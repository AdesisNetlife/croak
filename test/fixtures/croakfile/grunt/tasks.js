var grunt = require('grunt')

grunt.initConfig({
  log: {
    foo: {},
    bar: 'hello croak'
  },
  write: {
    file: __dirname + '/file.json'
  },
  parse: {
    path: '<%= grunt.cwd %>',
    version: '<%= grunt.version %>'
  }
})

grunt.registerMultiTask('log', 'Log stuff.', function() {
  grunt.log.writeln(this.target + ': ' + this.data)
})

grunt.registerMultiTask('write', 'Write file.', function() {
  grunt.log.writeln(this.target + ': ' + this.data)
})

grunt.registerMultiTask('parse', 'Parse contents', function() {
  grunt.log.writeln(this.target + ': ' + this.data)
})

grunt.registerTask('default', ['log'])
