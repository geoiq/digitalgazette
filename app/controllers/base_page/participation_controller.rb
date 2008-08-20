=begin

ParticipationController
---------------------------------

This is a controller for managing participations with a page
(ie user_participations and group_participations).

=end

class BasePage::ParticipationController < ApplicationController

  before_filter :login_required
  verify :method => :post, :only => [:move]

  helper 'base_page'

  # TODO: add non-ajax version
  # TODO: send a 'made public' message to watchers
  # Requires :admin access
  def update_public
    @page.public = ('true' == params[:public])
    @page.updated_by = current_user
    @page.save
    render :template => 'base_page/participation/reset_public_line'
  end

  # post
  def add_star
    @page.add(current_user, :star => true)
    redirect_to page_url(@page)
  end
  def remove_star
    @page.add(current_user, :star => false)
    redirect_to page_url(@page)
  end

  # xhr
  def add_watch
    @page.add(current_user, :watch => true)
    @upart = @page.participation_for_user(current_user)
    render :template => 'base_page/participation/reset_watch_line'
  end
  def remove_watch
    @page.add(current_user, :watch => false)
    @upart = @page.participation_for_user(current_user)
    render :template => 'base_page/participation/reset_watch_line'
  end
  
  def details
    render :template => 'base_page/reset_sidebar'
  end

  def show_popup
    render :template => 'base_page/participation/show_' + params[:name] + '_popup'
  end

  # alter the group_participations so that the primary group is
  # different.
  # requires :admin access
  def move
    if params[:cancel]
      redirect_to page_url(@page)
    elsif params[:group_id].any?
      group = Group.find params[:group_id]
      @page.remove(@page.group) if @page.group
      @page.add(group)
      @page.group = group
      current_user.updated(@page)
      @page.save
      clear_referer(@page)
      redirect_to page_url(@page)      
    end
  end
  
  ##
  ## PAGE SHARING
  ## 

  # share this page with a notice message to any number of recipients. 
  #
  # if the recipient is a user name, then the message and the page show up in
  # user's, and optionally they are alerted via email if that is their personal
  # settings.
  #
  # if the recipient is an email address, an email is sent to the address with a
  # magic url that lets the recipient view the page by clicking on a link
  # and using their email as the password.
  # 
  # the sending user must have admin access to send to recipients
  # who do not already have the ability to view the page.
  # 
  # the recipient may be an entire group, in which case we grant access
  # and send to each user individually. 
  #
  # you cannot share to users/groups that you cannot pester, unless
  # the page is private and they already have access.
  #
  def share
    begin
      if params[:cancel]
        render :template => 'base_page/reset_sidebar'
        return
      end
      users, groups, emails, errors = parse_recipients(params[:recipients])
      unless errors.empty?
        flash_message_now :title => 'Could not understand some recipients. Please try again.', :error => errors
        render :template => 'base_page/show_errors'
        return
      end
      access = :admin # params[:access]
      msg = params[:message]
      users_to_email = [] 
      # puts [users, groups, emails, errors].inspect
      users.each do |user|
        if current_user.share_page_with_user(@page, user, :access => access, :message => msg)
          users_to_email << user if user.wants_notification_email?
        end
      end
      groups.each do |group|
        users_succeeded = current_user.share_page_with_group(@page, group,
          :access => access, :message => msg)
        users_succeeded.each do |user|
          users_to_email << user if user.wants_notification_email?
        end
      end
  #    emails.each do |email|
  #      Mailer.deliver_page_notice_with_url_access(email, msg, mailer_options)
  #    end
      users_to_email.each do |user|
        puts 'emailing %s' % user.email
        Mailer.deliver_page_notice(user, msg, mailer_options)
      end
      unless current_user.valid?
        flash_message_now :object => current_user # display any sending errors
      end
      render :template => 'base_page/reset_sidebar'
    rescue Exception => error
      flash_message_now :title => 'Error: ' + error.class.to_s, :error => error.to_s
      render :template => 'base_page/reset_sidebar'
    end
  end
  
  protected
  
  # called by share()
  # parses a list of recipients, turning them into email, user, or group
  # objects as appropriate.
  def parse_recipients(recipients)
    users = []; groups = []; emails = []; errors = []
    if recipients.is_a? Hash
      to = []
      recipients.each do |key,value|
        to << key if value == '1'
      end
    elsif recipients.is_a? Array
      to = recipients
    elsif recipients.is_a? String
      to = recipients.split(/[\s,]/)
    end
    to.each do |entity|
      if entity =~ RFC822::EmailAddress
        emails << entity
      elsif g = Group.get_by_name(entity)
        groups << g
      elsif u = User.find_by_login(entity)
        users << u
      else
        errors << '"%s" does not match the name of any users or groups and is not a valid email address' % entity
      end
    end
    [users, groups, emails, errors]
  end


  def authorized?
    if ['update_public', 'move'].include? params[:action]
      current_user.may? :admin, @page
    else
      current_user.may? :view, @page
    end
  end
  
  prepend_before_filter :fetch_page
  def fetch_page
    if params[:id]
      # not yet used:
      #@upart = UserParticipation.find_by_id(params[:id])
      #@page = @upart.page
    elsif params[:page_id]
      @page = Page.find_by_id(params[:page_id])
      @upart = @page.participation_for_user(current_user)
    end
    true
  end
  
end
