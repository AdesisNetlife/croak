require! 'resolve'

module <- <[ async exit coffee-script rimraf ]>for-each
module-path = resolve.sync module, basedir: "#{__dirname}/../node_modules/grunt/node_modules"
exports <<< (module): module-path |> require if module-path
