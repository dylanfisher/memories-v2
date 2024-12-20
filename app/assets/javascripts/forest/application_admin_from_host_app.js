$(document).on('click', '.media-item--grid__button__hide-from-public', function() {
  var $item = $(this);
  var url = $item.attr('data-hide-from-public-path');

  $.ajax({
    url: url,
    type: 'POST',
    dataType: 'script',
    success: function(data) {
      // console.log('data', data);
    },
    error: function(xhr, status, error) {
      console.warn('Error hiding media item from public', xhr.responseText, error);
    },
  });
});
