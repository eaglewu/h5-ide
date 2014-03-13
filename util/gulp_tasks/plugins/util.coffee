
gutil    = require("gulp-util")
notifier = require("node-notifier")
fs       = require("fs")
spawn    = require('child_process').spawn
Q        = require("q")

util =
  log  : (e)-> console.log e
  noop : ()->

  cwd  : process.cwd()

  endsWith : ( string, pattern )->
    if string.length < pattern.length then return false

    idx      = 0
    startIdx = string.length - pattern.length

    while idx < pattern.length
      if string[ startIdx + idx ] isnt pattern[ idx ]
        return false
      ++idx

    true

  notify : ( msg )->
    if GLOBAL.gulpConfig.enbaleNotifier and msg
      notifier.notify {
        title   : "IDE Gulp"
        message : msg
      }, ()-> # Add an callback, so that windows won't fail.
    null

  compileTitle : ( extra, printTime = true )->

    time = if printTime then " @" + (new Date()).toLocaleTimeString() else ""

    title = "[" + gutil.colors.green("Compile#{time}") + "]"
    if extra
      title += " " + gutil.colors.inverse( extra )
    title

  deleteFolderRecursive : ( path )->
    if not fs.existsSync( path ) then return

    for file, index in ( fs.readdirSync( path ) || [] )
      curPath = path + "/" + file
      if fs.lstatSync( curPath ).isDirectory()
        util.deleteFolderRecursive( curPath )
      else
        fs.unlinkSync( curPath )

    fs.rmdirSync( path )
    null

  runCommand : ( command, args, options, handlers )->
    d = Q.defer()
    process = spawn( command, args, options )

    handlers = handlers || {}

    onData = if handlers.apply and handlers.call then handlers else handlers.onData

    process.on "exit", ()-> d.resolve()

    if handlers.onError
      process.on "error", handlers.onError

    if onData
      process.stderr.on("data", (d)-> onData d.toString("utf8"), "error" )
      process.stdout.on("data", (d)-> onData d.toString("utf8"), "out" )

    d.promise

module.exports = util
