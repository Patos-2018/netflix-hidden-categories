module Api
  module V1
    class GenresController < ApplicationController

      def index
        @search = Genre.search {fulltext params[:w]}
        render :json => @search.results.to_json( :only => [:name] )
      end

    end
  end
end
