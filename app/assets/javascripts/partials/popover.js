// Popover

$(document).on('click', '#open-popover', function() {
  var $popover = $('#help-popover');

  App.$body.addClass('is-viewing-popover');

  $popover.removeClass('d-none');

  $(document).on('click.popoverCloser', function(e) {
    var $target = $(e.target);
    var $popover = $('#help-popover');

    if ( $target.closest('.popover__inner').length && !$target.closest('.popover__close').length ) return;

    App.$body.removeClass('is-viewing-popover');

    $popover.addClass('d-none');

    $(document).off('click.popoverCloser');
  });
});
