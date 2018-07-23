module Api
  module V1
    class GenresController < ApplicationController

      def index
        @search = Genre.search do
          fulltext params[:w]
          paginate page: 1, per_page: params[:limit]
        end
        render :json => @search.results.to_json( :only => [:name] )
      end

    end
  end
end
