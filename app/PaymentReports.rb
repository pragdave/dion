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

require 'app/Application'
require 'app/PaymentReportsTemplates'

class PaymentReports < Application

  app_info(:name => "PaymentsReports")

  class AppData
    attr_accessor :start_date
    attr_accessor :end_date
  end

  def app_data_type
    AppData
  end

  ######################################################################

  def daily_money_reports
    @data.start_date = DionDate.new("start", Time.now)
    @data.end_date   = DionDate.new("end",   Time.now)
    daily_money_common
  end

  def daily_money_common
    values = { 'form_url' => url(:produce_report) }

    @data.start_date.add_to_hash(values)
    @data.end_date.add_to_hash(values)

    standard_page("Money Report", values, DAILY_MONEY_REPORT_DATES)
  end


  def produce_report
    values = hash_from_cgi

    @data.start_date.from_hash(values)
    @data.end_date.from_hash(values)
    
    errors = @data.start_date.error_list + @data.end_date.error_list

    if errors.empty? && @data.start_date > @data.end_date
      errors = [ "Start date is after end date" ]
    end

    unless errors.empty?
      error_list(errors)
      return daily_money_common
    end

    case values['type'].strip
    when "DIRECT CHECKS"
      payment_report("Check", PaymentMethod::CHECK)
    when "CREDIT CARDS"
      payment_report("CC", PaymentMethod::CC)
    when "PURCHASE ORDERS"
      payment_report("PO", PaymentMethod::PO)
    when "CHECKS PAYING POs"
      checks_paying_pos_report
    when "ALL CHECKS AND CCs"
      summary_report
    else
      raise "Unknown report type: '#{values['type'].inspect}'"
    end

  end


  def payment_report(name, pay_type)
    payments = Payment.daily_report(@data.start_date,
                                    @data.end_date,
                                    pay_type)

    report_common(name, payments)
  end


  def checks_paying_pos_report
    payments = Payment.daily_checks_paying_pos(@data.start_date,
                                               @data.end_date)
    
    report_common("Checks Paying PO", payments, true)
  end


  def summary_report
    direct_checks = Payment.daily_report(@data.start_date,
                                    @data.end_date,
                                    PaymentMethod::CHECK)

    ccs = Payment.daily_report(@data.start_date,
                                    @data.end_date,
                                    PaymentMethod::CC)

    po_checks = Payment.daily_checks_paying_pos(@data.start_date,
                                                @data.end_date)

    # we make the checks that pay the POs look like original checks
    
    po_checks = po_checks.each do |pay|
      pay.pay_processed = pay.pay_paying_processed
      pay.pay_our_ref   = pay.pay_paying_check_our_ref
      pay.pay_doc_ref   = pay.pay_paying_check_doc_ref
      pay.pay_payor     = pay.pay_paying_check_payor
    end

    all_checks = direct_checks + po_checks

    if all_checks.empty? && ccs.empty?
      note "No payments processed in date range specified"
      return daily_money_common
    end

    values = {}
    unless all_checks.empty?
      values['checks'] = [ payment_values("All Checks", all_checks, false) ]
    end

    unless ccs.empty?
      values['ccs'] = [ payment_values("Credit Cards", ccs, false) ]
    end

    standard_page("Overall Summary", values, OVERALL_SUMMARY, DAILY_SUMMARY, DAILY_SUMMARY)

  end

  def report_common(name, payments, two_line=false)
    if payments.empty?
      note "No #{name}s processed in date range specified"
      return daily_money_common
    end

    values = payment_values(name, payments, two_line)
    standard_page("#{name} Summary", values, 
                  two_line ? DAILY_SUMMARY_TWOLINE : DAILY_SUMMARY)
  end

  def payment_values(name, payments, two_line)

    total = 0.0
    count = 0
    list = payments.map do |pay|
      count += 1
      total += pay.pay_amount
      pay.add_to_hash({})
    end

    values = {
      'start' => @data.start_date.to_s,
      'end'   => @data.end_date.to_s,
      'type'  => name,
      'count' => count,
      'total' => fmt_money(total),
      'list' => list
    }
  end


end
