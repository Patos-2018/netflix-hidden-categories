module Api
  module V1
    class MoviesController < ApplicationController

      def index
        @search = NetflixTitle.search do
          fulltext params[:w]
        end

        if params[:titles_q] == 'true'
          fields = { only: [:name, :id, :uri, :netflix_titles_count] }
        else
          fields = { only: [:name, :id, :uri] }
        end
        
        page_limit = Integer(params[:limit]) - 1
        render :json => @search.results[0].genres[0..page_limit].to_json( fields )
      end

    end
  end
end
