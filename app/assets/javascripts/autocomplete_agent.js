$(document).ready(function(){
  $("#hoge").on('cocoon:after-insert', function(e, added_task){
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
        }
      }).data("ui-autocomplete")._renderItem = function(ul, item) {
        return $( "<li>" )
          .append( "<a>" + item.label + "<br>" + item.desc + "</a>" )
          .appendTo(ul);
      };
    });
  });
});
