// Lazy load content

$(function() {
  var $els = $('.lazy-content');

  $els.each(function() {
    var $el = $(this);

    $el.hide().after($el.attr('data-lazy-content'));
  });
});
