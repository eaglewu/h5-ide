/*
#**********************************************************
#* Filename: UI.modal
#* Creator: Angel
#* Description: UI.modal
#* Date: 20140213
# **********************************************************
# (c) Copyright 2014 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var modal = function (template, dismiss, callback, options)
{
	var modal_wrap = $('#modal-wrap');

	if (!modal_wrap[0])
	{
		$(document.body).append('<div id="modal-wrap"></div>');
		modal_wrap = $('#modal-wrap');
	}

	if (options && options.opacity)
	{
		modal_wrap.css('background-color', 'rgba(0, 0, 0, ' + options.opacity + ')');
	}

	modal_wrap.html('<div id="modal-box">' + template + '</div>');

	$('#modal-box').children(':first').show();

	modal.position();

	if (dismiss === true)
	{
		$("#modal-wrap")
			.on('click', modal.dismiss);
		$(document)
			.on('keyup', modal.keyup);
	}

	$(window).on('resize', modal.position);

	// $('#wrapper').addClass('blur-effect');

	$("#modal-box")
		.on('click', '.modal-close', modal.close)
		.on('mousedown', '.modal-header', {'options': options}, modal.drag.mousedown);

	if (callback)
	{
		callback();
	}

	return true;
};

modal.open = function (event)
{
	var target = $(this),
		target_template = target.data('modal-template'),
		target_data = target.data('modal-data');

	if (target_template && target_data)
	{
		modal(
			MC.template[ target_template ]( target_data ),
			target.data('modal-dismiss')
		);
		target.trigger('modal-shown');

		$('#modal-wrap').one('closed', function ()
		{
			target.trigger('modal-closed');
		});
	}

	return true;
};

modal.keyup = function (event)
{
	if (event.which === 27)
	{
		modal.close();
	}

	// else if ( event.which == 13 ) {
	// 	var btns = $("#modal-wrap").find(".modal-footer").find(".btn").filter(":not(.btn-silver,.modal-close)")
	// 	if ( btns.length == 1 ) {
	// 		btns.click()
	// 	}
	// }

	return false;
};

modal.dismiss = function (event)
{
	if (event.target.id === 'modal-wrap')
	{
		modal.close();
	}
};

modal.close = function ( evt )
{
	$(window).off('resize', modal.position);

	// $('#wrapper').removeClass('blur-effect');

	$(document).off('keyup', modal.keyup);
	// 	.off('click', '.modal-close', modal.close)
	// 	.off('mousedown', '.modal-header', modal.drag.mousedown)
	// 	.off('click', modal.dismiss)

	$('#modal-wrap')
		.trigger('closed')
		.remove();

	if ( evt && evt.target.tagName === "A" && evt.preventDefault ) {
		evt.preventDefault();
	}
};

modal.isPopup = function ()
{
	// if ($('#modal-box').html() === void 0) {
	// 	return false;
	// } else {
	// 	return true;
	// }
	return $('#modal-box').html() !== void 0
};

modal.drag = {
	mousedown: function (event)
	{
		var target = $('#modal-box'),
			target_position = target.position();

		$(document).on({
			'mousemove': modal.drag.mousemove,
			'mouseup': modal.drag.mouseup
		}, {
			'target': target,
			'left': event.pageX - target_position.left,
			'top': event.pageY - target_position.top,
			'options': event.data.options
		});

		event.preventDefault();
		// return false;
	},

	mousemove: function (event)
	{
		event.data.target.css({
			'top': event.pageY - event.data.top,
			'left': event.pageX - event.data.left
		});

		return false;
	},

	mouseup: function (event)
	{
		var target = event.data.target,
			options = event.data.options,
			position = target.position(),
			height = target.height(),
			width = target.width(),
			prop = {};

		if (options && options.conflict === 'loose')
		{
			if (position.top < 0)
			{
				prop['top'] = 10;
			}

			if (position.left < -width * 0.8)
			{
				prop['left'] = 10;
			}

			if (position.top > window.innerHeight - height + (height * 0.7))
			{
				prop['top'] = window.innerHeight - height - 10;
			}

			if (position.left > window.innerWidth - width + (width * 0.8))
			{
				prop['left'] = window.innerWidth - width - 25;
			}
		}
		else
		{
			if (position.top < 0)
			{
				prop['top'] = 10;
			}

			if (position.left < 0)
			{
				prop['left'] = 10;
			}

			if (position.top > window.innerHeight - height)
			{
				prop['top'] = window.innerHeight - height - 10;
			}

			if (position.left > window.innerWidth - width)
			{
				prop['left'] = window.innerWidth - width - 25;
			}
		}

		if (!$.isEmptyObject(prop))
		{
			target.animate(prop, 300);
		}

		$(document).off({
			'mousemove': modal.drag.mousemove,
			'mouseup': modal.drag.mouseup
		});

		return false;
	}
};

modal.position = function ()
{
	var modal_box = $('#modal-box');

	modal_box.css({
		'top': (window.innerHeight - modal_box.height()) / 2,
		'left': (window.innerWidth - modal_box.width()) / 2
	});

	return true;
};

$(document).ready(function ()
{
	$(document).on('click', '.modal', modal.open);
});
