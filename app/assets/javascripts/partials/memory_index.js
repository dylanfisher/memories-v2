// Memory index

App.pageLoad.push(function() {
  var $memories = $('.memory-index__memory');

  if ( !$memories.length ) return;

  var getRandom = function(arr, n) {
    var result = new Array(n);
    var len = arr.length;
    var taken = new Array(len);
    if (n > len)
      throw new RangeError("getRandom: more elements taken than available");
    while (n--) {
      var x = Math.floor(Math.random() * len);
      result[n] = arr[x in taken ? taken[x] : x];
      taken[x] = --len in taken ? taken[len] : len;
    }
    return result;
  };

  var randomizeImages = function($elements) {
    $elements.each(function() {
      var $memory = $(this);
      var $previewArea = $memory.find('.memory-index__preview-area');
      var allUrls = JSON.parse( $memory.attr('data-image-urls') );
      var urls = getRandom(allUrls, Math.min(6, allUrls.length));
      var newElements = [];

      for (var i = urls.length - 1; i >= 0; i--) {
        newElements.push('<div class="col-4 col-md-2 ' + (i < 3 ? 'mt-2 mt-md-0' : '') + '"><div class="memory-index__image background-image landscape-image lazy-image lazy-image--background lazyload" data-bg="' + urls[i] + '"></div></div>');
      }

      $previewArea.html(newElements);
    });
  };

  randomizeImages($memories);

  $(document).off('keypress.memoryIndex');
  $(document).on('keypress.memoryIndex', function(e) {
    if ( e.which == 114 ) {
      // "r" key was pressed
      $memories.each(function() {
        var $memory = $(this);

        if ( App.inViewport($memory) ) {
          randomizeImages($memory);
        }
      });
    }
  });
});
