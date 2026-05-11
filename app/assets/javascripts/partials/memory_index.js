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

var visibleMemories = new Set();
var memoryObserver;

var initMemoryObserver = function() {
  if (memoryObserver || !('IntersectionObserver' in window)) return;

  memoryObserver = new IntersectionObserver(function(entries) {
    entries.forEach(function(entry) {
      if (entry.isIntersecting) {
        visibleMemories.add(entry.target);
      } else {
        visibleMemories.delete(entry.target);
      }
    });
  });
};

var observeMemories = function($memories) {
  if (!memoryObserver) return;

  $memories.each(function() {
    memoryObserver.observe(this);
  });
};

var visibleMemoryElements = function($memories) {
  if (memoryObserver) {
    return $(Array.from(visibleMemories));
  }

  return $memories.filter(function() {
    return App.inViewport(this);
  });
};

var initMemories = function() {
  initMemoryObserver();

  var $newMemories = $('.memory-index__memory.not-initialized');
  var $memories = $('.memory-index__memory');

  if ( !$memories.length ) return;

  randomizeImages($newMemories);
  observeMemories($newMemories);
  $newMemories.removeClass('not-initialized');

  $(document).off('keypress.memoryIndex');
  $(document).on('keypress.memoryIndex', function(e) {
    if ( e.which == 114 ) {
      // "r" key was pressed
      randomizeImages(visibleMemoryElements($('.memory-index__memory')));
    }
  });
}

App.pageLoad.push(function() {
  initMemories();
  loadNextMemoryPage();
});

let loading = false;

var nextMemoryPageUrl = function(nextPage) {
  var params = new URLSearchParams(window.location.search);
  params.set('page', nextPage);
  return window.location.pathname + '?' + params.toString();
};

var loadNextMemoryPage = function() {
  const $nextPageLink = $('#next-page');
  if (!$nextPageLink.length || loading) return;

  loading = true;
  const nextPage = $nextPageLink.data('page');

  $.ajax({
    url: nextMemoryPageUrl(nextPage),
    type: 'GET',
    dataType: 'script',
    cache: true,
    success: function() {
      initMemories();
      loading = false;
      loadNextMemoryPage();
    },
    error: function() {
      loading = false;
    },
  });
};
