// Generated by CoffeeScript 1.6.2
var Buffer, Helper, Q, StreamFuncs, buildLangSrc, cached, chokidar, coffee, coffeelint, coffeelintOptions, compileCoffeeOnlyRegex, compileDev, compileIgnorePath, es, fs, gulp, gulpif, gutil, indexOf, lrServer, path, setupCompileStream, tinylr, vm, watch;

gulp = require("gulp");

gutil = require("gulp-util");

path = require("path");

Buffer = require('buffer').Buffer;

es = require("event-stream");

Q = require("q");

fs = require("fs");

vm = require("vm");

tinylr = require("tiny-lr");

chokidar = require("chokidar");

coffee = require("gulp-coffee");

coffeelint = require("gulp-coffeelint");

gulpif = require("gulp-if");

cached = require("gulp-cached");

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

lrServer = null;

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
  createLrServer: function() {
    if (lrServer) {
      return;
    }
    gutil.log(gutil.colors.bgBlue(" Starting livereload server... "));
    lrServer = tinylr();
    lrServer.server.removeAllListeners('error');
    lrServer.server.on("error", function(e) {
      if (e.code !== "EADDRINUSE") {
        return;
      }
      console.error('[LR Error] Cannot start livereload server. You already have a server listening on %s', lrServer.port);
      return lrServer = null;
    });
    lrServer.listen(GLOBAL.gulpConfig.livereloadServerPort, function(err) {
      if (err) {
        gutil.log("[LR Error]", "Cannot start livereload server");
        lrServer = null;
      }
      return null;
    });
    return null;
  },
  log: function(e) {
    return console.log(e);
  },
  noop: function() {},
  compileTitle: function() {
    return "[" + gutil.colors.green("Compile @" + ((new Date()).toLocaleTimeString())) + "]";
  }
};

StreamFuncs = {
  jshint: require("./jshint"),
  lintReporter: require('./reporter'),
  coffeeErrorPrinter: function(error) {
    console.log(gutil.colors.red.bold("\n[CoffeeError]"), error.message.replace(process.cwd(), "."));
    return null;
  },
  throughLiveReload: function() {
    return es.through(function(file) {
      if (lrServer) {
        lrServer.changed({
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
      var buffer, index;

      buffer = file.contents;
      index = 0;
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
      }
      this.emit("data", file);
      return null;
    });
  },
  throughLangSrc: function() {
    var gruntMock, pipeline, startPipeline,
      _this = this;

    startPipeline = coffee();
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
    var coffeeBranch, coffeeCompile, pipeline;

    coffeeBranch = cached("coffee");
    coffeeCompile = coffeeBranch.pipe(gulpif(Helper.shouldLintCoffee, coffeelint(void 0, coffeelintOptions))).pipe(StreamFuncs.throughCoffeeConditionalCompile()).pipe(coffee({
      sourceMap: GLOBAL.gulpConfig.coffeeSourceMap
    }));
    pipeline = coffeeCompile.pipe(es.through(function(f) {
      console.log(Helper.compileTitle(), "" + f.relative);
      return this.emit("data", f);
    })).pipe(gulpif(Helper.shouldLintCoffee, StreamFuncs.jshint())).pipe(gulpif(Helper.shouldLintCoffee, StreamFuncs.lintReporter())).pipe(gulp.dest("."));
    if (GLOBAL.gulpConfig.reloadJsHtml) {
      pipeline.pipe(StreamFuncs.throughLiveReload());
    }
    coffeeCompile.removeAllListeners("error");
    coffeeCompile.on("error", StreamFuncs.coffeeErrorPrinter);
    return coffeeBranch;
  }
};

setupCompileStream = function(stream) {
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
};

watch = function() {
  var changeHandler, cwd, watchStream, watcher;

  Helper.createLrServer();
  watcher = chokidar.watch("./src", {
    usePolling: false,
    useFsEvents: true,
    ignoreInitial: true,
    ignored: /([\/\\]\.)|src.(test|vender)/
  });
  cwd = process.cwd();
  watchStream = es.through();
  setupCompileStream(watchStream);
  changeHandler = function(path) {
    var stats;

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
      watchStream.emit("data", {
        path: path
      });
      return;
    }
    fs.readFile(path, function(err, data) {
      if (!data) {
        return;
      }
      watchStream.emit("data", new gutil.File({
        cwd: cwd,
        base: cwd,
        path: path,
        contents: data
      }));
      return null;
    });
    return null;
  };
  gutil.log(gutil.colors.bgBlue(" Watching file changes... "));
  watcher.on("add", changeHandler);
  watcher.on("change", changeHandler);
  watcher.on("error", function(e) {
    return console.log("[error]", e);
  });
  return null;
};

compileDev = function(allCoffee) {
  var deferred;

  if (allCoffee) {
    path = ["src/**/*.coffee", "!src/test/**/*"];
  } else {
    path = ["src/**/*.coffee", "!src/test/**/*", "!src/service/**/*", "!src/model/**/*"];
  }
  deferred = Q.defer();
  setupCompileStream(gulp.src(path, {
    cwdbase: true
  })).on("end", function() {
    return deferred.resolve();
  });
  return deferred.promise;
};

module.exports = {
  watch: watch,
  compileDev: compileDev
};
