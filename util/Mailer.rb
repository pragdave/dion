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

# There's a bug in the 1.6.7 resolv.rb: it fails to untaint the
# lines read from /etc files, and hence fails when run under
# mod ruby. Our local version fixes this.

require 'util/resolv'

require "net/smtp"
require "Config"
require "web/Template"

class Mailer

  # simple regexp for name matching

  HostChars = %{-!#$%&\'*+\\/0-9=?A-Z_`a-z{|}~}
  NameChars = HostChars + '.'

  EmailRegexp = Regexp.new("^[#{NameChars}]+@([#{HostChars}]+(\.[#{HostChars}]+)+)$")

  def Mailer.invalid_email_address?(email)

    dns = Resolv::DNS.new
    
    begin
      
      unless EmailRegexp.match(email)
        return "Invalid format for e-mail address '#{email}'"
      end
      
      domain = $1.untaint
      
      begin
        dns.getresources(domain, Resolv::DNS::Resource::IN::A)
        return nil
      rescue Resolv::ResolvError
        begin
          dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
          return nil
        rescue Resolv::ResolvError
        end
      end
      
      return "Invalid mail address '#{email}'"
    ensure
#      dns.close
    end
  end

  def send_from_template(to, subject, values, template, force=false)

    return if Config::DEBUG && !force
    
    values = values.dup
    if to.kind_of? Array
      return if to.empty?
      to_string = to.join(", ")
    else
      return unless to && to.length > 0
      to_string = to
    end

    values["to"]      = to_string
    values["from"]    = Config::MAIL_SENDER
    values["subject"] = subject
    values["date"]    = Time.now.to_s

    msg = ""
    msg = Template.new(STD_HEADER, template).write_plain_on(msg, values)

    Net::SMTP.start(Config::SMTP_SERVER, 25 ) do |smtp|
      smtp.send_mail(msg, Config::MAIL_SENDER, to)
    end
  end

STD_HEADER =
"To: %to%
From: %from%
Subject: %subject%
Date: %date%

!INCLUDE!
"

end
