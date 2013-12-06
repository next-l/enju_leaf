module NacsisUserRequestsHelper

  def request_type_facet(request_type, current_request_types, facet)
    string = ''
    current = true if current_request_types.include?(request_type)
    string << "<strong>" if current
    string << link_to("#{t('activerecord.attributes.nacsis_user_request.request_type_names')[request_type.request_type]} (" + facet.count.to_s + ")", url_for(params.merge(:page => nil, :request_type => request_type.request_type, :view => nil)))
    string << "</strong>" if current
    string.html_safe
  end

  def state_facet(state, current_states, facet)
    string = ''
    current = true if current_states.include?(state)
    string << "<strong>" if current
    string << link_to("#{t('activerecord.attributes.nacsis_user_request.state_names')[state.state]} (" + facet.count.to_s + ")", url_for(params.merge(:page => nil, :state => state.state, :view => nil)))
    string << "</strong>" if current
    string.html_safe
  end

end
