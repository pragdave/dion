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

require "app/Select"
require 'app/ListsTemplates'

class Lists < Select

  app_info(:name => "Lists")

  # Define the contents of the various reports

  ######################################################################

  RS = Struct.new(:desc, :columns, :tables, :joins, :outer_joins, :keys)

  ReportSets = {
    TEAMPAK => {
      'd1' => RS.new("Passport, name, type, status",
                     [ 
                       'mem_id',
                       'mem_passport_prefix',
                       'mem_passport',
                       'mem_name',
                       'mem_type',
                       'mem_state'
                     ],
                     nil,
                     nil,
                     nil,
                     1),

      'd2' => RS.new("School name, district name, region",
                     [ 'mem_schoolname',
                       'mem_district',
                       'reg_name',
                     ],
                     nil,
                     nil,                      
                     {"membership" => "region on (reg_id=mem_region)"},
                     nil),

      'd3' => RS.new("Name, mailing address, phone, email of contact",
                     [ 'c2.con_first_name',
                       'c2.con_last_name', 
                       'c2.con_email',
                       'c2.con_day_tel',
                       'c2.con_eve_tel',
                       'c2.con_fax_tel',
                       'a2m.add_line1',
                       'a2m.add_line2',
                       'a2m.add_city',
                       'a2m.add_state',
                       'a2m.add_zip',
                       'a2m.add_county',
                       'a2m.add_country',
                     ],
                     [ "user_table u2", "contact c2", "address a2m" ],
                     "u2.user_id=mem_admin and " +
                     "c2.con_id=u2.user_contact and " +
                     "a2m.add_id=c2.con_mail",
                     nil,
                     nil),

      
      'd4' => RS.new("Name, mailing address, phone, email of creator",
                     [ 'c1.con_first_name',
                       'c1.con_last_name', 
                       'c1.con_email',
                       'c1.con_day_tel',
                       'c1.con_eve_tel',
                       'c1.con_fax_tel',
                       'a1m.add_line1',
                       'a1m.add_line2',
                       'a1m.add_city',
                       'a1m.add_state',
                       'a1m.add_zip',
                       'a1m.add_county',
                       'a1m.add_country',
                     ],
                     [ "user_table u1", "contact c1", "address a1m" ],
                     "u1.user_contact = c1.con_id and " +
                     "u1.user_id=mem_creator and a1m.add_id=c1.con_mail",
                     nil,
                     nil),

    },

    TEAM    => {
      "d1" => RS.new("Team passport, Team name, TeamPak name, School name, challenge, level",
                     [ 'mem_id',
                       'team_id',
                       'mem_passport_prefix',
                       'mem_passport',
                       'team_passport_suffix',
                       'team_name',
                       'mem_name',
                       'mem_schoolname',
                       'chd_name',
                       'team_level',
                     ],
                     [ "membership", "challenge_desc", "challenge" ],
                     "mem_id=team_mem_id and cha_id=team_challenge and cha_chd_id=chd_id",
                     nil,
                     2),

      "d2" => RS.new("Team member name, D.O.B., Grade",
                     [ "Name 1",
                       "Dob 1",
                       "Grade 1",
                       "Name 2",
                       "Dob 2",
                       "Grade 2",
                       "Name 3",
                       "Dob 3",
                       "Grade 3",
                       "Name 4",
                       "Dob 4",
                       "Grade 4",
                       "Name 5",
                       "Dob 5",
                       "Grade 5",
                       "Name 6",
                       "Dob 6",
                       "Grade 6",
                       "Name 7",
                       "Dob 7",
                       "Grade 7",
                     ],
                     nil,nil,nil, nil),
                   
      "d3" => RS.new("Full contact details for first team manager",
                     [ "1st TM First Name",
                       "1st TM Last Name",
                       "1st TM E-Mail",
                       '1st TM Day Tel',
                       '1st TM Eve. Tel',
                       '1st TM Fax',
                       '1st TM Add Line1',
                       '1st TM Add Line2',
                       '1st TM City',
                       '1st TM State',
                       '1st TM Zip',
                       '1st TM County',
                       '1st TM Country',
                     ],
                     nil, nil, nil, nil),

      "d4" => RS.new("Name and e-mail for all team managers",
                     [ 
                       "TM 1: First name",
                       "TM 1: Last name",
                       "TM 1: E-Mail",
                       "TM 2: First name",
                       "TM 2: Last name",
                       "TM 2: E-Mail",
                       "TM 3: First name",
                       "TM 3: Last name",
                       "TM 3: E-Mail",
                       "TM 4: First name",
                       "TM 4: Last name",
                       "TM 4: E-Mail",
                       "TM 5: First name",
                       "TM 5: Last name",
                       "TM 5: E-Mail",
                     ],
                     nil, nil, nil, nil),

    },



    USER    => {
      "d1" => RS.new("Nickname, Name, E-Mail, Primary Affiliate",
                     [ 'user_id',
                       'user_acc_name',
                       'con_first_name',
                       'con_last_name',
                       'con_email',
                       'aff_short_name',
                       'aff_long_name',
                     ],
                     [ "contact", "affiliate" ],
                     "con_id=user_contact and aff_id=user_affiliate",
                     nil,
                     1),

      "d2" => RS.new("Daytime, evening, and fax numbers",
                     [ 'con_day_tel',
                       'con_eve_tel',
                       'con_fax_tel',
                     ],
                     [ "contact" ],
                     "con_id=user_contact",
                     nil,
                     nil),

      "d3" => RS.new("Mailing address",
                     [ 'mail.add_line1',
                       'mail.add_line2',
                       'mail.add_city',
                       'mail.add_state',
                       'mail.add_zip',
                       'mail.add_county',
                       'mail.add_country'
                     ],
                     [ "contact", "address mail" ],
                     "con_id=user_contact and mail.add_id=con_mail",
                     nil,
                     nil),

      "d4" => RS.new("Shipping address",
                     [ 'ship.add_line1',
                       'ship.add_line2',
                       'ship.add_city',
                       'ship.add_state',
                       'ship.add_zip',
                       'ship.add_county',
                       'ship.add_country'
                     ],
                     [ "contact", "address ship" ],
                     "con_id=user_contact and ship.add_id=con_ship",
                     nil,
                     nil),

    },

  }



  ######################################################################

  def function
    "Report"
  end

  ######################################################################


  def work_out_data
    count = count_matches
    if count.zero?
      error "No data matches"
      return select_criteria
    end

    values = {
      'count' => count,
      'form_url' => url(:handle_list),
      'function' => function,
    }

    values['warn'] = true if count > 100


    opts = ReportSets[@data.selection_type]
    dl_list = opts.keys.sort.map do |k|
      values[k] = k == 'd1'
      {
        'opt' => k, 'desc' => opts[k].desc
      }
    end
    
    values['dl_list'] = dl_list
      
    standard_page("What Data to Report", values, WHAT_TO_DO)

  end


  ######################################################################

  def handle_list
    cols   = []
    tables = []
    joins  = []
    outer_joins = []
    keys   = nil

    opts = ReportSets[@data.selection_type]
    opts.each do |k, ds|
      if "on" == @cgi[k]
        cols.concat ds.columns
        tables.concat ds.tables if ds.tables
        joins << ds.joins if ds.joins
        outer_joins << ds.outer_joins if ds.outer_joins
        keys = ds.keys if ds.keys
      end
    end

    if cols.empty?
      note "You didn't select any data to report on"
      return work_out_data
    end

    do_list(cols, tables, joins, outer_joins, keys)
  end

  ######################################################################

  def do_list(cols, tables, joins, outer_joins, keys)
    where = @data.where_clause
    unless joins.empty?
      join_clause = joins.join(" and ")
      if where
        where << " and " << join_clause
      else
        where = join_clause
      end
    end

    col_names = cols.join(",")

    cols = cols.map {|col| col.gsub(/[-:. ]/, "_").sub(/^(\d)/) { "X#$1"} }

    # preload a values array so we're not constantly creating
    # objects later

#CGI::x @data

    table_names = (@data.tables.map{|t| t.name} | tables).join(", ")

    # if there are any outer joins, merge them in to the
    # from clause

    outer_joins.each do |ojs|
      ojs.each do |table, join|
        table_names.sub!(Regexp.new(table + "(,|$)")) {
          "#{table} left outer join #{join}#$1"
        }
      end
    end

    op = header_for(cols)

    case @data.selection_type
    when TEAMPAK
      fetcher = Membership
      template = TEAMPAK_TEMPLATE
    when TEAM    
      fetcher = Team
      template = TEAM_TEMPLATE
    when USER
      fetcher = User
      template = USER_TEMPLATE
    end

    fixup_query(table_names, where)

    # Get the data and write it
    fetcher.download(col_names, where, table_names) do |row|
      write_record(template, op, cols, row, keys)
    end

    values = { 'when' => Time.now.strftime("%d-%b-%y %I:%M %p") }
    standard_page("Your Report", values, REPORT, op)

  end

  ######################################################################
  
  def write_record(template, op, cols, row, keys)
    tmpl = Template.new(template)
    values = {}

    cols.each_with_index do |name, i|
      value = row[i]
      value = value.to_s if value
      values[name] = value
    end

    if keys
      add_lookup_url(values, *row[0, keys])
    end

    tmpl.write_html_on(op, values)
  end


  def header_for(cols)
    template = case @data.selection_type
               when TEAMPAK then TEAMPAK_HEADER
               when TEAM    then TEAM_HEADER
               when USER    then USER_HEADER
               end
    tmpl = Template.new(template)
    values = {}
    cols.each { |name| values[name] = 1 }
    op = ""
    tmpl.write_html_on(op, values)
    op
  end

  
  def add_lookup_url(values, row_id, team_id=nil)
    url = case @data.selection_type
          when TEAMPAK then @context.url(Register, :handle_status, row_id)
          when TEAM    then @context.url(Teams, :handle_status, row_id, team_id)
          when USER    then @context.url(UserStuff, :display_details_for_id, row_id)
          end
    values['url'] = url
  end
end
