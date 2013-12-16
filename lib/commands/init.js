var croak, prompt, async, FILENAME, program, ref$, echo, exit, file, x$, init;
croak = require('../croak');
prompt = require('../prompt');
async = require('../modules').async;
FILENAME = require('../constants').FILENAME;
program = require('commander');
ref$ = require('../common'), echo = ref$.echo, exit = ref$.exit, file = ref$.file;
x$ = program.command('init [name]');
x$.description('\n  Create new projects in .croakrc');
x$.usage('[options]');
x$.option('--force', 'Force command execution');
x$.option('-x, --gruntfile <path>', 'Specifies the Gruntfile path');
x$.option('-z, --pkg <name>', 'Specifies the build node package to use');
x$.option('-g, --global', 'Creates a global config file');
x$.option('-s, --sample', 'Creates a file with a sample project config');
x$.option('-d, --usedef', 'Set the project to use by default');
x$.on('--help', function(){
  return echo('Usage examples:\n\n  $ croak init\n  $ croak init -g\n  $ croak init project --sample\n  $ croak init my-project -x ../path/to/Gruntfile.js\n  $ croak init -p my-project -z build-pkg -g\n');
});
x$.action(function(){
  return init.apply(this, arguments);
});
module.exports = init = function(name, options){
  var pkg, sample, gruntfile, parent, global, force, usedef, setDefault, setConfigProject, getConfigPath, successMessage, writeConfig, createProjectWithPackage, createProjectWithGruntfile, createSampleProject, promptCreationProcess;
  pkg = options.pkg, sample = options.sample, gruntfile = options.gruntfile, parent = options.parent, global = options.global, force = options.force, usedef = options.usedef;
  croak.config.load();
  setDefault = function(name, local){
    return croak.config.set('$default', name, local);
  };
  setConfigProject = function(project, data, global){
    var local;
    local = !global;
    croak.config.set(project, data, local);
    if (usedef) {
      return setDefault(project, local);
    }
  };
  getConfigPath = function(){
    return croak.config.dirname()[global ? 'global' : 'local'];
  };
  successMessage = function(){
    return echo(
    "\n" + FILENAME + " created successfully in: " + getConfigPath() + "\n\nTo start using Grunt via Croak, simply run:\n$ croak run task -p my-project\n\nThank you for using Croak!");
  };
  writeConfig = function(){
    var message;
    try {
      croak.config.write();
      return successMessage();
    } catch (e$) {
      message = e$.message;
      return exit(1)(
      "Cannot create the file: " + message);
    }
  };
  createProjectWithPackage = function(project, pkg){
    var data;
    data = {
      'package': pkg
    };
    setConfigProject(project, data, global);
    writeConfig();
    return exit(0);
  };
  createProjectWithGruntfile = function(project, gruntfile){
    var data;
    data = {
      gruntfile: gruntfile
    };
    setConfigProject(project, data, global);
    writeConfig();
    return exit(0);
  };
  createSampleProject = function(){
    var createDefault;
    createDefault = function(){
      var projectName, data;
      projectName = name || 'name';
      data = {
        gruntfile: '../path/to/Gruntfile.js',
        extend: true,
        overwrite: false,
        register_tasks: false,
        debug: false,
        stack: true
      };
      return setConfigProject(projectName, data, global);
    };
    createDefault();
    writeConfig();
    return exit(0);
  };
  promptCreationProcess = function(){
    var data, project, enterProject, enterHasPackage, enterGruntfile, enterExtend, enterOverride, enterRegisterTasks, enterSetDefaultProject, save;
    data = {};
    project = null;
    enterProject = function(done){
      if (project = name) {
        return done();
      }
      return prompt("Enter the project name:", function(err, name){
        if (croak.config.get(
        name) !== null && !force) {
          exit(1)(
          "Project '" + name + "' already exists. Use --force to override it");
        }
        project = name;
        return done();
      });
    };
    enterHasPackage = function(done){
      return prompt("The project has a node.js build package? [Y/n]:", 'confirm', function(err, it){
        if (!it) {
          return done();
        }
        return prompt("Enter the package name:", function(err, it){
          data['package'] = it;
          return done();
        });
      });
    };
    enterGruntfile = function(done){
      if (data['package']) {
        return done();
      }
      return prompt("Enter the Gruntfile path (e.g: ${HOME}/build/Gruntfile.js):", function(err, it){
        data.gruntfile = it;
        return done();
      });
    };
    enterExtend = function(done){
      if (!global) {
        return done();
      }
      return prompt("Enable extend tasks? [Y/n]:", 'confirm', function(err, it){
        data.extend = it;
        return done();
      });
    };
    enterOverride = function(done){
      if (!global) {
        return done();
      }
      return prompt("Enable overwrite tasks? [Y/n]:", 'confirm', function(err, it){
        data.overwrite = it;
        return done();
      });
    };
    enterRegisterTasks = function(done){
      if (!global) {
        return done();
      }
      return prompt("Enable task registering? [Y/n]:", 'confirm', function(err, it){
        data.register_tasks = it;
        return done();
      });
    };
    enterSetDefaultProject = function(done){
      if (usedef) {
        return done();
      }
      return prompt("Use the '" + project + "' project by default? [Y/n]:", 'confirm', function(err, it){
        usedef = it;
        return done();
      });
    };
    save = function(){
      setConfigProject(project, data, global);
      writeConfig();
      return exit(0);
    };
    return async.series([enterProject, enterHasPackage, enterGruntfile, enterOverride, enterExtend, enterRegisterTasks, enterSetDefaultProject, save]);
  };
  if (gruntfile && name) {
    return createProjectWithGruntfile(name, gruntfile);
  } else if (pkg && name) {
    return createProjectWithPackage(name, pkg);
  } else if (sample) {
    return createSampleProject();
  } else {
    return promptCreationProcess();
  }
};