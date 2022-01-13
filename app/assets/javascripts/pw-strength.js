(function($) {
  $.fn.pwstrength = function(options) {

    // Establish our default settings
    var settings = $.extend({
      meterId       : null,
      textId        : null,
      suggestionsId : null,
      strengths : {
        0: "very weak",
        1: "weak",
        2: "moderate",
        3: "strong",
        4: "very strong"
      }
    }, options);

    return this.each(function() {
      var $this = $(this);

      $this.on('input', function() {
        var val = $this.val();
        var result = zxcvbn(val);

        var meter = $(settings.meterId)
        var text = $(settings.textId)
        var suggestions = $(settings.suggestionsId)

        // Update the text indicator and meter
        if(val !== "") {
          text.html(settings.strengths[result.score]);
          meter.removeClass();
          meter.addClass("strength-" + result.score);

          if(result.score < 3) {
            suggestions.html("<small>Avoid passwords that are easy to guess.</small>");
          } else {
            suggestions.html("");
          }
        }
        else {
          text.html("");
          suggestions.html("");
          meter.removeClass();
        }

      });
    });
  }

}(jQuery));

