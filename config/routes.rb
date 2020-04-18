Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  scope(path: '/t-bone') do
    # show files
    get '/single/:file_id', to: 'show_file#show_single'
    get '/multi/:file_id', to: 'show_file#show_multi'
    get '/excel/:homework_id', to: 'show_file#show_excel'
    get '/image/:file_id', to: 'show_file#show_image'
    get '/notice/:file_id', to: 'show_file#show_notice'
    get '/file-zip/:homework_id', to: 'show_file#show_many'

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
    post '/homework', to: 'api#create'
    get '/files/:homework_id', to: 'api#show_files'

    # SideKiq
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'

    # Boards
    resources :board, controller: :boards, param: :board_id

    # Comments
    resources :comment, controller: :comments, param: :board_id, only: %i[show create]
    resources :comment, controller: :comments, param: :comment_id, only: :destroy

    resources :cocomment, controller: :cocomments, param: :comment_id, only: %i[show create]
    resources :cocomment, controller: :cocomments, param: :cocomment_id, only: :destroy

    # mail
    post '/email', to: 'api#email'
  end
end
