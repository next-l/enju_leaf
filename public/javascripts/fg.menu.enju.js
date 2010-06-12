$(function(){
  $('.fg-button').hover(
    function(){ $(this).removeClass('ui-state-default').addClass('ui-state-focus'); },
    function(){ $(this).removeClass('ui-state-focus').addClass('ui-state-default'); }
  );
  $('#fg_search').menu({ 
    content: $('#fg_search').next().html(),
    showSpeed: 100 
  });
  $('#fg_message').menu({ 
    content: $('#fg_message').next().html(),
    showSpeed: 100 
  });
  $('#fg_circulation').menu({ 
    content: $('#fg_circulation').next().html(),
    showSpeed: 100 
  });
  $('#fg_acquisition').menu({ 
    content: $('#fg_acquisition').next().html(),
    showSpeed: 100 
  });
  $('#fg_request').menu({ 
    content: $('#fg_request').next().html(),
    showSpeed: 100 
  });
  $('#fg_event').menu({ 
    content: $('#fg_event').next().html(),
    showSpeed: 100 
  });
  $('#fg_configuration').menu({ 
    content: $('#fg_configuration').next().html(),
    showSpeed: 100 
  });
});
