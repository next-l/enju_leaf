$(function() {
  $(".content_pagination a").live("click", function() {
    $(".content_pagination").html("Page is loading...");
    $.get(this.href, null, null, "script");
    return false;
  });
  $(".sidebar_pagination a").live("click", function() {
    $(".sidebar_pagination").html("Page is loading...");
    $.get(this.href, null, null, "script");
    return false;
  });
});
