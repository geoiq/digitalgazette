module DigitalGazette
  module SearchControllerExtension
    def self.included(base)
      base.instance_eval do
        skip_before_filter :login_required, :fetch_user, :login_with_http_auth
        # alias_method_chain :render_search_results, :digitalgazette
      end
    end

    # def render_search_results_with_digitalgazette
    #   @path.default_sort('updated_at') if @path.search_text.empty?
    #   @pages = Page.paginate_by_path(@path, options_for_me({:method => :sphinx}.merge(pagination_params)))

    #   # if there was a text string in the search, generate extracts for the results
    #   if @path.search_text and @pages.any?
    #     begin
    #       add_excerpts_to_pages(@pages)
    #     rescue Errno::ECONNREFUSED, Riddle::VersionError, Riddle::ResponseError => err
    #       RAILS_DEFAULT_LOGGER.warn "failed to extract keywords from sphinx search: #{err}."
    #     end
    #   end

    #   full_url = search_url + @path
    #   handle_rss(:title => full_url, :link => full_url,
    #              :image => (@user ? avatar_url(:id => @user.avatar_id||0, :size => 'huge') : nil))
    # end
  end
end
