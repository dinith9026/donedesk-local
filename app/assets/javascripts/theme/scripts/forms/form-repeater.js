/*=========================================================================================
		File Name: form-repeater.js
		Description: Repeat forms or form fields
		----------------------------------------------------------------------------------------
		Item Name: Robust - Responsive Admin Theme
		Version: 1.2
		Author: PIXINVENT
		Author URL: http://www.themeforest.net/user/pixinvent
==========================================================================================*/

(function(window, document, $) {
	'use strict';

	jQuery(function($) {
		// Default
		$('.repeater-default').repeater({
			isFirstItemUndeletable: true
		});

		// Custom Show / Hide Configurations
		$('.file-repeater, .contact-repeater').repeater({
			show: function () {
				$(this).slideDown();
			},
			hide: function(remove) {
				if (confirm('Are you sure you want to remove this item?')) {
					$(this).slideUp(remove);
				}
			}
		});
	});

})(window, document, jQuery);
