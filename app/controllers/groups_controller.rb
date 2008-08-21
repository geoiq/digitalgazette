require 'svg/svg' 

class GroupsController < ApplicationController
  include GroupsHelper
  
  #layout :choose_layout
  stylesheet 'groups'
  
  before_filter :find_group, :except => ['list','create','index']
  
  before_filter :login_required,
    :except => [:list, :index, :show, :search, :archive, :tags]
    
  verify :method => :post,
    :only => [:destroy, :update ]

  def initialize(options={})
    super()
    @group = options[:group] # the group context, if any
  end  
  
  def index
    list
    render :action => 'list'
  end

  def list
    @groups = Group.find :all, :conditions => 'type IS NULL'
    set_banner "groups/banner_search", Style.new(:background_color => "#1B5790", :color => "#eef")
  end

  def show
    @stylesheet = 'landing'
    if logged_in? and current_user.member_of?(@group)
      @access = :private
    elsif @group.publicly_visible_group
      @access = :public
    else
#     TODO: make this look identical to the page returned if the group/committee doesn't exist
#           perhaps it should be handled in the dispatch controller, and this code should never be reached
      @group = nil
      set_banner "groups/banner_nothing", Style.new(:background_color => "#1B5790", :color => "#eef")
      return render(:template => 'groups/show_nothing')
    end
    
    @pages = Page.find_by_path('descending/updated_at/limit/20', options_for_group(@group))
    @profile = @group.profiles.send(@access)
    @committees = @group.committees_for @access
    
    @wiki = private_or_public_wiki()
  end

  def visualize
    unless logged_in? and current_user.member_of?(@group)
      message( :error => 'you do not have permission to do that', :later => true )
      redirect_to url_for_group(@group)
    end

    # return xhtml so that svg content is rendered correctly --- only works for firefox (?)    
    response.headers['Content-Type'] = 'application/xhtml+xml'       
  end

  def archive
    #XXX: this belongs in the model
    case Page.connection.adapter_name
    when "SQLite"
      dates = "strftime('%m', created_at) AS month, strftime('%Y', created_at) AS year"
    when "MySQL"
      dates = "MONTH(pages.created_at) AS month, YEAR(pages.created_at) AS year"
    else
      raise "#{Article.connection.adapter_name} is not yet supported here"
    end

    sql = "SELECT #{dates}, count(pages.id) " +
     "FROM pages JOIN group_participations ON pages.id = group_participations.page_id " +
     "JOIN user_participations ON pages.id = user_participations.id " +
     "WHERE group_participations.group_id = #{@group.id} "
    unless may_admin_group?
      sql += " AND (pages.public = 1#{' OR user_participations.user_id = %d' % current_user.id if logged_in?}) "
    end
    sql += "GROUP BY year, month ORDER BY year, month"
    @months = Page.connection.select_all(sql)
    
    unless @months.empty?
      @current_year = (Date.today).year 
      @start_year = @months[0]['year'] || @current_year.to_s
      @current_month = (Date.today).month

      @path = params[:path] || []
      @parsed = parse_filter_path(params[:path])
      unless @parsed.keyword?('month')
        @path << 'month' << @months.last['month'] #@current_month
        @parsed << [ 'month', @months.last['month'] ]
      end
      unless @parsed.keyword?('year')
        @path << 'year' << @months.last['year'] #@current_year
        @parsed << [ 'year', @months.last['year'] ]
      end

      @pages, @sections = Page.find_and_paginate_by_path(@path, options_for_group(@group))
    end
  end
  
  def search
    if request.post?
      path = build_filter_path(params[:search])
      redirect_to groups_url(:id => @group, :action => 'search') + path   
    else
      @pages, @sections = Page.find_and_paginate_by_path(params[:path], options_for_group(@group))
      if parsed_path.sort_arg?('created_at') or parsed_path.sort_arg?('created_by_login')    
        @columns = [:icon, :title, :created_by, :created_at, :contributors_count]
      else
        @columns = [:icon, :title, :updated_by, :updated_at, :contributors_count]
      end
    end

    handle_rss :title => @group.name, :description => @group.summary,
               :link => url_for_group(@group),
               :image => avatar_url(:id => @group.avatar_id||0, :size => 'huge')
  end
  
  def tags
    tags = params[:path] || []
    path = tags.collect{|a|['tag',a]}.flatten
    @pages, @sections = Page.find_and_paginate_by_path(path, options_for_group(@group))
  end

  def tasks
    @stylesheet = 'tasks'
    @javascript = :extra
    @pages, @sections = Page.find_and_paginate_by_path('type/task/pending', options_for_group(@group))
    @task_lists = @pages.collect{|page|page.data}
  end

  # login required
  def create
    set_banner "groups/banner_search", Style.new(:background_color => "#1B5790", :color => "#eef")

    @parent = Group.find(params[:parent_id]) if params[:parent_id]
    if @parent and not current_user.member_of?(@parent)
      message( :error => 'you do not have permission to do that'.t, :later => true )
      redirect_to url_for_group(@parent)
      return
    end

    if request.post?
      if @parent
        @group = Committee.new(params[:group])
      else
        @group = Group.new(params[:group])
      end
      if @group.save
        flash_message :success => 'Group was successfully created.'.t
        @group.memberships.create :user => current_user, :group => @group
        if @parent
          @group.parent = @parent
          @parent.users.each do |u|
            u.clear_cache
          end
        end
        redirect_to url_for_group(@group)
      else
        flash_message_now :object => @group
      end
    else #create placeholder objects to base the form off
      if @parent
        @group = Committee.new
      else
        @group = Group.new
      end
    end
  end

  # login required
  def edit
  end
     
  # login required
  # post required
  def update
#  require 'ruby-debug'; debugger
    @group.update_attributes(params[:group])
    
    @group.publicly_visible_group = params[:group][:publicly_visible_group] if params[:group]
    @group.publicly_visible_committees = params[:group][:publicly_visible_committees] if params[:group]
    @group.publicly_visible_members = params[:group][:publicly_visible_members] if params[:group]
    @group.accept_new_membership_requests = params[:group][:accept_new_membership_requests] if params[:group]
    
    if @group.save
      redirect_to :action => 'edit', :id => @group
      flash_message :success => 'Group was successfully updated.'
    else
      flash_message_now :object => @group  
    end
  end
  
  # login required
  # post required
  def destroy
    if @group.users.uniq.size > 1 or @group.users.first != current_user
      flash_message :error => 'You can only delete a group if you are the last member'
      redirect_to :action => 'show', :id => @group
    else
      parent = @group.parent
      @group.destroy
      if parent
        parent.users.each {|u| u.clear_cache}
        redirect_to url_for_group(parent)
      else
        redirect_to :action => 'list'
      end
    end
  end  
     
  protected
  
  # returns a private wiki if it exists, a public one otherwise
  def private_or_public_wiki
    if @access == :private and (@profile.wiki.nil? or @profile.wiki.body == '' or @profile.wiki.body.nil?)
      public_profile = @group.profiles.public
      public_profile.create_wiki unless public_profile.wiki
      public_profile.wiki
    else
      @profile.create_wiki unless @profile.wiki
      @profile.wiki
    end
  end
  
  #def choose_layout
  #   return 'application' if ['list','index', 'create'].include? params[:action]
  #   return 'groups'
  #end
  
  def context
    group_context
    unless ['show','index','list'].include? params[:action]
      add_context params[:action], url_for(:controller=>'groups', :action => params[:action], :id => @group, :path => params[:path])
      # url_for is used here to capture the path
    end
  end
  
  def find_group
    @group = Group.get_by_name params[:id].sub(' ','+') if params[:id]
    if @group and (@group.publicly_visible_group or (@group.committee? and @group.parent.publicly_visible_group) or may_admin_group?) ##committees need to be handled better
      @left_column = render_to_string(:partial => 'sidebar')
      return true
    else
      render :template => 'groups/show_nothing'
      return false
    end
  end
  
  def authorized?
    non_members_post_allowed = %w(archive search tags tasks create)
    non_members_get_allowed = %w(show members) + non_members_post_allowed
    if request.get? and non_members_get_allowed.include? params[:action]
      return true
    elsif request.post? and non_members_post_allowed.include? params[:action]
      return true
    else
      return(logged_in? and current_user.member_of? @group)
    end
  end    
  
end
