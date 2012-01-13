$(function() {
  $(".content_pagination a").live("click", function() {
    $.get(this.href, null, null, "script");
    return false;
  });
  $(".sidebar_pagination a").live("click", function() {
    $.get(this.href, null, null, "script");
    return false;
  });
});
