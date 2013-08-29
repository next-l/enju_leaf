$(function() {
  $(".content_pagination a").on("click", function() {
    $.get(this.href, null, null, "script");
    return false;
  });
  $(".sidebar_pagination a").on("click", function() {
    $.get(this.href, null, null, "script");
    return false;
  });
});
