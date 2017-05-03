document.documentElement.className = 'hidden';

$(function(){
  $('#bar1').menubar({
    position:{
      within: $("#demo-frame").add(window).first()
    }
  });
  $('.hidden').removeClass('hidden');
});

$(document).ready(function(){
  $("#tabs").tabs();
  $('.hidden').removeClass('hidden');
});
