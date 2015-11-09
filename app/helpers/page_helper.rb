module PageHelper
  def check_all_button( param, label )
    html = <<-EOF
    <button type="button" id="check_all_#{ param }">#{ label }</button>
    <script>
      $(function(){
        $("#check_all_#{ param }").click(function(e){
          var checkboxes = $("input##{ param }");
          checkboxes.prop("checked", !checkboxes.prop("checked"));
        });
      });
    </script>
    EOF
    html.html_safe
  end
end
