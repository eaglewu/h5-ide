var gulp  = require('gulp');
var gutil = require('gulp-util');
var fs    = require('fs');
var os    = require('os');

var serverTask  = require('./gulptasks/server');
var developTask = require('./gulptasks/develop');
var deployTask  = require('./gulptasks/deploy');

// Load user-config
GLOBAL.gulpConfig = require('./gulpconfig.default');
if ( fs.existsSync("./gulpconfig.js") ) {
  gutil.log("Loaded Custom Config");
  var custom = require('./gulpconfig')
  for ( var i in custom ) {
    GLOBAL.gulpConfig[ i ] = custom[ i ]
  }
}

if ( GLOBAL.gulpConfig.pollingWatch === "auto" ) {
  GLOBAL.gulpConfig.pollingWatch = os.type() !== "Darwin"
}


// Develop
gulp.task("default", function(){
  developTask.compile().then(function(){
    serverTask();
    developTask.watch();
  });
});

gulp.task("watch", function(){
  serverTask();
  developTask.watch();
});


// Test
gulp.task("maketest", function(){ return require('./gulptasks/test').compile(); });
gulp.task("test",     function(){ return require('./gulptasks/test').run(); });


// Compile gulp files
gulp.task("makegulp", function(){ return require('./gulptasks/makegulp')(); })


// Deploy
gulp.task("debug", function(){
  var a = argv( "debug" );
  if ( a === false ) { return; }
  deployTask.debug( a );
});
gulp.task("release", function(){
  var a = argv( "release" );
  if ( a === false ) { return; }
  deployTask.release( a );
});

function argv( cmd ) {
  var index = process.argv.indexOf( cmd );
  if ( index < 0 ) {
    console.error("Fail to parse cmd");
    return false;
  }

  var argv = process.argv.splice( index + 1 );
  if ( argv.length >= 2 ) {
    return argv[1].replace(/^-./,"")
  }

  return argv[0] || "";
}



// Debug
gulp.task("trace", function(){ return require('./gulptasks/trace')(); });



// Deprecated
gulp.task("build", function(){ console.log("Deprecated, read the help doc please."); });
gulp.task("public",  function(){ console.log("Deprecated, use `gulp build -b public` instead."); });
// gulp.task("qa_build", function(){ return deployTask.build( "qa" ); })
// gulp.task("qa", ["qa_build"], function(){ return serverTask.create("./qa", 3002); });



// Help
gulp.task("help", function(){
  console.log( "\n ===== Daily Development =====")
  console.log( "+ gulp");
  console.log( "      Compile IDE and start a local server @{staticFileServer:staticFileServerPort}\n" );
  console.log( "+ gulp watch");
  console.log( "      Start a local server @{staticFileServer:staticFileServerPort}\n" );

  console.log( "\n ===== Delpoyment =====")
  console.log( "+ gulp debug [-b BranchName]");
  console.log( "      Compile in debug mode. Push to remote repo, default branch is `develop`\n" );
  console.log( "+ gulp release [-b BranchName]");
  console.log( "      Compile in release mode. Push to remote repo, default branch is `master`\n" );
  console.log( "+ gulp makegulp")
  console.log( "      Compile the gulp tasks.\n" );

  console.log( "\n ===== Test =====")
  console.log( "+ gulp test");
  console.log( "      Run test." );
  console.log( "+ gulp maketest");
  console.log( "      Compile test files." );

  console.log( "\n ===== Debug =====")
  console.log( "+ gulp trace\n");

});
