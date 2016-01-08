$(document).ready(function(){
  $("#tabs").tabs();
  $('#bar1').menubar({
    position:{
      within: $("#demo-frame").add(window).first()
    }
  });
  $('.hidden').removeClass('hidden');
});
