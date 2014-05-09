define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'aws_quickstart'     : { url:'/aws/',	method:'quickstart',	params:['username', 'session_id', 'region_name']   },
		'aws_public'         : { url:'/aws/',	method:'public',	params:['username', 'session_id', 'region_name', 'filters']   },
		'aws_property'       : { url:'/aws/',	method:'property',	params:['username', 'session_id']   },
		'aws_resource'       : { url:'/aws/',	method:'resource',	params:['username', 'session_id', 'region_name', 'resources', 'addition', 'retry_times']   },
		'aws_price'          : { url:'/aws/',	method:'price',	params:['username', 'session_id']   },
		'aws_status'         : { url:'/aws/',	method:'status',	params:['username', 'session_id']   },
	}

	for ( var i in Apis ) {
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
