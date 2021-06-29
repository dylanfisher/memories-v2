// Screensaver

App.pageLoad.push(function() {
  var $el = $('#screensaver');

  if ( !$el.length ) return;

  var timer;
  var url = $el.attr('data-screensaver-path');
  var getImage = function() {
    $.ajax({
      url: url,
      dataType: 'script'
    }).done(function(data) {
      timer = window.setTimeout(function() {
        getImage();
      }, 8000);
    });
  };

  getImage();

  $(document).on('click', function() {
    if ( timer ) window.clearTimeout(timer);
    getImage();
  });

  $(document).on('keyup', function(e) {
    if ( timer ) window.clearTimeout(timer);
    getImage();
  });
});
