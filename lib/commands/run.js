var croak, util, program, ref$, echo, exit, x$, run;
croak = require('../croak');
util = require('../common');
program = require('commander');
ref$ = require('../common'), echo = ref$.echo, exit = ref$.exit;
x$ = program.command('run [task]');
x$.description('\n  Run Grunt tasks');
x$.usage('<task> [options]');
x$.option('-p, --project <path>', 'Specifies the project to run');
x$.option('-c, --croakrc <path>', 'Use a custom .croakrc file path');
x$.option('-x, --gruntfile <path>', 'Specifies the Gruntfile path');
x$.option('-z, --pkg <name>', 'Specifies the build node package to use');
x$.option('-b, --base <path>', 'Specify an alternate base path');
x$.option('-f, --force', 'A way to force your way past warnings');
x$.option('-d, --debug', 'Enable debugging mode for tasks that support it');
x$.option('-v, --verbose', 'Verbose mode. A lot more information output');
x$.option('-t, --tasks <path>', 'Additional directory paths to scan for task and "extra" files');
x$.option('-n, --npm <path>', 'Npm-installed grunt plugins to scan for task and "extra" files');
x$.option('-w, --no-write', 'Disable writing files (dry run)');
x$.option('--no-color', 'Disable colored output');
x$.option('--stack', 'Print a stack trace when exiting with a warning or fatal error');
x$.option('--completion', 'Output shell auto-completion rules');
x$.on('--help', function(){
  return echo('Usage examples:\n\n  $ croak run\n  $ croak run task -p my-project\n  $ croak run task --verbose --force --stack\n  $ croak run task --gruntfile path/to/Gruntfile.js\n  $ croak run task --base path/to/base/dir/\n');
});
x$.action(function(){
  return run.apply(this, arguments);
});
run = function(task, options){
  var gruntfile, base, debug, verbose, parent, project, croakrc, echoDebug, message;
  gruntfile = options.gruntfile, base = options.base, debug = options.debug, verbose = options.verbose, parent = options.parent, project = options.project, croakrc = options.croakrc;
  echoDebug = function(){
    if (debug || verbose) {
      return echo.apply(null, ['>>'.green].concat(Array.prototype.slice.call(arguments), ['\n']));
    }
  };
  echoDebug(
  'Croak started in verbose mode'.green);
  try {
    croak.load(croakrc);
  } catch (e$) {
    message = e$.message;
    exit(1)(
    "Cannot read .croakrc: " + message);
  }
  if (!gruntfile) {
    if (!project) {
      echoDebug(
      'Project argument not specified, trying to resolve project from croak.config...');
      if (!(project = croak.config.projectResolve())) {
        exit(1)(
        'Cannot resolve a default project, you must specify the project. Use:\n$ croak run task -p project');
      } else {
        echoDebug(
        "Config file found, using the default project '" + project.$project + "'...");
      }
    } else {
      if (!(project = croak.config.get(
      project))) {
        exit(2)(
        'Project not found. Have you actually configured it?');
      }
    }
  }
  if (project && !gruntfile) {
    gruntfile = project.gruntfile;
  }
  if (!gruntfile) {
    exit(2)(
    "Cannot find the Gruntfile. Missing required 'gruntfile' option");
  }
  echoDebug(
  "Looking for the Gruntfile in:\n" + gruntfile);
  if (!(gruntfile = util.gruntfilePath(gruntfile))) {
    exit(2)(
    'Gruntfile not found. Cannot run the task');
  }
  if (project) {
    echoDebug(
    "Running project '" + project.$project + "'...");
  }
  echoDebug(
  "Gruntfile loaded:\n" + gruntfile);
  echoDebug(
  ("Running " + (task || 'default') + " task...").cyan);
  options.croakrc = croakrc;
  options.gruntfile = gruntfile;
  options.base = base;
  options.debug = debug;
  options.verbose = verbose;
  return croak.init(project, options);
};