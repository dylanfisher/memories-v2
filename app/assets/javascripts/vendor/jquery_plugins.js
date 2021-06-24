(function($) {
  // jQuery nextWrap and prevWrap selectors.
  // Usage: $('.element').nextWrap()
  $.fn.nextWrap = function( selector ) {
    var $next = $(this).next( selector );
    if ( ! $next.length ) {
      $next = $(this).parent().children( selector ).first();
    }
    return $next;
  };

  $.fn.prevWrap = function( selector ) {
    var $previous = $(this).prev( selector );
    if ( ! $previous.length ) {
      $previous = $(this).parent().children( selector ).last();
    }
    return $previous;
  };
}(jQuery));
