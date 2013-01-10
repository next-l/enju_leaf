$(function(){
  function select(event, ui) {
    $("<div/>").text("Selected: " + ui.item.text()).appendTo("#log");
    if (ui.item.text() == 'Quit') {
      $(this).menubar('destroy');
    }
  }
  $('#bar1').menubar({
    position:{
      within: $("#demo-frame").add(window).first()
    }
  });
});
