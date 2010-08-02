class MapPage < Page
  acts_as_solr

  def self.get_solr_find_condition_by_user_or_uploader(params)
    conditions = {}
    if params[:user_login]
      conditions.merge! :user_login => params[:user_login]
    end
    # conditions.merge! :groups => (logged_in? ? current_user.get_all_group_ids : [Configuration.everyman_group] )
    conditions
  end
  BBOX_REGEX = /bbox:([\d.,-]+)/
  def self.extract_in(query)
    bbox_match = BBOX_REGEX.match(query)
    if bbox_match
      query = query.gsub(BBOX_REGEX, '')
      bbox = bbox_match[1].split(%r{,\s*})
    end
    bbox
  end
  def self.search(params = {})
    @query = params[:query] ||= params[:mh_query] ||= ""
    @query.gsub!(/[']/, '\\\\\'')
    @query << " tag:#{params[:tag]}" if params.include?(:tag)

    params[:limit] = 10 if params[:limit].blank? # ||= doesn't work for 'empty' parameters
    params[:page] = 1 if params[:page].blank?
    conditions = { }.merge({
      :models => ["Map"],
      :page => params[:page],
      :per_page => params[:limit],
    })
    conditions[:id] = params[:id] if params.include?(:id)
    conditions[:filter_restricted] = true if params[:fr] == 'true'
    conditions[:state] = [:described, :complete] if params[:mode] == 'nonpending'
    conditions[:in] = extract_in(@query)
    conditions[:in] ||= params[:bbox].split(%r{,\s*}) unless params[:bbox].blank?
    conditions[:since] = Time.parse(params[:since]).strftime("%Y-%m-%dT%H:%M:%SZ") if params.include?(:since)
    conditions[:until] = Time.parse(params[:until]).strftime("%Y-%m-%dT%H:%M:%SZ") if params.include?(:until)
    conditions[:source] = params[:source] unless params[:source].blank?
    # conditions[:state] = "saved"

    logger.debug "Query: #{@query}"
    @results = GeocommonsSearch::Search.paginate(@query, conditions)
    @tags = GeocommonsSearch::Search.tags_from_results(@results) || []
    [@results, @tags]
  end
end
