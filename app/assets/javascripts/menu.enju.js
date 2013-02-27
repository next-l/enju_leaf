document.documentElement.className = 'hidden';

$(function(){
  $('#bar1').menubar({
    position:{
      within: $("#demo-frame").add(window).first()
    }
  });
  $('.hidden').removeClass('hidden');
});
