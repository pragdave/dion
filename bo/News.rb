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

require 'bo/BusinessObject'
require 'bo/DionDate'

class News < BusinessObject

  def News.created_by(user)
    $store.select(NewsTable, "news_posted_by=?", user.user_id).map {|n| new(n) }
  end

  def News.delete_article(news_id)
    $store.delete_where(NewsTable, "news_id=?", news_id)
  end

  def News.with_id(news_id)
    maybe_return($store.select_one(NewsTable, "news_id=?", news_id))
  end


  def News.count_for_region(reg_id)
    $store.count(NewsTable, "news_reg_id=?", reg_id)
  end


  def News.reassign_region(old_reg_id, new_reg_id)
    if new_reg_id
      $store.update_where(NewsTable,
                          "news_reg_id=?",
                          "news_reg_id=?",
                          new_reg_id,
                          old_reg_id)
    else
      $store.delete_where(NewsTable, "news_reg_id=?", old_reg_id);
    end
  end

  ######################################################################

  def initialize(data_object = nil)
    d = @data_object = data_object || fresh_news
    @start_date  = DionDate.new("start_date", d.news_start_date)
    @end_date    = DionDate.new("end_date",   d.news_end_date)
  end

  def fresh_news
    d = NewsTable.new
    d.news_byline   = ''
    d.news_summary = ''
    d.news_story   = ''
    today = Date.today
    d.news_start_date = DBI::Date.new(today)
    d.news_end_date   = DBI::Date.new(today + 61)
    d
  end

  def posted_by=(user)
    @posted_by = user
    @data_object.news_posted_by = user.user_id
  end

  def posted_by
    @posted_by ||= User.with_id(@data_object.news_posted_by)
  end

  def add_to_hash(values, prefix=nil, convert=false)
    super(values, prefix)
    @start_date.add_to_hash(values)
    @end_date.add_to_hash(values)
#    puts CGI.escapeHTML(values.inspect)
    if convert && values['news_story']
      values['news_story'] = News.convert_article(values['news_story'])
    end
    values
  end

  def from_hash(values)
    d = @data_object
    d.news_summary = values['news_summary']
    d.news_story   = values['news_story']
    @start_date.from_hash(values)
    @end_date.from_hash(values)
  end

  def error_list
    errs = []
    d = @data_object
    
    errs << "Missing title" if d.news_summary.empty?
    errs << "Missing story" if d.news_story.empty?

    errs.concat @start_date.error_list
    errs.concat @end_date.error_list

    if errs.empty?
      if @start_date >= @end_date
        errs << "End date must be after start date"
      end
    end

    errs
  end


  def save
    d = @data_object
    d.news_start_date = @start_date.date
    d.news_end_date = @end_date.date
    super
  end


  def News.convert_article(str)
    str.gsub(/^\s*$/m, "#{Template::OPEN_TAG}p#{Template::CLOSE_TAG}\n")
  end
end
