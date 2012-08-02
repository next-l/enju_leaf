// check checkbox
$(document).ready(function() {
  var $tgt_parent = $("input.check-parent");
  var $tgt_child = $("input.check-child");

  $tgt_parent.click(function(){
    $(this).parents("div.parent").find('input.check-child').attr('checked', this.checked);
  });
  $tgt_child.click(function(){
    var checkNum = $(this).parents("div.parent").find('input.check-child:checked').length;
    var listNum = $(this).parents("div.parent").find('input.check-child').length;
    if(checkNum < listNum)
      $(this).parents("div.parent").find("input.check-parent").attr('checked', false);
    if(checkNum == listNum)
      $(this).parents("div.parent").find("input.check-parent").attr('checked', true);
  });
});


// change format when push submit button
function push_submit(format) {
  var o = document.getElementById('form');
  if(format == 'pdf')
//    o.action = "<%= checkoutlists_path(:format => 'pdf') %>";
    o.action = location.pathname +  ".pdf";
  else if(format == 'tsv')
//    o.action = "<%= checkoutlists_path(:format => 'tsv') %>";
    o.action = location.pathname + ".tsv";
  else
    o.action = url;
  o.submit();
}
