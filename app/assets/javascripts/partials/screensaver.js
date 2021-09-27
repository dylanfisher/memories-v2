// Screensaver

App.pageLoad.push(function() {
  var $el = $('#screensaver');

  if ( !$el.length ) return;

  var timer;
  var url = $el.attr('data-screensaver-path');
  var duration = parseInt( App.getParameterByName('duration') ) || 8000;
  var skipAutoplay = App.getParameterByName('autoplay');
  var getImage = function() {
    $.ajax({
      url: url,
      dataType: 'script'
    }).done(function(data) {
      if ( !skipAutoplay ) {
        timer = window.setTimeout(function() {
          getImage();
        }, duration);
      }
    });
  };

  getImage();

  $(document).on('click', function() {
    if ( timer ) window.clearTimeout(timer);
    getImage();
  });

  $(document).on('keyup', function(e) {
    // Space key
    if ( e.keyCode == 32 ) {
      if ( timer ) window.clearTimeout(timer);
      getImage();
    }
  });
});
