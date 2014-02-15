/*
#**********************************************************
#* MC.canvas
#* Description: Canvas logic core
# **********************************************************
# (c) Copyright 2014 Madeiracloud  All Rights Reserved
# **********************************************************
*/

// JSON data for current tab
//MC.canvas_data = {};

// Variable for current tab
// MC.canvas_property = {};

MC.canvas = {
	getState: function ()
	{
		//return Tabbar.current;
		//return MC.canvas_data.stack_id !== undefined ? 'app' : 'stack';
		var state = '',
			current = Tabbar.current;

		if (
			current === 'new' ||
			current === 'stack'
		)
		{
			state = 'stack';
		}
		else if (
			current === 'app' ||
			current === 'appedit' ||
			current === 'appview'
		)
		{
			state = current;
		}

		return state;
	},

	display: function (id, key, is_visible)
	{
		var target = $('#' + id + '_' + key);

		if (is_visible === null || is_visible === undefined)
		{
			switch (target.attr('display'))
			{
				case 'none':
					is_visible = false;
					break;

				default:
					is_visible = true;
					break;
			}
			return is_visible;
		}
		else if (is_visible === true)
		{
			target.attr('display', 'inline');
			target.attr('style', '');
			Canvon(target).addClass('tooltip');
		}
		else
		{
			target.attr('display', 'none');
			target.attr('style', 'opacity:0');
			Canvon(target).removeClass('tooltip');
		}
	},

	update: function (id, type, key, value)
	{
		var target = $('#' + id + '_' + key),
			value;

		switch (type)
		{
			case 'text':
				if (key.indexOf("name") !== -1)
				{
					value = MC.canvasName( value );
				}

				if (target.length === 0)
				{
					target = $('#' + id).find("." + key);
				}

				target.text(value);
				break;

			case 'image':
				//target.attr('href', value);
				target[ 0 ].setAttributeNS("http://www.w3.org/1999/xlink", "href", value);
				break;

			case 'eip':
				target.attr('data-eip-state', value);
				break;

			case 'id':
				target.attr('id', value);
				break;

			case 'color':
				target.attr('style', 'fill:' + value);
				break;

			case 'tooltip': //add tooltip
				Canvon( '#' + id + '_' + key )
					.addClass('tooltip')
					.data( 'tooltip', value )
					.attr( 'data-tooltip', value );
				break;
		}

		return true;
	},

	resize: function (target, type)
	{
		var canvas_size = $canvas.size(),
			scale_ratio = $canvas.scale(),
			key = target === 'width' ? 0 : 1,
			node_minX = [],
			node_minY = [],
			node_maxX = [],
			node_maxY = [],
			coordinate,
			size,
			value,
			target_value,
			screen_maxX,
			screen_maxY;

		if (type === 'expand')
		{
			canvas_size[ key ] += 60;

			$('#svg_resizer_' + target + '_shrink').show();
		}

		if (type === 'shrink')
		{
			$.each($canvas.node(), function (index, item)
			{
				coordinate = item.position();
				size = item.size();

				node_maxX.push(coordinate[0] + size[0]);
				node_maxY.push(coordinate[1] + size[1]);
			});

			$.each($canvas.group(), function (index, item)
			{
				coordinate = item.position();
				size = item.size();

				node_maxX.push(coordinate[0] + size[0]);
				node_maxY.push(coordinate[1] + size[1]);
			});

			screen_maxX = Math.max.apply(Math, node_maxX);
			screen_maxY = Math.max.apply(Math, node_maxY);

			target_value = target === 'width' ? screen_maxX : screen_maxY;

			if ((canvas_size[ key ] - 60) <= target_value)
			{
				canvas_size[ key ] = 20 + target_value;

				$('#svg_resizer_' + target + '_shrink').hide();
			}
			else
			{
				canvas_size[ key ] -= 60;

				if (canvas_size[ key ] === 20 + target_value)
				{
					$('#svg_resizer_' + target + '_shrink').hide();
				}
			}
		}

		$('#svg_canvas')[0].setAttribute('viewBox', '0 0 ' + MC.canvas.GRID_WIDTH * canvas_size[0] + ' ' + MC.canvas.GRID_HEIGHT * canvas_size[1]);

		$('#svg_canvas').attr({
			'width': canvas_size[0] * MC.canvas.GRID_WIDTH / scale_ratio,
			'height': canvas_size[1] * MC.canvas.GRID_HEIGHT / scale_ratio
		});

		$('#canvas_container, #canvas_body').css({
			'width': canvas_size[0] * MC.canvas.GRID_WIDTH / scale_ratio,
			'height': canvas_size[1] * MC.canvas.GRID_HEIGHT / scale_ratio
		});

		$canvas.size(canvas_size[0], canvas_size[1]);

		return true;
	},

	zoomIn: function ()
	{
		var canvas_size = $canvas.size(),
			$canvas_body = $('#canvas_body'),
			newClass = "",
			scale_ratio = $canvas.scale();

		if (scale_ratio > 1)
		{
			$canvas.scale((scale_ratio * 10 - 2) / 10);

			scale_ratio = $canvas.scale();

			$('#svg_canvas')[0].setAttribute('viewBox', '0 0 ' + MC.canvas.GRID_WIDTH * canvas_size[0] + ' ' + MC.canvas.GRID_HEIGHT * canvas_size[1]);

			newClass = $canvas_body.attr("class").replace(/zoomlevel_[^\s]+\s?/g, "") + "zoomlevel_" + ("" + scale_ratio).replace(".", "_");
			$canvas_body.attr("class", newClass);

			$('#canvas_container, #canvas_body').css({
				'width': canvas_size[0] * MC.canvas.GRID_WIDTH / scale_ratio,
				'height': canvas_size[1] * MC.canvas.GRID_HEIGHT / scale_ratio
			});

			$('#svg_canvas').attr({
				'width': canvas_size[0] * MC.canvas.GRID_WIDTH / scale_ratio,
				'height': canvas_size[1] * MC.canvas.GRID_HEIGHT / scale_ratio
			});
		}

		if (scale_ratio === 1 && $('#canvas_body').hasClass('canvas_zoomed'))
		{
			$('#canvas_body')
				.removeClass('canvas_zoomed');
		}

		MC.canvas.event.clearSelected();

		return true;
	},

	zoomOut: function ()
	{
		var canvas_size = $canvas.size(),
			$canvas_body = $('#canvas_body'),
			newClass = "",
			scale_ratio = $canvas.scale();

		if (scale_ratio < 1.6)
		{
			$canvas.scale((scale_ratio * 10 + 2) / 10);

			scale_ratio = $canvas.scale();

			$('#svg_canvas')[0].setAttribute('viewBox', '0 0 ' + MC.canvas.GRID_WIDTH * canvas_size[0] + ' ' + MC.canvas.GRID_HEIGHT * canvas_size[1]);

			newClass = $.trim($canvas_body.attr("class").replace(/zoomlevel_[^\s]+\s?/g, "")) + " zoomlevel_" + ("" + scale_ratio).replace(".", "_");
			$canvas_body.attr("class", newClass);

			$('#canvas_container, #canvas_body').css({
				'width': canvas_size[0] * MC.canvas.GRID_WIDTH / scale_ratio,
				'height': canvas_size[1] * MC.canvas.GRID_HEIGHT / scale_ratio
			});

			$('#svg_canvas').attr({
				'width': canvas_size[0] * MC.canvas.GRID_WIDTH / scale_ratio,
				'height': canvas_size[1] * MC.canvas.GRID_HEIGHT / scale_ratio
			});
		}

		$('#canvas_body')
			.addClass('canvas_zoomed');

		MC.canvas.event.clearSelected();

		return true;
	},

	_addPad: function (point, adjust)
	{
		//add by xjimmy, adjust point
		switch (point.angle)
		{
			case 0:
				point.x += MC.canvas.PORT_PADDING;
				point.y -= adjust;
				break;

			case 90:
				point.x -= adjust;
				point.y -= MC.canvas.PORT_PADDING;
				break;

			case 180:
				point.x -= MC.canvas.PORT_PADDING;
				point.y -= adjust;
				break;

			case 270:
				point.x -= adjust;
				point.y += MC.canvas.PORT_PADDING;
				break;
		}
	},

	_getPath: function (prev, current, next)
	{
		//add by xjimmy, generate path by three point
		var sign = 0,
			delta = 0,
			cornerRadius = MC.canvas.CORNER_RADIUS, //8
			closestRange = 2 * MC.canvas.CORNER_RADIUS, //2*cornerRadius
			p1,
			p2;

		/*1.above or below*/
		if (prev.x === current.x)
		{
			//1.1 calc p1
			delta = current.y - prev.y;
			if (Math.abs(delta) <= closestRange )
			{
				//use middle point between prev and current
				p1 = { 'x': current.x, 'y': (prev.y + current.y) / 2};
			}
			else
			{
				sign = delta ? (delta < 0 ? -1 : 1) : 0;
				p1 = { 'x': current.x, 'y': current.y - cornerRadius * sign};
			}

			//1.2 calc p2
			delta = current.x - next.x;
			if (Math.abs(delta) <= closestRange)
			{
				//use middle point between current and next
				p2 = { 'x': (current.x + next.x) / 2, 'y': current.y};
			}
			else
			{
				sign = delta ? (delta < 0 ? -1 : 1) : 0;
				p2 = { 'x': current.x - cornerRadius * sign, 'y': current.y};
			}
		}
		else
		{
			/*2.left or right*/
			//2.1 calc p1
			delta = current.x - prev.x;
			if (Math.abs(delta) <= closestRange)
			{
				//use middle point between prev and current
				p1 = { 'x': (prev.x + current.x) / 2, 'y': current.y};
			}
			else
			{
				sign = delta ? (delta < 0 ? -1 : 1) : 0;
				p1 = { 'x': current.x - cornerRadius * sign, 'y': current.y};
			}

			//2.2 calc p2
			delta = current.y - next.y;
			if (Math.abs(delta) <= closestRange)
			{
				//use middle point between current and next
				p2 = { 'x': current.x, 'y': (current.y + next.y) / 2};
			}
			else
			{
				sign = delta ? (delta < 0 ? -1 : 1) : 0;
				p2 = { 'x': current.x, 'y': current.y - cornerRadius * sign};
			}
		}

		return ' L ' + p1.x + ' ' + p1.y + ' Q ' + current.x + ' ' + current.y + ' ' + p2.x + ' ' + p2.y;
	},

	_bezier_q_corner: function(controlPoints)
	{
		var d = '';

		if (controlPoints.length>=6)
		{
			var start0 = controlPoints[0],
				start = controlPoints[1],
				end = controlPoints[controlPoints.length-2],
				end0 = controlPoints[controlPoints.length-1],
				mid,
				c2,
				c3;

				/*
				mid = {
					x: (start.x + end.x)/2,
					y: (start.y + end.y)/2
				};

				c2 = {
					x: mid.x,
					y: start.y
				};

				c3 = {
					x: mid.x,
					y: mid.y
				};

				d = 'M ' + start0.x + ' ' + start0.y + ' L ' + start.x + ' ' + start.y
					+ ' Q ' + c2.x + ' ' + c2.y + ' ' + c3.x + ' ' + c3.y
					+ ' T ' + end.x + ' ' + end.y
					+ ' L ' + end0.x + ' ' + end0.y;
				*/

				/*
				//method 1
				mid = {
					x: (start.x + end.x)/2,
					y: (start.y + end.y)/2
				};

				c2 = {
					x: mid.x,
					y: start.y
				};

				c3 = {
					x: mid.x,
					y: end.y
				};

				d = 'M ' + start0.x + ' ' + start0.y + ' L ' + start.x + ' ' + start.y
					+ ' C ' + c2.x + ' ' + c2.y + ' ' + c3.x + ' ' + c3.y
					+ ' ' + end.x + ' ' + end.y
					+ ' L ' + end0.x + ' ' + end0.y;
				*/

				//method 2
				mid = {
					x: (start.x + end.x)/2,
					y: (start.y + end.y)/2
				};

				c2 = controlPoints[2];

				c3 = controlPoints[controlPoints.length - 3];

				d = 'M ' + start0.x + ' ' + start0.y
					+ ' Q ' + c3.x + ' ' + c3.y
					+ ' ' + end.x + ' ' + end.y
					+ ' L ' + end0.x + ' ' + end0.y;

		}
		else
		{
			$.each(controlPoints, function (idx, value)
			{
				if (idx === 0)
				{
					//start0 point
					d = 'M ' + value.x + " " + value.y;
				}
				else if (idx === (controlPoints.length - 1))
				{
					//end0 point
					d += ' ' + value.x + ' ' + value.y;
				}
				else
				{
					//middle point
					prev_p = controlPoints[idx - 1]; //prev point
					next_p = controlPoints[idx + 1]; //next point

					if (
						(prev_p.x === value.x && next_p.x === value.x) ||
						(prev_p.y === value.y && next_p.y === value.y)
					)
					{
						//three point one line
						d += ' L ' + value.x + ' ' + value.y;
					}
					else
					{
						//fold line
						var c3   = controlPoints[controlPoints.length - 3],
							end  = controlPoints[controlPoints.length - 2],
							end0 = controlPoints[controlPoints.length - 1];

						d += ' Q ' + c3.x + ' ' + c3.y + ' ' + end.x + ' ' + end.y + ' L ' + end0.x + ' ' + end0.y;
						return false;
					}
				}
				last_p = value;
			});
		}

		return d;
	},

	_bezier_qt_corner: function(controlPoints)
	{
		var d = '';

		if (controlPoints.length>=4)
		{
			var start0 = controlPoints[0],
				start = controlPoints[1],
				end = controlPoints[controlPoints.length-2],
				end0 = controlPoints[controlPoints.length-1],
				mid,
				c2,
				c3;

				/*
				mid = {
					x: (start.x + end.x)/2,
					y: (start.y + end.y)/2
				};

				c2 = {
					x: mid.x,
					y: start.y
				};

				c3 = {
					x: mid.x,
					y: mid.y
				};

				d = 'M ' + start0.x + ' ' + start0.y + ' L ' + start.x + ' ' + start.y
					+ ' Q ' + c2.x + ' ' + c2.y + ' ' + c3.x + ' ' + c3.y
					+ ' T ' + end.x + ' ' + end.y
					+ ' L ' + end0.x + ' ' + end0.y;
				*/

				/*
				//method 1
				mid = {
					x: (start.x + end.x)/2,
					y: (start.y + end.y)/2
				};

				c2 = {
					x: mid.x,
					y: start.y
				};

				c3 = {
					x: mid.x,
					y: end.y
				};

				d = 'M ' + start0.x + ' ' + start0.y + ' L ' + start.x + ' ' + start.y
					+ ' C ' + c2.x + ' ' + c2.y + ' ' + c3.x + ' ' + c3.y
					+ ' ' + end.x + ' ' + end.y
					+ ' L ' + end0.x + ' ' + end0.y;
				*/

				//method 2
				mid = {
					x: (start.x + end.x)/2,
					y: (start.y + end.y)/2
				};

				c2 = controlPoints[2];

				c3 = controlPoints[controlPoints.length - 3];

				d = 'M ' + start0.x + ' ' + start0.y + ' L ' + start.x + ' ' + start.y
					+ ' C ' + c2.x + ' ' + c2.y + ' ' + c3.x + ' ' + c3.y
					+ ' ' + end.x + ' ' + end.y
					+ ' L ' + end0.x + ' ' + end0.y;

		}
		else
		{
			$.each(controlPoints, function (idx, value)
			{
				if (idx === 0)
				{
					//start0 point
					d = 'M ' + value.x + " " + value.y;
				}
				else if (idx === (controlPoints.length - 1))
				{
					//end0 point
					d += ' L ' + value.x + ' ' + value.y;
				}
				else
				{
					//middle point
					prev_p = controlPoints[idx - 1]; //prev point
					next_p = controlPoints[idx + 1]; //next point

					if (
						(prev_p.x === value.x && next_p.x === value.x) ||
						(prev_p.y === value.y && next_p.y === value.y)
					)
					{
						//three point one line
						d += ' L ' + value.x + ' ' + value.y;
					}
					else
					{
						//fold line
						d += MC.canvas._getPath(prev_p, value, next_p);
					}
				}
				last_p = value;
			});
		}

		return d;
	},

	_round_corner: function (controlPoints)
	{
		//add by xjimmy, draw round corner of fold line
		var d = '',
			last_p = {},
			prev_p = {},
			next_p = {};

		$.each(controlPoints, function (idx, value)
		{
			if (idx === 0)
			{
				//start0 point
				d = 'M ' + value.x + " " + value.y;
			}
			else if (idx === (controlPoints.length - 1))
			{
				//end0 point
				d += ' L ' + value.x + ' ' + value.y;
			}
			else
			{
				//middle point
				prev_p = controlPoints[idx - 1]; //prev point
				next_p = controlPoints[idx + 1]; //next point

				if (
					(prev_p.x === value.x && next_p.x === value.x) ||
					(prev_p.y === value.y && next_p.y === value.y)
				)
				{
					//three point one line
					d += ' L ' + value.x + ' ' + value.y;
				}
				else
				{
					//fold line
					d += MC.canvas._getPath(prev_p, value, next_p);
				}
			}
			last_p = value;
		});

		return d;
	},

	_adjustMidY: function (port_id, mid_y, point, sign)
	{
		switch (port_id)
		{
			case 'rtb-src-top':
			case 'rtb-src-bottom':
				mid_y = point.y;
				break;

			case 'rtb-tgt':
			case 'elb-assoc':
			case 'elb-sg-in':
			case 'elb-sg-out':
				mid_y = point.y + 40 * sign;
				break;
		}
		return mid_y;
	},

	_adjustMidX: function (port_id, mid_x, point, sign)
	{
		switch (port_id)
		{
			case 'rtb-tgt-left':
			case 'rtb-tgt-right':
			case 'elb-assoc':
			case 'elb-sg-in':
			case 'elb-sg-out':
				if (point.angle === 0)
				{//left port
					mid_x = point.x + 4;
				}
				else if (point.angle === 180)
				{//right port
					mid_x = point.x - 4;
				}
				break;

			case 'rtb-src': //both top and bottom
				mid_x = point.x + 40 * sign;
				break;
		}
		return mid_x;
	},

	route: function (controlPoints, start0, end0, from_type, to_type, from_port_name, to_port_name)
	{
		//add by xjimmy, connection algorithm (xjimmy's algorithm)
		var start = {},
			end = {},
			mid_x,
			mid_y,
			//start.x>=end.x
			start_0_90 = false,
			end_0_90 = false,
			start_180_270 = false,
			end_180_270 = false,
			//start.x<end.x
			start_0_270 = false,
			end_0_270 = false,
			start_90_180 = false,
			end_90_180 = false;

		//deep copy
		$.extend(true, start, start0);
		$.extend(true, end, end0);

		if (Math.sqrt(Math.pow(end0.y - start0.y, 2) + Math.pow(end0.x-start0.x, 2)) > MC.canvas.PORT_PADDING * 2)
		{
			//add pad to start and end
			MC.canvas._addPad(start, 0);
			MC.canvas._addPad(end, 0);
		}

		MC.canvas._addPad(start, 0);
		MC.canvas._addPad(end, 0);

		//ensure start.y>=end.y
		if (start.y < end.y)
		{
			var tmp  = {};
			$.extend(true, tmp, start);
			$.extend(true, start, end);
			end = tmp;
			//swap start0 and end0 when swap start and end
			var tmp0  = {};
			$.extend(true, tmp0, start0);
			$.extend(true, start0, end0);
			end0 = tmp0;
			//swap from_type and to_type
			var tmp_type  = from_type;
			from_type = to_type;
			to_type = tmp_type;
			//swap from_port_name and to_port_name
			var tmp_port_name  = from_port_name;
			from_port_name = to_port_name;
			to_port_name = tmp_port_name;
		}

		if (start.x >= end.x)
		{
			start_0_90 = start.connectionAngle === 0 || start.connectionAngle === 90;
			end_0_90 = end.connectionAngle === 0 || end.connectionAngle === 90;
			start_180_270 = start.connectionAngle === 180 || start.connectionAngle === 270;
			end_180_270 = end.connectionAngle === 180 || end.connectionAngle === 270;
		}
		else
		{
			//start.x<end.x
			start_0_270 = start.connectionAngle === 0 || start.connectionAngle === 270;
			end_0_270 = end.connectionAngle === 0 || end.connectionAngle === 270;
			start_90_180 = start.connectionAngle === 90 || start.connectionAngle === 180;
			end_90_180 = end.connectionAngle === 90 || end.connectionAngle === 180;
		}

		//1.start point
		controlPoints.push( { 'x': start0.x, 'y': start0.y });
		controlPoints.push( { 'x': start.x, 'y': start.y });

		//2.control point
		if (
			(start_0_90 && end_0_90) ||
			(start_90_180 && end_90_180)
		)
		{
			//A
			controlPoints.push( { 'x': start.x, 'y': end.y });
		}
		else if (
			(start_180_270 && end_180_270) ||
			(start_0_270 && end_0_270)
		)
		{
			//B
			controlPoints.push( { 'x': end.x, 'y': start.y });
		}
		else if (
			(start_0_90 && end_180_270) ||
			(start_90_180 && end_0_270)
		)
		{
			//C
			mid_y = (start.y + end.y) / 2;
			if ( (to_type === "AWS.VPC.RouteTable" || to_type === "AWS.ELB" ) && to_type !== from_type)
			{
				if (Math.abs(mid_y - end.y) > 5)
				{
					mid_y = MC.canvas._adjustMidY(to_port_name, mid_y, end, 1);
				}
			}
			else if ( (from_type === "AWS.VPC.RouteTable" || to_type === "AWS.ELB" ) && to_type !== from_type)
			{
				if (Math.abs(start.y - mid_y) > 5)
				{
					mid_y = MC.canvas._adjustMidY(from_port_name, mid_y, start, -1);
				}
			}
			controlPoints.push( { 'x': start.x, 'y': mid_y });
			controlPoints.push( { 'x': end.x, 'y': mid_y });
		}
		else if (
			(start_180_270 && end_0_90) ||
			(start_0_270 && end_90_180)
		)
		{
			//D
			mid_x = (start.x + end.x) / 2;
			if ( (to_type === 'AWS.VPC.RouteTable' || to_type === 'AWS.ELB' ) && to_type !== from_type)
			{
				if (Math.abs(start.x - mid_x) > 5)
				{
					mid_x = MC.canvas._adjustMidX(to_port_name, mid_x, start, 1);
				}
			}
			else if (from_type === 'AWS.VPC.RouteTable' && to_type !== from_type)
			{
				if (Math.abs(mid_x - end.x) > 5)
				{
					if (to_type === 'AWS.VPC.InternetGateway' || to_type === 'AWS.VPC.VPNGateway')
					{
						mid_x = MC.canvas._adjustMidX(from_port_name, mid_x, end, -1);
					}
					else
					{
						mid_x = MC.canvas._adjustMidX(from_port_name, mid_x, start, -1);
					}
				}
			}
			else if (from_type === 'AWS.ELB' && to_type !== from_type)
			{
				if (Math.abs(mid_x - end.x) > 5)
				{
					if (to_type === 'AWS.EC2.Instance' || to_type === 'AWS.VPC.Subnet' || to_type === 'AWS.AutoScaling.Group' || to_type === 'AWS.AutoScaling.LaunchConfiguration' )
					{
						mid_x = MC.canvas._adjustMidX(from_port_name, mid_x, end, -1);
					}
					else
					{
						mid_x = MC.canvas._adjustMidX(from_port_name, mid_x, start, -1);
					}
				}
			}
			controlPoints.push({'x': mid_x, 'y': start.y});
			controlPoints.push({'x': mid_x, 'y': end.y});
		}

		//3.end point
		controlPoints.push({'x': end.x, 'y': end.y});
		controlPoints.push({'x': end0.x, 'y': end0.y});

		return controlPoints;
	},

	updateResizer: function(node, width, height)
	{
		var pad = 10,
			top = 0;

		width = width * MC.canvas.GRID_WIDTH;
		height = height * MC.canvas.GRID_HEIGHT;

		$(node).find('.resizer-wrap').empty().append(
			Canvon.rectangle(0, top, pad, pad).attr({'class': 'group-resizer resizer-topleft', 'data-direction': 'topleft'}),
			Canvon.rectangle(pad, top, width - 2 * pad, pad).attr({'class': 'group-resizer resizer-top', 'data-direction': 'top'}),
			Canvon.rectangle(width - pad, top, pad, pad).attr({'class': 'group-resizer resizer-topright', 'data-direction': 'topright'}),
			Canvon.rectangle(0, top + pad, pad, height - 2 * pad).attr({'class': 'group-resizer resizer-left', 'data-direction': 'left'}),
			Canvon.rectangle(width - pad, top + pad, pad, height - 2 * pad).attr({'class': 'group-resizer resizer-right', 'data-direction': 'right'}),
			Canvon.rectangle(0, height + top - pad, pad, pad).attr({'class': 'group-resizer resizer-bottomleft', 'data-direction': 'bottomleft'}),
			Canvon.rectangle(pad, height + top - pad, width - 2 * pad, pad).attr({'class': 'group-resizer resizer-bottom', 'data-direction': 'bottom'}),
			Canvon.rectangle(width - pad, height + top - pad, pad, pad).attr({'class': 'group-resizer resizer-bottomright', 'data-direction': 'bottomright'})
		);
	},

	route2: function (start, end)
	{
		//add by xjimmy, connection algorithm (xjimmy's algorithm)
		var controlPoints = [],
			start0 = {},
			end0 = {},
			//start.x >= end.x
			start_0_90 = false,
			end_0_90 = false,
			start_180_270 = false,
			end_180_270 = false,
			//start.x<end.x
			start_0_270 = false,
			end_0_270 = false,
			start_90_180 = false,
			end_90_180 = false;


		//first and last point
		$.extend(true, start0, start);
		$.extend(true, end0, end);

		if (Math.sqrt(Math.pow(end0.y - start0.y, 2) + Math.pow(end0.x - start0.x, 2)) > MC.canvas.PORT_PADDING * 2)
		{
			//add pad to start and end
			MC.canvas._addPad(start, 0);
			MC.canvas._addPad(end, 0);
		}

		MC.canvas._addPad(start, 0);
		MC.canvas._addPad(end, 0);

		//ensure start.y>=end.y
		if (start.y < end.y)
		{
			var tmp = start;
			start = end;
			end = tmp;
			var tmp0 = start0;
			start0 = end0;
			end0 = tmp0;
		}

		if (start.x >= end.x)
		{
			start_0_90 = start.angle === 0 || start.angle === 90;
			end_0_90 = end.angle === 0 || end.angle === 90;
			start_180_270 = start.angle === 180 || start.angle === 270;
			end_180_270 = end.angle === 180 || end.angle === 270;
		}
		else
		{
			//start.x<end.x
			start_0_270 = start.angle === 0 || start.angle === 270;
			end_0_270 = end.angle === 0 || end.angle === 270;
			start_90_180 = start.angle === 90 || start.angle === 180;
			end_90_180 = end.angle === 90 || end.angle === 180;
		}

		//1.start point
		controlPoints.push(start0);
		controlPoints.push(start);

		//2.control point
		if (
			(start_0_90 && end_0_90) || (start_90_180 && end_90_180)
		)
		{
			//A
			controlPoints.push(
			{
				x: start.x,
				y: end.y
			});
		}
		else if (
			(start_180_270 && end_180_270) || (start_0_270 && end_0_270)
		)
		{
			//B
			controlPoints.push(
			{
				x: end.x,
				y: start.y
			});
		}
		else if (
			(start_0_90 && end_180_270) || (start_90_180 && end_0_270)
		)
		{
			//C
			mid_y = Math.round((start.y + end.y) / 2);
			if ((end.type === "AWS.VPC.RouteTable" || end.type === "AWS.ELB") && end.type !== start.type)
			{
				if (Math.abs(mid_y - end.y) > 5)
				{
					mid_y = MC.canvas._adjustMidY(end.name, mid_y, end, 1);
				}
			}
			else if ((start.type === "AWS.VPC.RouteTable" || end.type === "AWS.ELB") && end.type !== start.type)
			{
				if (Math.abs(start.y - mid_y) > 5)
				{
					mid_y = MC.canvas._adjustMidY(start.name, mid_y, start, -1);
				}
			}
			controlPoints.push(
			{
				x: start.x,
				y: mid_y
			});
			controlPoints.push(
			{
				x: end.x,
				y: mid_y
			});
		}
		else if (
			(start_180_270 && end_0_90) || (start_0_270 && end_90_180)
		)
		{
			//D
			mid_x = Math.round((start.x + end.x) / 2);
			if ((end.type === 'AWS.VPC.RouteTable' || end.type === 'AWS.ELB') && end.type !== start.type)
			{
				if (Math.abs(start.x - mid_x) > 5)
				{
					mid_x = MC.canvas._adjustMidX(end.name, mid_x, start, 1);
				}
			}
			else if (start.type === 'AWS.VPC.RouteTable' && end.type !== start.type)
			{
				if (Math.abs(mid_x - end.x) > 5)
				{
					if (end.type === 'AWS.VPC.InternetGateway' || end.type === 'AWS.VPC.VPNGateway')
					{
						mid_x = MC.canvas._adjustMidX(start.name, mid_x, end, -1);
					}
					else
					{
						mid_x = MC.canvas._adjustMidX(start.name, mid_x, start, -1);
					}
				}
			}
			else if (start.type === 'AWS.ELB' && end.type !== start.type)
			{
				if (Math.abs(mid_x - end.x) > 5)
				{
					if (end.type === 'AWS.EC2.Instance' || end.type === 'AWS.VPC.Subnet' || end.type === 'AWS.AutoScaling.Group' || end.type === 'AWS.AutoScaling.LaunchConfiguration')
					{
						mid_x = MC.canvas._adjustMidX(start.name, mid_x, end, -1);
					}
					else
					{
						mid_x = MC.canvas._adjustMidX(start.name, mid_x, start, -1);
					}
				}
			}
			controlPoints.push(
			{
				x: mid_x,
				y: start.y
			});
			controlPoints.push(
			{
				x: mid_x,
				y: end.y
			});
		}

		//3.end point
		controlPoints.push(end);
		controlPoints.push(end0);

		return controlPoints;
	},

	// by xjimmy
	genPath: function (from_port, to_port, from_port_offset, to_port_offset, canvas_offset, scale_ratio, connection_option)
	{
		var offset_startX = 0,
			offset_endX = 0,
			controlPoints = [],

			startX = Math.round( (from_port_offset.left - canvas_offset.left + (from_port_offset.width / 2)) * scale_ratio ),
			startY = Math.round( (from_port_offset.top - canvas_offset.top + (from_port_offset.height / 2)) * scale_ratio ),
			endX = Math.round( (to_port_offset.left - canvas_offset.left + (to_port_offset.width / 2)) * scale_ratio ),
			endY = Math.round( (to_port_offset.top - canvas_offset.top + (to_port_offset.height / 2)) * scale_ratio ),

			start0 = {
				x : startX,
				y : startY,
				connectionAngle: from_port.getAttribute('data-angle') * 1
			};

			end0 = {
				x: endX,
				y: endY,
				connectionAngle: to_port.getAttribute('data-angle') * 1
			},

			path;

		if (from_type === 'AWS.VPC.RouteTable' && from_target_port === "rtb-src")
		{
			offset_startX += 1;
		}

		if (to_type === 'AWS.VPC.RouteTable' && to_target_port === "rtb-src")
		{
			offset_endX += 1;
		}

		//add pad to start0 and end0
		MC.canvas._addPad(start0, 1);
		MC.canvas._addPad(end0, 1);

		// straight line
		if (start0.x === end0.x || start0.y === end0.y)
		{
			path = 'M ' + start0.x + ' ' + start0.y + ' L ' + end0.x + ' ' + end0.y;
		}
		else
		{
			// fold line
			MC.canvas.route(controlPoints, start0, end0, from_type, to_type ,from_target_port, to_target_port);

			if (controlPoints.length > 0)
			{
				if (connection_option.type === 'sg')
				{
					switch (MC.canvas_property.LINE_STYLE)
					{
						case 0: //straight
							path = 'M ' + controlPoints[0].x + ' ' + controlPoints[0].y +
								' L ' + controlPoints[1].x + ' ' + controlPoints[1].y +
								' L ' + controlPoints[controlPoints.length-2].x + ' ' + controlPoints[controlPoints.length-2].y +
								' L ' + controlPoints[controlPoints.length-1].x + ' ' + controlPoints[controlPoints.length-1].y;
							break;

						case 1: //elbow
							path = MC.canvas._round_corner(controlPoints);
							break;

						case 2: //bezier-q
							path = MC.canvas._bezier_q_corner(controlPoints);
							break;

						case 3: //bezier-qt
							path = MC.canvas._bezier_qt_corner(controlPoints);
							break;
					}
				}
				else
				{
					path = MC.canvas._round_corner(controlPoints); //elbow
				}
			}
		}
		return path;
    },

	connect: function (from_uid, from_target_port, to_uid, to_target_port, line_id)
	{
		var canvas_offset = $canvas.offset(),

			from_node = document.getElementById( from_uid ),
			to_node = document.getElementById( to_uid ),

			from_item = $canvas(from_uid),
			to_item = $canvas(to_uid),

			from_node_type = from_item.nodeType,
			to_node_type = to_item.nodeType,

			from_type = from_item.type,
			to_type = to_item.type,

			connection_option = MC.canvas.CONNECTION_OPTION[ from_type ][ to_type ],
			//connection_target_data = {},
			scale_ratio = $canvas.scale(),

			direction,

			from_port,
			to_port,
			from_port_offset,
			to_port_offset,

			port_direction,

			dash_style,
			path,
			svg_line;

		if (connection_option)
		{
			if ($.type(connection_option) === 'array')
			{
				$.each(connection_option, function (index, item)
				{
					if (
						item.from === from_target_port &&
						item.to === to_target_port
					)
					{
						connection_option = item;
					}
				});
			}

			// Special connection
			if (
				connection_option.direction
			)
			{
				direction = connection_option.direction;

				if (direction.from && direction.to)
				{
					if (from_node[0].getBoundingClientRect().left > to_node[0].getBoundingClientRect().left)
					{
						from_port = document.getElementById(from_uid + '_port-' + from_target_port + '-left');
						to_port = document.getElementById(to_uid + '_port-' + to_target_port + '-right');
					}
					else
					{
						from_port = document.getElementById(from_uid + '_port-' + from_target_port + '-right');
						to_port = document.getElementById(to_uid + '_port-' + to_target_port + '-left');
					}

					from_port_offset = from_port.getBoundingClientRect();
					to_port_offset = to_port.getBoundingClientRect();
				}
				else
				{
					if (direction.from)
					{
						to_port = document.getElementById(to_uid + '_port-' + to_target_port);
						to_port_offset = to_port.getBoundingClientRect();

						if (direction.from === 'vertical')
						{
							port_direction = to_port_offset.top > from_node[0].getBoundingClientRect().top ? 'bottom' : 'top';
						}

						if (direction.from === 'horizontal')
						{
							port_direction = to_port_offset.left > from_node[0].getBoundingClientRect().left ? 'right' : 'left';
						}

						from_port = document.getElementById(from_uid + '_port-' + from_target_port + '-' + port_direction);
						from_port_offset = from_port.getBoundingClientRect();
					}

					if (direction.to)
					{
						from_port = document.getElementById(from_uid + '_port-' + from_target_port);
						from_port_offset = from_port.getBoundingClientRect();

						if (direction.to === 'vertical')
						{
							port_direction = from_port_offset.top > to_node[0].getBoundingClientRect().top ? 'bottom' : 'top';
						}

						if (direction.to === 'horizontal')
						{
							port_direction = from_port_offset.left > to_node[0].getBoundingClientRect().left ? 'right' : 'left';
						}

						to_port = document.getElementById(to_uid + '_port-' + to_target_port + '-' + port_direction);
						to_port_offset = to_port.getBoundingClientRect();
					}
				}
			}
			else
			{
				from_port = document.getElementById(from_uid + '_port-' + from_target_port);
				from_port_offset = from_port.getBoundingClientRect();

				to_port = document.getElementById(to_uid + '_port-' + to_target_port);
				to_port_offset = to_port.getBoundingClientRect();
			}

			path = MC.canvas.genPath(from_port, to_port, from_port_offset, to_port_offset, canvas_offset, scale_ratio, connection_option);

			svg_line = document.getElementById( line_id );

			if (svg_line !== null)
			{
				$(svg_line).children().attr('d', path);
			}
			else
			{
				MC.paper.start();

				MC.paper.path(path);
				MC.paper.path(path).attr('class','fill-line');

				if (connection_option.dash_line === true)
				{
					MC.paper.path(path).attr('class', 'dash-line');
				}

				svg_line = MC.paper.save();

				document.getElementById('line_layer').appendChild(svg_line);

				svg_line.setAttributeNS("http://www.w3.org/1999/xlink", "class", 'line line-' + connection_option.type);
				svg_line.setAttributeNS("http://www.w3.org/1999/xlink", "data-type", 'line');
				svg_line.id = line_id;

				svg_line = null;
			}

			return true;
		}
		else
		{
			return false;
		}
	},

	select: function (id)
	{
		var item = $canvas(id),
			target = item.$element(),
			node_type = item.nodeType,
			clone_node;

		Canvon(target).addClass('selected');

		if (node_type === 'line')
		{
			clone = target.clone();

			target.remove();
			$('#line_layer').append(clone);
		}

		if (node_type === 'node')
		{
			clone = target.clone();

			target.remove();
			$('#node_layer').append(clone);

			$.each(item.connection(), function (index, item)
			{
				Canvon('#' + item.line + ', #' + id + '_port-' + item.port).addClass('view-show');
			});

			Canvon(clone.find('.port')).addClass('view-show');
		}

		$canvas.selected_node().length = 0;

		$canvas.selected_node().push( id );

		return true;
	},

	move: function (node, x, y)
	{
		var target_item = $canvas(node.id),
			target_type = target_item.type,
			node_type = target_item.nodeType,

			connection_stack = [],

			group_child,
			group_coordinate,
			group_offsetX,
			group_offsetY,

			group_size,

			node_item,
			node_coordinate;

		if (node_type === 'node')
		{
			target_item.position(x, y);
			target_item.reConnect();
		}

		if (node_type === 'group')
		{
			group_child = MC.canvas.groupChild(node);

			group_coordinate = target_item.position();

			group_size = target_item.size();

			group_offsetX = x - group_coordinate[0];
			group_offsetY = y - group_coordinate[1];

			target_item.position(x, y);
			target_item.reConnect();

			$.each(group_child, function (index, item)
			{
				node_item = $canvas( item.id );
				node_coordinate = node_item.position();

				node_item.position(node_coordinate[0] + group_offsetX, node_coordinate[1] + group_offsetY);

				// Re-draw group connection
				if (
					node_item.type === 'AWS.VPC.Subnet' ||
					node_item.type === 'AWS.AutoScaling.Group' ||
					node_item.nodeType === 'node'
				)
				{
					$.each(node_item.connection(), function (i, data)
					{
						connection_stack.push( data.line );
					});
				}
			});

			$.each(connection_stack, function (index, value)
			{
				$canvas( value ).reConnect();
			});

			// Re-draw group connection
			if (target_type === 'AWS.VPC.Subnet' || target_type === 'AWS.AutoScaling.Group')
			{
				target_item.reConnect();
			}

			if (target_type === 'AWS.VPC.VPC')
			{
				var group_left = x,
					group_top = y,
					group_width = group_size[0],
					group_height = group_size[1],

					igw_gateway,
					igw_item,

					vgw_gateway,
					vgw_item;

				igw_gateway = $('.AWS-VPC-InternetGateway');
				vgw_gateway = $('.AWS-VPC-VPNGateway');

				if (igw_gateway[0])
				{
					igw_item = $canvas(igw_gateway.attr('id'));
					//igw_top = igw_item.position()[1] + group_offsetY;

					// MC.canvas.COMPONENT_SIZE[0] / 2 = 4
					igw_item.position(group_left - 4, igw_item.position()[1] + group_offsetY);

					igw_item.reConnect();
				}

				if (vgw_gateway[0])
				{
					vgw_item = $canvas(vgw_gateway.attr('id'));
					//vgw_top = vgw_item.position()[1] + group_offsetY;

					// MC.canvas.COMPONENT_SIZE[0] / 2 = 4
					vgw_item.position(group_left + group_width - 4, vgw_item.position()[1] + group_offsetY);

					vgw_item.reConnect();
				}
			}
		}
	},

	position: function (node, x, y)
	{
		x = x > 0 ? x : 0;
		y = y > 0 ? y : 0;

		var transformVal = node.transform.baseVal,
			translateVal;

		if (transformVal.numberOfItems === 1)
		{
			/* MC.canvas.GRID_WIDTH = 10 */
			/* MC.canvas.GRID_HEIGHT = 10 */
			transformVal.getItem(0).setTranslate(x * 10, y * 10);
		}
		else
		{
			/* MC.canvas.GRID_WIDTH = 10 */
			/* MC.canvas.GRID_HEIGHT = 10 */
			translateVal = node.ownerSVGElement.createSVGTransform();

			translateVal.setTranslate(x * 10, y * 10);

			transformVal.appendItem(translateVal);
		}

		return true;
	},

	groupSize: function (node, width, height)
	{
		var group = node.getElementsByClassName('group')[0];

		group.width.baseVal.value = width * 10;
		group.height.baseVal.value = height * 10;
		group.x.baseVal.value = 0;
		group.y.baseVal.value = 0;

		return true;
	},

	remove: function (node)
	{
		$(node).remove();

		return true;
	},

	pixelToGrid: function (x, y)
	{
		var scale_ratio = $canvas.scale();

		return {
			'x': Math.ceil(x * scale_ratio / MC.canvas.GRID_WIDTH),
			'y': Math.ceil(y * scale_ratio / MC.canvas.GRID_HEIGHT)
		};
	},

	matchPoint: function (x, y)
	{
		var coordinate = MC.canvas.pixelToGrid(x, y),
			node_coordinate,
			matched,
			size;

		$.each($canvas.node(), function (index, item)
		{
			node_coordinate = item.position();
			size = item.size();

			if (
				node_coordinate &&
				node_coordinate[0] <= coordinate.x &&
				node_coordinate[0] + size[0] >= coordinate.x &&
				node_coordinate[1] <= coordinate.y &&
				node_coordinate[1] + size[1] >= coordinate.y
			)
			{
				matched = document.getElementById( item.id );

				return false;
			}
		});

		return matched;
	},

	isMatchPlace: function (target_id, target_type, node_type, x, y, width, height)
	{
		var group_stack = [
				document.getElementById('asg_layer').childNodes,
				document.getElementById('subnet_layer').childNodes,
				document.getElementById('az_layer').childNodes,
				document.getElementById('vpc_layer').childNodes
			],
			points = [
				{
					'x': x,
					'y': y
				},
				{
					'x': x + width,
					'y': y
				},
				{
					'x': x,
					'y': y + height
				},
				{
					'x': x + width,
					'y': y + height
				}
			],
			canvas_size = $canvas.size(),
			match_option = MC.canvas.MATCH_PLACEMENT[ $canvas.platform() ][ target_type ],
			ignore_stack = [],
			match = [],
			result = {},
			is_matched = false,
			match_status,
			match_target,
			group_node,
			group_child,
			coordinate,
			size,

			// For specially fast iteration algorithm
			point = points.length,
			layer,
			i;

		if (target_id !== null)
		{
			ignore_stack.push(target_id);

			if (node_type === 'group')
			{
				group_child = MC.canvas.groupChild(document.getElementById(target_id));

				$.each(group_child, function (index, item)
				{
					if ($canvas( item.id ).nodeType === 'group')
					//if (item.getAttribute('data-type') === 'group')
					{
						ignore_stack.push(item.id);
					}
				});
			}
		}

		while ( point-- )
		{
			layer = group_stack.length;

			while ( layer-- )
			{
				if ( group_stack[ layer ] )
				{
					match_status = {};
					i = group_stack[ layer ].length;

					while ( i-- )
					{
						id = group_stack[ layer ][ i ].id;

						group_item = $canvas(id);
						coordinate = group_item.position();
						size = group_item.size();

						if (
							$.inArray(id, ignore_stack) === -1 &&
							points[ point ].x > coordinate[0] &&
							points[ point ].x < coordinate[0] + size[0] &&
							points[ point ].y > coordinate[1] &&
							points[ point ].y < coordinate[1] + size[1]
						)
						{
							match_status['is_matched'] = $.inArray(group_item.type, match_option) > -1;
							match_status['target'] = id;
							match_target = id;
						}
					}

					if (!$.isEmptyObject(match_status))
					{
						match[ point ] = match_status;
					}
				}
			}
		}

		is_matched =
			match[0] &&
			match[1] &&
			match[2] &&
			match[3] &&

			match[0].is_matched &&
			match[1].is_matched &&
			match[2].is_matched &&
			match[3].is_matched &&

			match[0].target === match[1].target &&
			match[0].target === match[2].target &&
			match[0].target === match[3].target &&

			// canvas right offset = 3
			x + width < canvas_size[0] - 3 &&
			y + height < canvas_size[1] - 3;

		if (
			!is_matched &&
			$.inArray('Canvas', match_option) > -1 &&
			!match[0] &&
			!match[1] &&
			!match[2] &&
			!match[3] &&

			// canvas right offset = 3
			x + width < canvas_size[0] - 3 &&
			y + height < canvas_size[1] - 3
		)
		{
			is_matched = true;
			match_target = 'Canvas';
		}

		return {
			'is_matched': is_matched,
			'target': is_matched ? match_target : null
		};
	},

	isBlank: function (target_id, target_type, node_type, start_x, start_y, width, height)
	{
		var isBlank = true,
			end_x,
			end_y,
			coordinate,
			size;

		if (node_type === 'group')
		{
			end_x = start_x + width;
			end_y = start_y + height;

			$.each($canvas.group(), function (key, item)
			{
				coordinate = item.position();
				size = item.size();

				if (
					item.id !== target_id &&
					item.type === target_type &&
					coordinate[0] < end_x &&
					coordinate[0] + size[0] > start_x &&
					coordinate[1] < end_y &&
					coordinate[1] + size[1] > start_y
				)
				{
					isBlank = false;
				}
			});
		}

		return isBlank;
	},

	parentGroup: function (node_id, target_type, start_x, start_y, end_x, end_y)
	{
		var group_parent_type = MC.canvas.MATCH_PLACEMENT[ $canvas.platform() ][ target_type ],
			matched = null,
			group_item,
			coordinate,
			size;

		$.each($canvas.group(), function (key, item)
		{
			group_item = $canvas(item.id);

			coordinate = group_item.position();
			size = group_item.size();

			if (
				node_id !== item.id &&
				$.inArray(group_item.type, group_parent_type) > -1 &&
				(
					coordinate[0] <= start_x &&
					coordinate[0] + size[0] >= start_x
				)
				&&
				(
					coordinate[1] <= start_y &&
					coordinate[1] + size[1] >= start_y
				)
			)
			{
				matched = document.getElementById( item.id );

				//return false;
			}
		});

		return matched;
	},

	areaChild: function (node_id, target_type, start_x, start_y, end_x, end_y)
	{
		var group_weight = MC.canvas.GROUP_WEIGHT[ target_type ],
			matched = [],
			coordinate,
			size;

		$.each($canvas.node(), function (key, item)
		{
			coordinate = item.position();
			size = item.size();

			if (
				node_id !== item.id &&
				item.type !== 'AWS.VPC.InternetGateway' &&
				item.type !== 'AWS.VPC.VPNGateway' &&
				(
					(coordinate[0] > start_x &&
					coordinate[0] < end_x)
					||
					(coordinate[0] + size[0] > start_x &&
					coordinate[0] + size[0] < end_x)
				)
				&&
				(
					(coordinate[1] > start_y &&
					coordinate[1] < end_y)
					||
					(coordinate[1] + size[1] > start_y &&
					coordinate[1] + size[1] < end_y)
				)
			)
			{
				matched.push(document.getElementById( item.id ));
			}
		});

		$.each($canvas.group(), function (key, item)
		{
			coordinate = item.position();
			size = item.size();

			if (
				node_id !== item.id &&
				(
					$.inArray(item.type, group_weight) > -1 ||
					item.type === target_type
				) &&
				start_x <= coordinate[0] + size[0] &&
				end_x >= coordinate[0] &&
				start_y <= coordinate[1] + size[1] &&
				end_y >= coordinate[1]
			)
			{
				matched.push(document.getElementById( item.id ));
			}
		});

		return matched;
	},

	groupChild: function (group_node)
	{
		var group_item = $canvas(group_node.id),
			coordinate = group_item.position(),
			size = group_item.size();

		return MC.canvas.areaChild(
			group_item.id,
			group_item.type,
			coordinate[ 0 ],
			coordinate[ 1 ],
			coordinate[ 0 ] + size[ 0 ],
			coordinate[ 1 ] + size[ 1 ]
		);
	}
};

MC.canvas.layout = {
	init: function ()
	{
		MC.paper = Canvon('#svg_canvas');

		var canvas_size = $canvas.size(),
			attr = {
				'width' : canvas_size[0] * MC.canvas.GRID_WIDTH,
				'height': canvas_size[1] * MC.canvas.GRID_HEIGHT
			};
		
		// var dict_sg = {};
		// var dict_sg_elb = {};

		// //patch: for duplicate sg name of elb (1)
		// $.each(components, function (key, value)
		// {
		// 	try
		// 	{
		// 		if (value.type === "AWS.EC2.SecurityGroup")
		// 		{
		// 			if (value.resource.GroupDescription === "Automatically created SG for load-balancer")
		// 			{
		// 				if (!dict_sg[ value.name ])
		// 				{
		// 					dict_sg[ value.name ] = [];
		// 				}
		// 				dict_sg[ value.name ].push( value.uid );
		// 			}
		// 		}
		// 		if (value.type === "AWS.ELB")
		// 		{
		// 			$.each(value.resource.SecurityGroups, function(sg_key, value_ref)
		// 			{
		// 				if (!dict_sg_elb[MC.extractID(value_ref)])
		// 				{
		// 					dict_sg_elb[MC.extractID(value_ref)]=[];
		// 				}
		// 				dict_sg_elb[MC.extractID(value_ref)].push(value.name);
		// 			});
		// 		}
		// 	}
		// 	catch(error)
		// 	{
		// 		console.warn("find duplicate sg name of elb failed");
		// 		return true;
		// 	}
		// });
		// //patch: for duplicate sg name of elb (2)
		// $.each( dict_sg, function (elb_name, sg_uids)
		// {
		// 	try
		// 	{
		// 		if (sg_uids && sg_uids.length>1)
		// 		{//duplicate
		// 			$.each( sg_uids, function(k,sg_uid)
		// 			{
		// 				if (!dict_sg_elb[sg_uid])
		// 				{//no reference
		// 					console.warn("sg_uid " + sg_uid +" has no reference" );
		// 					//delete sg rule
		// 					MC.aws.sg.deleteRefInAllComp(sg_uid);
		// 					//delete sg component
		// 					delete components[sg_uid];
		// 				}
		// 			});
		// 		}
		// 	}
		// 	catch(error)
		// 	{
		// 		console.warn("remove duplicate sg failed");
		// 		return true;
		// 	}
		// });

		$('#svg_canvas').attr( attr );
		$('#canvas_container').css( attr );

		return true;
	}
};

// MC.canvas.data = {
// 	get: function (key)
// 	{
// 		var context = MC.canvas_data,
// 			namespaces = key.split('.'),
// 			last = namespaces.pop(),
// 			i = 0,
// 			length = namespaces.length,
// 			context;

// 		for (; i < length; i++)
// 		{
// 			context = context[ namespaces[ i ] ];
// 		}

// 		return context[ last ];
// 	},

// 	set: function (key, value)
// 	{
// 		var context = MC.canvas_data,
// 			namespaces = key.split('.'),
// 			last = namespaces.pop(),
// 			i = 0,
// 			length = namespaces.length,
// 			context;

// 		for (; i < length; i++)
// 		{
// 			context = context[ namespaces[ i ] ];
// 		}

// 		return context[ last ] = value;
// 	},

// 	delete: function (key)
// 	{
// 		var context = MC.canvas_data,
// 			namespaces = key.split('.'),
// 			last = namespaces.pop(),
// 			i = 0,
// 			length = namespaces.length,
// 			context;

// 		for (; i < length; i++)
// 		{
// 			context = context[ namespaces[ i ] ];
// 		}

// 		delete context[ last ];
// 	}
// };

MC.canvas.volume = {
	bubble: function (id, node_id, volume_type)
	{
		if (!$('#volume-bubble-box')[0])
		{
			var target = $('#' + id),
				canvas_container = $('#canvas_container'),
				canvas_offset = $canvas.offset(),
				target_uid = id.replace(/_[0-9]*$/ig, ''),
				width,
				height,
				target_offset,
				target_width,
				target_height,
				bubble_box;

			canvas_container.append('<div id="volume-bubble-box"><div class="arrow"></div><div id="volume-bubble-content"></div></div>');
			bubble_box = $('#volume-bubble-box');

			volume_list = volume_type ? $canvas( $('#' + volume_type + '-wrap').data('target-id') ).listVolume( node_id ) : $canvas( id ).volume();

			$.each(volume_list, function (i, item)
			{
				item.instance_id = id;
			});

			$('#volume-bubble-content').html(
				MC.template.instanceVolume( volume_list )
			);

			if (volume_type)
			{
				target_offset = target.offset();
				target_width = target.width();
				target_height = target.height();
			}
			else
			{
				target_offset = target[0].getBoundingClientRect();
				target_width = target_offset.width;
				target_height = target_offset.height;
			}

			width = bubble_box.width();
			height = bubble_box.height();

			bubble_box
				.addClass('bubble-left')
				.data('target-id', id)
				.css({
					'left': target_offset.left + target_width + 15 - canvas_offset.left,
					'top': target_offset.top - canvas_offset.top - ((height - target_height) / 2)
				})
				.show();

			if (target.prop('namespaceURI') === 'http://www.w3.org/2000/svg')
			{
				MC.canvas.update(id, 'image', 'volume_status', MC.canvas.IMAGE.INSTANCE_VOLUME_ATTACHED_ACTIVE);
			}
		}
	},

	show: function ()
	{
		event.stopImmediatePropagation();

		var target = $(this),
			bubble_box = $('#volume-bubble-box'),
			target_id = target.data('target-id'),
			target_uid = target_id.replace(/_[0-9]*$/ig, ''),

			volume_type =
				target.hasClass('instanceList-item-volume') ? 'instanceList' :
				target.hasClass('asgList-item-volume') ? 'asgList' : null,

			volume_list = volume_type ? $canvas( $('#' + volume_type + '-wrap').data('target-id') ).listVolume( target.parent().data('id') ) : $canvas(target_id).volume(),

			volume_length = volume_list.length,
			bubble_target_id;

		if (!bubble_box[0])
		{
			if (MC.canvas.getState() === 'app')
			{
				if (volume_type)
				{
					MC.canvas.volume.bubble( target_id, target.parent().data('id'), volume_type );

					return false;
				}
				else if (
					//$('#' + target_id + '_instance-number').text() * 1 === 1 ||
					//target.hasClass('instanceList-item-volume') ||
					$canvas( target_id ).list().length === 0
				)
				{
					MC.canvas.volume.bubble(target_id);

					return false;
				}
				else
				{
					$canvas( target_uid ).select();

					return false;
				}

				if ($canvas(target_id).type === 'AWS.AutoScaling.LaunchConfiguration')
				{
					MC.canvas.asgList.show.call( this, event );

					return false;
				}
			}

			if (
				MC.canvas.getState() === 'appedit' &&
				$canvas(target_id).type === 'AWS.AutoScaling.LaunchConfiguration'
			)
			{
				$canvas( target_uid ).select();

				return false;
			}

			if (volume_length > 0)
			{
				MC.canvas.volume.bubble(target_id);
			}
			else
			{
				if ($('#' + target_id).prop('namespaceURI') === 'http://www.w3.org/2000/svg')
				{
					MC.canvas.update(target_id, 'image', 'volume_status', MC.canvas.IMAGE.INSTANCE_VOLUME_NOT_ATTACHED);
				}
			}
		}
		else
		{
			bubble_target_id = bubble_box.data('target-id');

			MC.canvas.volume.close();
			// MC.canvas.event.clearSelected();

			// $canvas(target_uid).select();

			if (target_uid !== bubble_target_id)
			{
				if (
					MC.canvas.getState() === 'app' &&
					volume_type
				)
				{
					MC.canvas.volume.bubble( target_id, target.parent().data('id'), volume_type );
				}
				else
				{
					MC.canvas.volume.bubble(target_id);
				}
			}
		}

		return false;
	},

	select: function (id)
	{
		MC.canvas.event.clearSelected();

		$('#instance_volume_list').find('.selected').removeClass('selected');

		$('#' + id).addClass('selected');

		$(document).on('keyup', MC.canvas.volume.remove);

		return false;
	},

	close: function (event)
	{
		var bubble_box = $('#volume-bubble-box'),
			target;

		if (event)
		{
			target = $(event.target);
			if (
				target.attr('class') === 'instance-volume' ||
				target.is('.snapshot_item') ||
				target.parent().is('.snapshot_item') ||
				target.is('.volume_item') ||
				target.parent().is('.volume_item')
			)
			{
				return false;
			}
		}

		if (bubble_box[0])
		{
			target_id = bubble_box.data('target-id');
			bubble_box.remove();

			if ($('#' + target_id).prop('namespaceURI') === 'http://www.w3.org/2000/svg')
			{
				MC.canvas.update(target_id, 'image', 'volume_status', MC.canvas.IMAGE.INSTANCE_VOLUME_NOT_ATTACHED);
			}

			$(document)
				.off('keyup', MC.canvas.volume.remove)
				.off('click', ':not(.instance-volume, #volume-bubble-box)', MC.canvas.volume.close);
		}
	},

	remove: function (event)
	{
		if (
			(
				event.which === 46 ||
				// For Mac
				event.which === 8
			)
			&&
			MC.canvas.getState() !== 'app' &&
			event.target === document.body
		)
		{
			var bubble_box = $('#volume-bubble-box'),
				target_id = bubble_box.data('target-id'),
				target_node = $('#' + target_id),
				target_offset = target_node[0].getBoundingClientRect(),
				volume_id = $('#instance_volume_list').find('.selected').attr('id');

			if ( $canvas(volume_id).remove() )
			{
				$('#' + volume_id).parent().remove();

				bubble_box.css('top',  target_offset.top - $('#canvas_container').offset().top - ((bubble_box.height() - target_offset.height) / 2));

				$('#instance_volume_number').text(
					$canvas( target_id ).volume().length
				);

				$canvas.trigger("CANVAS_NODE_SELECTED", "");

			}

			$(document).off('keyup', MC.canvas.volume.remove);

			return true;
		}
	},

	mousedown: function (event)
	{
		if (event.which === 1)
		{
			var target = $(this),
				target_offset = target.offset(),
				canvas_offset = $canvas.offset(),
				node_type = target.data('type'),
				state = MC.canvas.getState(),
				shadow,
				clone_node;

			if (
				state === 'app' ||
				state === 'appview'// ||
				//$canvas( target.data('instance') ).type === 'AWS.AutoScaling.LaunchConfiguration'
			)
			{
				//MC.canvas.volume.select(this.id);
				$canvas( this.id, 'AWS.EC2.EBS.Volume' ).select();

				return false;
			}

			$(document.body)
				.append('<div id="drag_shadow"><div class="resource-icon resource-icon-volume"></div></div>')
				.append('<div id="overlayer" class="grabbing"></div>');

			shadow = $('#drag_shadow');

			shadow
				.addClass('AWS-EC2-EBS-Volume')
				.css({
					'top': event.pageY - 50,
					'left': event.pageX - 50
				});

			Canvon('.AWS-EC2-Instance, .AWS-AutoScaling-LaunchConfiguration').addClass('attachable');

			$(document).on({
				'mousemove': MC.canvas.volume.mousemove,
				'mouseup': MC.canvas.volume.mouseup
			}, {
				'target': target,
				'instance_id': target.data('instance'),
				'canvas_offset': $canvas.offset(),
				'canvas_body': $('#canvas_body'),
				'shadow': shadow,
				'originalPageX': event.pageX,
				'originalPageY': event.pageY,
				'action': 'move'
			});

			$canvas( this.id ).select();

			return false;
		}
	},

	mousemove: function (event)
	{
		var match_node = MC.canvas.matchPoint(
				event.pageX - event.data.canvas_offset.left,
				event.pageY - event.data.canvas_offset.top
			),
			node_type = match_node ? match_node.getAttribute('data-class') : null,
			event_data = event.data,
			target_type = MC.canvas.getState() === 'appedit' ? ['AWS.EC2.Instance'] : ['AWS.EC2.Instance', 'AWS.AutoScaling.LaunchConfiguration'];

		if (
			event_data.originalX !== event.pageX ||
			event_data.originalY !== event.pageY
		)
		{
			event_data.shadow
				.css({
					'top': event.pageY - 50,
					'left': event.pageX - 50
				})
				.show();

			event_data.canvas_body.addClass('node-dragging');
		}

		if (
			match_node &&
			$.inArray(node_type, target_type) > -1
		)
		{
			// if (
			// 	event_data.action === 'move'// &&
			// 	//node_type === 'AWS.AutoScaling.LaunchConfiguration'
			// )
			// {
			// 	MC.canvas.volume.close();
			// }
			// else
			// {
				MC.canvas.volume.bubble(match_node.id);
			//}
		}
		else
		{
			MC.canvas.volume.close();
		}

		return false;
	},

	mouseup: function (event)
	{
		var target = $(event.data.target),
			node_option = target.data('option') || {},
			bubble_box = $('#volume-bubble-box'),
			original_node_volume_data,
			new_volume_name,
			target_volume_data,
			original_node_id,
			volume_type,
			new_volume,
			data_option,
			volume_id,
			target_id,
			target_az;

		Canvon('.AWS-EC2-Instance, .AWS-AutoScaling-LaunchConfiguration').removeClass('attachable');

		if (bubble_box[0])
		{
			target_id = bubble_box.data('target-id');
			target_node = $('#' + target_id);
			target_offset = target_node[0].getBoundingClientRect();

			if (event.data.action === 'move')
			{
				volume_id = target.attr('id');
				//data_option = target.data('json');
			}
			else
			{
				data_option = target.data('option');
				// data_option['instance_id'] = target_id;

				volume_item = $canvas(target_id).addVolume(data_option);

				if (volume_item)
				{
					volume_type = volume_item.snapshotId ? 'snapshot_item' : 'volume_item';

					$('#instance_volume_list').append('<li><a href="javascript:void(0)" id="' + volume_item.id +'" data-instance="' + target_id + '" class="' + volume_type + '"><span class="volume_name">' + volume_item.name + '</span><span class="volume_size">' + volume_item.size + 'GB</span></a></li>');

					$('#instance_volume_number').text(
						$canvas( target_id ).volume().length
					);

					$canvas( volume_item.id, 'AWS.EC2.EBS.Volume' ).select();
				}

				// if (volume_item.id === null)
				// {
				// 	event.data.action = 'cancel';
				// }
				// else
				// {
				// 	// if (target_node.data('class') === 'AWS.AutoScaling.LaunchConfiguration')
				// 	// {
				// 	// 	volume_id = new_volume;
				// 	// }
				// 	// else
				// 	// {
				// 	// 	volume_id = new_volume.id;
				// 	// 	//data_option.name = MC.canvas.data.get('component.' + volume_id + '.name');
				// 	// }
				// }
			}

			if (event.data.action === 'move')
			{
				//volume_item = $canvas(event.data.instance_id).volume(volume_id);

				if (event.data.instance_id !== target_id)
				{
					volume_item = $canvas(target_id).moveVolume(volume_id);

					if (volume_item)
					{
						volume_type = volume_item.snapshotId ? 'snapshot_item' : 'volume_item';

						$('#instance_volume_list').append('<li><a href="javascript:void(0)" id="' + volume_id +'" class="' + volume_type + '"><span class="volume_name">' + volume_item.name + '</span><span class="volume_size">' + volume_item.size + 'GB</span></a></li>');

						$('#instance_volume_number').text(
							$canvas( target_id ).volume().length
						);

						$canvas( volume_item.id, 'AWS.EC2.EBS.Volume' ).select();
					}
				}
			}

			bubble_box.css('top',  target_offset.top - $('#canvas_container').offset().top - ((bubble_box.height() - target_offset.height) / 2));
		}
		else
		{
			// dispatch event when is not matched
			$canvas.trigger("CANVAS_PLACE_NOT_MATCH", {
				'type': 'AWS.EC2.EBS.Volume'
			});
		}

		event.data.shadow.remove();

		event.data.canvas_body.removeClass('node-dragging');

		$('#overlayer').remove();

		$(document).off({
			'mousemove': MC.canvas.volume.mousemove,
			'mouseup': MC.canvas.volume.mouseup
		});

		return false;
	}
};

MC.canvas.asgList = {
	show: function (event)
	{
		event.stopImmediatePropagation();

		if (event.which === 1)
		{
			MC.canvas.event.clearList();

			var target = this.parentNode,
				target_id = target.id,
				target_offset = Canvon(target).offset(),
				canvas_offset = $canvas.offset();

			$('#canvas_container').append(
				MC.template.asgList( $canvas( target_id ).list() )
			);

			$('#asgList-wrap')
				.data('target-id', target.id)
				.on('click', '.asgList-item', MC.canvas.asgList.select)
				.css({
					'top': target_offset.top - canvas_offset.top - 30,
					'left': target_offset.left - canvas_offset.left - 20
				});

			MC.canvas.asgList.select.call($('#asgList-wrap .asgList-item').first());

			return true;
		}
	},

	close: function ()
	{
		$('#asgList-wrap').remove();

		return false;
	},

	select: function (event)
	{
		var target = $(this);

		$('#asgList-wrap .selected').removeClass('selected');

		target.addClass('selected');
		$canvas( $('#asgList-wrap').data('target-id') ).select( target.data('id') );


		return false;
	}
};

MC.canvas.instanceList = {
	show: function (event)
	{
		event.stopImmediatePropagation();

		if (event.which === 1)
		{
			MC.canvas.event.clearList();

			var target = this.parentNode,
				target_id = target.id,
				target_offset = Canvon('#' + target_id).offset(),
			   	canvas_offset = $canvas.offset(),
			   	list = $canvas( target_id ).list();

			if (list.length === 0)
			{
				$canvas(target_id).select();

				return false;
			}

			$('#canvas_container').append(
				MC.template.instanceList( list )
			);

			$('#instanceList-wrap')
				.data('target-id', target.id)
				.on('click', '.instanceList-item', MC.canvas.instanceList.select)
				.css({
					'top': target_offset.top - canvas_offset.top - 30,
					'left': target_offset.left - canvas_offset.left - 20
				});

			MC.canvas.instanceList.select.call($('#instanceList-wrap .instanceList-item').first());
		}

		return false;
	},

	close: function ()
	{
		$('#instanceList-wrap').remove();

		return false;
	},

	select: function (event)
	{
		var target = $(this),
			bubble_box = $('#volume-bubble-box');

		if (
			bubble_box[0] &&
			bubble_box.data('target-id') !== this.id
		)
		{
			MC.canvas.volume.close();
		}

		$('#instanceList-wrap .selected').removeClass('selected');

		target.addClass('selected');

		$canvas( $('#instanceList-wrap').data('target-id') ).select( target.data('id') );

		//$canvas.trigger('CANVAS_INSTANCE_SELECTED', target.data('id'));

		return false;
	}
};

MC.canvas.eniList = {
	show: function (event)
	{
		event.stopImmediatePropagation();

		if (event.which === 1)
		{
			MC.canvas.event.clearList();

			var target = this.parentNode,
				target_id = target.id,
				target_offset = Canvon('#' + target_id).offset(),
				canvas_offset = $canvas.offset(),
				list = $canvas( target_id ).list();

			if (list.length === 0)
			{
				$canvas(target_id).select();

				return false;
			}

			$('#canvas_container').append( MC.template.eniList( list ) );

			$('#eniList-wrap')
				.data('target-id', target.id)
				.on('click', '.eniList-item', MC.canvas.eniList.select)
				.css({
					'top': target_offset.top - canvas_offset.top - 30,
					'left': target_offset.left - canvas_offset.left - 20
				});

			MC.canvas.eniList.select.call($('#eniList-wrap .eniList-item').first());

			return false;
		}
	},

	close: function ()
	{
		$('#eniList-wrap').remove();

		return false;
	},

	select: function (event)
	{
		var target = $(this);

		$('#eniList-wrap .selected').removeClass('selected');

		target.addClass('selected');

		$canvas( $('#eniList-wrap').data('target-id') ).select( target.data('id') );

		//$canvas.trigger('CANVAS_ENI_SELECTED', target.data('id'));

		return false;
	}
};

MC.canvas.nodeState = {
	show: function (id)
	{
		var canvas_status = MC.canvas.getState(),
			target_type = $canvas(id).type;

		if (
			(
				canvas_status === 'stack' ||
				canvas_status === 'app' ||
				canvas_status === 'appedit'
			)
			&&
			(
				target_type === 'AWS.EC2.Instance' ||
				target_type === 'AWS.AutoScaling.LaunchConfiguration'
			)
		)
		{
			var resModel = Design.instance().component(id);
			var stateAry = resModel.getStateData();
			var stateNum = 0;

			if (stateAry && _.isArray(stateAry)) {
				stateNum = stateAry.length;
			}

			if ((canvas_status === 'app') && !stateNum)
			{
				return;
			}

			$('#canvas_container').append(MC.template.nodeState({
				state_num: stateNum
			}));

			MC.canvas.nodeState.updateNumber(stateNum);

			MC.canvas.nodeState.position(id);
		}
	},

	updateNumber: function (num)
	{
		$('#node-state-number').text(num);

		return false;
	},

	position: function (id)
	{
		var target = $('#' + id),
			offset = target[0].getBoundingClientRect(),
			canvas_offset = $('#svg_canvas').offset();

		$('#node-state-wrap')
			.css({
				'left': offset.left - canvas_offset.left + offset.width + 5,
				'top': offset.top - canvas_offset.top
			})
			.attr('data-id', id);

		return true;
	},

	popup: function (event)
	{
		event.stopImmediatePropagation();

		if (event.which === 1)
		{
			$canvas.trigger("STATE_ICON_CLICKED", $(this).data('id'));
		}

		return false;
	},

	remove: function (id)
	{
		var node_state = $('#node-state-wrap');

		if (node_state.data('id') === id)
		{
			node_state.remove();
		}

		return true;
	}
};

MC.canvas.event = {};

// Double click event simulation
MC.canvas.event.dblclick = function (callback)
{
	if (MC.canvas.event.dblclick.timer)
	{
		// Double click event call
		callback.call(this, event);

		return true;
	}

	MC.canvas.event.dblclick.timer = setTimeout(function ()
	{
		MC.canvas.event.dblclick.timer = null;
	}, 500);

	return false;
};

MC.canvas.event.dblclick.timer = null;

MC.canvas.event.dragable = {
	mousedown: function (event)
	{
		if (
			event.which === 1 &&
			event.ctrlKey
		)
		{
			event.stopImmediatePropagation();

			MC.canvas.event.ctrlMove.mousedown.call( this, event );

			return false;
		}

		if (event.which === 1)
		{
			// Double click event
			if (MC.canvas.event.dblclick(function ()
			{
				$canvas.trigger('SHOW_PROPERTY_PANEL');
			}))
			{
				return false;
			}

			var target = $(this),
				target_item = $canvas(this.id),
				target_offset = target_item.offset(),
				target_type = target_item.type,
				node_type = target_item.nodeType,
				svg_canvas = $('#svg_canvas'),
				canvas_offset = $canvas.offset(),
				canvas_body = $('#canvas_body'),
				platform = $canvas.platform(),
				currentTarget = $(event.target),
				shadow,
				target_group_type,
				SVGtranslate;

			if (target_type === 'AWS.AutoScaling.LaunchConfiguration')
			{
				if (currentTarget.is('.instance-volume'))
				{
					MC.canvas.volume.show.call(event.target);
				}
				else
				{
					MC.canvas.event.clearSelected();

					$canvas(this.id).select();
					MC.canvas.nodeState.show(this.id);
				}

				return false;
			}

			if (currentTarget.is('.instance-volume'))
			{
				MC.canvas.volume.show.call(event.target);

				return false;
			}

			if (currentTarget.is('.eip-status') && MC.canvas.getState() !== 'appview')
			{
				MC.canvas.event.EIPstatus.call(event.target);

				return false;
			}

			if (target_type === 'AWS.VPC.Subnet')
			{
				target.find('.port').hide();
			}

			shadow = target.clone();

			svg_canvas.append(shadow);

			target_group_type = MC.canvas.MATCH_PLACEMENT[ platform ][ target_type ];

			if (target_group_type)
			{
				$.each(target_group_type, function (index, item)
				{
					if (item !== 'AWS.AutoScaling.Group' && item !== 'Canvas')
					{
						Canvon('.' + item.replace(/\./ig, '-')).addClass('dropable-group');
					}
				});
			}

			$(document.body).append('<div id="overlayer" class="grabbing"></div>');

			// Caching the SVGtranslate object at first for fastest value manipulating.
			if (shadow[0].transform.numberOfItems === 0)
			{
				SVGtranslate = shadow[0].transform.baseVal.appendItem(
					shadow[0].ownerSVGElement.createSVGTransform()
				);
			}
			else
			{
				SVGtranslate = shadow[0].transform.baseVal.getItem(0);
			}

			if (target_type === 'AWS.VPC.InternetGateway' || target_type === 'AWS.VPC.VPNGateway')
			{
				Canvon(shadow).addClass('shadow');

				$(document).on({
					'mousemove': MC.canvas.event.dragable.gatewaymove,
					'mouseup': MC.canvas.event.dragable.gatewayup
				}, {
					'target': target,
					'canvas_body': canvas_body,
					'target_type': target_type,
					'node_type': node_type,
					'vpc_data': $canvas($('.AWS-VPC-VPC').attr('id')),
					'shadow': shadow,
					'offsetX': event.pageX - target_offset.left + canvas_offset.left,
					'offsetY': event.pageY - target_offset.top + canvas_offset.top,
					'originalPageX': event.pageX,
					'originalPageY': event.pageY,
					'scale_ratio': $canvas.scale(),
					'SVGtranslate': SVGtranslate
				});
			}
			else
			{
				$(document).on({
					'mousemove': MC.canvas.event.dragable.mousemove,
					'mouseup': Canvon(event.target).hasClass('asg-resource-dragger') ?
						// For asgExpand
						MC.canvas.event.dragable.asgExpandup :
						// Default
						MC.canvas.event.dragable.mouseup
				}, {
					'target': target,
					'canvas_body': canvas_body,
					'target_type': target_type,
					'node_type': node_type,
					'shadow': shadow,
					'offsetX': event.pageX - target_offset.left + canvas_offset.left,
					'offsetY': event.pageY - target_offset.top + canvas_offset.top,
					'groupChild': node_type === 'group' ? MC.canvas.groupChild(this) : null,
					'originalPageX': event.pageX,
					'originalPageY': event.pageY,
					'originalTarget': event.target,
					'size': target_item.size(),
					'grid_width': MC.canvas.GRID_WIDTH,
					'grid_height': MC.canvas.GRID_HEIGHT,
					'scale_ratio': $canvas.scale(),
					'SVGtranslate': SVGtranslate
				});
			}

			MC.canvas.volume.close();
			MC.canvas.event.clearSelected();
		}

		return false;
	},
	mousemove: function (event)
	{
		var event_data = event.data,
			target_id = event_data.target[0].id,
			target_type = event_data.target_type,
			node_type = event_data.node_type,
			size = event_data.size,
			grid_width = event_data.grid_width,
			grid_height = event_data.grid_height,
			scale_ratio = event_data.scale_ratio,
			coordinate = {
				'x': Math.round((event.pageX - event_data.offsetX) / (grid_width / scale_ratio)),
				'y': Math.round((event.pageY - event_data.offsetY) / (grid_height / scale_ratio))
			},
			match_place = MC.canvas.isMatchPlace(
				target_id,
				target_type,
				node_type,
				coordinate.x,
				coordinate.y,
				size[0],
				size[1]
			);

		if (
			event.pageX !== event_data.originalPageX &&
			event.pageY !== event_data.originalPageY &&
			!Canvon(event_data.shadow).hasClass('shadow')
		)
		{
			Canvon(event_data.shadow).addClass('shadow');
			event_data.canvas_body.addClass('node-dragging');
		}

		Canvon('.match-dropable-group').removeClass('match-dropable-group');

		if (match_place.is_matched)
		{
			Canvon('#' + match_place.target).addClass('match-dropable-group');
		}

		// Cached SVGtranslate (fast)
		event_data.SVGtranslate.setTranslate(coordinate.x * grid_width, coordinate.y * grid_height);

		return false;
	},
	mouseup: function (event)
	{
		var event_data = event.data,
			target = event_data.target,
			target_id = target.attr('id'),
			target_item = $canvas(target_id),
			target_type = event_data.target_type,
			node_type = event_data.node_type;

		if (target_type === 'AWS.VPC.Subnet')
		{
			event_data.target.find('.port').show();
		}

		// Selected
		if (
			event.pageX === event_data.originalPageX &&
			event.pageY === event_data.originalPageY
		)
		{
			if (MC.canvas.getState() === 'app')
			{
				MC.canvas.instanceList.show.call( target[0], event);
			}
			else
			{
				$canvas(target_id).select();
				MC.canvas.volume.close();

				if (target_item.type === 'AWS.EC2.Instance')
				{
					MC.canvas.nodeState.show(target_id);
				}
			}
		}
		else
		{
			var svg_canvas = $("#svg_canvas"),
				canvas_offset = $canvas.offset(),
				shadow_offset = Canvon(event_data.shadow).offset(),
				layout_node_data = $canvas.node(),

				scale_ratio = $canvas.scale(),
				size,
				match_place,
				coordinate,
				clone_node,
				parentGroup;

			if (node_type === 'node')
			{
				size = event_data.size;

				coordinate = MC.canvas.pixelToGrid(
					shadow_offset.left - canvas_offset.left,
					shadow_offset.top - canvas_offset.top
				);

				match_place = MC.canvas.isMatchPlace(
					target_id,
					target_type,
					node_type,
					coordinate.x,
					coordinate.y,
					size[0],
					size[1]
				);

				parentGroup = MC.canvas.parentGroup(
					target_id,
					target_type,
					coordinate.x,
					coordinate.y,
					coordinate.x + size[0],
					coordinate.y + size[1]
				);

				if (
					coordinate.x > 0 &&
					coordinate.y > 0 &&
					match_place.is_matched // &&
				// 	// Disallow Instance to ASG
				// 	// !(
				// 	// 	parentGroup &&
				// 	// 	parentGroup.getAttribute('data-class') === 'AWS.AutoScaling.Group' &&
				// 	// 	target_type === 'AWS.EC2.Instance'
				// 	// )
				// 	// &&
				// 	// target_item.changeParent()
				// 	// &&
				// 	// (
				// 	// 	$canvas.trigger(BEFORE_DROP_EVENT, {'src_node': target_id, 'tgt_parent': parentGroup ? parentGroup.id : ''}) &&
				// 	// 	!BEFORE_DROP_EVENT.isDefaultPrevented()
				// 	// )
				)
				{
					target_item.changeParent((parentGroup ? parentGroup.id : 'canvas'), function ()
					{
						this.move(coordinate.x, coordinate.y);
						this.reConnect();
					});
				}
			}

			if (node_type === 'group')
			{
				var coordinate = MC.canvas.pixelToGrid(
						shadow_offset.left - canvas_offset.left,
						shadow_offset.top - canvas_offset.top
					),
					layout_group_data = $canvas.group(),
					group_data = layout_group_data[ target_id ],
					group_coordinate = target_item.position(),
					group_size = target_item.size(),
					group_type = target_item.type,
					group_padding = MC.canvas.GROUP_PADDING,
					child_stack = [],
					unique_stack = [],
					connection_stack = {},
					coordinate_fixed = false,
					match_place,
					areaChild,
					parentGroup,
					parent_data,
					parent_coordinate,
					parent_size,
					data,
					connection_target_id,
					fixed_areaChild,
					group_offsetX,
					group_offsetY,
					matched_child,
					child_data,
					//child_type,
					isBlank;

				if (group_type === 'AWS.VPC.VPC')
				{
					if (coordinate.y <= 3)
					{
						coordinate.y = 3;
					}

					if (coordinate.x <= 5)
					{
						coordinate.x = 5;
					}
				}
				else
				{
					if (coordinate.y <= 2)
					{
						coordinate.y = 2;
					}

					if (coordinate.x <= 2)
					{
						coordinate.x = 2;
					}
				}

				match_place = MC.canvas.isMatchPlace(
					target_id,
					target_type,
					node_type,
					// Make it larger for better place determination
					coordinate.x - 1,
					coordinate.y - 1,
					group_size[0] + 2,
					group_size[1] + 2
				);

				areaChild = MC.canvas.areaChild(
					target_id,
					target_type,
					coordinate.x,
					coordinate.y,
					coordinate.x + group_size[0],
					coordinate.y + group_size[1]
				);

				parentGroup = MC.canvas.parentGroup(
					target_id,
					group_type,
					coordinate.x,
					coordinate.y,
					coordinate.x + group_size[0],
					coordinate.y + group_size[1]
				);

				$.each(areaChild, function (index, item)
				{
					child_stack.push(item.id);
				});

				$.each(event_data.groupChild, function (index, item)
				{
					child_stack.push(item.id);
				});

				$.each(child_stack, function (index, item)
				{
					if ($.inArray(item, unique_stack) === -1)
					{
						unique_stack.push(item);
					}
				});

				if (parentGroup)
				{
					parent_item = $canvas(parentGroup.id);
					parent_data = layout_group_data[ parentGroup.id ];
					parent_coordinate = parent_item.position();
					parent_size = parent_item.size();

					if (parent_coordinate[0] + group_padding > coordinate.x)
					{
						coordinate.x = parent_coordinate[0] + group_padding;
						coordinate_fixed = true;
					}
					if (parent_coordinate[0] + parent_size[0] - group_padding < coordinate.x + group_size[0])
					{
						coordinate.x = parent_coordinate[0] + parent_size[0] - group_padding - group_size[0];
						coordinate_fixed = true;
					}
					if (parent_coordinate[1] + group_padding > coordinate.y)
					{
						coordinate.y = parent_coordinate[1] + group_padding;
						coordinate_fixed = true;
					}
					if (parent_coordinate[1] + parent_size[1] - group_padding < coordinate.y + group_size[1])
					{
						coordinate.y = parent_coordinate[1] + parent_size[1] - group_padding - group_size[1];
						coordinate_fixed = true;
					}

					if (coordinate_fixed)
					{
						fixed_areaChild = MC.canvas.areaChild(
							target_id,
							target_type,
							coordinate.x,
							coordinate.y,
							coordinate.x + group_size[0],
							coordinate.y + group_size[1]
						);
					}
				}

				group_offsetX = coordinate.x - group_coordinate[0];
				group_offsetY = coordinate.y - group_coordinate[1];

				isBlank =
					MC.canvas.isBlank(
						target_id,
						group_type,
						'group',
						coordinate.x,
						coordinate.y,
						group_size[0],
						group_size[1]
					) &&
					event_data.groupChild.length === unique_stack.length;

				if (
					(
						(
							coordinate_fixed &&
							match_place.is_matched &&
							event_data.groupChild.length === fixed_areaChild.length
						)
						||
						(
							!coordinate_fixed &&
							match_place.is_matched &&
							isBlank
						)
					)
				)
				{
					target_item.changeParent((parentGroup ? parentGroup.id : 'canvas'), function ()
					{
						this.move(coordinate.x, coordinate.y);
						this.reConnect();
					});
				}
				else if (!isBlank)
				{
					//dispatch event when is not blank
					$canvas.trigger("CANVAS_PLACE_OVERLAP");
				}
			}

			$canvas(target_id).select();
			MC.canvas.nodeState.show(target_id);
		}

		event_data.shadow.remove();
		event_data.canvas_body.removeClass('node-dragging');

		$('#overlayer').remove();

		Canvon('.dropable-group').removeClass('dropable-group');

		Canvon('.match-dropable-group').removeClass('match-dropable-group');

		$(document).off({
			'mousemove': MC.canvas.event.dragable.mousemove,
			'mouseup': MC.canvas.event.dragable.mouseup
		});
	},
	gatewaymove: function (event)
	{
		var event_data = event.data,
			gateway_top = Math.round((event.pageY - event_data.offsetY) / (MC.canvas.GRID_HEIGHT / event_data.scale_ratio)),
			vpc_coordinate = event_data.vpc_data.position(),
			vpc_size = event_data.vpc_data.size(),
			target_type = event_data.target_type;

		// MC.canvas.COMPONENT_SIZE for AWS.VPC.InternetGateway and AWS.VPC.VPNGateway = 8
		if (gateway_top > vpc_coordinate[1] + vpc_size[1] - 8)
		{
			gateway_top = vpc_coordinate[1] + vpc_size[1] - 8;
		}

		if (gateway_top < vpc_coordinate[1])
		{
			gateway_top = vpc_coordinate[1];
		}

		if (target_type === 'AWS.VPC.InternetGateway')
		{
			// Cached SVGtranslate (fast)
			event_data.SVGtranslate.setTranslate(
				(vpc_coordinate[0] - 4) * MC.canvas.GRID_WIDTH,
				gateway_top * MC.canvas.GRID_HEIGHT
			);
		}

		if (target_type === 'AWS.VPC.VPNGateway')
		{
			// Cached SVGtranslate (fast)
			event_data.SVGtranslate.setTranslate(
				(vpc_coordinate[0] + vpc_size[0] - 4) * MC.canvas.GRID_WIDTH,
				gateway_top * MC.canvas.GRID_HEIGHT
			);
		}

		return false;
	},
	gatewayup: function (event)
	{
		var target = event.data.target,
			target_id = target.attr('id'),
			target_item = $canvas(target_id),
			target_type = target_item.type,
			canvas_offset = $canvas.offset(),
			shadow_offset = Canvon(event.data.shadow).offset(),
			node_class = target.data('class'),
			scale_ratio = $canvas.scale(),
			coordinate = MC.canvas.pixelToGrid(shadow_offset.left - canvas_offset.left, shadow_offset.top - canvas_offset.top);

		target_item.position(null, coordinate.y);

		target_item.reConnect();

		target_item.select();

		Canvon('.dropable-group').removeClass('dropable-group');

		event.data.shadow.remove();

		event.data.canvas_body.removeClass('node-dragging');

		$('#overlayer').remove();

		$(document).off({
			'mousemove': MC.canvas.event.gatewaymove,
			'mouseup': MC.canvas.event.gatewayup
		});
	},
	asgExpandup: function (event)
	{
		var event_data = event.data,
			target = event.data.target,
			target_id = target.attr('id'),
			target_type = event.data.target_type,
			node_type = event_data.nodeType,
			asg_item = $canvas(target_id),
			svg_canvas = $('#svg_canvas'),
			canvas_offset = $canvas.offset(),
			shadow_offset = Canvon(event.data.shadow).offset(),
			scale_ratio = $canvas.scale(),
			coordinate = MC.canvas.pixelToGrid(shadow_offset.left - canvas_offset.left, shadow_offset.top - canvas_offset.top),
			size = event_data.size,
			areaChild = MC.canvas.areaChild(
				target_id,
				target_type,
				coordinate.x,
				coordinate.y,
				coordinate.x + size[0],
				coordinate.y + size[1]
			),
			match_place = MC.canvas.isMatchPlace(
				null,
				target_type,
				node_type,
				coordinate.x,
				coordinate.y,
				size[0],
				size[1]
			),
			parentGroup = MC.canvas.parentGroup(
				target_id,
				target_type,
				coordinate.x,
				coordinate.y,
				coordinate.x + size[0],
				coordinate.y + size[1]
			);

		if (
			areaChild.length === 0 &&
			match_place.is_matched
		)
		{
			asg_item.asgExpand(match_place.target, coordinate.x, coordinate.y);

			asg_item.select();
		}

		Canvon('.dropable-group').removeClass('dropable-group');

		event.data.shadow.remove();

		event.data.canvas_body.removeClass('node-dragging');

		$('#overlayer').remove();

		$(document).off({
			'mousemove': MC.canvas.event.dragable.mousemove,
			'mouseup': MC.canvas.event.dragable.asgExpandup
		});
	}
};

MC.canvas.event.drawConnection = {
	mousedown: function (event)
	{
		if (event.which === 1)
		{
			var svg_canvas = $('#svg_canvas'),
				canvas_offset = svg_canvas.offset(),
				target = $(this),
				target_offset = Canvon(this).offset(),

				parent = target.parent(),
				node_id = parent.attr('id'),
				parent_item = $canvas(node_id),
				parent_type = parent_item.type,

				position = target.data('position'),
				port_type = target.data('type'),
				port_name = target.data('name'),
				connection_option = MC.canvas.CONNECTION_OPTION[ parent_type ],
				scale_ratio = $canvas.scale(),
				offset = {},
				port_position_offset = 8 / scale_ratio,
				node_connection = parent_item.connection(),
				target_connection_option,
				target_item,
				target_data,
				target_node,
				target_port,
				is_connected,
				line_data;

			//calculate point of junction
			switch (position)
			{
				case 'left':
					offset.left = target_offset.left;
					offset.top  = target_offset.top + port_position_offset;
					break;

				case 'right':
					offset.left = target_offset.left + port_position_offset;
					offset.top  = target_offset.top + port_position_offset;
					break;

				case 'top':
					offset.left = target_offset.left + port_position_offset;
					offset.top  = target_offset.top;
					break;

				case 'bottom':
					offset.left = target_offset.left + port_position_offset;
					offset.top  = target_offset.top + port_position_offset;
					break;
			}

			$(document.body).append('<div id="overlayer"></div>');

			svg_canvas.append(Canvon.group().attr({
				'class': 'draw-line-wrap line-' + port_type,
				'id': 'draw-line-connection'
			}));

			$(document).on({
				'mousemove': MC.canvas.event.drawConnection.mousemove,
				'mouseup': MC.canvas.event.drawConnection.mouseup
			}, {
				'connect': target.data('connect'),
				'originalTarget': target.parent(),
				'originalX': (offset.left - canvas_offset.left) * scale_ratio,
				'originalY': (offset.top - canvas_offset.top) * scale_ratio,
				'option': connection_option,
				'draw_line': $('#draw-line-connection'),
				'port_name': port_name,
				'canvas_offset': canvas_offset,
				'scale_ratio': scale_ratio
			});

			MC.canvas.event.clearSelected();

			// Keep hover style on
			$.each(node_connection, function (index, item)
			{
				Canvon('#' + item.line).addClass('view-keephover');
			});

			// Highlight connectable port
			$.each(connection_option, function (type, option)
			{
				if ($.type(option) !== 'array')
				{
					option = [option];
				}

				$.each(option, function (index, value)
				{
					if (value.from === port_name)
					{
						$('.' + type.replace(/\./ig, '-') + ':not(#' + node_id + ')').each(function (index, item)
						{
							if (parent_item.isConnectable(value.from, item.id, value.to))
							{
								target_node = this;

								$(target_node).find('.port-' + value.to).each(function ()
								{
									target_port = $(this);

									if (target_port.css('display') !== 'none')
									{
										Canvon(target_node).addClass('connectable');

										Canvon(target_port).addClass("connectable-port view-show");
									}
								});
							}
						});
					}
				});
			});
		}

		return false;
	},

	mousemove: function (event)
	{
		var event_data = event.data,
			canvas_offset = event_data.canvas_offset,
			scale_ratio = event_data.scale_ratio,
			endX = (event.pageX - canvas_offset.left) * scale_ratio,
			endY = (event.pageY - canvas_offset.top) * scale_ratio,
			startX = event_data.originalX,
			startY = event_data.originalY,
			angle = Math.atan2(endY - startY, endX - startX),
			arrow_length = 8,

			arrowPI = 3.141592653589793 / 6,
			arrowAngleA = angle - arrowPI,
			arrowAngleB = angle + arrowPI;

		event_data.draw_line.empty().append(
			Canvon.line(startX, startY, endX, endY).attr('class', 'draw-line'),

			Canvon.polygon([
				[endX, endY],
				[endX - arrow_length * Math.cos(arrowAngleA), endY - arrow_length * Math.sin(arrowAngleA)],
				[endX - arrow_length * Math.cos(arrowAngleB), endY - arrow_length * Math.sin(arrowAngleB)]
			]).attr('class', 'draw-line-arrow')
		);

		return false;
	},

	mouseup: function (event)
	{
		event.data.draw_line.remove();

		var match_node = MC.canvas.matchPoint(
				Math.round(event.pageX - event.data.canvas_offset.left),
				Math.round(event.pageY - event.data.canvas_offset.top)
			),
			//svg_canvas = $('#svg_canvas'),
			from_node = event.data.originalTarget,
			port_name = event.data.port_name,
			from_type = from_node.data('class'),

			to_node,
			port_name,
			to_port_name,
			line_id,
			coordinate,
			group_coordinate,
			group_size;

		if (
			(
				from_type === 'AWS.VPC.RouteTable' || from_type === 'AWS.ELB'
			)
			&&
			!match_node
		)
		{
			coordinate = MC.canvas.pixelToGrid(event.pageX - event.data.canvas_offset.left, event.pageY - event.data.canvas_offset.top);

			match_node = null;

			$.each($canvas.group(), function (key, item)
			{
				group_coordinate = item.position();
				group_size = item.size();

				if (
					item.type === 'AWS.VPC.Subnet' &&
					group_coordinate &&

					// Specially extend subnet area
					group_coordinate[0] - 2 < coordinate.x &&
					group_coordinate[0] + group_size[0] + 2 > coordinate.x &&
					group_coordinate[1] < coordinate.y &&
					group_coordinate[1] + group_size[1] > coordinate.y
				)
				{
					match_node = document.getElementById( item.id );

					return false;
				}
			});
		}

		if (match_node)
		{
			to_node = $(match_node);

			if (
				$.inArray(from_node.data('class'), ['AWS.EC2.Instance', 'AWS.AutoScaling.LaunchConfiguration']) > -1 &&
				to_node.data('class') === 'AWS.ELB'
			)
			{
				match_node_offset = match_node.getBoundingClientRect();

				if (event.pageX > (match_node_offset.left + match_node_offset.width / 2))
				{
					to_port_name = 'elb-sg-out';
				}
				if (event.pageX < (match_node_offset.left + match_node_offset.width / 2))
				{
					to_port_name = 'elb-sg-in';
				}
			}
			else
			{
				to_port_name = to_node.find('.connectable-port').data('name');
			}

			if (!from_node.is(to_node) && to_port_name !== undefined)
			{
				$canvas.connect(from_node.attr('id'), port_name, to_node.attr('id'), to_port_name);
			}
		}

		Canvon('#svg_canvas .connectable').removeClass('connectable');

		Canvon('#svg_canvas .view-keephover').removeClass('view-keephover');

		Canvon('#svg_canvas .view-show').removeClass('view-show');

		Canvon('#svg_canvas .connectable-port').removeClass('connectable-port');

		$('#overlayer').remove();

		$(document).off({
			'mousemove': MC.canvas.event.drawConnection.mousemove,
			'mouseup': MC.canvas.event.drawConnection.mouseup,
		});

		return false;
	}
};

MC.canvas.event.siderbarDrag = {
	mousedown: function (event)
	{
		if (event.which === 1)
		{
			var target = $(this),
				target_offset = target.offset(),
				svg_canvas = $('#svg_canvas'),
				canvas_offset = $canvas.offset(),
				target_type = target.data('type'),
				node_type = target.data('component-type'),
				platform = $canvas.platform(),
				shadow,
				clone_node,
				default_width,
				default_height,
				target_group_type,
				size;

			if (target.data('enable') === false)
			{
				return false;
			}

			$(document.body).append('<div id="drag_shadow"></div><div id="overlayer" class="grabbing"></div>');
			shadow = $('#drag_shadow');

			if (node_type === 'group')
			{
				size = MC.canvas.GROUP_DEFAULT_SIZE[ target_type ];

				shadow.addClass(target_type.replace(/\./ig, '-'));
			}
			else
			{
				clone_node = target.find('.resource-icon').clone();
				shadow.append(clone_node);
				size = MC.canvas.COMPONENT_SIZE[ target_type ];
			}

			shadow
				.css({
					'top': event.pageY - 50,
					'left': event.pageX - 50,
					'width': size[0] * MC.canvas.GRID_WIDTH,
					'height': size[1] * MC.canvas.GRID_HEIGHT
				})
				.show();

			if (target_type === 'AWS.EC2.EBS.Volume')
			{
				if (MC.canvas.getState() === 'appedit')
				{
					Canvon('.AWS-EC2-Instance').addClass('attachable');
				}
				else
				{
					Canvon('.AWS-EC2-Instance, .AWS-AutoScaling-LaunchConfiguration').addClass('attachable');
				}

				shadow.addClass('AWS-EC2-EBS-Volume');

				$(document).on({
					'mousemove': MC.canvas.volume.mousemove,
					'mouseup': MC.canvas.volume.mouseup
				}, {
					'target': target,
					'canvas_offset': canvas_offset,
					'canvas_body': $('#canvas_body'),
					'shadow': shadow
				});
			}
			else
			{
				target_group_type = MC.canvas.MATCH_PLACEMENT[ platform ][ target_type ];

				if (target_group_type)
				{
					Canvon('.' + target_group_type.join(',').replace(/\./ig, '-').replace(/,/ig, ',.')).addClass('dropable-group');
				}

				$(document).on({
					'mousemove': MC.canvas.event.siderbarDrag.mousemove,
					'mouseup': MC.canvas.event.siderbarDrag.mouseup
				}, {
					'target': target,
					'node_type': node_type,
					'canvas_offset': canvas_offset,
					'target_type': target_type,
					'shadow': shadow,
					'scale_ratio': $canvas.scale(),
					'component_size': node_type === 'node' ? MC.canvas.COMPONENT_SIZE[ target_type ] : MC.canvas.GROUP_DEFAULT_SIZE[ target_type ]
				});
			}

			$('#canvas_body').addClass('node-dragging');
		}

		MC.canvas.volume.close();
		MC.canvas.event.clearSelected();

		return false;
	},

	mousemove: function (event)
	{
		var event_data = event.data,
			shadow = event_data.shadow[0],
			canvas_offset = event_data.canvas_offset,
			target_id = event_data.target[0].id,
			node_type = event_data.node_type,
			target_type = event_data.target_type,
			component_size = event_data.component_size,

			// MC.canvas.GRID_WIDTH
			grid_width = 10,

			// MC.canvas.GRID_HEIGHT
			grid_height = 10,

			scale_ratio = event_data.scale_ratio,
			coordinate = {
				'x': Math.round((event.pageX - canvas_offset.left - 50) / (grid_width / scale_ratio)),
				'y': Math.round((event.pageY - canvas_offset.top - 50) / (grid_height / scale_ratio))
			},
			match_place = MC.canvas.isMatchPlace(
				null,
				target_type,
				node_type,
				coordinate.x,
				coordinate.y,
				component_size[0],
				component_size[1]
			);

		Canvon('.match-dropable-group').removeClass('match-dropable-group');

		if (match_place.is_matched)
		{
			Canvon('#' + match_place.target).addClass('match-dropable-group');
		}

		shadow.style.top = (event.pageY - 50) + 'px';
		shadow.style.left = (event.pageX - 50) + 'px';

		return false;
	},

	mouseup: function (event)
	{
		if (!$('#canvas_body').hasClass('canvas_zoomed'))
		{
			var target = $(event.data.target),
				target_id = target.attr('id') || '',
				node_type = target.data('component-type'),
				target_type = target.data('type'),
				canvas_offset = $canvas.offset(),
				shadow_offset = event.data.shadow.position(),
				node_option = target.data('option') || {},
				coordinate = MC.canvas.pixelToGrid(shadow_offset.left - canvas_offset.left, shadow_offset.top - canvas_offset.top),
				component_size,
				match_place,
				default_group_size,
				new_node,
				vpc_id,
				vpc_item,
				vpc_coordinate,
				areaChild,
				new_node_id;

			if (coordinate.x > 0 && coordinate.y > 0)
			{
				if (node_type === 'node')
				{
					component_size = MC.canvas.COMPONENT_SIZE[ target_type ];

					if (target_type === 'AWS.VPC.InternetGateway' || target_type === 'AWS.VPC.VPNGateway')
					{
						vpc_id = $('.AWS-VPC-VPC').attr('id');
						vpc_item = $canvas( vpc_id );
						vpc_coordinate = vpc_item.position();
						vpc_size = vpc_item.size();

						node_option.groupUId = vpc_id;

						if (coordinate.y > vpc_coordinate[1] + vpc_size[1] - component_size[1])
						{
							coordinate.y = vpc_coordinate[1] + vpc_size[1] - component_size[1];
						}
						if (coordinate.y < vpc_coordinate[1])
						{
							coordinate.y = vpc_coordinate[1];
						}

						if (target_type === 'AWS.VPC.InternetGateway')
						{
							coordinate.x = vpc_coordinate[0] - (component_size[1] / 2);
						}
						if (target_type === 'AWS.VPC.VPNGateway')
						{
							coordinate.x = vpc_coordinate[0] + vpc_size[0] - (component_size[1] / 2);
						}

						$canvas.add(target_type, node_option, coordinate);
					}
					else
					{
						match_place = MC.canvas.isMatchPlace(
							null,
							target_type,
							node_type,
							coordinate.x,
							coordinate.y,
							component_size[0],
							component_size[1]
						);

						if (match_place.is_matched)
						{
							node_option.groupUId = match_place.target;

							new_node_id = $canvas.add(target_type, node_option, coordinate);

							if (new_node_id)
							{
								MC.canvas.select(new_node_id);

								if (target_type === 'AWS.EC2.Instance')
								{
									MC.canvas.nodeState.show(new_node_id);
								}
							}
						}
						else
						{
							// dispatch event when is not matched
							$canvas.trigger("CANVAS_PLACE_NOT_MATCH", {
								'type': target_type
							});
						}
					}
				}

				if (node_type === 'group')
				{
					default_group_size = MC.canvas.GROUP_DEFAULT_SIZE[ target_type ];

					// Move a little bit offset for Subnet because its port
					if (target_type === 'AWS.VPC.Subnet')
					{
						//coordinate.x -= 1;
					}

					match_place = MC.canvas.isMatchPlace(
						null,
						target_type,
						node_type,
						coordinate.x,
						coordinate.y,
						default_group_size[0],
						default_group_size[1]
					),
					areaChild = MC.canvas.areaChild(
						null,
						target_type,
						coordinate.x,
						coordinate.y,
						coordinate.x + default_group_size[0],
						coordinate.y + default_group_size[1]
					);

					if (
						match_place.is_matched
					)
					{
						if (
							MC.canvas.isBlank(
								target_id,
								target_type,
								'group',
								// Enlarge a little bit to make the drop place correctly.
								coordinate.x - 1,
								coordinate.y - 1,
								default_group_size[0] + 2,
								default_group_size[1] + 2
							) && areaChild.length === 0
						)
						{
							node_option.groupUId = match_place.target;

							new_node_id = $canvas.add(target_type, node_option, coordinate);

							if (!(MC.aws.vpc.getVPCUID() && target_type === "AWS.EC2.AvailabilityZone"))
							{
								//has no vpc
								MC.canvas.select(new_node_id);
							}
						}
						else
						{
							// dispatch event when is not blank
							$canvas.trigger("CANVAS_PLACE_OVERLAP");
						}
					}
					else
					{
						// dispatch event when is not matched
						$canvas.trigger("CANVAS_PLACE_NOT_MATCH", {
							type: target_type
						});
					}
				}
			}

			if (target_type === 'AWS.VPC.InternetGateway' || target_type === 'AWS.VPC.VPNGateway')
			{
				event.data.shadow.animate({
					'left': coordinate.x * MC.canvas.GRID_WIDTH + canvas_offset.left,
					'top': coordinate.y * MC.canvas.GRID_HEIGHT + canvas_offset.top,
					'opacity': 0
				}, function ()
				{
					event.data.shadow.remove();
				});
			}
			else
			{
				event.data.shadow.remove();
			}
		}
		else
		{
			$canvas.trigger("CANVAS_ZOOMED_DROP_ERROR");

			event.data.shadow.remove();
		}

		Canvon('.dropable-group').removeClass('dropable-group');

		Canvon('.match-dropable-group').removeClass('match-dropable-group');

		$('#overlayer').remove();

		$('#canvas_body').removeClass('node-dragging');

		$(document).off({
			'mousemove': MC.canvas.event.mousemove,
			'mouseup': MC.canvas.event.mouseup
		});
	}
};

MC.canvas.event.groupResize = {
	mousedown: function (event)
	{
		if (event.which === 1)
		{
			var target = event.target,
				parent = $(target.parentNode.parentNode),
				parent_item = $canvas(parent.attr('id')),
				group = parent.find('.group'),
				group_offset = group[0].getBoundingClientRect(),
				canvas_offset = $canvas.offset(),
				scale_ratio = $canvas.scale(),
				grid_width = MC.canvas.GRID_WIDTH,
				grid_height = MC.canvas.GRID_HEIGHT,
				group_left = (group_offset.left - canvas_offset.left) * scale_ratio,
				group_top = (group_offset.top - canvas_offset.top) * scale_ratio,
				type = parent_item.type,
				line_layer = document.getElementById('line_layer');

			if (type === 'AWS.VPC.Subnet')
			{
				// Re-draw group connection
				$.each(parent_item.connection(), function (i, value)
				{
					line_layer.removeChild(document.getElementById( value.line ));
				});
			}

			// Hide label
			parent.find('.group-label, .port').hide();

			$(document.body).append('<div id="overlayer" style="cursor: ' + $(event.target).css('cursor') + '"></div>');

			$(document)
				.on({
					'mousemove': MC.canvas.event.groupResize.mousemove,
					'mouseup': MC.canvas.event.groupResize.mouseup
				}, {
					'parent': parent,
					'resizer': target,
					//'group_title': parent.find('.group-label'),
					'target': group,
					'originalTarget': group[0],
					'group_child': MC.canvas.groupChild(target.parentNode.parentNode),
					'originalX': event.pageX,
					'originalY': event.pageY,
					'originalWidth': group_offset.width,
					'originalHeight': group_offset.height,
					'originalTop': group_offset.top,
					'originalLeft': group_offset.left,
					'originalTranslate': parent.attr('transform'),
					'canvas_offset': canvas_offset,
					'offsetX': event.pageX - canvas_offset.left,
					'offsetY': event.pageY - canvas_offset.top,
					'direction': $(target).data('direction'),
					'group_type': type,
					'scale_ratio': scale_ratio,
					'group_min_padding': MC.canvas.GROUP_MIN_PADDING,
					'parentGroup': MC.canvas.parentGroup(
						parent.attr('id'),
						type,
						Math.ceil(group_left / grid_width),
						Math.ceil(group_top / grid_height),
						Math.ceil((group_offset.left + group_offset.width) / grid_width),
						Math.ceil((group_offset.top + group_offset.height) / grid_height)
					),
					'group_port': type === 'AWS.VPC.Subnet' ? [
						parent.find('.port-subnet-assoc-in').first(),
						parent.find('.port-subnet-assoc-out').first()
					] : null
				});
		}

		return false;
	},
	mousemove: function (event)
	{
		var event_data = event.data,
			target = event_data.originalTarget,
			direction = event_data.direction,
			//type = event_data.group_type,
			scale_ratio = event_data.scale_ratio,
			group_min_padding = event_data.group_min_padding,
			left = Math.ceil((event.pageX - event_data.originalLeft) / 10) * 10 * scale_ratio,
			max_left = event_data.originalWidth * scale_ratio - group_min_padding,
			top = Math.ceil((event.pageY - event_data.originalTop) / 10) * 10 * scale_ratio,
			max_top = event_data.originalHeight * scale_ratio - group_min_padding,
			prop,
			key;

		switch (direction)
		{
			case 'topleft':
				prop = {
					'y': top > max_top ? max_top : top,
					'x': left > max_left ? max_left : left,
					'width': event_data.originalWidth * scale_ratio - left,
					'height': event_data.originalHeight * scale_ratio - top
				};
				break;

			case 'topright':
				prop = {
					'y': top > max_top ? max_top : top,
					'width': Math.round((event_data.originalWidth + event.pageX - event_data.originalX) / 10) * 10 * scale_ratio,
					'height': event_data.originalHeight * scale_ratio - top
				};
				break;

			case 'bottomleft':
				prop = {
					'x': left > max_left ? max_left : left,
					'width': event_data.originalWidth * scale_ratio - left,
					'height': Math.round((event_data.originalHeight + event.pageY - event_data.originalY) / 10) * 10 * scale_ratio
				};
				break;

			case 'bottomright':
				prop = {
					'width': Math.round((event_data.originalWidth + event.pageX - event_data.originalX) / 10) * 10 * scale_ratio,
					'height': Math.round((event_data.originalHeight + event.pageY - event_data.originalY) / 10) * 10 * scale_ratio
				};
				break;

			case 'top':
				prop = {
					'y': top > max_top ? max_top : top,
					'height': event_data.originalHeight * scale_ratio - top
				};
				break;

			case 'right':
				prop = {
					'width': Math.round((event_data.originalWidth + event.pageX - event_data.originalX) / 10) * 10 * scale_ratio
				};
				break;

			case 'bottom':
				prop = {
					'height': Math.round((event_data.originalHeight + event.pageY - event_data.originalY) / 10) * 10 * scale_ratio
				};
				break;

			case 'left':
				prop = {
					'x': left > max_left ? max_left : left,
					'width': event_data.originalWidth * scale_ratio - left
				};
				break;
		}

		if (prop.width !== undefined && prop.width < group_min_padding)
		{
			prop.width = group_min_padding;
		}

		if (prop.height !== undefined && prop.height < group_min_padding)
		{
			prop.height = group_min_padding;
		}

		// Using baseVal for best performance
		for (key in prop)
		{
			target[ key ].baseVal.value = prop[ key ];
		}

		return false;
	},
	mouseup: function (event)
	{
		var event_data = event.data,
			parent = event_data.parent,
			target = event_data.target,
			originalTarget = target[0],
			type = event_data.group_type,
			//group_title = event_data.group_title,
			direction = event_data.direction,
			parent_offset = parent[0].getBoundingClientRect(),
			canvas_offset = event_data.canvas_offset,
			scale_ratio = $canvas.scale(),
			grid_width = MC.canvas.GRID_WIDTH,
			grid_height = MC.canvas.GRID_HEIGHT,
			offsetX = originalTarget.x.baseVal.value,// target.attr('x') * 1,
			offsetY = originalTarget.y.baseVal.value,//target.attr('y') * 1,
			group_id = parent.attr('id'),

			group_width = Math.round(originalTarget.width.baseVal.value / grid_width),
			group_height = Math.round(originalTarget.height.baseVal.value / grid_height),
			group_left = Math.round(((parent_offset.left - canvas_offset.left) * scale_ratio + offsetX) / grid_width),
			group_top = Math.round(((parent_offset.top - canvas_offset.top) * scale_ratio + offsetY) / grid_height),

			canvas_size = $canvas.size(),
			node_minX = [],
			node_minY = [],
			node_maxX = [],
			node_maxY = [],

			group_padding = MC.canvas.GROUP_PADDING,
			parentGroup = event_data.parentGroup,
			//label_coordinate = MC.canvas.GROUP_LABEL_COORDINATE[ type ],
			group_node,
			group_coordinate,
			layout_connection_data,
			parent_data,
			parent_size,
			parent_coordinate,
			item_data,
			item_coordinate,
			item_size,
			group_maxX,
			group_maxY,
			group_minX,
			group_minY,

			igw_gateway,
			igw_gateway_id,
			igw_gateway_data,
			igw_top,

			vgw_gateway,
			vgw_gateway_id,
			vgw_gateway_data,
			vgw_top,

			port_top,
			line_connection;

		// adjust group_left
		if (offsetX < 0)
		{
			// when resize by left,topleft, bottomleft
			group_left = Math.round((parent_offset.left - canvas_offset.left) * scale_ratio / grid_width);
		}

		// adjust group_top
		if (
			direction === 'top' ||
			direction === 'topleft' ||
			direction === 'topright'
		)
		{
			if (offsetY < 0)
			{
				group_top = Math.round((parent_offset.top - canvas_offset.top) * scale_ratio / grid_height);
			}
			else if (offsetY > 0)
			{
				group_top = Math.round(((parent_offset.top - canvas_offset.top)  * scale_ratio + offsetY) / grid_width);
			}
		}

		$.each(event_data.group_child, function (index, item)
		{
			item = $canvas( item.id );

			item_size = item.size();
			item_coordinate = item.position();

			node_minX.push(item_coordinate[0]);
			node_minY.push(item_coordinate[1]);
			node_maxX.push(item_coordinate[0] + item_size[0]);
			node_maxY.push(item_coordinate[1] + item_size[1]);
		});

		group_maxX = Math.max.apply(Math, node_maxX) + group_padding;
		group_maxY = Math.max.apply(Math, node_maxY) + group_padding;
		group_minX = Math.min.apply(Math, node_minX) - group_padding;
		group_minY = Math.min.apply(Math, node_minY) - group_padding;

		switch (direction)
		{
			case 'topleft':
				if (group_left >= group_minX)
				{
					group_width += (group_left - group_minX);
					group_left = group_minX;
				}

				if (group_top >= group_minY)
				{
					group_height += (group_top - group_minY);
					group_top = group_minY;
				}
				break;

			case 'topright':
				group_width = group_width + group_left >= group_maxX ? group_width : group_maxX - group_left;

				if (group_top >= group_minY)
				{
					group_height += (group_top - group_minY);
					group_top = group_minY;
				}
				break;

			case 'bottomleft':
				if (group_left >= group_minX)
				{
					group_width += (group_left - group_minX);
					group_left = group_minX;
				}

				group_height = group_height + group_top >= group_maxY ? group_height : group_maxY - group_top;
				break;

			case 'bottomright':
				group_width = group_width + group_left >= group_maxX ? group_width : group_maxX - group_left;
				group_height = group_height + group_top >= group_maxY ? group_height : group_maxY - group_top;
				break;

			case 'top':
				if (group_top >= group_minY)
				{
					group_height += (group_top - group_minY);
					group_top = group_minY;
				}
				break;

			case 'right':
				group_width = group_width + group_left >= group_maxX ? group_width : group_maxX - group_left;
				break;

			case 'bottom':
				group_height = group_height + group_top >= group_maxY ? group_height : group_maxY - group_top;
				break;

			case 'left':
				if (group_left >= group_minX)
				{
					group_width += (group_left - group_minX);
					group_left = group_minX;
				}
				break;
		}

		if (parentGroup)
		{
			parent_data = $canvas( parentGroup.id );
			parent_size = parent_data.size();
			parent_coordinate = parent_data.position();

			if (group_left < parent_coordinate[0] + group_padding)
			{
				group_width = group_left + group_width - parent_coordinate[0] - group_padding;
				group_left = parent_coordinate[0] + group_padding;
			}

			if (group_top < parent_coordinate[1] + group_padding)
			{
				group_height = group_top + group_height - parent_coordinate[1] - group_padding;
				group_top = parent_coordinate[1] + group_padding;
			}

			if (group_width + group_left > parent_coordinate[0] + parent_size[0] - group_padding)
			{
				group_width = parent_coordinate[0] + parent_size[0] - group_padding - group_left;
			}

			if (group_height + group_top > parent_coordinate[1] + parent_size[1] - group_padding)
			{
				group_height = parent_coordinate[1] + parent_size[1] - group_padding - group_top;
			}
		}

		// Top coordinate fix
		if (type === 'AWS.VPC.VPC')
		{
			if (group_top <= 3)
			{
				group_height = group_height + group_top - 3;
				group_top = 3;
			}

			if (group_left <= 5)
			{
				group_width = group_width + group_left - 5;
				group_left = 5;
			}
		}
		else
		{
			if (group_top <= 2)
			{
				group_height = group_height + group_top - 2;
				group_top = 2;
			}

			if (group_left <= 2)
			{
				group_width = group_width + group_left - 2;
				group_left = 2;
			}
		}

		if (
			group_width > group_padding &&
			group_height > group_padding &&

			event_data.group_child.length === MC.canvas.areaChild(
				group_id,
				type,
				group_left,
				group_top,
				group_left + group_width,
				group_top + group_height
			).length &&

			// canvas right offset = 3
			group_left + group_width < canvas_size[0] - 3 &&
			group_top + group_height < canvas_size[1] - 3
		)
		{
			if (type === 'AWS.VPC.VPC')
			{
				igw_gateway = $('.AWS-VPC-InternetGateway');
				vgw_gateway = $('.AWS-VPC-VPNGateway');

				if (igw_gateway[0])
				{
					igw_item = $canvas(igw_gateway[0].id);

					igw_top = igw_item.position()[1];

					if (igw_top > group_top + group_height - 8)
					{
						igw_top = group_top + group_height - 8;
					}

					if (igw_top < group_top)
					{
						igw_top = group_top;
					}

					// MC.canvas.COMPONENT_SIZE[0] / 2 = 4
					igw_item.position(group_left - 4, igw_top);

					igw_item.reConnect();
				}

				if (vgw_gateway[0])
				{
					vgw_item = $canvas(vgw_gateway[0].id);

					vgw_top = vgw_item.position()[1];

					if (vgw_top > group_top + group_height - 8)
					{
						vgw_top = group_top + group_height - 8;
					}

					if (vgw_top < group_top)
					{
						vgw_top = group_top;
					}

					// MC.canvas.COMPONENT_SIZE[0] / 2 = 4
					vgw_item.position(group_left + group_width - 4, vgw_top);

					vgw_item.reConnect();
				}
			}

			// parent.attr('transform',
			// 	'translate(' +
			// 		group_left * 10 + ',' +
			// 		group_top * 10 +
			// 	')'
			// );

			// target.attr({
			// 	'x': 0,
			// 	'y': 0,
			// 	'width': group_width * 10,
			// 	'height': group_height * 10
			// });

			// group_title.attr({
			// 	'x': label_coordinate[0],
			// 	'y': label_coordinate[1]
			// });

			group_node = $canvas( group_id );

			group_node.position(group_left, group_top);
			group_node.size(group_width, group_height);

			MC.canvas.updateResizer(parent, group_width, group_height);
		}
		else
		{
			group_width = Math.round(event_data.originalWidth * scale_ratio / 10);
			group_height = Math.round(event_data.originalHeight * scale_ratio / 10);

			group_node = $canvas( group_id );
			group_coordinate = group_node.position();

			// if (type === 'AWS.VPC.Subnet')
			// {
			// 	event_data.group_port[0].show();
			// 	event_data.group_port[1].show();
			// }

			group_node.position(group_coordinate[0], group_coordinate[1]);
			group_node.size(group_width, group_height);

			//parent.attr('transform', event_data.originalTranslate);

			// target.attr({
			// 	'x': 0,
			// 	'y': 0,
			// 	'width': event_data.originalWidth * scale_ratio,
			// 	'height': event_data.originalHeight * scale_ratio
			// });

			//group_node.reConnect();

			MC.canvas.updateResizer(parent, group_width, group_height);
		}

		parent.find('.group-label, .port').show();

		if (type === 'AWS.VPC.Subnet')
		{
			port_top = (group_height * MC.canvas.GRID_HEIGHT / 2) - 5;

			event_data.group_port[0].attr('transform', 'translate(-12, ' + port_top + ')');

			event_data.group_port[1].attr('transform', 'translate(' + (group_width * MC.canvas.GRID_WIDTH + 10) + ', ' + port_top + ')');

			//group_node.reConnect();
		}

		group_node.reConnect();

		$('#overlayer').remove();

		$(document)
			.off({
				'mousemove': MC.canvas.event.groupResize.mousemove,
				'mouseup': MC.canvas.event.groupResize.mouseup
			});
	}
};

MC.canvas.event.ctrlMove = {
	mousedown: function (event)
	{
		if (
			event.which === 1 &&
			event.ctrlKey
		)
		{
			event.stopImmediatePropagation();

			var canvas_offset = $canvas.offset(),
				canvas = $('#canvas'),
				scroll_content = canvas.find('.scroll-content').first()[0];

			$(document).on({
				'mousemove': MC.canvas.event.ctrlMove.mousemove,
				'mouseup': MC.canvas.event.ctrlMove.mouseup
			}, {
				'canvas': canvas,
				'offsetX': event.pageX,
				'offsetY': event.pageY,
				'originalCoordinate': {
					'left': scroll_content.realScrollLeft ? scroll_content.realScrollLeft : 0,
					'top': scroll_content.realScrollTop ? scroll_content.realScrollTop : 0
				}
			});

			$(document.body).append('<div id="overlayer" class="grabbing"></div>');

			return false;
		}
	},

	mousemove: function (event)
	{
		var event_data = event.data;

		scrollbar.scrollTo(event_data.canvas, {
			'left': event_data.offsetX - event.pageX - event_data.originalCoordinate.left,
			'top': event_data.offsetY - event.pageY - event_data.originalCoordinate.top
		});

		return false;
	},

	mouseup: function ()
	{
		$('#overlayer').remove();

		$(document).off({
			'mousemove': MC.canvas.event.ctrlMove.mousemove,
			'mouseup': MC.canvas.event.ctrlMove.mouseup
		});

		return false;
	}
};

MC.canvas.event.EIPstatus = function ()
{
	$canvas( this.parentNode.id ).toggleEip();

	return false;
};

MC.canvas.event.selectLine = function (event)
{
	if (event.which === 1)
	{
		MC.canvas.event.clearSelected();

		$canvas(this.id).select();
	}

	return false;
};

MC.canvas.event.selectNode = function (event)
{
	if (event.which === 1)
	{
		// Double click event
		if (MC.canvas.event.dblclick(function ()
		{
			$canvas.trigger('SHOW_PROPERTY_PANEL');
		}))
		{
			return false;
		}

		MC.canvas.event.clearSelected();

		$canvas(this.id).select();
		MC.canvas.nodeState.show(this.id);
	}

	return false;
};

MC.canvas.event.appMove = function (event)
{
	if (event.which === 1)
	{
		var target = $canvas(this.id);

		MC.canvas.event.clearSelected();

		if (
			target.class === 'AWS.EC2.Instance' ||
			target.nodeType === 'group'
		)
		{
			MC.canvas.event.dragable.mousedown.call( this, event );
		}
		else
		{
			target.select();
		}
	}

	return false;
};

MC.canvas.event.appDrawConnection = function ()
{
	if ($(this).is([
		'.port-instance-sg',
		'.port-eni-sg',
		'.port-launchconfig-sg',
		'.port-elb-sg'
		].join(', ')
	))
	{
		MC.canvas.event.drawConnection.mousedown.call( this, event );
	}

	return false;
};

MC.canvas.event.clearList = function (event)
{
	MC.canvas.instanceList.close();
	MC.canvas.eniList.close();
	MC.canvas.asgList.close();
	MC.canvas.event.clearSelected(event);

	return true;
};

MC.canvas.event.nodeHover = function (event)
{
	var connection = $canvas(this.id).connection(),
		stack = [],
		length = connection.length;

	while ( length-- )
	{
		stack[ length ] = '#' + connection[ length ].line;
	}

	Canvon( stack.join(',') )[ event.type === 'mouseenter' ? 'addClass' : 'removeClass' ]( 'view-hover' );

	return true;
};

MC.canvas.event.clearSelected = function (event)
{
	// Except for tab switching
	if (event && $(event.currentTarget).is('#tab-bar li'))
	{
		return false;
	}

	Canvon('#svg_canvas .selected').removeClass('selected');

	Canvon('#svg_canvas .view-show').removeClass('view-show');

	$('#node-state-wrap').remove();

	// Empty selected_node
	$canvas.selected_node().length = 0;

	return true;
};

MC.canvas.event.clickBlank = function (event)
{
	if (event.target.id === 'svg_canvas')
	{
		//dispatch event when click blank area in canvas
		$canvas.trigger("CANVAS_NODE_SELECTED", "");
	}

	return true;
};

MC.canvas.keypressed = [];

MC.canvas.event.keyEvent = function (event)
{
	var canvas_status = MC.canvas.getState();

	if ($('#modal-wrap')[0] != null)
	{
		return true;
	}

	if (
		$.inArray(canvas_status, [
			'new',
			'app',
			'stack',
			'appedit',
			'appview'
		]) > -1
	)
	{
		var keyCode = event.which,
			nodeName = event.target.nodeName.toLowerCase(),
			selected_node;

		MC.canvas.keypressed.push(keyCode);

		// Disable key event for input & textarea
		if (
			nodeName === 'input' ||
			nodeName === 'textarea' ||
			event.target.contentEditable === 'true'
		)
		{
			return true;
		}

		// Delete resource - [delete/backspace]
		if (
			(
				keyCode === 46 ||
				// For Mac
				keyCode === 8
			) &&
			(
				canvas_status === 'stack' ||
				canvas_status === 'appedit'
			) &&
			$canvas.selected_node().length > 0 &&
			event.target === document.body
		)
		{
			MC.canvas.volume.close();
			$.each($canvas.selected_node(), function (index, id)
			{
				$canvas( id ).remove();
			});
			$canvas.selected_node().length = 0;

			return false;
		}

		if (
			$canvas.selected_node().length === 1 &&
			MC.canvas.keypressed.join('').match(/383840403739373966656665$/i)
		)
		{
			if ($('#' + $canvas.selected_node()[ 0 ]).data('type') !== 'node')
			{
				return false;
			}

			var offset = Canvon('#' + $canvas.selected_node()[ 0 ]).offset();

			$(document.body).append('<div id="s"></div>');

			$('#s')
				.text('HP +' + MC.rand(100, 9999))
				.css({
					'border-radius': '4px',
					'padding': '5px 0',
					'background-color': 'rgba(102, 45, 63, 0.8)',
					'font-weight': '700',
					'position': 'absolute',
					'z-index': 999,
					'text-align': 'center',
					'color': 'rgb(252, 232, 244)',
					'font-weigh': 'bold',
					'font-size': 12,
					'width': offset.width,
					'top': offset.top + offset.height / 2 - 15,
					'left': offset.left
				});

			setTimeout(function ()
			{
				$('#s').fadeOut(function () {$(this).remove();});
			}, 1500);

			MC.canvas.keypressed = [];

			return false;
		}

		// Disable backspace
		if (
			keyCode === 8 &&
			nodeName !== 'input' &&
			nodeName !== 'textarea'
		)
		{
			return false;
		}

		// Switch node - [tab]
		if (
			keyCode === 9 &&
			$canvas.selected_node().length === 1
		)
		{
			var 	current_node_id = $canvas.selected_node()[ 0 ],
				//selected_node = $('#' + current_node_id),
				//layout_node_data = $canvas.node(),
				node_stack = [],
				index = 0,
				current_index,
				next_node;

			if ($canvas(current_node_id).nodeType !== 'node')
			{
				return false;
			}

			$.each($canvas.node(), function (index, item)
			{
				if (item.id === current_node_id)
				{
					current_index = index;
				}

				node_stack.push(item.id);

				index++;
			});

			if (current_index === node_stack.length - 1)
			{
				current_index = 0;
			}
			else
			{
				current_index++;
			}

			next_node = $('#' + node_stack[ current_index ]);

			MC.canvas.event.clearSelected();

			$canvas(next_node.attr('id')).select();

			return false;
		}

		// Move node - [up, down, left, right]
		if (
			$.inArray(keyCode, [37, 38, 39, 40]) > -1 &&
			(
				canvas_status === 'stack' ||
				canvas_status === 'appedit' ||
				canvas_status === 'appview'
			) &&
			$canvas.selected_node().length === 1 &&
			$('#' + $canvas.selected_node()[ 0 ]).data('type') !== 'line'
		)
		{
			var target = $('#' + $canvas.selected_node()[ 0 ]),
				target_id = $canvas.selected_node()[ 0 ],
				target_item = $canvas(target_id),
				node_type = target_item.nodeType,
				target_type = target_item.type,
				coordinate = target_item.position(),
				canvas_size = $canvas.size(),
				scale_ratio = $canvas.scale(),
				coordinate = {'x': coordinate[0], 'y': coordinate[1]},
				component_size = target_item.size(),
				match_place,
				vpc_id,
				vpc_item,
				vpc_size,
				vpc_coordinate;

			if (node_type !== 'node')
			{
				return false;
			}

			if (keyCode === 38)
			{
				coordinate.y--;
			}

			if (keyCode === 40)
			{
				coordinate.y++;
			}

			if (target_type === 'AWS.VPC.InternetGateway' || target_type === 'AWS.VPC.VPNGateway')
			{
				match_place = {};

				vpc_id = $('.AWS-VPC-VPC').attr('id');
				vpc_item = $canvas(vpc_id);
				vpc_coordinate = vpc_item.position();
				vpc_size = vpc_item.size();

				match_place.is_matched =
					coordinate.y <= vpc_coordinate[1] + vpc_size[1] - component_size[1] &&
					coordinate.y >= vpc_coordinate[1];
			}
			else
			{
				if (keyCode === 37)
				{
					coordinate.x--;
				}

				if (keyCode === 39)
				{
					coordinate.x++;
				}

				match_place = MC.canvas.isMatchPlace(
					target_id,
					target_type,
					node_type,
					coordinate.x,
					coordinate.y,
					component_size[0],
					component_size[1]
				);
			}

			if (
				coordinate.x > 0 &&
				coordinate.y > 0 &&
				match_place.is_matched &&

				coordinate.x + component_size[0] < canvas_size[0] - 3 &&
				coordinate.y + component_size[1] < canvas_size[1] - 3
			)
			{
				target_item.position(coordinate.x, coordinate.y);

				target_item.reConnect();
			}

			if (
				target_type === 'AWS.EC2.Instance' &&
				$('#node-state-wrap').data('id') === target_id
			)
			{
				MC.canvas.nodeState.position(target_id);
			}

			return false;
		}

		// Save stack - [Ctrl + S]
		if (
			event.ctrlKey && keyCode === 83 &&
			canvas_status === 'stack'
		)
		{
			$canvas.trigger("CANVAS_SAVE");

			return false;
		}

		// ZoomIn - [Ctrl + +]
		if (
			event.ctrlKey && keyCode === 187
		)
		{
			MC.canvas.zoomIn();

			return false;
		}

		// ZoomIn - [Ctrl + -]
		if (
			event.ctrlKey && keyCode === 189
		)
		{
			MC.canvas.zoomOut();

			return false;
		}
	}
};

MC.canvas.analysis = function ( data )
{
	console.info(data);
	var
		// component_data = data.component,
		// layout_data = data.layout,
		connection_data = $canvas.connection(),

		resources = {},
		resource_stack = {},

		elb_child_stack = [],
		elb_connection,

		GROUP_INNER_PADDING = 2,
		GROUP_MARGIN = 2,

		VPC_PADDING_LEFT = 20,
		VPC_PADDING_TOP = 10,
		VPC_PADDING_RIGHT = 8,
		VPC_PADDING_BOTTOM = 5,

		ELB_START_LEFT = 14,
		ELB_SIZE = MC.canvas.COMPONENT_SIZE['AWS.ELB'],

		// Initialize group construction
		SUBGROUP = {
			'AWS.VPC.VPC': ['AWS.EC2.AvailabilityZone'],
			'AWS.EC2.AvailabilityZone': ['AWS.VPC.Subnet'],
			'AWS.VPC.Subnet': [
				'AWS.EC2.Instance',
				'AWS.AutoScaling.Group',
				'AWS.VPC.NetworkInterface'
			],
			'AWS.AutoScaling.Group': ['AWS.AutoScaling.LaunchConfiguration']
		},

		SORT_ORDER = {
			'AWS.AutoScaling.Group': 1,
			'AWS.EC2.Instance': 2,
			'AWS.VPC.NetworkInterface': 3
		},

		GROUP_DEFAULT_SIZE = {
			'AWS.VPC.VPC': [60, 60],
			'AWS.EC2.AvailabilityZone': [17, 17],
			'AWS.VPC.Subnet': [15, 15],
			'AWS.AutoScaling.Group' : [13, 13]
		},

		// For children node order
		POSITION_METHOD = {
			'AWS.VPC.VPC': 'vertical',
			'AWS.EC2.AvailabilityZone': 'horizontal',
			'AWS.VPC.Subnet': 'matrix',
			'AWS.AutoScaling.Group': 'center'
		},

		layout,
		previous_node;

	$.each($canvas.node(), function (index, item)
	{
		resources[ item.id ] = item;
	});

	$.each($canvas.group(), function (index, item)
	{
		resources[ item.id ] = item;
	});

	$.each(resources, function (key, value)
	{
		var type = value.type,
			stack = resource_stack[ type ];

		if (stack === undefined)
		{
			resource_stack[ type ] = [];
		}

		resource_stack[ type ].push(key);
	});

	layout = {
		'id': resource_stack[ 'AWS.VPC.VPC' ][0],
		'coordinate': [5, 3],
		'size': [0, 0],
		'type': 'AWS.VPC.VPC'
	};

	// ELB connected children
	if (resource_stack[ 'AWS.ELB' ] !== undefined)
	{
		$.each(resource_stack[ 'AWS.ELB' ], function (current_index, id)
		{
			$.each($canvas( id ).connection(), function (i, item)
			{
				if (item.port === 'elb-sg-out')
				{
					elb_child_stack.push( item.target );
				}
			});
		});
	}

	function searchChild(id)
	{
		var children = [],
			target_group = SUBGROUP[ resources[ id ].type ],
			node_data,
			node_child;

		$.each(resources, function (key, value)
		{
			if (
				$.inArray(resources[ key ].type, target_group) > -1 &&
				value.parentId === id
			)
			{
				node_child = searchChild(key);

				node_data = {
					'id': key,
					'coordinate': [0, 0],
					'size': [0, 0],
					'type': value.type
				};

				if (MC.canvas.COMPONENT_SIZE[ value.type ] !== undefined)
				{
					node_data.size = MC.canvas.COMPONENT_SIZE[ value.type ];
				}

				if (GROUP_DEFAULT_SIZE[ value.type ] !== undefined)
				{
					node_data.size = GROUP_DEFAULT_SIZE[ value.type ];
				}

				if (node_child)
				{
					node_data[ 'children' ] = node_child;
				}

				children.push(node_data);
			}
		});

		return children.length < 1 ? false : children;
	}

	node_child = searchChild( resource_stack[ 'AWS.VPC.VPC' ][0] );

	if (node_child)
	{
		layout[ 'children' ] = node_child;
	}

	function checkChild(node)
	{
		if (node.children !== undefined)
		{
			var count = 0;

			$.each(node.children, function (i, item)
			{
				count += checkChild(item);
			});

			node.totalChild = count + node.children.length;

			if (node.type === 'AWS.VPC.Subnet')
			{
				node.hasELBConnected = false;

				$.each(node.children, function (i, item)
				{
					if ($.inArray(item.id, elb_child_stack) > -1)
					{
						node.hasELBConnected = true;
					}

					if (item.type === 'AWS.AutoScaling.Group')
					{
						if (
							item.children !== undefined &&
							$.inArray(item.children[ 0 ].id, elb_child_stack) > -1
						)
						{
							node.hasELBConnected = true;
						}
					}
				});
			}

			return node.children.length;
		}
		else
		{
			node.totalChild = 0;

			if (node.type === 'AWS.VPC.Subnet')
			{
				node.hasELBConnected = false;
			}

			return 0;
		}
	}

	checkChild( layout );

	function sortChild(node)
	{
		if (node.children !== undefined)
		{
			if (node.type === 'AWS.EC2.AvailabilityZone')
			{
				node.children.sort(function (a, b)
				{
					if (
						(a.hasELBConnected === true && b.hasELBConnected === true)
						||
						(a.hasELBConnected === false && b.hasELBConnected === false)
					)
					{
						return b.totalChild - a.totalChild;
					}
					else
					{
						if (
							a.hasELBConnected === true &&
							b.hasELBConnected === false
						)
						{
							return -1;
						}

						if (
							a.hasELBConnected === false &&
							b.hasELBConnected === true
						)
						{
							return 1;
						}
					}
				});
			}
			else
			{
				node.children.sort(function (a, b)
				{
					return b.totalChild - a.totalChild;
				});
			}

			$.each(node.children, function (i, item)
			{
				sortChild( item );
			});
		}
	}

	sortChild( layout );

	function absPosition(node, x, y)
	{
		node.coordinate[0] += x;
		node.coordinate[1] += y;

		if (node.children !== undefined)
		{
			$.each(node.children, function (i, item)
			{
				absPosition(item, node.coordinate[0], node.coordinate[1]);
			});
		}
	}

	absPosition( layout, 0, 0 );

	function positionSubnetChild(node)
	{
		var stack = {},
			children = node.children,
			length = children.length,
			method = POSITION_METHOD[ node.type ],
			max_width = 0,
			max_height = 0,

			NODE_MARGIN_LEFT = 2,
			NODE_MARGIN_TOP = 2,

			unique_row = {},
			noELBstack = [],

			elb_connected_instance = [],
			normal_instance = [],
			hasUniqueInstanceConnectedToELB = false,

			max_column = Math.ceil( Math.sqrt( length ) ),
			max_row = length === 0 ? 0 : Math.ceil( length / max_column ),
			column_index = 0,
			row_index = 0,

			node_connection,
			hasELBConnected,
			targetELB;

		children.sort(function (a, b)
		{
			return SORT_ORDER[ a.type ] - SORT_ORDER[ b.type ];
		});

		$.each(children, function (current_index, item)
		{
			hasELBConnected = false;
			targetELB = null;

			if (stack[ item.type ] === undefined)
			{
				stack[ item.type ] = [];
			}

			stack[ item.type ].push( item );

			// Check connection
			if (
				(
					item.type === 'AWS.AutoScaling.Group' ||
					item.type === 'AWS.EC2.Instance'
				) &&
				item.children !== undefined
			)
			{
				node_connection = resources[ item.children[ 0 ].id ].connection();
			}
			else
			{
				node_connection = resources[ item.id ].connection();
			}

			if (node_connection)
			{
				$.each(node_connection, function (i, data)
				{
					if (resources[ data.target ].type === 'AWS.ELB')
					{
						if (connection_data[ data.line ].target[ data.target ] === 'elb-sg-out')
						{
							hasELBConnected = true;
							targetELB = data.target;
						}
					}
				});

				if (hasELBConnected)
				{
					if (unique_row[ targetELB ] === undefined)
					{
						unique_row[ targetELB ] = [];
					}

					unique_row[ targetELB ].push( item );
				}
				else
				{
					if (item.type === 'AWS.AutoScaling.Group')
					{
						noELBstack.push( item );
					}
				}
			}
			else
			{
				if (item.type === 'AWS.AutoScaling.Group')
				{
					noELBstack.push( item );
				}
			}
		});

		var column_count = 0,
			row_width = 0,
			row_top = 0,
			left_padding = 0,
			row_index,

			// Range
			ASG_WIDTH = 15,
			ASG_HEIGHT = 15,
			INSTANCE_WIDTH = 11,
			INSTANCE_HEIGHT = 11;

		if (noELBstack.length > 0)
		{
			unique_row[ 'zz' ] = noELBstack;
		}

		$.each(unique_row, function (row, row_stack)
		{
			row_top = 0;

			row_stack.sort(function (a, b)
			{
				return SORT_ORDER[ a.type ] - SORT_ORDER[ b.type ];
			});

			$.each(row_stack, function (row_index, item)
			{
				if (item.type === 'AWS.AutoScaling.Group')
				{
					row_width = ASG_WIDTH;

					item.coordinate = [
						left_padding + 2,
						row_top + GROUP_INNER_PADDING
					];

					row_top += ASG_HEIGHT;

					if (item.children !== undefined)
					{
						positionChild( item );
					}
				}

				if (item.type === 'AWS.EC2.Instance')
				{
					row_width = row_width === ASG_WIDTH ? ASG_WIDTH : INSTANCE_WIDTH;

					item.coordinate = [
						// Adjust instance x axis with ASG (+2)
						left_padding + (row_width === ASG_WIDTH ? 4 : 2),
						// Adjust instance y axis with ASG (+4)
						row_top + GROUP_INNER_PADDING
					];

					row_top += INSTANCE_HEIGHT;
				}
			});

			column_count++;

			left_padding += row_width;
		})

		if (stack[ 'AWS.EC2.Instance' ] !== undefined)
		{
			$.each(stack[ 'AWS.EC2.Instance' ], function (i, item)
			{
				if ($.inArray(item.id, elb_child_stack) === -1)
				{
					normal_instance.push( item );
				}
			});

			normal_instance.sort(function (a, b)
			{
				return $canvas( a.id ).getModel().attributes.name.localeCompare( $canvas( b.id ).getModel().attributes.name );
			});
		}

		if (normal_instance.length > 0)
		{
			var childLength = normal_instance.length,
				max_child_column = Math.ceil( Math.sqrt( childLength ) ),
				max_child_row = childLength === 0 ? 0 : Math.ceil( childLength / max_child_column ),
				column_index = 0,
				row_index = 0;

			$.each(normal_instance, function (i, item)
			{
				if (column_index >= max_child_column)
				{
					column_index = 0;
					row_index++;
				}

				item.coordinate = [
					column_index * 9 + (column_index * NODE_MARGIN_LEFT) + GROUP_INNER_PADDING,
					row_index * 9 + (row_index * NODE_MARGIN_LEFT) + GROUP_INNER_PADDING
				];

				column_index++;
			});

			$.each(normal_instance, function (i, item)
			{
				item.coordinate[0] += left_padding;
			});

			left_padding += max_child_column * INSTANCE_WIDTH;
		}

		if (stack[ 'AWS.VPC.NetworkInterface' ] !== undefined)
		{
			var childLength = stack[ 'AWS.VPC.NetworkInterface' ].length,
				max_child_column = Math.ceil( Math.sqrt( childLength ) ),
				max_child_row = childLength === 0 ? 0 : Math.ceil( childLength / max_child_column ),
				eni_padding = 0,
				column_index = 0,
				row_index = 0;

			$.each(stack[ 'AWS.VPC.NetworkInterface' ], function (i, item)
			{
				if (column_index >= max_child_column)
				{
					column_index = 0;
					row_index++;
				}

				item.coordinate = [
					column_index * 9 + (column_index * NODE_MARGIN_LEFT) + eni_padding + GROUP_INNER_PADDING,
					row_index * 9 + (row_index * NODE_MARGIN_LEFT) + GROUP_INNER_PADDING
				];

				column_index++;
			});
		}

		if (stack[ 'AWS.VPC.NetworkInterface' ] !== undefined)
		{
			$.each(stack[ 'AWS.VPC.NetworkInterface' ], function (i, item)
			{
				item.coordinate[0] += left_padding;
			});
		}

		var max_width = 0,
			max_height = 0,
			item_coordinate,
			component_size;

		$.each(children, function (i, item)
		{
			item_coordinate = item.coordinate;

			component_size = MC.canvas.COMPONENT_SIZE[ item.type ];

			if (item_coordinate[0] + component_size[0] > max_width)
			{
				max_width = item_coordinate[0] + component_size[0];
			}

			if (item_coordinate[1] + component_size[1] > max_height)
			{
				max_height = item_coordinate[1] + component_size[1];
			}
		});

		node.size = [
			max_width + GROUP_INNER_PADDING,
			max_height + GROUP_INNER_PADDING
		];
	}

	function sortSubnet( children )
	{
		var internetELBconnected = [],
			internalELBconnected = [],
			normalSubnet = [],

			isInternetELBconnected,
			isInternalELBconnected,

			//layout_component_data = MC.canvas_data.

			elb_type,
			item_connection;

		$.each(children, function (i, item)
		{
			isInternetELBconnected = false;
			isInternalELBconnected = false;

			if (item.children !== undefined)
			{
				$.each(item.children, function (index, node)
				{
					if (
						node.type === 'AWS.AutoScaling.Group' &&
						node.children !== undefined
					)
					{
						node = node.children[ 0 ];
					}

					node_connection = resources[ node.id ].connection();

					if (node_connection)
					{
						$.each(node_connection, function (index, data)
						{
							if (resources[ data.target ].type === 'AWS.ELB')
							{
								elb_type = $canvas( data.target ).getModel().attributes.internal ? 'internal' : 'internet-facing';

								if (elb_type === 'internet-facing')
								{
									isInternetELBconnected = true;
								}

								if (elb_type === 'internal')
								{
									isInternalELBconnected = true;
								}
							}
						});
					}
				});

				if (isInternetELBconnected)
				{
					internetELBconnected.push( item );
				}
				else if (isInternalELBconnected)
				{
					internalELBconnected.push( item );
				}
			}

			if (!isInternetELBconnected && !isInternalELBconnected)
			{
				normalSubnet.push( item );
			}
		});

		internetELBconnected.sort(function (a, b)
		{
			return b.totalChild - a.totalChild;
		});

		internetELBconnected.sort(function (a, b)
		{
			return b.totalChild - a.totalChild;
		});

		normalSubnet.sort(function (a, b)
		{
			if (
				b.totalChild === a.totalChild &&
				(
					b.totalChild > 0 &&
					a.totalChild > 0
				)
			)
			{
				var weight = {
						'a': 0,
						'b': 0
					};

				$.each({"a": a, "b": b}, function (key, value)
				{
					$.each(value.children, function (i, item)
					{
						if (item.type === 'AWS.AutoScaling.Group')
						{
							weight[ key ] += 3;
						}

						if (item.type === 'AWS.EC2.Instance')
						{
							weight[ key ] += 2;
						}

						if (item.type === 'AWS.VPC.NetworkInterface')
						{
							weight[ key ] += 1;
						}
					});
				});

				return weight.b - weight.a;
			}
			else
			{
				return b.totalChild - a.totalChild;
			}
		});

		children = internetELBconnected.concat(internalELBconnected, normalSubnet);

		return children;
	}

	function positionChild(node)
	{
		var children = node.children,
			GROUP_MARGIN = 2,

			length = children.length,
			method = POSITION_METHOD[ node.type ],
			max_width = 0,
			max_height = 0,

			NODE_MARGIN_LEFT = 2,
			NODE_MARGIN_TOP = 2;

		if (node.type === 'AWS.EC2.AvailabilityZone')
		{
			GROUP_MARGIN = 4;
		}

		if (method === 'matrix')
		{
			positionSubnetChild(node);
		}

		if (method === 'vertical')
		{
			$.each(children, function (current_index, item)
			{
				item.coordinate = [
					0 + GROUP_INNER_PADDING,
					current_index + GROUP_INNER_PADDING
				];

				if (item.children !== undefined)
				{
					positionChild( item );
				}

				if (item.size[0] > max_width)
				{
					max_width = item.size[0];
				}

				max_height += item.size[1];

				if (current_index > 0)
				{
					previous_node = children[ current_index - 1 ];
					item.coordinate = [
						0 + GROUP_INNER_PADDING,
						previous_node.size[1] + previous_node.coordinate[1] + GROUP_MARGIN
					];

					max_height += GROUP_MARGIN * 2;
				}
			});

			node.size = [
				max_width + (GROUP_INNER_PADDING * 2),
				max_height + (GROUP_MARGIN * (length - 1)) + GROUP_INNER_PADDING
			];
		}

		if (method === 'horizontal')
		{
			if (node.type === 'AWS.EC2.AvailabilityZone')
			{
				children = sortSubnet( children );
			}

			$.each(children, function (current_index, item)
			{
				item.coordinate = [
					current_index + GROUP_INNER_PADDING,
					0 + GROUP_INNER_PADDING
				];

				if (item.children !== undefined)
				{
					positionChild( item );
				}

				if (item.size[1] > max_height)
				{
					max_height = item.size[1];
				}

				max_width += item.size[0];

				if (current_index > 0)
				{
					previous_node = children[ current_index - 1 ];
					item.coordinate = [
						previous_node.size[0] + previous_node.coordinate[0] + GROUP_MARGIN,
						0 + GROUP_INNER_PADDING
					];

					max_width += GROUP_MARGIN * 2;
				}
			});

			node.size = [
				max_width - (GROUP_MARGIN * (length - 1)) + (GROUP_INNER_PADDING * 2),
				max_height + (GROUP_INNER_PADDING * 2)
			];
		}

		if (method === 'center')
		{
			$.each(children, function (current_index, item)
			{
				item.coordinate = [2, 2];
			});

			node.size = [13, 13];
		}
	}

	if (layout.children)
	{
		positionChild( layout );
	}

	// VPC padding
	if (layout.children)
	{
		$.each(layout.children, function (i, item)
		{
			item.coordinate[0] += VPC_PADDING_LEFT;
			item.coordinate[1] += VPC_PADDING_TOP;
		});
	}

	// RouteTable
	if (resource_stack[ 'AWS.VPC.RouteTable' ] !== undefined)
	{
		var ROUTE_TABLE_START_LEFT = 15,
			ROUTE_TABLE_START_TOP = 5,
			ROUTE_TABLE_MARGIN = 4,
			ROUTE_TABLE_SIZE = MC.canvas.COMPONENT_SIZE['AWS.VPC.RouteTable'],
			RT_to_IGW = [],
			RT_to_VGW = [],
			RT_other = [],
			RT_prefer,
			RT_connection,
			RT_connect_target;

		if (resource_stack[ 'AWS.VPC.RouteTable' ].length > 0)
		{
			resource_stack[ 'AWS.VPC.RouteTable' ].sort(function (a, b)
			{
				return $canvas( a ).getModel().attributes.name.localeCompare( $canvas( b ).getModel().attributes.name );
			});

			$.each(resource_stack[ 'AWS.VPC.RouteTable' ], function (index, id)
			{
				RT_prefer = false;
				RT_connection = $canvas( id ).connection();

				$.each(RT_connection, function (i, data)
				{
					if (data.port === 'rtb-tgt')
					{
						RT_connect_target = $canvas( data.target ).type;

						if (RT_connect_target === 'AWS.VPC.InternetGateway')
						{
							RT_prefer = true;
							RT_to_IGW.push( id );
						}

						if (RT_connect_target === 'AWS.VPC.VPNGateway')
						{
							RT_prefer = true;
							RT_to_VGW.push( id );
						}

					}
				});

				if (RT_prefer === false)
				{
					RT_other.push( id );
				}
			});

			// RT Children join
			resource_stack[ 'AWS.VPC.RouteTable' ] = _.unique( RT_to_IGW.concat(RT_to_VGW, RT_other) );

			$.each(resource_stack[ 'AWS.VPC.RouteTable' ], function (current_index, id)
			{
				$canvas( id ).position(
					(current_index + 1) * ROUTE_TABLE_SIZE[0] + ((current_index + 1) * ROUTE_TABLE_MARGIN) + ROUTE_TABLE_START_LEFT,
					ROUTE_TABLE_START_TOP
				);
			});
		}
	}

	// Add AZ margin for ELB
	var elb_stack = layout.children,
		max_first_height = 0;

	if (
		elb_stack !== undefined &&
		elb_stack.length > 1 &&
		resource_stack[ 'AWS.ELB' ] !== undefined
	)
	{
		// var i = 1,
		// 	l = elb_stack.length;

		// for ( ; i < l ; i++ )
		// {
		// 	elb_stack[ i ].coordinate[ 1 ] += 15;
		// }

		max_first_height = elb_stack[ 0 ].coordinate[ 1 ] + elb_stack[ 0 ].size[ 1 ];

		if (elb_stack[ 2 ])
		{
			if (elb_stack[ 2 ].size[ 1 ] > elb_stack[ 0 ].size[ 1 ])
			{
				elb_stack[ 2 ].coordinate = [
					elb_stack[ 0 ].coordinate[ 0 ] + elb_stack[ 0 ].size[ 0 ] + 5,
					elb_stack[ 0 ].coordinate[ 1 ]
				];

				elb_stack[ 0 ].coordinate = [
					elb_stack[ 0 ].coordinate[ 0 ],
					elb_stack[ 0 ].coordinate[ 1 ] + (elb_stack[ 2 ].size[ 1 ] - elb_stack[ 0 ].size[ 1 ]) / 2
				];

				max_first_height = elb_stack[ 2 ].coordinate[ 1 ] + elb_stack[ 2 ].size[ 1 ];
			}
			else
			{
				elb_stack[ 2 ].coordinate = [
					elb_stack[ 0 ].coordinate[ 0 ] + elb_stack[ 0 ].size[ 0 ] + 5,
					elb_stack[ 0 ].coordinate[ 1 ] + elb_stack[ 0 ].size[ 1 ] - elb_stack[ 2 ].size[ 1 ]
				];
			}
		}

		if (elb_stack[ 1 ])
		{
			elb_stack[ 1 ].coordinate[ 1 ] = max_first_height + 15;
		}

		if (elb_stack[ 3 ])
		{
			elb_stack[ 3 ].coordinate = [
				elb_stack[ 1 ].coordinate[ 0 ] + elb_stack[ 1 ].size[ 0 ] + 5,
				elb_stack[ 1 ].coordinate[ 1 ]
			];
		}
	}

	// ELB
	if (resource_stack[ 'AWS.ELB' ] !== undefined)
	{
		resource_stack[ 'AWS.ELB' ].sort(function (a, b)
		{
			a = $canvas( a ).getModel().attributes.internal ? 'internal' : 'internet-facing';
			b = $canvas( b ).getModel().attributes.internal ? 'internal' : 'internet-facing';

			return b.localeCompare( a );
		});

		if (elb_stack.length > 1)
		{
			$.each(resource_stack[ 'AWS.ELB' ], function (current_index, id)
			{
				$canvas( id ).position(
					ELB_START_LEFT + (current_index * 10) + (current_index * 10),
					max_first_height + 5
				);
			});
		}
		else
		{
			$.each(resource_stack[ 'AWS.ELB' ], function (current_index, id)
			{
				$canvas( id ).position(
					ELB_START_LEFT,
					elb_stack[ 0 ].coordinate[ 0 ] + (elb_stack[ 0 ].size[ 1 ] / 2 - 5) + current_index * 10
				);
			});
		}
	}

	function absPosition(node, x, y)
	{
		var coordinate = node.coordinate;

		coordinate[0] += x;
		coordinate[1] += y;

		if (node.children !== undefined)
		{
			$.each(node.children, function (i, item)
			{
				absPosition(item, coordinate[0], coordinate[1]);
			});
		}
	}

	absPosition( layout, 0, 0 );

	function updateLayoutData(node)
	{
		var resource = resources[ node.id ];

		$canvas( node.id ).position( node.coordinate[0], node.coordinate[1] );

		if (node.size !== undefined)
		{
			$canvas( node.id ).size( node.size[0], node.size[1] );
			//resource.size = node.size;
		}

		if (node.children !== undefined)
		{
			$.each(node.children, function (i, item)
			{
				updateLayoutData( item );
			});
		}
	}

	updateLayoutData( layout );

	function VPCsize()
	{
		var VPC_max_width = 0,
			VPC_max_height = 0,
			//layout_data = data.layout.component,
			ignore_type = ['AWS.VPC.CustomerGateway', 'AWS.VPC.InternetGateway', 'AWS.VPC.VPNGateway'],
			coordinate,
			size,
			group_size,
			item_type;

		$.each($canvas.node(), function (i, item)
		{
			coordinate = item.position();
			size = item.size();

			if ($.inArray(item.type, ignore_type) === -1)
			{
				//component_size = MC.canvas.COMPONENT_SIZE[ item.type ];

				if (coordinate[0] + size[0] > VPC_max_width)
				{
					VPC_max_width = coordinate[0] + size[0];
				}

				if (coordinate[1] + size[1] > VPC_max_height)
				{
					VPC_max_height = coordinate[1] + size[1];
				}
			}
		});

		$.each($canvas.group(), function (i, item)
		{
			coordinate = item.position();
			size = item.size();

			if (item.type !== 'AWS.AutoScaling.Group')
			{
				if (coordinate[0] + size[0] > VPC_max_width)
				{
					VPC_max_width = coordinate[0] + size[0];
				}

				if (coordinate[1] + size[1] > VPC_max_height)
				{
					VPC_max_height = coordinate[1] + size[1];
				}
			}
		});

		layout.size[0] = VPC_max_width - layout.coordinate[0] + VPC_PADDING_RIGHT;
		layout.size[1] = VPC_max_height - layout.coordinate[1] + VPC_PADDING_BOTTOM;

		$canvas( layout.id ).size(
			 VPC_max_width - layout.coordinate[0] + VPC_PADDING_RIGHT,
			 VPC_max_height - layout.coordinate[1] + VPC_PADDING_BOTTOM
		);
	}

	VPCsize();

	// IGW & VGW
	if (resource_stack[ 'AWS.VPC.InternetGateway' ] !== undefined)
	{
		$canvas( resource_stack[ 'AWS.VPC.InternetGateway' ][ 0 ] ).position(
			layout.coordinate[0] - 4,
			layout.coordinate[1] + (layout.size[1] / 2) - 4
		);
	}

	if (resource_stack[ 'AWS.VPC.VPNGateway' ] !== undefined)
	{
		$canvas( resource_stack[ 'AWS.VPC.VPNGateway' ][ 0 ] ).position(
			layout.coordinate[0] + layout.size[0] - 4,
			layout.coordinate[1] + (layout.size[1] / 2) - 4
		);
	}

	// CGW
	if (resource_stack[ 'AWS.VPC.CustomerGateway' ] !== undefined)
	{
		$.each(resource_stack[ 'AWS.VPC.CustomerGateway' ], function (i, item)
		{
			$canvas( item ).position(
				layout.coordinate[0] + layout.size[0] + 8,
				layout.coordinate[1] + (i * 11) + (layout.size[1] / 2) - 5
			);
		});
	}

	// Canvas size
	var canvas_width = layout.size[ 0 ] + 80,
		canvas_height = layout.size[ 1 ] + 50;

	$canvas.size(
		canvas_width < 180 ? 180 : canvas_width,
		canvas_height < 150 ? 150 : canvas_height
	);

	return true;
};

MC.canvas.benchmark = function (count)
{
	var NODE_MARGIN_LEFT = 2,
		NODE_MARGIN_TOP = 2,
		NODE_START_LEFT = 8,
		NODE_START_TOP = 8,
		GROUP_INNER_PADDING = 2,

		max_child_column = Math.ceil( Math.sqrt( count ) ),
		max_child_row = count === 0 ? 0 : Math.ceil( count / max_child_column ),
		scale_ratio = $canvas.scale(),
		column_index = 0,
		row_index = 0,
		i = 0;

	var AZ_id = $canvas.add("AWS.EC2.AvailabilityZone", {"name": "us-east-1a"}, {'x': 5, 'y': 5});

	for (; i < count; i++)
	{
		if (column_index >= max_child_column)
		{
			column_index = 0;
			row_index++;
		}

		$canvas.add(
			"AWS.EC2.Instance",
			{
				"imageId": "ami-cde4bca4",
				"cachedAmi" : {
					"osType": "amazon",
					"architecture": "i386",
					"rootDeviceType": "ebs"
				},
				"groupUId": AZ_id
			},
			{
				'x': NODE_START_LEFT + column_index * 9 + (column_index * NODE_MARGIN_LEFT) + GROUP_INNER_PADDING,
				'y': NODE_START_TOP + row_index * 9 + (row_index * NODE_MARGIN_TOP) + GROUP_INNER_PADDING
			}
		);

		column_index++;
	}

	$canvas(AZ_id).size((max_child_column * (9 + NODE_MARGIN_LEFT)) + 8, (max_child_row * (9 + NODE_MARGIN_TOP)) + 8);
	MC.canvas.updateResizer($('#' + AZ_id)[0], (max_child_column * (9 + NODE_MARGIN_LEFT)) + 8, (max_child_row * (9 + NODE_MARGIN_TOP)) + 8);

	canvas_size = [
		(max_child_column * (9 + NODE_MARGIN_LEFT)) + 50,
		(max_child_row * (9 + NODE_MARGIN_TOP)) + 50
	];

	$('#svg_canvas').attr({
		'width': canvas_size[0] * MC.canvas.GRID_WIDTH / scale_ratio,
		'height': canvas_size[1] * MC.canvas.GRID_HEIGHT / scale_ratio
	});

	$('#canvas_container, #canvas_body').css({
		'width': canvas_size[0] * MC.canvas.GRID_WIDTH / scale_ratio,
		'height': canvas_size[1] * MC.canvas.GRID_HEIGHT / scale_ratio
	});

	$canvas.size(canvas_size[0], canvas_size[1]);
};

/* Blob.js
 * A Blob implementation.
 * 2013-06-20
 *
 * By Eli Grey, http://eligrey.com
 * By Devin Samarin, https://github.com/eboyjr
 * License: X11/MIT
 *   See LICENSE.md
 */

/*global self, unescape */
/*jslint bitwise: true, regexp: true, confusion: true, es5: true, vars: true, white: true,
  plusplus: true */

/*! @source http://purl.eligrey.com/github/Blob.js/blob/master/Blob.js */
if (!(typeof Blob === "function" || typeof Blob === "object") || typeof URL === "undefined")
if ((typeof Blob === "function" || typeof Blob === "object") && typeof webkitURL !== "undefined") (self || window).URL = webkitURL;
else var Blob = (function (view) {
  "use strict";

  var BlobBuilder = view.BlobBuilder || view.WebKitBlobBuilder || view.MozBlobBuilder || view.MSBlobBuilder || (function(view) {
    var
        get_class = function(object) {
        return Object.prototype.toString.call(object).match(/^\[object\s(.*)\]$/)[1];
      }
      , FakeBlobBuilder = function BlobBuilder() {
        this.data = [];
      }
      , FakeBlob = function Blob(data, type, encoding) {
        this.data = data;
        this.size = data.length;
        this.type = type;
        this.encoding = encoding;
      }
      , FBB_proto = FakeBlobBuilder.prototype
      , FB_proto = FakeBlob.prototype
      , FileReaderSync = view.FileReaderSync
      , FileException = function(type) {
        this.code = this[this.name = type];
      }
      , file_ex_codes = (
          "NOT_FOUND_ERR SECURITY_ERR ABORT_ERR NOT_READABLE_ERR ENCODING_ERR "
        + "NO_MODIFICATION_ALLOWED_ERR INVALID_STATE_ERR SYNTAX_ERR"
      ).split(" ")
      , file_ex_code = file_ex_codes.length
      , real_URL = view.URL || view.webkitURL || view
      , real_create_object_URL = real_URL.createObjectURL
      , real_revoke_object_URL = real_URL.revokeObjectURL
      , URL = real_URL
      , btoa = view.btoa
      , atob = view.atob

      , ArrayBuffer = view.ArrayBuffer
      , Uint8Array = view.Uint8Array
    ;
    FakeBlob.fake = FB_proto.fake = true;
    while (file_ex_code--) {
      FileException.prototype[file_ex_codes[file_ex_code]] = file_ex_code + 1;
    }
    if (!real_URL.createObjectURL) {
      URL = view.URL = {};
    }
    URL.createObjectURL = function(blob) {
      var
          type = blob.type
        , data_URI_header
      ;
      if (type === null) {
        type = "application/octet-stream";
      }
      if (blob instanceof FakeBlob) {
        data_URI_header = "data:" + type;
        if (blob.encoding === "base64") {
          return data_URI_header + ";base64," + blob.data;
        } else if (blob.encoding === "URI") {
          return data_URI_header + "," + decodeURIComponent(blob.data);
        } if (btoa) {
          return data_URI_header + ";base64," + btoa(blob.data);
        } else {
          return data_URI_header + "," + encodeURIComponent(blob.data);
        }
      } else if (real_create_object_URL) {
        return real_create_object_URL.call(real_URL, blob);
      }
    };
    URL.revokeObjectURL = function(object_URL) {
      if (object_URL.substring(0, 5) !== "data:" && real_revoke_object_URL) {
        real_revoke_object_URL.call(real_URL, object_URL);
      }
    };
    FBB_proto.append = function(data/*, endings*/) {
      var bb = this.data;
      // decode data to a binary string
      if (Uint8Array && (data instanceof ArrayBuffer || data instanceof Uint8Array)) {
        var
            str = ""
          , buf = new Uint8Array(data)
          , i = 0
          , buf_len = buf.length
        ;
        for (; i < buf_len; i++) {
          str += String.fromCharCode(buf[i]);
        }
        bb.push(str);
      } else if (get_class(data) === "Blob" || get_class(data) === "File") {
        if (FileReaderSync) {
          var fr = new FileReaderSync;
          bb.push(fr.readAsBinaryString(data));
        } else {
          // async FileReader won't work as BlobBuilder is sync
          throw new FileException("NOT_READABLE_ERR");
        }
      } else if (data instanceof FakeBlob) {
        if (data.encoding === "base64" && atob) {
          bb.push(atob(data.data));
        } else if (data.encoding === "URI") {
          bb.push(decodeURIComponent(data.data));
        } else if (data.encoding === "raw") {
          bb.push(data.data);
        }
      } else {
        if (typeof data !== "string") {
          data += ""; // convert unsupported types to strings
        }
        // decode UTF-16 to binary string
        bb.push(unescape(encodeURIComponent(data)));
      }
    };
    FBB_proto.getBlob = function(type) {
      if (!arguments.length) {
        type = null;
      }
      return new FakeBlob(this.data.join(""), type, "raw");
    };
    FBB_proto.toString = function() {
      return "[object BlobBuilder]";
    };
    FB_proto.slice = function(start, end, type) {
      var args = arguments.length;
      if (args < 3) {
        type = null;
      }
      return new FakeBlob(
          this.data.slice(start, args > 1 ? end : this.data.length)
        , type
        , this.encoding
      );
    };
    FB_proto.toString = function() {
      return "[object Blob]";
    };
    return FakeBlobBuilder;
  }(view));

  return function Blob(blobParts, options) {
    var type = options ? (options.type || "") : "";
    var builder = new BlobBuilder();
    if (blobParts) {
      for (var i = 0, len = blobParts.length; i < len; i++) {
        builder.append(blobParts[i]);
      }
    }
    return builder.getBlob(type);
  };
}(window));

/* canvas-toBlob.js
 * A canvas.toBlob() implementation.
 * 2011-07-13
 *
 * By Eli Grey, http://eligrey.com and Devin Samarin, https://github.com/eboyjr
 * License: X11/MIT
 *   See LICENSE.md
 */

/*global self */
/*jslint bitwise: true, regexp: true, confusion: true, es5: true, vars: true, white: true,
  plusplus: true */

/*! @source http://purl.eligrey.com/github/canvas-toBlob.js/blob/master/canvas-toBlob.js */

(function(view) {
"use strict";
var
    Uint8Array = view.Uint8Array
  , HTMLCanvasElement = view.HTMLCanvasElement
  , is_base64_regex = /\s*;\s*base64\s*(?:;|$)/i
  , base64_ranks
  , decode_base64 = function(base64) {
    var
        len = base64.length
      , buffer = new Uint8Array(len / 4 * 3 | 0)
      , i = 0
      , outptr = 0
      , last = [0, 0]
      , state = 0
      , save = 0
      , rank
      , code
      , undef
    ;
    while (len--) {
      code = base64.charCodeAt(i++);
      rank = base64_ranks[code-43];
      if (rank !== 255 && rank !== undef) {
        last[1] = last[0];
        last[0] = code;
        save = (save << 6) | rank;
        state++;
        if (state === 4) {
          buffer[outptr++] = save >>> 16;
          if (last[1] !== 61 /* padding character */) {
            buffer[outptr++] = save >>> 8;
          }
          if (last[0] !== 61 /* padding character */) {
            buffer[outptr++] = save;
          }
          state = 0;
        }
      }
    }
    // 2/3 chance there's going to be some null bytes at the end, but that
    // doesn't really matter with most image formats.
    // If it somehow matters for you, truncate the buffer up outptr.
    return buffer.buffer;
  }
;
if (Uint8Array) {
  base64_ranks = new Uint8Array([
      62, -1, -1, -1, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1
    , -1, -1,  0, -1, -1, -1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9
    , 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25
    , -1, -1, -1, -1, -1, -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35
    , 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51
  ]);
}
if (HTMLCanvasElement && !HTMLCanvasElement.prototype.toBlob) {
  HTMLCanvasElement.prototype.toBlob = function(callback, type /*, ...args*/) {
      if (!type) {
      type = "image/png";
    } if (this.mozGetAsFile) {
      callback(this.mozGetAsFile("canvas", type));
      return;
    }
    var
        args = Array.prototype.slice.call(arguments, 1)
      , dataURI = this.toDataURL.apply(this, args)
      , header_end = dataURI.indexOf(",")
      , data = dataURI.substring(header_end + 1)
      , is_base64 = is_base64_regex.test(dataURI.substring(0, header_end))
      , blob
    ;
    if (Blob.fake) {
      // no reason to decode a data: URI that's just going to become a data URI again
      blob = new Blob
      if (is_base64) {
        blob.encoding = "base64";
      } else {
        blob.encoding = "URI";
      }
      blob.data = data;
      blob.size = data.length;
    } else if (Uint8Array) {
      if (is_base64) {
        blob = new Blob([decode_base64(data)], {type: type});
      } else {
        blob = new Blob([decodeURIComponent(data)], {type: type});
      }
    }
    callback(blob, dataURI);
  };
}
}(window));

MC.canvas.exportPNG = function ( $svg_canvas_element, data )
{

	/*
	data = {
		isExport   : boolean
		createBlob : false
		drawInfo   : true
		onFinish   : function (required)
		name       : string
	}
	*/

	if ( !data.onFinish ) { return; }
	// Prepare grid background
	if ( !MC.canvas.exportPNG.bg )
	{
		var img = document.createElement("img");
		img.src = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAIAAAACUFjqAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAHUlEQVQYV2P48ePHf9yAgabSHz9+/I4bENI9gNIA0iYpJd74eOIAAAAASUVORK5CYII=";
		MC.canvas.exportPNG.bg = img;

		$("<div id='export-png-wrap'></div>").appendTo("body").hide();
	}


	var svg_canvas_element = $svg_canvas_element[0];
	var size               = svg_canvas_element.getBBox();
	var clone              = svg_canvas_element.cloneNode( true );
	var beforeRender       = null;
	var line               = clone.getElementById("svg_padding_line");

	// cloneNode won't clone the xmlns:xlink attribute
	clone.setAttribute( "xmlns:xlink", "http://www.w3.org/1999/xlink" );
	clone.removeAttribute( "id" );

	// Insert the document so that we can calculate the style.
	$("#export-png-wrap")
		.append( clone )
		.attr("class", $("#canvas_container").attr("class"));

	// Inline styles
	var removeArray = [ clone ]; /// Detach the clone from document.
	var children = clone.children || clone.childNodes;
	for ( var i = 0; i < children.length; ++i ) {
		if ( !children[i].tagName ) { continue; }
		MC.canvas.exportPNG.fixSVG( children[i], removeArray );
	}
	// Remove unnecessary elements
	for ( i = 0; i < removeArray.length; ++i ) {
		var ref = removeArray[i];
		if ( ref.remove ) {
			ref.remove();
		} else {
			ref.parentNode.removeChild( ref );
		}
	}

	// Prepare to insert header for Exporting Image
	if ( data.isExport ) {
		var replaceEl = document.createElementNS("http://www.w3.org/2000/svg", "g");
		replaceEl.textContent = "PLACEHOLDER";
		// We use canvg's translate instead of calling context.translate()
		// because context.translate seems a little bit slow.
		replaceEl.setAttribute("transform","translate(0 54)");
		clone.insertBefore( replaceEl, line );
	}

	// Remove a line that is useless
	clone.removeChild(line);

	// Generate svg text, and remove data attributes
	var svg = (new XMLSerializer()).serializeToString( clone )
							.replace(/data-[^=]+="[^"]*?"/g, "");

	// Insert header
	if ( data.isExport ) {
		if ( MC.canvas.exportPNG.href === undefined ) {
			// In IE, XMLSerializer will change xlink:href to href
			MC.canvas.exportPNG.href = svg.indexOf("xlink:href") == -1 ? "href" : "xlink:href";
		}

		var time = "";
		var name = "";
		if ( data.drawInfo !== false ) {
			time = MC.dateFormat( new Date(), 'yyyy-MM-dd hh:mm:ss' );
			name = data.name;
		}

		var head = '<rect fill="#ad5992" width="100%" height="4" y="-54"></rect><rect fill="#252526" width="100%" height="50" y="-50"></rect><image ' + MC.canvas.exportPNG.href + '="./assets/images/ide/logo-t.png" x="10" y="-42" width="160" height="34"></image><text x="100%" y="-27" fill="#fff" text-anchor="end" transform="translate(-10 0)">' + time + '</text><text fill="#fff" x="100%" y="-13" text-anchor="end" transform="translate(-10 0)">' + name + '</text>';

		svg = svg.replace("PLACEHOLDER</g>", head).replace("</svg>", "</g></svg>");
	}

	// Calc the size for the canvas
	// In IE, getBBox returns SvgRect which is not allowed to modified.
	size = { width : size.width + 50, height : size.height + 30 };

	// Calc the perfect size
	if ( data.isExport ) {
		size.height += 54;

		if ( size.width  < 360 ) { size.width  = 360; }
		if ( size.height < 380 ) { size.height = 380; }

		beforeRender = function( ctx ){
			var pat = ctx.createPattern( MC.canvas.exportPNG.bg, 'repeat' );
			ctx.fillStyle = pat;
			ctx.fillRect(0, 54, size.width, size.height-54);
		}
	} else {
		beforeRender = function( ctx ){
			var ratio1 = 220 / size.width;
			var ratio2 = 145 / size.height;
			var ratio  = ratio1 <= ratio2 ? ratio2 : ratio1;

			var pattern = document.createElement('canvas');
			pattern.width  = size.width;
			pattern.height = size.height;

			size.width  = 220;
			size.height = 145;

			patternctx = pattern.getContext("2d");

			patternctx.fillStyle = patternctx.createPattern( MC.canvas.exportPNG.bg, 'repeat' );
			patternctx.fillRect(0, 0, pattern.width, pattern.height);

			ctx.scale( ratio, ratio );
			ctx.drawImage( pattern, 0, 0, pattern.width, pattern.height );
		}
	}

	// Draw
	var canvas = document.createElement('canvas');
	canvas.width  = size.width;
	canvas.height = size.height;
	canvg( canvas, svg, {
		beforeRender : beforeRender,
		afterRender  : function() {

			onFinish = data.onFinish;
			data.onFinish = null;

			if ( data.createBlob === true ) {
				canvas.toBlob(function( blob, possibleDataURL ){

					if ( typeof possibleDataURL === "string" ) {
						// We are using an 3rd party implementation of toBlob
						// And we get the DataURL.
						data.image = possibleDataURL;
					} else {
						data.image = canvas.toDataURL();
					}
					data.blob = blob;
					onFinish( data );
				});
			} else {
				data.image = canvas.toDataURL();
				onFinish( data );
			}
		}
	});
};

MC.canvas.exportPNG.fixSVG = function( element, removeArray ) {

	var tagName = element.tagName.toLowerCase();

	// Remove <defs/>, empty <g/> and g.resizer-wrap
	if ( tagName === "defs" ) { return removeArray.push( element ); }

	var children = element.children || element.childNodes;
	var remove   = false;

	if ( tagName === "g" ) {
		if ( children.length == 0 ) {
			remove = true;
		} else if ( !element.classList ) {
			var k = element.getAttribute("class");
			if ( k && k.indexOf("resizer-wrap") != -1 ) {
				remove = true;
			}
		} else if ( element.classList.contains("resizer-wrap") ) {
				remove = true;
		}
	}

	if ( !remove ) {
		if ( !element.classList ) {
			k = element.getAttribute("class");
			if ( k && k.indexOf("fill-line") != -1 ) {
				remove = true;
			}
		} else if ( element.classList.contains("fill-line") ) {
			remove = true;
		}
	}
	if ( remove ) { return removeArray.push(element); }

	var ss = window.getComputedStyle( element );
	// Remove non-visual element
	if ( ss.visibility == "hidden" || ss.display == "none" || ss.opacity == "0" ) {
		return removeArray.push( element );
	}

	// Store the inline stylesheet in stylez
	var s = [];

	if ( ss.opacity != 1 ) { s.push( "opacity:" + ss.opacity ); }

	if ( tagName !== "g" && tagName !== "image" ) {
		// Fill
		if ( ss.fillOpacity == 0 ) {
			s.push( "fill:none" );
		} else {
			if ( ss.fill != "#000000" ) { s.push( "fill:" + ss.fill ); }
			if ( ss.fillOpacity != 1 )  { s.push( "fill-opacity:" + ss.fillOpacity ); }
		}

		// Stroke
		var t1 = (ss.strokeWidth + "").replace("px", "");
		if ( ss.strokeWidth == 0 || ss.strokeOpacity == 0 ) {
			s.push( "stroke:none" );
		} else {
			s.push( "stroke:" + ss.stroke );
			if ( t1 != 1 )               { s.push( "stroke-width:" + ss.strokeWidth ); }
			if ( ss.strokeOpacity != 1 ) { s.push( "stroke-opacity:" + ss.strokeOpacity ); }
		}
		if ( ss.strokeLinejoin !="miter" ) { s.push("stroke-linejoin:"+ss.strokeLinejoin); }
		if ( ss.strokeDasharray!="none"  ) { s.push("stroke-dasharray:"+ss.strokeDasharray); }

		// Text ( Font-family is hard coded in UI.canvg )
		if ( tagName === "text" ) {
			s.push( "font-size:"+ ss.fontSize );
			if ( ss.textAnchor != "start" ) { s.push( "text-anchor:" + ss.textAnchor ); }
		}
	}

	if ( s.length ) {
		element.setAttribute("stylez", s.join(";"));
	}

	for ( var i = 0; i < children.length; ++i ) {
		var c = children[i];
		if ( !c.tagName ) { continue; }
		MC.canvas.exportPNG.fixSVG( c, removeArray );
		c.removeAttribute("id");
		c.removeAttribute("class");
	}
}
