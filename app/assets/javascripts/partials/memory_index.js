// Memory index

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

var initMemories = function() {
  var $newMemories = $('.memory-index__memory.not-initialized');
  var $memories = $('.memory-index__memory');

  if ( !$memories.length ) return;

  randomizeImages($newMemories);

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
}

App.pageLoad.push(function() {
  initMemories();
});

let loading = false;

$(window).on('scroll.memoriesInfiniteLoad', $.throttle(500, function() {
  const $nextPageLink = $('#next-page');
  if (!$nextPageLink.length || loading) return;

  if ( window.innerHeight + window.scrollY >= document.body.offsetHeight - window.innerHeight && !loading ) {
    loading = true;
    const nextPage = $nextPageLink.data('page');

    $.ajax({
      url: `/memories?page=${nextPage}`,
      type: 'GET',
      dataType: 'script',
      success: function() {
        initMemories();
        loading = false;
      },
      error: function() {
        loading = false;
      },
    });
  }
}));
