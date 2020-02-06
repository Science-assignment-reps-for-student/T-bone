Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # Files
  get '/file/:file_id', to: 'file#showOne'
  get '/files:homework_id', to: 'file#showMany'
  post '/file/:homework_id', to: 'file#create'
  get '/excel/:homework_id', to: 'file#showExcel'
  post '/excel/:homework_id', to: 'file#createExcel'

  # APIS
  get '/homework/:homework_id', to: 'api#show'
  patch '/homework/:homework_id', to: 'api#update'
  get '/homework/notice-file/:file_id', to: 'api#show_notice_file'
  post '/homework', to: 'api#create'
  post '/auth', to: 'api#auth'
  post '/user', to: 'api#create_user'

  # Test
  post '/', to: 'api#fun'

  # Sockets
  mount ActionCable.server, at: '/cable'
end
