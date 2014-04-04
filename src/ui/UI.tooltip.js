/*
#**********************************************************
#* Filename: UI.tooltip
#* Creator: Angel
#* Description: UI.tooltip
#* Date: 20140115
# **********************************************************
# (c) Copyright 2014 Madeiracloud  All Rights Reserved
# **********************************************************
*/

define(["jquery"], function(){


(function ()
{
	var tooltip = function (event)
	{
		var target = $(this),
			content = $.trim(target.data('tooltip')),
			tooltip_box = $('#tooltip_box'),
			docElem = document.documentElement,
			target_offset,
			width,
			height,
			target_width,
			target_height,
			tooltip_timer;

		if (content !== '' && !target.hasClass('parsley-error'))
		{
			if (!tooltip_box[0])
			{
				$(document.body).append('<div id="tooltip_box"></div>');
				tooltip_box = $('#tooltip_box');
			}

			tooltip_box.text(content).show();

			if (target.prop('namespaceURI') === 'http://www.w3.org/2000/svg')
			{
				target_offset = target[0].getBoundingClientRect();
				target_width = target_offset.width;
				target_height = target_offset.height;
			}
			else
			{
				target_offset = target.offset();
				target_width = target.innerWidth();
				target_height = target.innerHeight();
			}

			width = tooltip_box.width();
			height = tooltip_box.height();

			tooltip_box.css({
				'left': target_offset.left + target_width + width - docElem.scrollLeft > window.innerWidth ?
					target_offset.left + target_width - width - 20 :
					target_offset.left + 5,
				'top': target_offset.top + target_height + height - docElem.scrollTop + 45 > window.innerHeight ?
					target_offset.top - height - 15 :
					target_offset.top + target_height + 8
			});

			$(document.body).on('mouseleave', '.tooltip', tooltip.clear);

			tooltip.timer.push(
				setInterval(function ()
				{
					if (target.closest('html').length === 0)
					{
						tooltip.clear();
					}
				}, 1000)
			);
		}

		return true;
	};

	tooltip.timer = [],

	tooltip.clear = function ()
	{
		$(document.body).off('mouseleave', '.tooltip', tooltip.clear);
		$('#tooltip_box').remove();

		$.each(tooltip.timer, function (index, timer)
		{
			clearInterval(timer);
		});

		return false;
	};

	$(document).ready(function ()
	{
		$(document.body).on('mouseenter', '.tooltip', tooltip);
	});
})();

});
