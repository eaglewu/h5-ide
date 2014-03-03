// Generated by CoffeeScript 1.6.2
module.exports.create = function() {
  var defaultHeader, file, gutil, http, nstatic, server;

  gutil = require("gulp-util");
  nstatic = require("node-static");
  http = require("http");
  defaultHeader = {
    "Cache-Control": "no-cache"
  };
  gutil.log(gutil.colors.bgBlue.white(" Creating File Server... "));
  file = new nstatic.Server("./src", {
    cache: false,
    headers: defaultHeader
  });
  server = http.createServer(function(request, response) {
    request.addListener('end', function() {
      var errorHandler, filePath, url;

      url = request.url;
      if (url === "/") {
        filePath = "/ide.html";
      } else if (url[url.length - 1] === "/") {
        response.writeHead(301, {
          "Location": url.substring(0, url.length - 1)
        });
        response.end();
        return;
      } else if (url.indexOf(".", 1) === -1) {
        filePath = url + ".html";
      }
      errorHandler = function(e) {
        console.log("[ServerError]", e.message, request.url);
        response.writeHead(404);
        response.end();
        return null;
      };
      if (filePath) {
        file.serveFile(filePath, 200, defaultHeader, request, response).addListener("error", errorHandler);
      } else {
        file.serve(request, response).addListener("error", errorHandler);
      }
      return null;
    });
    request.resume();
    return null;
  });
  server.listen(GLOBAL.gulpConfig.staticFileServerPort);
  return null;
};
