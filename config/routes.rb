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
  post '/homework', to: 'api#create'
  post '/auth', to: 'api#auth'
  post '/user', to: 'api#create_user'

  # Sockets
  mount ActionCable.server => '/cable'
end
