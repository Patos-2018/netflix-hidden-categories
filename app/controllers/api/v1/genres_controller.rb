module Api
  module V1
    class GenresController < ApplicationController

      def index
        @search = Genre.search do
          fulltext params[:w]
          paginate page: 1, per_page: params[:limit]
        end
        show_fields = { only: [:name] }
        if params[:titles_q] == 'true'
          show_fields = { only: [:name, :id] }
        end

        render :json => @search.results.to_json( show_fields )
      end

    end
  end
end
