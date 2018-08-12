module Api
  module V1
    class GenresController < ApplicationController

      def index
        @search = Genre.search do
          fulltext params[:w]
          paginate page: 1, per_page: params[:limit]
          if params[:sort_by] == 'abc'
            order_by :sort_title
          elsif params[:sort_by] == 'nTitles'
            order_by :netflix_titles_count, :desc
          end
        end

        if params[:titles_q] == 'true'
          fields = { only: [:name, :id, :uri, :netflix_titles_count] }
        else
          fields = { only: [:name, :id, :uri] }
        end

        render :json => @search.results.to_json( fields )
      end

    end
  end
end
