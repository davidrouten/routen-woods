module Admin
  class SearchController < BaseController
    def index
      results = GlobalSearch.new(params[:q]).results
      render json: results
    end
  end
end
