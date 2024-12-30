// Memory show

App.pageLoad.push(function() {
  var $mediaItems = $('.media-item');
  var mediaItemCount = $mediaItems.length;
  var $activeItem;
  var index = 0;

  $mediaItems.first().addClass('active');

  $(document).off('keydown.memoryShow');
  $(document).on('keydown.memoryShow', function(e) {
    if ( e.which != 37 && e.which != 39 ) return;

    if ( e.which == 37 ) {
      // left key
      index -= 1;
      index = Math.max(0, index);
    } else if ( e.which == 39 ) {
      // right key
      index += 1;
      index = Math.min(mediaItemCount - 1, index);
    }

    $activeItem = $mediaItems.eq(index);

    if ( $activeItem && $activeItem.length ) {
      window.scrollTo(0, $activeItem.offset().top);
    }
  });

  if ( App.$html.hasClass('controller--memories action--show') ) {
    lazySizesConfig.expFactor = 10;
  }
});
