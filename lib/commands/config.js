var init, prompt, croak, async, program, ref$, echo, exit, x$, commands, loadConfig;
init = require('./init');
prompt = require('../prompt');
croak = require('../croak');
async = require('../modules').async;
program = require('commander');
ref$ = require('../common'), echo = ref$.echo, exit = ref$.exit;
x$ = program.command('config <action> [key] [value]');
x$.description('\n  Read/write/update/remove croak config');
x$.option('--force', 'Force the command execution');
x$.option('-p, --project', 'Specifies the project to run');
x$.option('-x, --gruntfile <path>', 'Specifies the Gruntfile path');
x$.option('-z, --pkg <name>', 'Specifies the build node package to use');
x$.option('-g, --global [path]', 'Use the global config file');
x$.option('-c, --croakrc [path]', 'Use a custom .croakrc file path');
x$.usage('[create|list|remove|set|get]');
x$.on('--help', function(){
  return echo('Usage examples:\n\n  $ croak config list\n  $ croak config create\n  $ croak config remove project\n  $ croak config get -g project.gruntfile\n  $ croak config set project.gruntfile ${HOME}/builder/Gruntfile.js\n');
});
x$.action(function(it){
  if (!commands[it]) {
    exit(1)(
    it + " command not supported. Use --help to see the available commands");
  }
  return commands[it].apply(commands, Array.prototype.slice.call(arguments).slice(1));
});
commands = {
  list: function(key, value, options){
    var croakrc, global, globalFlag, ref$, local;
    croakrc = options.croakrc, global = options.global;
    globalFlag = global;
    if (croakrc) {
      croak.config.localPath = croakrc;
    }
    ref$ = croak.config.raw(), global = ref$.global, local = ref$.local;
    if (global.data != null) {
      echo("; global " + global.path + "\n" + global.data);
    }
    if (local.data != null && !globalFlag) {
      return echo("; local " + local.path + "\n" + local.data);
    }
  },
  show: function(){
    return this.list.apply(this, arguments);
  },
  raw: function(){
    return this.list.apply(this, arguments);
  },
  create: function(name, value, options){
    return init(name, {
      sample: true,
      global: options.global
    });
  },
  add: function(){
    return this.create.apply(this, arguments);
  },
  remove: function(key, value, options){
    var croakrc, message;
    if (!key) {
      exit(1)(
      "Missing required 'key' argument");
    }
    croakrc = options.croakrc;
    loadConfig(
    croakrc);
    try {
      croak.config.remove(key);
      croak.config.write();
      return echo(
      "'" + key + "' was removed successfully from config");
    } catch (e$) {
      message = e$.message;
      return exit(1)(
      "Cannot delete '" + key + "' due to an error: " + message);
    }
  },
  'delete': function(){
    return this.remove.apply(this, arguments);
  },
  get: function(key, value, options){
    var croakrc, prop, data, own$ = {}.hasOwnProperty, results$ = [];
    if (!key) {
      exit(1)(
      "Missing required 'key' argument");
    }
    croakrc = options.croakrc;
    loadConfig(
    croakrc);
    if (value = croak.config.get(key.toLowerCase())) {
      if (typeof value === 'string') {
        return echo(
        value);
      } else {
        for (prop in value) if (own$.call(value, prop)) {
          data = value[prop];
          results$.push(echo(
          prop + ": " + data));
        }
        return results$;
      }
    } else {
      return exit(1)(
      "Config '" + key + "' value do not exists");
    }
  },
  set: function(key, value, options){
    var croakrc, global, message;
    if (!key) {
      exit(1)(
      "Missing required 'key' argument");
    }
    if (!value) {
      exit(1)(
      "Missing required 'value' argument");
    }
    croakrc = options.croakrc, global = options.global;
    loadConfig(
    croakrc);
    if (value = croak.config.set(key, value, !global)) {
      try {
        croak.config.write();
      } catch (e$) {
        message = e$.message;
        exit(1)(
        "Cannot save config due to an error: " + message);
      }
      return echo(
      "Value '" + key + "' updated successfully");
    } else {
      return exit(1)(
      "Cannot set '" + key + "'. Project '" + key.split('.')[0] + "' do not exists or it is an invalid option");
    }
  }
};
loadConfig = function(it){
  var message;
  try {
    return croak.config.load(it);
  } catch (e$) {
    message = e$.message;
    return exit(1)(
    "Cannot read .croakrc: " + message);
  }
};