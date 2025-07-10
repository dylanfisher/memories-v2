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

document.addEventListener("DOMContentLoaded", () => {
  const button = document.getElementById("generate_shared_link");
  const input  = document.getElementById("shared_link_input");
  if (!button || !input) return;

  button.addEventListener("click", () => {
    // create 16 random bytes → 32-char hex string
    const bytes = new Uint8Array(32);
    window.crypto.getRandomValues(bytes);
    const hex = Array.from(bytes)
      .map(b => b.toString(32).padStart(2, "0"))
      .join("");
    input.value = hex;
  });
});
