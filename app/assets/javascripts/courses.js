$(function() {

  // "Continue to exam" modal / Prevent video seeking
  var video = $('#video-material');
  var previousTime = 0;

  if (video) {
    if (video.data('show-continue-modal')) {
      video.bind('ended', function (evt) {
        $('#continue-modal').modal('show');
      });
    }

    if (video.data('prevent-fwd-seeking')) {
      video.bind('timeupdate', function (evt) {
        var v = document.getElementById('video-material');

        if (!v.seeking) {
          previousTime = Math.max(previousTime, v.currentTime);
        }
      });

      video.bind('seeking', function (evt) {
        var v = document.getElementById('video-material');

        if (v.currentTime > previousTime) {
          v.currentTime = previousTime;
        }
      });
    }
  }

  // Direct-to-S3 upload for course material
  $('.direct-upload').find('input:file').each(function(i, elem) {
    var fileInput     = $(elem);
    var form          = $(fileInput.parents('form:first'));
    var submitButton  = form.find(':submit');
    var progressBar  = $('#course-material-progress-bar');
    var barContainer = $('#course-material-progress-bar-container');
    var barCaption    = $('#course-material-progress-bar-caption');
    var successMsg    = $('#course-material-upload-success');
    var filenameMsg   = $('#course-material-filename');
    var s3KeyField    = $('#course_material_s3_key');
    var formData      = form.data('material-form-data');

    // Disable Save button if we don't have an uploaded file yet
    if (!s3KeyField.val()) {
      submitButton.prop('disabled', true);
    }

    barContainer.hide();

    if (filenameMsg.text().length == 0) {
      successMsg.hide();
    }

    fileInput.fileupload({
      fileInput:       fileInput,
      url:             form.data('material-presigned-post-url'),
      type:            'POST',
      autoUpload:       true,
      formData:         formData,
      paramName:        'file', // S3 does not like nested name fields i.e. name="user[avatar_url]"
      dataType:         'XML',  // S3 returns XML if success_action_status is set to 201
      replaceFileInput: false,
      progressall: function (e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        progressBar.val(progress);
      },
      add: function (e, data) {
        formData["Content-Type"] = data.files[0].type;
        data.formData = formData
        data.submit();
      },
      start: function (e) {
        barContainer.show();
        fileInput.hide();
      },
      done: function(e, data) {
        submitButton.prop('disabled', false);

        // extract key and generate URL from response
        var key = $(data.jqXHR.responseXML).find("Key").text();

        filename = key.substring(key.lastIndexOf('/')+1);
        barCaption.text('Uploaded ' + filename);

        s3KeyField.val(key)
        barContainer.hide();
        successMsg.show();
        filenameMsg.text(filename);
      },
      fail: function(e, data) {
        fileInput.show();
        fileInput.val('');
        barCaption.html('<span class="text-danger">Failed. Please wait a few minutes and try again.');
      }
    });
  });

  $('.direct-upload').on('submit', function(e){
    $('#course_material').remove();
  });
});
