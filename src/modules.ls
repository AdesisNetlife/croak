resolve = require 'resolve'

importModule = (module) -> 
  exports[module] = require resolve.sync 'colors', basedir: __dirname + '/../node_modules/grunt/node_modules'

<[ lodash async exit coffee-script, rimraf ]>forEach importModule
