module Api
  module V1
    class GenresController < ApplicationController

      def index
        @search = Genre.search {fulltext params[:w]}
        render :json => @search.results
      end

    end
  end
end
