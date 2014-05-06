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

require "bo/TeamLevel"

class ChallengeDownload < BusinessObject

  NUM_PDFS = 7
  
  def ChallengeDownload.with_id(cdl_id)
    maybe_return($store.select_one(ChallengeDownloadTable, "cdl_id=?", cdl_id))
  end


  Pdf = Struct.new(:lang, :path)

  ######################################################################

  def initialize(data_object = nil)
    @data_object = data_object || fresh_challengedownload
    @pdfs = []
    for i in 1..NUM_PDFS
      lang = @data_object.send("cdl_lang_#{i}")
      path = @data_object.send("cdl_pdf_path_#{i}")
      @pdfs << Pdf.new(lang, path)
    end
  end

  def fresh_challengedownload
    c = ChallengeDownloadTable.new
    c.cdl_desc = ''
    c.cdl_pdf_path_1  = ''
    c.cdl_lang_1      = 'English'
    c.cdl_icon_url    = ''
    c.cdl_pdf_path_1  = ''
    c
  end


  def add_to_hash(values)
    values['cdl_desc']         = @data_object.cdl_desc
    values['cdl_icon_url']     = @data_object.cdl_icon_url

    NUM_PDFS.times do |i|
      values["cdl_lang_#{i}"]     = @pdfs[i].lang
      values["cdl_pdf_path_#{i}"] = @pdfs[i].path
    end
    values
  end

  def from_hash(values)
    @data_object.cdl_desc     = values['cdl_desc']
    @data_object.cdl_icon_url = values['cdl_icon_url']

    NUM_PDFS.times do |i|
       @pdfs[i].lang = values["cdl_lang_#{i}"]     
       @pdfs[i].path = values["cdl_pdf_path_#{i}"] 
    end

    @pdfs[0].lang = 'English'
  end


  def save(with_primary_key=nil)
$stderr.puts "Saving"
$stderr.puts inspect
    for i in 1..NUM_PDFS
      pdf = @pdfs[i-1]
      @data_object.send("cdl_lang_#{i}=", pdf.lang)
      @data_object.send("cdl_pdf_path_#{i}=", pdf.path)
    end
    super(with_primary_key)
  end


  def error_list
    c = @data_object
    errs = []
    errs << "Missing description"    if c.cdl_desc.empty?
    errs << "Missing icon url"       if c.cdl_icon_url.empty?

    @pdfs.each do |pdf|
      if !pdf.lang.empty? && pdf.path.empty?
        errs << "Missing pdf file for language '#{pdf.lang}'"
      elsif pdf.lang.empty? && !pdf.path.empty?
        errs << "Missing language for pdf '#{pdf.path}'"
      end
      unless pdf.path.empty?
        if pdf.path =~ %r{^[-\w/.]+$}
          pdf.path.untaint
          errs << "File #{pdf.path} not found" unless File.exist?(pdf.path)
        else
          errs << "Invalid path #{pdf.path}" 
        end
      end
    end

    if @pdfs[0].path.empty?
      errs << "Missing English pdf file name"
    end

    errs
  end

  
  # Return a list of non-empty pdfs
  def nonempty_pdfs
    @pdfs.select {|p| !p.lang.empty?}
  end

end
