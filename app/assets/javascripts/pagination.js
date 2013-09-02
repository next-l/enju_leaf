$(function() {
  $(document).on("click", ".content_pagination a", function() {
    $.get(this.href, null, null, "script");
    return false;
  });
  $(document).on("click", ".sidebar_pagination a", function() {
    $.get(this.href, null, null, "script");
    return false;
  });
});
