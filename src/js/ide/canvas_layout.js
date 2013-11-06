
// [ Warning!!!! ] DEAD CODE
// This source code is dead. listen() / ready() / connect() seems like doing nothing.
// But it pollutes the window object. Which makes it un-removable !!!!
// Dom Ready
var listen = function ()
{
	var canvas_state = MC.canvas.getState(),
		canvas_container = $('#canvas_container'),
		name_space = '.CANVAS_EVENT';

	MC.paper = Canvon('#svg_canvas');

	canvas_container
		.off(name_space)
		.removeClass('canvas_state_app canvas_state_appedit canvas_state_stack');

	if (canvas_state === 'app')
	{
		canvas_container
			.addClass('canvas_state_' + canvas_state)
			.on('click' + name_space, '.line', MC.canvas.event.selectLine)
			.on('mousedown' + name_space, MC.canvas.event.clearSelected)
			.on('mousedown' + name_space, '#svg_canvas', MC.canvas.event.clickBlank)
			.on('mouseenter'  + name_space + ' mouseleave'  + name_space, '.node', MC.canvas.event.nodeHover)
			.on('selectstart' + name_space, returnFalse)
			.on('mousedown' + name_space, '.dragable', MC.canvas.event.selectNode)
			.on('mousedown' + name_space, '.AWS-AutoScaling-LaunchConfiguration .instance-number-group', MC.canvas.asgList.show)
			.on('mousedown' + name_space, '.AWS-EC2-Instance .instance-number-group', MC.canvas.instanceList.show)
			.on('mousedown' + name_space, '.AWS-VPC-NetworkInterface .eni-number-group', MC.canvas.eniList.show)
			.on('mousedown' + name_space, MC.canvas.event.ctrlMove.mousedown);
	}

	if (canvas_state === 'appedit')
	{
		canvas_container
			.addClass('canvas_state_' + canvas_state)
			.on('mousedown' + name_space, '.instance-volume, .instanceList-item-volume', MC.canvas.volume.show)
			.on('mousedown' + name_space, '.port', MC.canvas.event.appDrawConnection)
			.on('mousedown' + name_space, '.dragable', MC.canvas.event.dragable.mousedown)
			.on('mousedown' + name_space, '.group-resizer', MC.canvas.event.groupResize.mousedown)
			.on('click' + name_space, '.line', MC.canvas.event.selectLine)
			.on('mousedown' + name_space, MC.canvas.event.clearSelected)
			.on('mousedown' + name_space, '#svg_canvas', MC.canvas.event.clickBlank)
			.on('mouseenter'  + name_space + ' mouseleave'  + name_space, '.node', MC.canvas.event.nodeHover)
			.on('selectstart' + name_space, returnFalse)
			.on('mousedown' + name_space, MC.canvas.event.ctrlMove.mousedown);
	}

	if (canvas_state === 'stack')
	{
		canvas_container
			.addClass('canvas_state_' + canvas_state)
			.on('mousedown' + name_space, '.port', MC.canvas.event.drawConnection.mousedown)
			.on('mousedown' + name_space, '.dragable', MC.canvas.event.dragable.mousedown)
			.on('mousedown' + name_space, '.group-resizer', MC.canvas.event.groupResize.mousedown)
			.on('mouseenter'  + name_space + ' mouseleave'  + name_space, '.node', MC.canvas.event.nodeHover)
			.on('click' + name_space, '.line', MC.canvas.event.selectLine)
			.on('mousedown' + name_space, MC.canvas.event.clearSelected)
			.on('mousedown' + name_space, '#svg_canvas', MC.canvas.event.clickBlank)
			.on('selectstart' + name_space, returnFalse)
			.on('mousedown' + name_space, MC.canvas.event.ctrlMove.mousedown);
	}

	$('#tab-content-design').on('click', '#canvas-panel, #resource-panel', MC.canvas.volume.close);
};

// Dom Ready
var canvas_initialize = function ()
{
	$(document).on('keydown', MC.canvas.event.keyEvent);

	$('#header, #navigation, #tab-bar').on('click', MC.canvas.volume.close);

	$('#tab-content-design').on('mousedown', '.resource-item', MC.canvas.event.siderbarDrag.mousedown);

	$(document.body)
		.on('mousedown', '#instance_volume_list a', MC.canvas.volume.mousedown);

};

// Dom Ready
var connect = function ()
{

};

define( ['jquery'], function() {
	return {
		'listen'     : listen,
		'canvas_initialize' : canvas_initialize,
		'connect'    : connect
	};
});
