class SearchController < ApplicationController

protected
  def render_search_results2
    @path.default_sort('updated_at') if @path.search_text.empty?
    @pages = Page.paginate_by_path(@path, options_for_me({:method => :sphinx}.merge(pagination_params)))

    @maps, @tags = Map.search(params)

    # if there was a text string in the search, generate extracts for the results
    if @path.search_text and @pages.any?
      begin
        add_excerpts_to_pages(@pages)
      rescue Errno::ECONNREFUSED, Riddle::VersionError, Riddle::ResponseError => err
        RAILS_DEFAULT_LOGGER.warn "failed to extract keywords from sphinx search: #{err}."
      end
    end

    full_url = search_url + @path
    handle_rss :title => full_url, :link => full_url
      # ,:image => avatar_url(:id => @user.avatar_id||0, :size => 'huge')
  end


end
