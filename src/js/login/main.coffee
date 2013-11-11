
###
//main
require( [ 'login' ], function( login ) {
	login.ready();
});
###

require [ 'domReady', 'login', 'MC' ], ( domReady, login ) ->

	### env:prod ###
	if window.location.protocol is 'http:' and window.location.hostname isnt 'localhost'
		currentLocation = window.location.toString()
		currentLocation = currentLocation.replace('http:', 'https:')
		window.location = currentLocation
	### env:prod:end ###

	domReady () ->
		if MC.isSupport() == false
			$(document.body).prepend '<div id="unsupported-browser"><p>MadeiraCloud IDE does not support the browser you are using.</p> <p>For a better experience, we suggest you use the latest version of <a href=" https://www.google.com/intl/en/chrome/browser/" target="_blank">Chrome</a>, <a href=" http://www.mozilla.org/en-US/firefox/all/" target="_blank">Firefox</a> or <a href=" http://windows.microsoft.com/en-us/internet-explorer/ie-10-worldwide-languages" target="_blank">IE10</a>.</p></div>'

		login.ready()