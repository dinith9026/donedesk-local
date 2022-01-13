$(function() {
  var elems = Array.prototype.slice.call(document.querySelectorAll('.is-admin-switch'));

  elems.forEach(function(html) {
    new Switchery(html, { size: 'small' });
  });
});
