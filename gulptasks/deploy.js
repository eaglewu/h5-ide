var BuildProcess, Q, SrcOption, Tasks, TasksEnvironment, coffee, conditional, confCompile, dest, end, es, fileLogger, fs, gulp, gutil, handlebars, ideversion, include, langsrc, logTask, path, requirejs, rjsconfig, rjsreporter, stdRedirect, stripdDebug, util, variable;

gulp = require("gulp");

gutil = require("gulp-util");

es = require("event-stream");

fs = require("fs");

Q = require("q");

path = require("path");

coffee = require("gulp-coffee");

stripdDebug = require("gulp-strip-debug");

include = require("./plugins/include");

langsrc = require("./plugins/langsrc");

conditional = require("./plugins/conditional");

handlebars = require("./plugins/handlebars");

ideversion = require("./plugins/ideversion");

variable = require("./plugins/variable");

rjsconfig = require("./plugins/rjsconfig");

requirejs = require("./plugins/r");

rjsreporter = require("./plugins/rjsreporter");

util = require("./plugins/util");

SrcOption = {
  "base": "./src"
};

logTask = function(msg, noNewlineWhenNotVerbose) {
  msg = "[ " + (gutil.colors.bgBlue.white(msg)) + " ] ";
  if (noNewlineWhenNotVerbose && !GLOBAL.gulpConfig.verbose) {
    process.stdout.write(msg);
  } else {
    console.log(msg);
  }
  return null;
};

fileLogger = function() {
  return es.through(function(f) {
    if (GLOBAL.gulpConfig.verbose) {
      console.log(util.compileTitle(f.extra, false), "" + f.relative);
    } else {
      process.stdout.write(".");
    }
    this.emit("data", f);
    return null;
  });
};

dest = function() {
  return gulp.dest("./build");
};

end = function(d, printNewlineWhenNotVerbose) {
  if (printNewlineWhenNotVerbose && !GLOBAL.gulpConfig.verbose) {
    return function() {
      process.stdout.write("\n");
      return d.resolve();
    };
  } else {
    return function() {
      return d.resolve();
    };
  }
};

stdRedirect = function(d) {
  process.stdout.write(d);
  return null;
};

confCompile = function() {
  return conditional(true, TasksEnvironment.isDebug);
};

TasksEnvironment = {
  isDebug: false,
  isRelease: false,
  isPublic: false
};

Tasks = {
  correctReleaseVersion: function() {
    var releaseVersion;
    if (TasksEnvironment.isRelease) {
      releaseVersion = GLOBAL.gulpConfig.version.split(".");
      releaseVersion.length = 3;
      GLOBAL.gulpConfig.version = releaseVersion.join(".");
    }
    return true;
  },
  checkGitVersion: function() {
    var d;
    logTask("Checking Git Version");
    d = Q.defer();
    util.runCommand("git", ["--version"], {}, function(version) {
      if (!version) {
        return;
      }
      version = version.split(" ") || [];
      version = parseFloat(version[2]);
      if (isNaN(version) || version < 1.9) {
        d.reject("Deployment need Git >=1.9");
      }
      return d.resolve(true);
    });
    return d.promise;
  },
  cleanRepo: function() {
    logTask("Removing ignored files in src (git clean -xdf)");
    return util.runCommand("git", ["clean", "-xdf"], {
      cwd: process.cwd() + "/src"
    }, stdRedirect);
  },
  copyAssets: function() {
    var d, p;
    logTask("Copying Assets & robots.txt");
    p = ['./src/assets/**/*', './src/robots.txt', '!*.glyphs', '!*.scss', '!./src/assets/config.rb'];
    d = Q.defer();
    gulp.src(p, SrcOption).pipe(dest()).on("end", end(d));
    return d.promise;
  },
  copyJs: function() {
    var d;
    logTask("Copying Js & Templates");
    d = Q.defer();
    gulp.src(['./src/**/*.js'], SrcOption).pipe(confCompile()).pipe(dest()).on("end", end(d));
    return d.promise;
  },
  compileLangSrc: function() {
    logTask("Compiling lang-source");
    return langsrc.build("./build", false);
  },
  compileCoffee: function() {
    var d, p, pipe;
    logTask("Compiling coffees", true);
    p = ['./src/**/*.coffee', '!./src/nls/*.coffee'];
    d = Q.defer();
    pipe = gulp.src(p, SrcOption).pipe(confCompile()).pipe(coffee({
      bare: true
    })).pipe(fileLogger());
    if (!TasksEnvironment.isDebug) {
      pipe = pipe.pipe(stripdDebug());
    }
    pipe.pipe(dest()).on("end", end(d, true));
    return d.promise;
  },
  compileTemplate: function() {
    var d, p;
    logTask("Compiling templates", true);
    p = ['./src/**/*.partials', './src/**/*.html', '!src/*.html', '!src/include/*.html'];
    d = Q.defer();
    gulp.src(p, SrcOption).pipe(confCompile()).pipe(handlebars(false)).pipe(fileLogger()).pipe(dest()).on("end", end(d, true));
    return d.promise;
  },
  processHtml: function() {
    var d, p;
    logTask("Processing ./src/*.html");
    p = ["./src/*.html"];
    d = Q.defer();
    gulp.src(p).pipe(confCompile()).pipe(include()).pipe(variable()).pipe(dest()).on("end", end(d));
    return d.promise;
  },
  concatJS: function() {
    var d;
    logTask("Concating JS");
    d = Q.defer();
    requirejs.optimize(rjsconfig(TasksEnvironment.isDebug), function(buildres) {
      if (rjsreporter(buildres)) {
        return d.resolve();
      } else {
        console.log(gutil.colors.bgRed.white("Aborted due to concat error"));
        return d.reject();
      }
    }, function(err) {
      console.log(err);
      return d.reject();
    });
    return d.promise;
  },
  removeBuildFolder: function() {
    util.deleteFolderRecursive(process.cwd() + "/build");
    return true;
  },
  fetchRepo: function() {
    var hadError, params, result;
    logTask("Checking out h5-ide-build");
    if (!util.deleteFolderRecursive(process.cwd() + "/h5-ide-build")) {
      throw new Error("Cannot delete ./h5-ide-build, please manually delete it then retry.");
    }
    params = ["clone", GLOBAL.gulpConfig.buildRepoUrl, "-v", "--progress", "--depth", "1", "-b", TasksEnvironment.repoBranch];
    if (GLOBAL.gulpConfig.buildUsername) {
      params.push("-c");
      params.push("user.name=\"" + GLOBAL.gulpConfig.buildUsername + "\"");
    }
    if (GLOBAL.gulpConfig.buildEmail) {
      params.push("-c");
      params.push("user.email=\"" + GLOBAL.gulpConfig.buildEmail + "\"");
    }
    hadError = false;
    result = util.runCommand("git", params, {}, function(d, type) {
      if (d.indexOf("fatal") !== -1) {
        console.log(d);
        hadError = true;
      }
      process.stdout.write(d);
      return null;
    });
    return result.then(function() {
      if (hadError) {
        throw new Error("Cannot checkout h5-ide-build");
      }
      return true;
    });
  },
  preCommit: function() {
    var commitData, move, option;
    logTask("Pre-commit");
    move = util.runCommand("mv", ["h5-ide-build/.git", "deploy/.git"], {});
    if (fs.existsSync("./h5-ide-build/.gitignore")) {
      move = move.then(function() {
        return util.runCommand("mv", ["h5-ide-build/.gitignore", "deploy/.gitignore"], {});
      });
    }
    option = {
      cwd: process.cwd() + "/deploy"
    };
    commitData = "";
    return move.then(function() {
      util.deleteFolderRecursive(process.cwd() + "/h5-ide-build");
      return util.runCommand("git", ["add", "-A"], option);
    }).then(function() {
      return util.runCommand("git", ["commit", "-m", "pre-" + (ideversion.version())], option, function(d) {
        commitData += d;
        return null;
      });
    }).then(function() {
      if (commitData[0] === "#") {
        console.log(commitData);
      } else {
        commitData = commitData.split("\n");
        console.log(commitData[0]);
        console.log(commitData[1]);
      }
      return true;
    });
  },
  fileVersion: function() {
    var fileData, listFile, noramlize, urlRegex, versions;
    logTask("Getting all files version");
    fileData = "";
    listFile = util.runCommand("git", ["ls-files", "-s"], {
      cwd: process.cwd() + "/deploy"
    }, function(d, type) {
      if (type === "out") {
        fileData += d;
      }
      return null;
    });
    urlRegex = /(\="|\='|url\('|url\(")([^'":]+?\/[^'"]+?\/[^'"?]+?)("|')/g;
    noramlize = /\\/g;
    versions = {};
    return listFile.then(function() {
      var entry, i, len, line, ref, results;
      ref = fileData.split("\n");
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        entry = ref[i];
        line = entry.split(/\s+?/);
        if (line[3]) {
          versions[line[3].replace(noramlize, "/")] = line[1].substr(0, 8);
        }
        results.push(null);
      }
      return results;
    }).then(function() {
      var d;
      d = Q.defer();
      gulp.src(["./deploy/*.html", "./deploy/assets/css/*.css"], {
        base: process.cwd() + "/deploy"
      }).pipe(es.through(function(f) {
        var cwd, newContent;
        cwd = path.resolve(process.cwd(), "./deploy");
        newContent = f.contents.toString("utf8").replace(urlRegex, function(match, p1, p2, p3) {
          var p, version;
          p = path.resolve(path.dirname(f.path), p2).replace(cwd, "");
          if (p[0] === "/" || p[0] === "\\") {
            p = p.replace(/\/|\\/, "");
          }
          version = versions[p];
          if (GLOBAL.gulpConfig.verbose) {
            console.log(p, version);
          }
          if (version) {
            return p1 + p2 + ("?v=" + version) + p3;
          } else {
            return match;
          }
        });
        f.contents = new Buffer(newContent);
        this.emit("data", f);
        return null;
      })).pipe(gulp.dest("./deploy")).on("end", end(d));
      return d.promise;
    }).then(function() {
      var buster, d, jsV, key, l, value;
      jsV = {};
      for (key in versions) {
        value = versions[key];
        l = key.length;
        if (key[l - 3] === "." && key[l - 2] === "j" && key[l - 1] === "s") {
          jsV[key] = value;
        }
      }
      buster = "window.FileVersions=" + JSON.stringify(jsV) + ";\n";
      d = Q.defer();
      gulp.src("./deploy/**/config.js").pipe(es.through(function(f) {
        f.contents = new Buffer(buster + f.contents.toString("utf8"));
        return this.emit("data", f);
      })).pipe(gulp.dest("./deploy")).on("end", end(d));
      return d.promise;
    });
  },
  logDeployInDevRepo: function() {
    if (!TasksEnvironment.isRelease) {
      return true;
    }
    logTask("Commit IdeVersion in h5-ide");
    ideversion.read(true);
    return util.runCommand("git", ["commit", "-m", '"Deploy ' + ideversion.version() + '"', "package.json"]);
  },
  finalCommit: function() {
    var devRepoV, option, task;
    logTask("Final Commit");
    option = {
      cwd: process.cwd() + "/deploy"
    };
    devRepoV = "HEAD";
    task = util.runCommand("git", ["rev-parse", "HEAD"], void 0, function(d) {
      devRepoV = d;
      return null;
    });
    return task.then(function() {
      return util.runCommand("git", ["add", "-A"], option);
    }).then(function() {
      return util.runCommand("git", ["commit", "-m", (ideversion.version()) + " ; DevRepo: MadeiraCloud/h5-ide@" + devRepoV], option);
    }).then(function() {
      if (GLOBAL.gulpConfig.autoPush) {
        console.log("[ " + gutil.colors.bgBlue.white("Pushing to Remote") + " ]");
        console.log(gutil.colors.bgYellow.black("  AutoPush might be slow, you can always kill the task at this moment. "));
        console.log(gutil.colors.bgYellow.black("  Then manually git-push `./deploy`. You can delete `./deploy` after git-pushing. "));
        return util.runCommand("git", ["push", "-v", "--progress", "-f"], option, stdRedirect);
      } else {
        console.log(gutil.colors.bgYellow.black("  AutoPush is disabled. Please manually git-push `./deploy`. "));
        console.log(gutil.colors.bgYellow.black("  You can delete `./deploy` after pushing. "));
        return true;
      }
    }).then(function() {
      if (GLOBAL.gulpConfig.autoPush) {
        if (!util.deleteFolderRecursive(process.cwd() + "/deploy")) {
          console.log(gutil.colors.bgYellow.black("  Cannot delete ./deploy. You should manually delete ./deploy before next deploying.  "));
        }
      }
      return true;
    });
  }
};

BuildProcess = function(mode, branchName) {
  TasksEnvironment.isDebug = mode === "debug";
  TasksEnvironment.isRelease = mode === "release";
  if (branchName) {
    TasksEnvironment.repoBranch = branchName;
  } else if (TasksEnvironment.isRelease) {
    TasksEnvironment.repoBranch = "master";
  } else {
    TasksEnvironment.repoBranch = "develop";
  }
  ideversion.read();
  return [Tasks.correctReleaseVersion, Tasks.checkGitVersion, Tasks.cleanRepo, Tasks.copyAssets, Tasks.copyJs, Tasks.compileLangSrc, Tasks.compileCoffee, Tasks.compileTemplate, Tasks.processHtml, Tasks.concatJS, Tasks.removeBuildFolder, Tasks.fetchRepo, Tasks.preCommit, Tasks.fileVersion, Tasks.logDeployInDevRepo, Tasks.finalCommit].reduce(Q.when, true).then(function() {
    console.log(gutil.colors.bgBlue.white("\n [Build Succeed] ") + "\n");
    return true;
  }, function(p) {
    console.log("[", gutil.colors.bgRed.white("Build Task Aborted"), "]", p);
    throw new Error("\n");
  });
};

module.exports = {
  debug: function(bn) {
    return BuildProcess("debug", bn);
  },
  release: function(bn) {
    return BuildProcess("release", bn);
  }
};
