$(function() {
  var autocompleteSource = $('.autocomplete').data('autocomplete-source');

  $('.autocomplete').autocomplete({
    source: autocompleteSource,
    autoFocus: true
  });
});
