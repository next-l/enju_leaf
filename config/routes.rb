Rails.application.routes.draw do
  root :to => "page#index"

  get '/page/about' => 'page#about'
  get '/page/configuration' => 'page#configuration'
  get '/page/advanced_search' => 'page#advanced_search'
  get '/page/add_on' => 'page#add_on'
  get '/page/export' => 'page#export'
  get '/page/import' => 'page#import'
  get '/page/msie_accelerator' => 'page#msie_accelerator'
  get '/page/opensearch' => 'page#opensearch'
  get '/page/statistics' => 'page#statistics'
  get '/page/system_information' => 'page#system_information'
  get '/page/routing_error' => 'page#routing_error'
end
