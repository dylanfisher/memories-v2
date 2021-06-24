// Screensaver

App.pageLoad.push(function() {
  var $el = $('#screensaver');

  if ( !$el.length ) return;

  var url = $el.attr('data-screensaver-path');
  var getImage = function() {
    $.ajax({
      url: url,
      dataType: 'script'
    }).done(function(data) {
      window.setTimeout(function() {
        getImage();
      }, 8000);
    });
  };

  getImage();
});
