fs = require 'fs'

# { resolved module name : date of file }
cache = {}

module.exports = (_require, name) ->
  resolvedName = _require.resolve(name)
  lastModified = fs.lstatSync(resolvedName).mtime
  if not cache[resolvedName] or lastModified > cache[resolvedName]
    cache[resolvedName] = lastModified
    delete _require.cache[resolvedName]
  return _require(name)
