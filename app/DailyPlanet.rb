# ----
# Copyright (c) 2003, 2003 David Thomas (dba Thomas Consulting)
# All Rights Reserved.
# The right to use this software is granted by separate license
# between Destination Imagination, Inc and David Thomas.
#
# No part of this program may be reproduced, stored in a retrieval
# system, or transmitted, in any form, or by any means unless 
# explicitly permitted by the license.
# -----

# Handle the posting of news

require 'app/Application'
require 'app/DailyPlanetTemplates'
require 'bo/Affiliate'
require 'bo/News'
require 'bo/Region'

class DailyPlanet < Application

  app_info(:name => :DailyPlanet, :login_required  => true)

  class AppData
    attr_accessor :article
    attr_accessor :distribution
  end

  def app_data_type
    AppData
  end

  ######################################################################

  def DailyPlanet.top_news_for_user(user, limit=10)
    hq_news = get_hq_news
    aff_news = get_aff_news(user.user_id)
    reg_news = get_reg_news(user.user_id)
    user_news = get_user_news(user.user_id)

    to_lose = hq_news.size + aff_news.size + reg_news.size + user_news.size - limit

    while to_lose > 0
      if hq_news.size > 0
        hq_news.pop
        to_lose -= 1
        break if to_lose <= 0
      end
      if aff_news.size > 0
        aff_news.pop
        to_lose -= 1
        break if to_lose <= 0
      end
      if reg_news.size > 0
        reg_news.pop
        to_lose -= 1
        break if to_lose <= 0
      end
      if user_news.size > 0
        user_news.pop
        to_lose -= 1
        break if to_lose <= 0
      end
    end

    all_news = hq_news + aff_news + reg_news + user_news
    all_news.map do |story|
      {
        'news_byline'  => story.news_byline,
        'news_summary' => story.news_summary,
        'news_id'      => story.news_id,
      }
    end
  end


  def DailyPlanet.get_hq_news
    $store.select(NewsTable,
                  "news_aff_id is null " +
                  "and news_reg_id is null " +
                  "and news_user_id is null " +
                  "and news_start_date <= date(now()) " +
                  "and news_end_date >= date(now()) " +
                  "order by news_id desc").map {|n| News.new(n)}
  end

  def DailyPlanet.get_aff_news(user_id)
    $store.select(NewsTable,
                  "news_reg_id is null " +
                  "and news_user_id is null " +
                  "and news_start_date <= date(now()) " +
                  "and news_end_date >= date(now()) " +
                  "and news_aff_id in " +
                  "  (select distinct role_affiliate from role " +
                  "   where role_user=?) " +
                  "order by news_id desc",
                  user_id).map {|n| News.new(n)}
  end

  def DailyPlanet.get_reg_news(user_id)
    $store.select(NewsTable,
                  "news_user_id is null " +
                  "and news_start_date <= date(now()) " +
                  "and news_end_date >= date(now()) " +
                  "and news_reg_id in " +
                  "  (select distinct role_region from role " +
                  "   where role_user=?) " +
                  "order by news_id desc",
                  user_id).map {|n| News.new(n)}
  end

  def DailyPlanet.get_user_news(user_id)
    $store.select(NewsTable,
                  "news_user_id = ? " +
                  "and news_start_date <= date(now()) " +
                  "and news_end_date >= date(now()) " +
                  "order by news_id desc",
                  user_id).map {|n| News.new(n)}
  end

  ######################################################################

  class Distribution
    ALL       = "all"
    USER      = "user"
    AFFILIATE = "aff"
    REGION    = "reg"

    def initialize(aff_id, reg_id)
      @audience = ALL
      @email    = ''
      @force_affiliate = @aff_id = aff_id
      @force_region    = @reg_id = reg_id
      @everyone = everyone
    end

    def add_to_hash(values)
      values["reg_checked"]  = @audience == REGION    ? "checked" : ""
      values["aff_checked"]  = @audience == AFFILIATE ? "checked" : ""
      values["all_checked"]  = @audience == ALL       ? "checked" : ""
      values["user_checked"] = @audience == USER      ? "checked" : ""

      if @force_affiliate
        unless @force_region
          values["reg_id"]       = @reg_id
          values["reg_options"]  = Region.options(@aff_id)
        end
      else
        values["aff_options"]  = Affiliate.options
        values["aff_id"]       = @aff_id
      end


      values["con_email"]    = @email

      values["everyone"] = @everyone

    end

    def from_hash(values)
      case (@audience = values['audience'])
      when AFFILIATE
        @aff_id = values['aff_id'].to_i

      when REGION
        @reg_id = values['reg_id'].to_i
        
      when ALL
        ;
      when USER
        @email = values['con_email']
      else
        raise "Invalid audience returned from_hash";
      end
    end

    def error_list
      errs = []
      case @audience
      when AFFILIATE
        errs << "Specify an affiliate" if @aff_id < 0

      when REGION
        errs << "Specify a region" if @reg_id < 0

      when ALL
        ;

      when USER
        if @email.empty?
          errs << "Enter the user's e-mail address"
        else
          user = User.with_email(@email)
          if user
            @user_id = user.user_id
          else
            errs << "Unknown user '#@email'" unless user
          end
        end

      else
        errs << "Invalid audience"
      end

      errs
    end

    def update_news(news)
      case @audience
      when ALL
        news.news_aff_id = @force_affiliate
        news.news_reg_id = @force_region
        
      when AFFILIATE
        news.news_aff_id = @aff_id
        news.news_reg_id = nil

      when REGION
        news.news_aff_id = @aff_id
        news.news_reg_id = @reg_id

      when USER
        news.news_user_id = @user_id
      end
    end

    # Add a qualifier to the "to everyone ..." part of the creation menu
    def everyone
      if @force_region
        "in " +  Region.with_id(@force_region).reg_name
      elsif @force_affiliate
        "in " + Affiliate.with_id(@force_affiliate).aff_short_name
      else
        ""
      end
    end

  end

  ######################################################################
  
  def display_news(news_id)
    news = News.with_id(news_id)
    if news.nil?
      note "That story has been deleted"
      refresh_news
      @session.pop
    else
      values = {
      }
      news.add_to_hash(values, nil, true)
      standard_page("News Story", values, DISPLAY_NEWS)
    end
  end

  ######################################################################
  
  def display_all_news
    refresh_news(false)

    news = []
    add_news(news, "Global DI News", 
             DailyPlanet.get_hq_news)
    add_news(news, "Affiliate News",
             DailyPlanet.get_aff_news(@session.user.user_id))
    add_news(news, "Regional News",
             DailyPlanet.get_reg_news(@session.user.user_id))
    add_news(news, "Personal News",
             DailyPlanet.get_user_news(@session.user.user_id))

    if news.empty?
      note "No news is good news!"
      @session.pop
      return
    end

    values = {
      'news' => news
    }

    standard_page("All The News", values, DISPLAY_ALL_NEWS)
  end

  def add_news(news, title, stories)
    unless stories.empty?
      news << { 
        'title'   => title, 
        'stories' => stories.map {|s| s.add_to_hash({}, nil, true) }
      }
    end
  end

  ######################################################################
  
  def refresh_news(pop = true)
    @session.news = DailyPlanet.top_news_for_user(@session.user)
    @session.pop if pop
  end

  ######################################################################

  # display this user's  current news story summaries, and
  # allow stories to be created, edited, or deleted

  def editors_desk(aff_id=nil, reg_id=nil)

    my_news = News.created_by(@session.user)

    values = {
      'handle_url' => url(:handle_news, aff_id, reg_id)
    }

    news_list = my_news.map do |news|
      news.add_to_hash({})
    end

    values['news_list'] = news_list unless news_list.empty?

    standard_page("Editor's Desk: '#{aff_id}'", values, EDITORS_DESK)
  end


  # We're slightly different than most code, as we dispatch on the
  # name of the button pressed

  def handle_news(aff_id, reg_id)
    if @cgi.has_key?('create')
      create_article(aff_id, reg_id)
    else
      @cgi.keys.each do |k|
        if /^edit_(\d+)/ =~ k
          edit_news(aff_id, reg_id, $1)
          break
        end
        if /^delete_(\d+)/ =~ k
          delete_news($1, aff_id, reg_id)
          break
        end
      end
    end
  end


  def delete_news(news_id, aff_id, reg_id)
    News.delete_article(news_id)
    editors_desk(aff_id, reg_id)
  rescue Exception => e
    ;
  end


  def edit_news(aff_id, reg_id, news_id)
    @data.article = News.with_id(news_id)
    @data.distribution = nil
    if @data.article.nil?
      note "Article has been deleted"
      editors_desk(aff_id, reg_id)
    else
      edit_common(aff_id, reg_id)
    end
  end


  # Create a new news article
  def create_article(aff_id, reg_id)
    a = @data.article = News.new
    @data.distribution = Distribution.new(aff_id, reg_id)
    a.posted_by = @session.user
    edit_common(aff_id, reg_id)
  end


  def edit_common(aff_id, reg_id)
    values = {
      'ok_url' => url(:accept_article, aff_id, reg_id)
    }

    @data.article.add_to_hash(values)
    if @data.distribution
      @data.distribution.add_to_hash(values)
      values['include_distro'] = true
    end
    standard_page("Hold the Press", values, EDIT_ARTICLE)
  end


  def accept_article(aff_id, reg_id)
    values = hash_from_cgi
    @data.article.from_hash(values)
    errors = @data.article.error_list
    
    if @data.distribution
      @data.distribution.from_hash(values)
      errors.concat @data.distribution.error_list
    end

    if errors.empty?
      set_byline(aff_id, reg_id)
      if @data.distribution
        @data.distribution.update_news(@data.article)
      end
      if reg_id && !@data.article.news_reg_id
        raise "no reg id: distribution.nil? = #{@data.distribution.nil?}"
      end
      @data.article.save
      @context.no_going_back
      editors_desk(aff_id, reg_id)
    else
      error_list errors
      edit_common(aff_id, reg_id)
    end
  end


  def set_byline(aff_id, reg_id)
    where = "DI"
    if reg_id
      reg = Region.with_id(reg_id)
      where = reg.reg_name
    elsif aff_id
      aff = Affiliate.with_id(aff_id)
      where = aff.aff_short_name
    end

    @data.article.news_byline = "#{where}: #{@session.user.contact.con_name}, " +
      "#{Time.now.strftime('%b %d')}"
  end

end
