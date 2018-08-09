Rails.application.routes.draw do

  scope module: :api do
    scope module: :v1 do
      get '/genres',     to: 'genres#index'
      get '/movies',     to: 'movies#index'
    end
  end    

end

