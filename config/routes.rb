Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # show files
  get '/single/:file_id', to: 'show_file#show_single'
  get '/multi/:file_id', to: 'show_file#show_multi'
  get '/excel/:file_id', to: 'show_file#show_excel'

  # create files
  post '/single/:homework_id', to: 'create_file#create_single'
  post '/multi/:homework_id', to: 'create_file#create_multi'
  post '/excel/:homework_id', to: 'create_file#create_excel'

  # update files
  put '/single/:homework_id', to: 'update_file#update_single'
  put '/multi/:homework_id', to: 'update_file#update_multi'
  put '/excel/:homework_id', to: 'update_file#update_excel'

  # APIS
  get '/homework/:homework_id', to: 'api#show'
  patch '/homework/:homework_id', to: 'api#update'
  delete '/homework/:homework_id', to: 'api#destroy'
  get '/homework/notice/:file_id', to: 'api#show_notice_file'
  post '/homework', to: 'api#create'
  post '/auth', to: 'api#auth'
  post '/user', to: 'api#create_user'

  # Test
  post '/', to: 'api#fun'

  # Sockets
  # mount ActionCable.server, at: '/cable'
end
