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

store_2002 = Store.new('DBI:Pg:dion_2002', 'dion', '')
store_2003 = Store.new('DBI:Pg:dion', 'dion', '')


######################################################################

class Counts
  attr_reader :min_date, :max_date

  def initialize(sql, store, date, offset)
    @data = {}

    @min_date = nil
    @max_date = nil

    @max_count = -1

    store.raw_select(sql, date) do |date, count|
      count = count.to_i
      date_bits = date.split('-').map{|n| n.to_i}
      date_bits[0] -= offset
      date = Date.new(*date_bits)
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

gdc.title = "Active TeamPaks 2003 (red) and 2002 (blue)"
#gdc.title_size = GDChart::GIANT
gdc.image_type = GDChart::PNG

gdc.BGColor = 0xf8FFf8

now = Time.now
this_year = sprintf("%04d-%02d-%02d", now.year, now.month, now.day)
last_year = sprintf("%04d-%02d-%02d", now.year-1, now.month, now.day)

sql = "
select to_char(mem_dt_activated, 'yyyy-mm-dd'), count(*)
from membership 
where mem_state = 'ACTIVE' and mem_dt_activated < ?
group by 1 order by 1"

count_2003 = Counts.new(sql, store_2003, this_year, 1)
count_2002 = Counts.new(sql, store_2002, '2003-02-01', 0)

sql = "
select to_char(mem_dt_activated, 'yyyy-mm-dd'), count(*)
from membership 
where mem_state = 'ACTIVE' and mem_dt_activated < ?
and mem_affiliate not in (128,129,144,145)
group by 1 order by 1"

count_2003_nosa = Counts.new(sql, store_2003, this_year, 1)

min_date = count_2002.min_date
max_date = count_2002.max_date

min_date = count_2003.min_date if !min_date || count_2003.min_date < min_date
max_date = count_2003.max_date if !max_date || count_2003.max_date > max_date

data_2003_nosa = []
data_2003 = []
data_2002 = []
label = []

sum_2002 = 0
sum_2003 = 0
sum_2003_nosa = 0

color_2003 = []
color_2002 = []
color_2003_nosa = []

date_iterator(min_date, max_date) do |date|
  sum_2002 += (count_2002[date] || 0)
  sum_2003 += (count_2003[date] || 0)
  sum_2003_nosa += (count_2003_nosa[date] || 0)

  data_2003_nosa << sum_2003_nosa
  data_2003 << sum_2003
  data_2002 << sum_2002

  color_2002 << 0x3030a0
  color_2003 << (date <= count_2003.max_date.to_s ? 0xc07070 : 0xffffff)
  color_2003_nosa << (date <= count_2003.max_date.to_s ? 0x902020 : 0xffffff)
  label  << date.sub(/^\d\d\d\d-/, '')
end

gdc.ExtColor = color_2002 + color_2003 + color_2003_nosa

data = data_2002 + data_2003 + data_2003_nosa

label = label + label

gdc.out_graph(400, 250, $stdout, GDChart::LINE,
	      data_2003.length, label, 3, data)
