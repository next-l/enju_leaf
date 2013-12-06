//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require jquery.colorbox-min
//= require jquery.highlight-3
//= require jquery.hotkeys
//= require jquery.cookie
//= require jquery.keypad
//= require fg.menu
//= require fg.menu.enju
//= require select_locale
//= require portlets
//= require tab_view
//= require event_calendar
//= require rails.validations
//= require function_key_control
//= require enju_audio_control
//= require enju_trunk
//= require jquery.spin
//= require jquery.upload-1.0.2
//= require jquery.simplecalendarjp
//= require jquery.autoKana
//= require select2

$(document).ready(function() {
  // check checkbox
  var $tgt_parent = $("input.check-parent");
  var $tgt_child = $("input.check-child");

  $tgt_parent.click(function(){
    $(this).parents("div.parent").find('input.check-child').prop('checked', this.checked);
  });
  $tgt_child.click(function(){
    var checkNum = $(this).parents("div.parent").find('input.check-child:checked').length;
    var listNum = $(this).parents("div.parent").find('input.check-child').length;
    if(checkNum < listNum)
      $(this).parents("div.parent").find("input.check-parent").prop('checked', false);
    if(checkNum == listNum)
      $(this).parents("div.parent").find("input.check-parent").prop('checked', true);
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

// clear all options for advanced search
function clear_all(){
   $('form').find("input[type=text], input[type=search]").val("");
   $('#exact_title').attr("checked", false);
   $('#exact_creator').attr("checked", false);
   $('#all_manifestations').attr("checked", false);
   $('#all_manifestation_types').attr("checked", true);
   $('#all_manifestation_types').parents("div.parent").find('input.check-child').attr('checked', true);
}
