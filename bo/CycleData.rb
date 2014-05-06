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

# Help in the calculation of affiliate fees on cycle

require "util/Formatters"

class CycleData

  class <<self
    include Formatters
  end

  # Return an affiliate-by-affiliate summary of where
  # we stand. We return an array of hashes that can be 
  # fed into the template code

  def CycleData.summary_list
    sql = 
      "select afee_aff_id, aff_long_name, " +
      "        sum(case when afee_paid_in_cycle is null then 0 else afee_amount end) as prev_total, " +
      "        sum(case when afee_paid_in_cycle is null then afee_amount else 0 end) as this_cycle " +
      "  from affiliate_fee, affiliate " +
      " where afee_aff_id=aff_id " +
      " group by afee_aff_id, aff_long_name " +
      " order by aff_long_name"

    res = $store.raw_select(sql)

    sum_prev_total = sum_this_cycle = sum_ytd_total = 0.0

    list = res.map do |row|
      prev_total = Float(row[2])
      this_cycle = Float(row[3])
      ytd_total  = prev_total + this_cycle
      sum_prev_total += prev_total
      sum_this_cycle += this_cycle
      sum_ytd_total  += ytd_total

      {
        'aff_id'        => row[0],
        'aff_long_name' => row[1],
        'prev_total'    => fmt_money(prev_total),
        'this_cycle'    => fmt_money(this_cycle),
        'ytd_total'     => fmt_money(ytd_total),
      }
    end

    {
      'summary' => list,
      'sum_prev_total'    => fmt_money(sum_prev_total),
      'sum_this_cycle'    => fmt_money(sum_this_cycle),
      'sum_ytd_total'     => fmt_money(sum_ytd_total),
    }
  end


  # Return all the fee information for a particular affiliate for the current
  # cycle

  def CycleData.values_for(aff_id, cycle_id=nil)
    sql = 
      "select afee_amount, afee_date_created, afee_desc, prd_long_desc, " +
      "       mem_passport_prefix, mem_passport "   +
      "  from affiliate_fee, line_item, products, " +
      "       orders left outer join membership on mem_id=order_mem_id " +
      " where afee_sale_id=li_id "   +
      "   and li_order_id=order_id " +
      "   and li_prd_id=prd_id " +
      "   and afee_paid_in_cycle #{cycle_id ? \"= #{cycle_id}\" : 'is null'} " +
      "   and afee_aff_id=?" +
      " order by afee_date_created"

    $stderr.puts sql
    coll_detail = {}
    ref_detail  = {}
    total = 0.0

    $store.raw_select(sql, aff_id).each do |amount, date, fee_desc, prd_desc, prefix, passport|
      amount = Float(amount)
      if passport
        fee_desc = fee_desc + " \##{prefix}-#{passport}"
      end
      if amount > 0
        coll_detail[prd_desc] ||= []
        coll_detail[prd_desc] << [ date, amount, fee_desc ]
        total += amount
      else
        ref_detail[prd_desc] ||= []
        ref_detail[prd_desc] << [ date, amount, fee_desc ]
        total -= amount
      end
    end

    fees = detail_list(coll_detail)
    refunds = detail_list(ref_detail)

    res = {}
    res['fees'] = fees unless fees.empty?
    res['refunds'] = refunds unless refunds.empty?
    res['total']   = fmt_money(total)
    res
  end


  # Return a list of all the fees or refunds

  def CycleData.detail_list(list)
    list.map do |prd_desc, details|
      total = 0
      det = []
      details.each do |date, amount, fee_desc|
        total += amount
        det << {
          'date'   => date.to_time.strftime("%d-%b-%y"), 
          'amount' => fmt_money(amount),
          'fee_desc' => fee_desc
        }
      end

      { 
        'prd_desc'  => prd_desc,
        'qty'       => details.size,
        'details'   => det,
        'total'     => fmt_money(total)
      }
    end
  end


  # Return the total amount of affiliate fees already paid
  def CycleData.aff_fees_paid
    sql = "select sum(afee_amount) from affiliate_fee where afee_paid_in_cycle is not null"
    res = $store.raw_select(sql)
    val = res[0][0]
    val = 0.00 if val.empty?
    val
  end

  # Return the total amount of affiliate fees not yet paid
  def CycleData.aff_fees_unpaid
    sql = "select sum(afee_amount) from affiliate_fee where afee_paid_in_cycle is null"
    res = $store.raw_select(sql)
    val = res[0][0]
    val = 0.00 if val.empty?
    val
  end


end
