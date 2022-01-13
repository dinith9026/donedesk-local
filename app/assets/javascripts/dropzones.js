$(function() {
	Dropzone.autoDiscover = false;
	var AUTH_TOKEN=$('meta[name="csrf-token"]').attr('content');

	if ($('#dpz-insurance-files').length) {
		var insuranceDropzone = new Dropzone('#dpz-insurance-files', {
			url: '/insurance',
			paramName: 'files',
			autoProcessQueue: false,
			addRemoveLinks: true,
			uploadMultiple: true,
			parallelUploads: 100,
			maxFiles: 10,
			params:{
				'authenticity_token': AUTH_TOKEN
			},
			init: function() {
				this.on('sending', function(file, xhr, formData) {
					// Add other fields within form to params
					formData.append('message', $('#message').val());
				});
			},
			successmultiple: function(data, response){
				$('#insurance-form').hide();
				$('#success-msg').show();
				window.scrollTo(0, 0);
			},
			errormultiple: function(data, response){
				$('#insurance-form').hide();
				$('#error-msg').show();
				window.scrollTo(0, 0);
			}
		});

		$('#insurance-form').submit(function(e){
			e.preventDefault();
			e.stopPropagation();

			if(insuranceDropzone.getQueuedFiles().length > 0){
				insuranceDropzone.processQueue();
			}
		});
	}
});
