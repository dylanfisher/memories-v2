// Image sequence block

(function() {
  var $blocks = [];

  var clearTimer = function($slide) {
    if ( $slide.data('timer') ) window.clearTimeout( $slide.data('timer') );
  };

  var animate = function($slide, duration) {
    var $next = $slide.nextWrap();

    $slide.removeClass('active');
    $next.addClass('active');

    $slide.data('timer', window.setTimeout(function() {
      animate($next, duration);
    }, duration));
  };

  var init = function($block) {
    if ( $block.data('paused') ) return;

    $block.data('destroyed', false).data('paused', true);

    var $slides = $block.find('.image-sequence-block__image');
    var duration = parseInt( $block.attr('data-duration') );

    if ( $slides.length < 2 ) return;

    animate($slides.filter('.active'), duration);
  };

  var destroy = function($block) {
    if ( $block.data('destroyed') ) return;

    $block.data('destroyed', true);

    pause($block);
  };

  var pause = function($block) {
    $block.data('paused', false)
          .find('.image-sequence-block__image')
          .each(function() {
            clearTimer( $(this) );
          });
  }

  App.pageLoad.push(function() {
    $blocks = $('.image-sequence-block__images');

    $blocks.each(function() {
      var $block = $(this);

      init($block);
    });
  });

  App.pageScrollThrottled.push(function() {
    if ( !$blocks.length ) return;


    $blocks.each(function() {
      var $block = $(this);

      if ( App.inViewport( $block ) ) {
        init($block);
      } else {
        pause($block);
      }
    });
  });
})();
