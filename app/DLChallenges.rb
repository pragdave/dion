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

require 'app/Application.rb'
require 'app/DLChallengesTemplates'
require 'bo/News'
require 'bo/ChallengeDesc'
require 'bo/ChallengeDownload'

class DLChallenges < Application

  app_info(:name => :DLChallenges, :login_required  => true)

  class AppData
  end

  def app_data_type
    AppData
  end

  ######################################################################

  def display_dl_copyright
    values = {}
    values['ok_url'] = url(:display_challenges)
    values['not_ok_url'] = @context.url(Portal)
    standard_page("Challenge Copyright", values, DL_COPYRIGHT)
  end

  ######################################################################

  def display_challenges
    challenges = ChallengeDesc.list
    odd = true
    list = challenges.map do |chd|
      cdl = ChallengeDownload.with_id(chd.chd_id)

      vals = {
        'name'    => chd.chd_name,
        'desc'    => News.convert_article(cdl.cdl_desc),
        'levels'  => chd.levels_as_string,
        'odd'     => (odd = !odd),
      }
      if cdl.cdl_icon_url &&!cdl.cdl_icon_url.empty?
        vals['icon_url'] = cdl.cdl_icon_url
      end

      dl_list = cdl.nonempty_pdfs.map do |pdf|
        base_url = url(:do_download, chd.chd_id, chd.chd_name, pdf.path)
        base_url += "/challenge-#{File.basename(pdf.path)}"
        {
          'lang' => pdf.lang,
          'dl_url'  => base_url
        }
      end

      vals['dl_list'] = dl_list

      vals
    end
    values = { 'list' =>  list }
    standard_page("Download Challenges", values, DOWNLOAD)
  end


  def do_download(chd_id, chd_name, path) 
    begin
      pdf = File.open(path) {|f| f.read}
    rescue
      error "That file is temporarily unavailable"
      display_challenges
      return
    end

    user = @session.user
    user.log("Downloaded challenge #{chd_name} (#{path})")
    user.role_add(user.user_affiliate,
                  user.user_region,
                  RoleNameTable::CHALLENGE_DOWNLOADER,
                  TargetTable::CHALLENGE,
                  chd_id)

#    req = Apache::request
#    req.cancel
    @request.status = Apache::HTTP_OK
    @request.content_type = 'application/pdf'
    hdrs = @request.headers_out
    @request['Content-Disposition'] = "attachment; filename=challenge-#{File.basename(path)}"
#    @request['Content-Description'] = chd_name
    hdrs['Content-Length'] = pdf.size.to_s
    @request.send_http_header
    @request << pdf

  end


end
