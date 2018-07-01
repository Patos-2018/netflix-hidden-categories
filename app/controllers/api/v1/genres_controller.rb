module Api
  module V1
    class GenresController < ApplicationController

      def index
        @genres = Genre.all
        render :json => @genres.to_json
      end

    end
  end
end
