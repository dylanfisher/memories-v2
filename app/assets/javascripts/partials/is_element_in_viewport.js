// Check if any part of an element is in viewport
// https://gist.github.com/davidtheclark/5515733

App.inViewport = function(el) {
  el = (el instanceof jQuery) ? el.get(0) : el;

  var rect = el.getBoundingClientRect();
  var windowHeight = (window.innerHeight || document.documentElement.clientHeight);
  var windowWidth = (window.innerWidth || document.documentElement.clientWidth);

  // http://stackoverflow.com/questions/325933/determine-whether-two-date-ranges-overlap
  var vertInView = (rect.top <= windowHeight) && ((rect.top + rect.height) >= 0);
  var horInView = (rect.left <= windowWidth) && ((rect.left + rect.width) >= 0);

  return (vertInView && horInView);
}
