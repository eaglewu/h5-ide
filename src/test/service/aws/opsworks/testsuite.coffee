#*************************************************************************************
#* Filename     : opsworks_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 17:15:11
#* Description  : qunit testsuite for opsworks_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

# Defer Qunit so RequireJS can work its magic and resolve all modules.
#!!Must be false
QUnit.config.autostart = false

# A list of all QUnit test Modules.  Make sure you include the `.js`
# extension so RequireJS resolves them as relative paths rather than using
# the `baseUrl` value supplied above.
testModules = [
	'/test/service/aws/opsworks/module_opsworks.js',
	##@@module-list
]

# Resolve all testModules and then start the Test Runner.
#!!Do not use QUnit.start
require testModules, QUnit.load
