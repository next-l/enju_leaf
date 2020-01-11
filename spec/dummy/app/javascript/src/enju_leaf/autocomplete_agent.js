$(document).ready(function(){
  $("#creator_form").on('cocoon:after-insert', function(e, added_task){
    $('.creator_full_name').focus(function(){
      $(this).autocomplete({
        minLength: 1,
        //source: '/agents.json'
        source: function(request, response){
          $.ajax({
            url: '/agents.json',
            datatype: 'json',
            data: {
              query: request.term + '*'
            },
            success: function(data) {
              response(data);
            }
          });
        },
        select: function(event, ui){
          //console.log(added_task[0].getElementsByTagName('input')[0]);
          added_task[0].getElementsByTagName('input')[0].value = ui.item.agent_id;
        }
      }).data("ui-autocomplete")._renderItem = function(ul, item) {
        return $( "<li>" )
          .append( "<a>" + item.label + "<br>" + item.desc + "</a>" )
          .appendTo(ul);
      };
    });
  });
});
