module Api
  module V1
    class GenresController < ApplicationController

      def index
        @search = Genre.search do
          fulltext params[:w]
          paginate page: 1, per_page: params[:limit]
          if params[:sort_by] == 'abc'
            order_by :sort_title
          end
        end
        render :json => @search.results.to_json( )
      end

    end
  end
end
