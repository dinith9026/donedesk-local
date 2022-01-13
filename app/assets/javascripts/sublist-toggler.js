$(function() {
  // Nested checkboxes list
  var selectedCount = $('#selected-count');

  selectedCount.html(selectedCount.data('default'));

  $('.sublist-toggler').click(function() {
    var sublist = $(this).parent().find('ul');
    sublist.toggle();

    if(sublist.is(":visible")) {
      $(this).addClass('icon-arrow-down-b');
      $(this).removeClass('icon-arrow-right-b');
    } else {
      $(this).addClass('icon-arrow-right-b');
      $(this).removeClass('icon-arrow-down-b');
    }
  });

  $('.sublist-toggler-child-option').on('click', function() {
    var parentName = $(this).data('parent');
    var parent = $('#sublist-toggler-parent-option-' + parentName);
    var employees = $('.sublist-toggler-child-option[data-parent="' + parentName + '"]');
    var checkedEmployees = employees.filter(':checked');
    var checkedCount = checkedEmployees.length;

    parent.prop('checked', checkedCount > 0);
    parent.prop('indeterminate', checkedCount > 0 && checkedCount < employees.length);
  });

  $('.sublist-toggler-parent-option').on('click', function() {
    var parentName = $(this).data('parent');
    $('.sublist-toggler-child-option[data-parent="' + parentName + '"]').prop('checked', $(this).is(':checked')).change();
  });

  $('.sublist-toggler-child-option').on('change', function() {
    var count = $('.sublist-toggler-child-option:checked').length;

    if(count > 0) {
      selectedCount.html(count + ' selected');
    } else {
      selectedCount.html(selectedCount.data('default'));
    }
  });
});
