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

require 'date'
require 'GDChart'
require 'db/Store'
require 'Config'

config = Config.current
$store = Store.new(config.db_connect_string, config.db_user, config.db_pw)


######################################################################

class Counts
  attr_reader :min_date, :max_date

  def initialize(sql)
    @data = {}

    @min_date = nil
    @max_date = nil

    @max_count = -1

    $store.raw_select(sql) do |date, count|
      count = count.to_i
      date = Date.new(*date.split('-').map{|n| n.to_i})
      @data[date.to_s] = count
      @max_count = count if count > @max_count

      if @min_date
        @min_date = date if date < @min_date
        @max_date = date if date > @max_date
      else
        @min_date = @max_date = date
      end        
    end
  end

  def [](date)
    @data[date]
  end
end

######################################################################

def date_iterator(min, max)
  min.upto(max) do |dt|
    yield dt.to_s
  end
end

######################################################################

gdc = GDChart.new

gdc.title = "TeamPaks registered (green) and activated (blue)/day"
#gdc.title_size = GDChart::GIANT
gdc.image_type = GDChart::PNG

gdc.BGColor = 0xf8FFf8


sql = "
select to_char(mem_dt_activated, 'yyyy-mm-dd'), count(*)
from membership 
where mem_state = 'ACTIVE' and mem_dt_activated < date_trunc('day', now())
group by 1 order by 1"

actives = Counts.new(sql)

sql = "
select to_char(mem_dt_created, 'yyyy-mm-dd'), count(*)
from membership 
where mem_state <> 'SUSPND' and mem_dt_created < date_trunc('day', now())
group by 1 order by 1"

signups = Counts.new(sql)

min_date = actives.min_date
max_date = actives.max_date

min_date = signups.min_date if !min_date || signups.min_date < min_date
max_date = signups.max_date if !max_date || signups.max_date > max_date

s_data = []
a_data = []
label = []

date_iterator(min_date, max_date) do |date|
  s_data << (signups[date] || 0)
  a_data << (actives[date] || 0)
  label  << date.sub(/^\d\d\d\d-/, '')
end

max = s_data.max
factor = 63.0/max
s_color = s_data.map {|d| d *= factor; 0x808080 + d.to_i*0x010102; 0x80ff80}

max = a_data.max
if actives.min_date
  factor = 63.0/max
else
  factor = 1
end

a_color = a_data.map {|d| d *= factor; 0x808080 + d.to_i*0x010201; 0x8080ff}

gdc.ExtColor = a_color + s_color

data = a_data + s_data

label = label + label

gdc.out_graph(400, 250, $stdout, GDChart::BAR3D,
	      s_data.length, label, 2, data)
