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

# Calculate and display affiliate fees on cycle

require 'app/CyclesTemplates'
require 'bo/Affiliate'
require 'bo/CycleData'
require 'bo/FeeCycle'
require 'reports/ReportsTemplates'

class Cycles < Application

  app_info(:name            => :Cycles,
           :login_required  => true)


  class AppData
    attr_accessor :fee_cycle
  end

  def app_data_type
    AppData
  end


  # Display a summary of the current fees for each affiliate
  def display_summary
    values = CycleData.summary_list
    values['summary'].each do |aff_entry|
      aff_entry['display_url'] = url(:display_affiliate, aff_entry['aff_id'])
    end

    standard_page("Affiliate Fee Summary", values, FEE_SUMMARY)
  end


  # Display details on a particuar affiliate
  def display_affiliate(aff_id)
    values = CycleData.values_for(aff_id)
    $stderr.puts values.inspect
    aff = Affiliate.with_id(aff_id)
    aff.add_to_hash(values)

    popup_page("Fees for #{values['aff_long_name']}",
               values,
               FEE_DETAILS)
  end

  # Wind up the current cycle and report on it
  def complete_cycle
    values = {
      'ok_url'     => url(:run_cycle),
      'cancel_url' => url(:cancel_cycle)
    }


    fee_cycle = FeeCycle.latest_cycle

    if fee_cycle
      values['last_date'] = fee_cycle.fmt_date
    end

    standard_page("Run Affiliate Fees", values, OK_TO_RUN_FEES)
  end

  def cancel_cycle
    note "Cycle processing canceled"
    @session.pop
  end

  # During the first part of cycle processing, we lock the FeeCycle
  # table, grab the next free cycle number, and use it to stamp
  # all the currently unstamped rows in the AffiliateFee table.
  # After this, we can release the lock and generate the reports
  # from that cycle id.

  def run_cycle
    count = 0
    fee_cycle = nil
    $store.transaction do
      $store.lock_table(FeeCycleTable)
      fee_cycle = FeeCycle.new
      fee_cycle.save

      count = AffiliateFee.put_unassigned_in_cycle(fee_cycle)
    end

    if count.zero?
      note "No fees are due to affiliates"
      @session.pop
      return
    end

    finish(fee_cycle)
  end

  # Finalize a cycle
  def finish(fee_cycle)
    @data.fee_cycle = fee_cycle
    values = {
      'cycle_id'   => fee_cycle.cycle_id,
      'print_url'  => url(:generate_reports_for),
      'cancel_url' => url(:dont_print),
      'include_empty' => false
    }
    standard_page("Print Statements", values, MAYBE_PRINT_STATEMENTS)
  end

  def dont_print
    @session.pop
  end

  # Produce the nice reports for this cycle
  def generate_reports_for
    fee_cycle = @data.fee_cycle
    include_empty = @cgi['include_empty'].downcase == 'on'

    report_path = nil
    report_data = []

    affiliates = Affiliate.list

    affiliates.each do |aff|
      # Don't do headquarters...
      next if aff.aff_id.zero?

      data = CycleData.values_for(aff.aff_id, fee_cycle.cycle_id)

      if data['fees'] || data['refunds'] || include_empty
        add_data_for_report(aff, fee_cycle, data)
        report_data << data
      end
    end

    unless report_data.empty?
      values = {
        'cycle_list' => report_data
      }

      report_path =  print_report(values, Reports::AFFILIATE_FEE_STATEMENT)

      if report_path
        values = {
          'report_url' => report_path
        }
        standard_page("Affiliate Fees", values, Reports::SHOW_REPORT)
      else
        error "Error producing reports"
        @session.pop
      end
    else
      note "Nothing to print"
      @session.pop
    end
  end

  def add_data_for_report(affiliate, fee_cycle, values)
    values['aff_long_name'] = affiliate.aff_long_name
    values['cycle_id']      = fee_cycle.cycle_id
    values['fmt_cycle_date'] = fee_cycle.fmt_date
    values['print_date']     = Time.now.strftime("%d-%b-%y %H:%M")
  end
end
