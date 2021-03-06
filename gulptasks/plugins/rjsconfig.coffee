
fs     = require("fs")
vm     = require("vm")
es     = require("event-stream")
coffee = require("gulp-coffee")

ConfigFile = "./src/ide/config.coffee"

readRequirejsConfig = ( path )->

  # We should compile the config.coffee without conditionalCompiler
  # instead of reading the compiled config.js
  s = fs.readFileSync path

  pipeline = es.through ()-> null

  pipeline.pipe(coffee({bare:true})).pipe es.through ( f )-> s = f.contents.toString("utf8");null

  pipeline.emit "data", {
    path     : path
    contents : s
    isNull   : ()-> false
    isStream : ()-> false
  }


  Context =
    window    : false
    version   : ""
    language  : ""
    requirejs : {}
    require   : ()-> return

  Context.require.config = ( config )->
    this.config = config
    null

  Context = vm.createContext( Context )
  vm.runInContext( s, Context )

  Context.require.config


extend = ( a )->
  for arg, idx in arguments
    if idx is 0 then continue
    for i of arg
      a[i] = arg[i]
  a

transformModules = ( config, traceMode )->
  # In traceMode, we doesn't exclude anything.
  # So that we can know every dependency of a module.

  # Transform the bundles
  exclude = [] # i18n!/nls/lang.js must have a suffix `.js`, otherwise, it will have error when compiling. And we always exclude the lang from anything.

  config.modules = []
  bundleExcludes = config.bundleExcludes || {}
  for bundleName, bundles of config.bundles

    config.modules.push {
      name    : bundleName
      include : bundles
      exclude : if traceMode then [] else exclude.concat( bundleExcludes[bundleName] || [] )
    }

    # We assume the first bundle is "requirelib", and "requirelib" cannot have "i18n!xxx" excluded.
    if exclude.length == 0
      exclude.push "i18n!/nls/lang.js"

    exclude.push bundleName

  delete config.bundles
  config

getConfig = ( debugMode = true, outputPath = "./deploy", traceMode = false )->
  if debugMode is true
    extra =
      optimize        : "none"
      optimizeCss     : "none"
      skipDirOptimize : true
  else
    extra =
      optimizeCss : "standard"

  config = extend( readRequirejsConfig( ConfigFile ), extra, {
    removeCombined : true
    baseUrl : "./build"
    dir     : outputPath
  } )

  # Read the config. Transform the bundles to modules
  transformModules( config, traceMode )

  ###
  # Example of the modules definination
  config.modules = [
    {
      name    : "vender/vender"
      create  : true
      include : [ "jquery", "underscore", "backbone", "handlebars", "Meteor" ]
    }

    {
      name   : "ui/ui"
      create : true
      include : ["UI.tooltip","UI.scrollbar"]
      exclude : [ "vender/vender" ]
    }
  ]
  ###

  config

module.exports = getConfig
