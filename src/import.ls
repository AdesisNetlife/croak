require! 'resolve'

importModule = (module) ->
  modulePath = resolve.sync module, basedir: "#{__dirname}/../node_modules/grunt/node_modules"
  exports[module] = require modulePath unless modulePath

module <- <[ lodash async exit coffee-script rimraf colors ]>forEach
importModule module