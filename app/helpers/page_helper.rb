module PageHelper
  def check_all_button( param, label, checked = true )
    func_name = "check_all"
    func_name = "un" + func_name if checked == false
    html = <<-EOF
    <button id="#{ func_name }_#{ param }">#{ label }</button>
    <script>
      $(function(){
        $("##{ func_name }_#{ param }").click(function(){
          $("input##{ param }").prop("checked", #{ checked });
	  return false;
        });
      });
    </script>
    EOF
    html.html_safe
  end
  def uncheck_all_button( param, label )
    check_all_button( param, label, false )
  end
end
