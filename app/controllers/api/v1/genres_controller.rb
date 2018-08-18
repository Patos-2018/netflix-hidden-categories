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

          if params[:active_genres] == 'true'
            with(:netflix_titles_count).greater_than 0
          end
        end

        fields = if params[:titles_q] == 'true'
                   { only: %i[name id uri netflix_titles_count] }
                 else
                   { only: %i[name id uri] }
                 end

        render json: @search.results.to_json(fields)
      end
    end
  end
end
