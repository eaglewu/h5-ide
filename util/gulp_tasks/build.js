// Generated by CoffeeScript 1.6.2
var Buffer, EventEmitter, Helper, Q, StreamFuncs, buildLangSrc, changeHandler, checkWatchHealthy, chokidar, coffee, coffeelint, coffeelintOptions, compileCoffeeOnlyRegex, compileDev, compileIgnorePath, es, fs, gulp, gulpif, gutil, indexOf, notifier, path, tinylr, vm, watch;

gulp = require("gulp");

gutil = require("gulp-util");

path = require("path");

Buffer = require('buffer').Buffer;

es = require("event-stream");

Q = require("q");

fs = require("fs");

vm = require("vm");

EventEmitter = require("events").EventEmitter;

tinylr = require("tiny-lr");

chokidar = require("chokidar");

notifier = require("node-notifier");

coffee = require("gulp-coffee");

coffeelint = require("gulp-coffeelint");

gulpif = require("gulp-if");

indexOf = require("./indexof");

buildLangSrc = require("../../config/lang");

coffeelintOptions = {
  indentation: {
    level: "ignore"
  },
  no_tabs: {
    level: "ignore"
  },
  max_line_length: {
    level: "ignore"
  }
};

compileIgnorePath = /.src.(test|vender|ui)/;

compileCoffeeOnlyRegex = /.src.(service|model)/;

Helper = {
  shouldLintCoffee: function(f) {
    return !f.path.match(compileCoffeeOnlyRegex);
  },
  endsWith: function(string, pattern) {
    var idx, startIdx;

    if (string.length < pattern.length) {
      return false;
    }
    idx = 0;
    startIdx = string.length - pattern.length;
    while (idx < pattern.length) {
      if (string[startIdx + idx] !== pattern[idx]) {
        return false;
      }
      ++idx;
    }
    return true;
  },
  notify: function(msg) {
    if (GLOBAL.gulpConfig.enbaleNotifier) {
      notifier.notify({
        title: "IDE Gulp",
        message: msg
      }, function() {});
    }
    return null;
  },
  lrServer: void 0,
  createLrServer: function() {
    if (Helper.lrServer !== void 0) {
      return;
    }
    gutil.log(gutil.colors.bgBlue.white(" Starting livereload server... "));
    Helper.lrServer = tinylr();
    Helper.lrServer.server.removeAllListeners('error');
    Helper.lrServer.server.on("error", function(e) {
      if (e.code !== "EADDRINUSE") {
        return;
      }
      console.error('[LR Error] Cannot start livereload server. You already have a server listening on %s', Helper.lrServer.port);
      return Helper.lrServer = null;
    });
    Helper.lrServer.listen(GLOBAL.gulpConfig.livereloadServerPort, function(err) {
      if (err) {
        gutil.log("[LR Error]", "Cannot start livereload server");
        Helper.lrServer = null;
      }
      return null;
    });
    return null;
  },
  log: function(e) {
    return console.log(e);
  },
  noop: function() {},
  compileTitle: function(extra) {
    var title;

    title = "[" + gutil.colors.green("Compile @" + ((new Date()).toLocaleTimeString())) + "]";
    if (extra) {
      title += " " + gutil.colors.inverse(extra);
    }
    return title;
  },
  cwd: process.cwd(),
  watchRetry: 0,
  watchIsWorking: false,
  createWatcher: function() {
    var compileAfterGitAction, gitDebounceTimer, watcher;

    if (GLOBAL.gulpConfig.pollingWatch) {
      gutil.log(gutil.colors.bgBlue.white(" Watching file changes... ") + " [Polling]");
      watcher = new EventEmitter();
      gulp.watch(["./src/**/*.coffee", "./src/assets/**/*"], function(event) {
        var type;

        if (event.type === "added") {
          type = "add";
        } else if (event.type === "changed") {
          type = "change";
        } else {
          return;
        }
        watcher.emit(type, event.path);
        return null;
      });
    } else {
      gutil.log(gutil.colors.bgBlue.white(" Watching file changes... ") + " [Native FSevent, git pull will not trigger changes]");
      watcher = chokidar.watch("./src", {
        usePolling: false,
        useFsEvents: true,
        ignoreInitial: true,
        ignored: /([\/\\]\.)|src.(test|vender)/
      });
      gitDebounceTimer = null;
      compileAfterGitAction = function() {
        console.log("[" + gutil.colors.green("Git Action Detected @" + ((new Date()).toLocaleTimeString())) + "] Ready to re-compile the whole project");
        gitDebounceTimer = null;
        return compileDev();
      };
      gulp.watch(["./.git/HEAD", "./.git/refs/heads/develop", "./.git/refs/heads/**/*"], function(event) {
        if (gitDebounceTimer === null) {
          gitDebounceTimer = setTimeout(compileAfterGitAction, 300);
        }
        return null;
      });
    }
    return watcher;
  }
};

StreamFuncs = {
  jshint: require("./jshint"),
  lintReporter: require('./reporter'),
  coffeeErrorPrinter: function(error) {
    console.log(gutil.colors.red.bold("\n[CoffeeError]"), error.message.replace(process.cwd(), "."));
    Helper.notify("Error occur when compiling " + error.message.replace(process.cwd(), ".").split(":")[0]);
    return null;
  },
  throughCached: function(nextPipe) {
    var newCache, pipeline;

    if (!GLOBAL.gulpConfig.enableCache) {
      return nextPipe;
    }
    newCache = {};
    pipeline = es.through(function(file) {
      var utf8Content;

      if (newCache[file.path]) {
        utf8Content = file.contents.toString("utf8");
        if (newCache[file.path] === utf8Content) {
          if (GLOBAL.gulpConfig.verbose) {
            console.log("[Cached]", file.path);
          }
          return;
        }
      }
      if (!utf8Content) {
        utf8Content = file.contents.toString("utf8");
      }
      newCache[file.path] = utf8Content;
      this.emit("data", file);
      return null;
    });
    pipeline.pipe(nextPipe);
    return pipeline;
  },
  throughLiveReload: function() {
    return es.through(function(file) {
      if (Helper.lrServer) {
        Helper.lrServer.changed({
          body: {
            files: [file.path]
          }
        });
      }
      return null;
    });
  },
  throughCoffeeConditionalCompile: function() {
    return es.through(function(file) {
      var buffer, found, index;

      buffer = file.contents;
      index = 0;
      found = 0;
      while ((index = indexOf(buffer, "### env:prod ###", index)) !== -1) {
        if (GLOBAL.gulpConfig.verbose) {
          console.log("[EnvProdFound]", file.relative);
        }
        buffer[index + 13] = buffer[index + 14] = buffer[index + 15] = 32;
        index = indexOf(buffer, "### env:prod:end ###", index + 16);
        if (index === -1) {
          console.log("[Missing EnvProdEnd]");
          break;
        }
        if (GLOBAL.gulpConfig.verbose) {
          console.log("[EnvProdEndFound]", file.relative);
        }
        buffer[index + 0] = buffer[index + 1] = buffer[index + 2] = 32;
        index += 20;
        ++found;
      }
      if (found) {
        file.extra = "EnvProdFound";
        if (found > 1) {
          file.extra += " x" + found;
        }
      }
      this.emit("data", file);
      return null;
    });
  },
  throughLangSrc: function() {
    var gruntMock, pipeline, startPipeline,
      _this = this;

    startPipeline = StreamFuncs.throughCached(coffee());
    pipeline = startPipeline.pipe(es.through(function(file) {
      var ctx;

      console.log(Helper.compileTitle(), "lang-souce.coffee");
      ctx = vm.createContext({
        module: {}
      });
      vm.runInContext(file.contents.toString("utf8"), ctx);
      buildLangSrc.run(gruntMock, Helper.noop, ctx.module.exports);
      return null;
    }));
    pipeline.pipe(gulp.dest("."));
    gruntMock = {
      log: {
        error: Helper.log
      },
      file: {
        write: function(p1, p2) {
          var cwd;

          cwd = process.cwd();
          pipeline.emit("data", new gutil.File({
            cwd: cwd,
            base: cwd,
            path: p1,
            contents: new Buffer(p2)
          }));
          return null;
        }
      }
    };
    return startPipeline;
  },
  throughCoffee: function() {
    var coffeeBranch, coffeeCompile, conditonalLint, pipeline;

    conditonalLint = gulpif(Helper.shouldLintCoffee, coffeelint(void 0, coffeelintOptions));
    coffeeBranch = StreamFuncs.throughCached(conditonalLint);
    coffeeCompile = conditonalLint.pipe(StreamFuncs.throughCoffeeConditionalCompile()).pipe(coffee({
      sourceMap: GLOBAL.gulpConfig.coffeeSourceMap
    }));
    pipeline = coffeeCompile.pipe(es.through(function(f) {
      console.log(Helper.compileTitle(f.extra), "" + f.relative);
      return this.emit("data", f);
    })).pipe(gulpif(Helper.shouldLintCoffee, StreamFuncs.jshint())).pipe(gulpif(Helper.shouldLintCoffee, StreamFuncs.lintReporter())).pipe(gulp.dest("."));
    if (GLOBAL.gulpConfig.reloadJsHtml) {
      pipeline.pipe(StreamFuncs.throughLiveReload());
    }
    coffeeCompile.removeAllListeners("error");
    coffeeCompile.on("error", StreamFuncs.coffeeErrorPrinter);
    return coffeeBranch;
  },
  workStream: null,
  workEndStream: null,
  createStreamObject: function() {
    if (StreamFuncs.workStream) {
      return;
    }
    StreamFuncs.workStream = es.through();
    StreamFuncs.workEndStream = StreamFuncs.setupCompileStream(StreamFuncs.workStream);
    return null;
  },
  setupCompileStream: function(stream) {
    var assetBranch, coffeeBranch, coffeeBranchRegex, langSrcBranch, langeSrcBranchRegex, liveReloadBranchRegex;

    assetBranch = StreamFuncs.throughLiveReload();
    langSrcBranch = StreamFuncs.throughLangSrc();
    coffeeBranch = StreamFuncs.throughCoffee();
    langeSrcBranchRegex = /lang-source\.coffee/;
    coffeeBranchRegex = /\.coffee$/;
    if (GLOBAL.gulpConfig.reloadJsHtml) {
      liveReloadBranchRegex = /(src.assets)|(\.js$)|(\.html$)/;
    } else {
      liveReloadBranchRegex = /src.assets/;
    }
    return stream.pipe(gulpif(langeSrcBranchRegex, langSrcBranch, true)).pipe(gulpif(coffeeBranchRegex, coffeeBranch, true)).pipe(gulpif(liveReloadBranchRegex, assetBranch, true));
  }
};

changeHandler = function(path) {
  var stats;

  Helper.watchIsWorking = true;
  if (!fs.existsSync(path)) {
    return;
  }
  stats = fs.statSync(path);
  if (stats.isDirectory()) {
    return;
  }
  if (GLOBAL.gulpConfig.verbose) {
    console.log("[Change]", path);
  }
  if (path.match(/src.assets/)) {
    StreamFuncs.workStream.emit("data", {
      path: path
    });
  } else {
    fs.readFile(path, function(err, data) {
      if (!data) {
        return;
      }
      StreamFuncs.workStream.emit("data", new gutil.File({
        cwd: Helper.cwd,
        base: Helper.cwd,
        path: path,
        contents: data
      }));
      return null;
    });
  }
  return null;
};

checkWatchHealthy = function(watcher) {
  if (GLOBAL.gulpConfig.pollingWatch) {
    return;
  }
  fs.writeFileSync("./src/robots.txt", fs.readFileSync("./src/robots.txt"));
  return setTimeout(function() {
    if (!Helper.watchIsWorking) {
      console.log("[Info]", "Watch is not working. Will retry in 2 seconds.");
      Helper.notify("Watch is not working. Will retry in 2 seconds.");
      watcher.removeAllListeners();
      return setTimeout((function() {
        return watch();
      }), 2000);
    }
  }, 500);
};

watch = function() {
  var watcher;

  ++Helper.watchRetry;
  if (Helper.watchRetry > 3) {
    console.log(gutil.colors.red.bold("[Fatal]", "Watch is still not working. Please manually retry."));
    Helper.notify("Watch is still not working. Please manually retry.");
    return;
  }
  Helper.createLrServer();
  StreamFuncs.createStreamObject();
  watcher = Helper.createWatcher();
  watcher.on("add", changeHandler);
  watcher.on("change", changeHandler);
  watcher.on("error", function(e) {
    return console.log("[error]", e);
  });
  checkWatchHealthy(watcher);
  return null;
};

compileDev = function(allCoffee) {
  var compileStream, deferred;

  if (allCoffee) {
    path = ["src/**/*.coffee", "!src/test/**/*"];
  } else {
    path = ["src/**/*.coffee", "!src/test/**/*", "!src/service/**/*", "!src/model/**/*"];
  }
  deferred = Q.defer();
  StreamFuncs.createStreamObject();
  compileStream = gulp.src(path, {
    cwdbase: true
  }).pipe(es.through(function(f) {
    StreamFuncs.workStream.emit("data", f);
    return null;
  }));
  compileStream.once("end", function() {
    return deferred.resolve();
  });
  return deferred.promise;
};

module.exports = {
  watch: watch,
  compileDev: compileDev
};
