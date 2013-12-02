require! 'resolve'

module <- <[ lodash async exit coffee-script rimraf colors ]>forEach
module-path = resolve.sync module, basedir: "#{__dirname}/../node_modules/grunt/node_modules"
exports[module] = require(module-path) if module-path