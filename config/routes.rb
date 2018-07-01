Rails.application.routes.draw do

  scope module: :api do
    scope module: :v1 do
      get '/genres',     to: 'genres#index'
    end
  end    

end

