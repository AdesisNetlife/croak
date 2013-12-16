var init, program, ref$, echo, exit, file, x$;
init = require('./init');
program = require('commander');
ref$ = require('../common'), echo = ref$.echo, exit = ref$.exit, file = ref$.file;
x$ = program.command('add [name]');
x$.description('\n  Add new projects in .croakrc');
x$.usage('[options]');
x$.option('--force', 'Force command execution');
x$.option('-x, --gruntfile <path>', 'Specifies the Gruntfile path');
x$.option('-z, --pkg <name>', 'Specifies the build node package to use');
x$.option('-g, --global', 'Creates a global config file');
x$.option('-s, --sample', 'Creates a file with a sample project config');
x$.on('--help', function(){
  return echo('Usage examples:\n\n  $ croak add\n  $ croak add -g\n  $ croak add project --sample\n  $ croak add my-project -x ../path/to/Gruntfile.js\n  $ croak add -p my-project -z build-pkg -g\n');
});
x$.action(function(){
  return init.apply(this, arguments);
});