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

class Download < Select

  app_info(:name => "Download")

  CRLF = "\r\n"

  # Define the contents of the various downloads

  ######################################################################

  DS = Struct.new(:desc, :columns, :tables, :joins, :outer_joins)

  DownloadSets = {
    TEAMPAK => {
      'd1' => DS.new("Passport, name, region, type, status",
                     [ 
                       'mem_passport_prefix',
                       'mem_passport',
                       'mem_name',
                       'reg_name',
                       'mem_type',
                       'mem_state'
                     ],
                     nil,
                     nil,
                     {"membership" => "region on (reg_id=mem_region)"}
                     ),

      'd2' => DS.new("School name, district name",
                     [ 'mem_schoolname',
                       'mem_district'
                     ],
                     nil, nil, nil),

      'd3' => DS.new("Name, mailing address, phone, email of contact",
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
                     nil),

      
      'd4' => DS.new("Name, mailing address, phone, email of creator",
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
                     nil),

    },

    TEAM    => {
      "d1" => DS.new("Team passport, Team name, TeamPak name, School name, challenge, level, " +
                     "valid flag",
                     [ "mem_passport_prefix||'-'||mem_passport||'-'||team_passport_suffix",
                       'team_name',
                       'mem_name',
                       'mem_schoolname',
                       'chd_name',
                       'team_level',
                       'team_is_valid',
                     ],
                     [ "membership", "challenge_desc", "challenge" ],
                     "mem_id=team_mem_id and cha_id=team_challenge and cha_chd_id=chd_id",
                     nil),

      "d2" => DS.new("Team member name, D.O.B., Grade",
                     [ "Name 1",
                       "DOB 1",
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
                     nil,nil,nil),
                   
      "d3" => DS.new("Full contact details for first team manager",
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
                     nil, nil, nil),

      "d4" => DS.new("Name and e-mail for all team managers",
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
                     nil, nil, nil),

      "d5" => DS.new("Data for Scoring Program (do not select any other entries above if chosing this option)",
                     [
                       %{case
                         when team_name = mem_schoolname then team_name
                         else team_name||'/'||mem_schoolname
                         end as "SCHOOL"},
                       "mem_passport_prefix||'-'||mem_passport||'-'||team_passport_suffix " +
                          'as "PASSPORT"',
                       'mem_district as "TOWN"',
                       'chd_short_name as "CHALLENGE"',
                       %{case
                         when team_level=1 then 'P'
                         when team_level=2 then 'E'
                         when team_level=3 then 'M'
                         when team_level=4 then 'S'
                         when team_level=5 then 'U'
                         else '?' 
                         end as "LEVEL"},
                       "'' as \"TCTIME\"",
                       "'' as \"ICTIME\"",
                       "'Y' as \"COMPETITIVE\"",
                     ],
                     [ "membership", "challenge_desc", "challenge" ],
                     "mem_id=team_mem_id and " +
                     "cha_id=team_challenge and " +
                     "cha_chd_id=chd_id and " +
                     "mem_is_active = 'Y' and " +
                     "team_level > 1",
                     nil),
    },



    USER    => {
      "d1" => DS.new("Nickname, Name, E-Mail, Primary Affiliate",
                     [ 'user_acc_name',
                       'con_first_name',
                       'con_last_name',
                       'con_email',
                       'aff_short_name',
                       'aff_long_name',
                     ],
                     [ "contact", "affiliate" ],
                     "con_id=user_contact and aff_id=user_affiliate",
                     nil),

      "d2" => DS.new("Daytime, evening, and fax numbers",
                     [ 'con_day_tel',
                       'con_eve_tel',
                       'con_fax_tel',
                     ],
                     [ "contact" ],
                     "con_id=user_contact",
                     nil),

      "d3" => DS.new("Mailing address",
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
                     nil),

      "d4" => DS.new("Shipping address",
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
                     nil),

    },

  }

  ######################################################################

  # Map column names into table headers

  NameMap = {
    'mem_passport_prefix' => "Passport Prefix",
    'mem_passport'        => "Passport",
    'mem_name'            => "TeamPak Name",
    'reg_name'            => "Region",
    'mem_type'            => "TeamPak Type",
    'mem_state'           => "TeamPak Status",
    'mem_schoolname'      => "School Name",
    'mem_district'        => "District",
    'c1.con_first_name'   => "Creator First Name",
    'c1.con_last_name'    => "Creator Last Name", 
    'c1.con_email'        => "Creator E-Mail",
    'c1.con_day_tel'      => "Creator Day Tel",
    'c1.con_eve_tel'      => "Creator Eve Tel",
    'c1.con_fax_tel'      => "Creator Fax",
    'a1m.add_line1'       => "Creator Add Line1",
    'a1m.add_line2'       => "Creator Add Line2",
    'a1m.add_city'        => "Creator City",
    'a1m.add_state'       => "Creator State",
    'a1m.add_zip'         => "Creator Zip",
    'a1m.add_county'      => "Creator County",
    'a1m.add_country'     => "Creator Country",
    'c2.con_first_name'   => "Contact First Name",
    'c2.con_last_name'    => "Contact Last Name", 
    'c2.con_email'        => "Contact E-Mail",
    'c2.con_day_tel'      => "Contact Day Tel",
    'c2.con_eve_tel'      => "Contact Eve Tel",
    'c2.con_fax_tel'      => "Contact Fax",
    'a2m.add_line1'       => "Contact Add Line1",
    'a2m.add_line2'       => "Contact Add Line2",
    'a2m.add_city'        => "Contact City",
    'a2m.add_state'       => "Contact State",
    'a2m.add_zip'         => "Contact Zip",
    'a2m.add_county'      => "Contact County",
    'a2m.add_country'     => "Contact Country",
    'user_acc_name'       => "Nickname",
    'con_first_name'      => 'First name',
    'con_last_name'       => 'Last name',
    'con_email'           => 'E-Mail',
    'aff_short_name'      => 'Short affiliate name',
    'aff_long_name'       => 'Full affiliate name',
    'con_day_tel'         => "Day telephone",
    'con_eve_tel'         => "Eve. telephone",
    'con_fax_tel'         => "Fax",
    'mail.add_line1'      => "Mailing Add Line1",
    'mail.add_line2'      => "Mailing Add Line2",
    'mail.add_city'       => "Mailing City",
    'mail.add_state'      => "Mailing State",
    'mail.add_zip'        => "Mailing Zip",
    'mail.add_county'     => "Mailing County",
    'mail.add_country'    => "Mailing Country",
    'ship.add_line1'      => "Shipping Add Line1",
    'ship.add_line2'      => "Shipping Add Line2",
    'ship.add_city'       => "Shipping City",
    'ship.add_state'      => "Shipping State",
    'ship.add_zip'        => "Shipping Zip",
    'ship.add_county'     => "Shipping County",
    'ship.add_country'    => "Shipping Country",

    "mem_passport_prefix||'-'||mem_passport||'-'||team_passport_suffix" => "Passport",
    'team_name'           => 'Team Name',
    'chd_name'            => "Challenge",
    'team_level'          => "Team Level",
    'team_is_valid'       => "Valid at Level",
  }

  ######################################################################

  def function
    "Download"
  end

  ######################################################################


  def work_out_data
    count = count_matches
    if count.zero?
      error "No data matches"
      return select_criteria
    end

    form_url = url(:handle_download) + "/dion-#{@context.context_id}.csv"

    values = {
      'count' => count,
      'form_url' => form_url,
      'function' => 'Download',
    }

    values['warn'] = true if count > 100


    opts = DownloadSets[@data.selection_type]
    dl_list = opts.keys.sort.map do |k|
      values[k] = k == 'd1'
      {
        'opt' => k, 'desc' => opts[k].desc
      }
    end
    
    values['dl_list'] = dl_list
      
    standard_page("What to Download", values, WHAT_TO_DO)

  end


  ######################################################################

  def handle_download
    cols   = []
    tables = []
    joins  = []
    outer_joins = []

    opts = DownloadSets[@data.selection_type]
    opts.each do |k, ds|
      if "on" == @cgi[k]
        cols.concat ds.columns
        tables.concat ds.tables if ds.tables
        joins << ds.joins if ds.joins
        outer_joins << ds.outer_joins if ds.outer_joins
      end
    end

    if cols.empty?
      note "You didn't select any data to download"
      return work_out_data
    end

    do_download(cols, tables, joins, outer_joins)
  end

  ######################################################################

  def do_download(cols, tables, joins, outer_joins)
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

    fixup_query(table_names, where)

    header = cols.map do |col|
      if col =~ /as "(\w+?)"/
        $1
      else
        NameMap[col] || col
      end
    end

    op = []
    
    write_csv(op, header)

    case @data.selection_type
    when TEAMPAK
      Membership.download(col_names, where, table_names) {|row| write_csv(op, row)}

    when TEAM
      Team.download(col_names, where, table_names) {|row| write_csv(op, row)}

    when USER
      User.download(col_names, where, table_names) {|row| write_csv(op, row)}
    end

    $show_debug = false
    req = Apache::request
    req.cancel
    req.status = Apache::HTTP_OK
    req.content_type = 'application/csv'
    hdrs = req.headers_out
#    hdrs['Content-Disposition'] = "attachment; filename=dion-#{@context.context_id}.csv"
    hdrs['Content-Description'] = "DION Download"
    size = 0
    op.each {|line| size += line.size}
    hdrs['Content-Length'] = size.to_s
    req.send_http_header
    req.write op.join

  end

  ######################################################################
  
  def write_csv(op, row)
    res = ""
    until row.empty?
      entry = row.shift.to_s
      if /[,"]|^0\d/ =~ entry
        entry = entry.gsub(/"/, '""')
        res << '"' << entry << '"'
      else
        res << entry
      end
      res << "," unless row.empty?
    end
    op << res << CRLF
  end

end
