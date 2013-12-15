require! 'resolve'

module <- <[ async exit coffee-script rimraf ]>forEach
module-path = resolve.sync module, basedir: "#{__dirname}/../node_modules/grunt/node_modules"
exports[module] = require module-path if module-path
