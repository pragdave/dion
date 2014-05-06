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

require 'web/Template'

class Reports

  @@count = 0

  BASE_DIR = File.dirname(File.expand_path(__FILE__))

  TMP_DIR = "/tmp"

  def generate(values, *templates)
    @@count += 1

    values['latex_dir'] = BASE_DIR

    target_sub_file = "op/#{rand(0x1000) * rand(0x1000)}.pdf"
    target_name = File.join(BASE_DIR, target_sub_file)

    script = File.dirname(ENV['SCRIPT_NAME'])

    target_url = File.join(script, "reports", target_sub_file)
 
    
    base_name = "#{$$}_#{@@count}"
    fname = File.join(TMP_DIR, base_name)
   
    File.open(fname + ".tex", "w") do |f|
      Template.new(*templates).write_tex_on(f, values)
    end

    res = os_cmd("cd #{TMP_DIR} && (TEXINPUTS=:#{BASE_DIR} pdflatex #{base_name}.tex)")
    if res
      res = os_cmd("cd #{TMP_DIR} && mv #{base_name}.pdf #{target_name}")
    end

    if res
      return target_url
    else
      return nil
    end
  end

  def os_cmd(cmd)
    $stderr.puts cmd
    cmd.untaint
    system(cmd + " 1>&2")
  end

end
