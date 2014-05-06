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

require 'bo/BusinessObject'

class Address < BusinessObject

  USA = "U.S.A."

  US_MAP = {
    "" => 1,
    "us" => 1, 
    "usa" => 1, 
    "unitedstates" => 1,
    "unitedstatesofamerica" => 1,
    "usofa" => 1
  }

  STATE_TO_ABBREV = {
    # APOs
    "AA" => "AA",
    "AE" => "AE",
    "AP" => "AP",

    # Regular
    "ALASKA"               => "AK",   "AK" => "AK",
    "ALABAMA"              => "AL",   "AL" => "AL",
    "ARKANSAS"             => "AR",   "AR" => "AR",
    "ARIZONA"              => "AZ",   "AZ" => "AZ",
    "CALIFORNIA"           => "CA",   "CA" => "CA",
    "COLORADO"             => "CO",   "CO" => "CO",
    "CONNECTICUT"          => "CT",   "CT" => "CT",
    "DISTRICT OF COLUMBIA" => "DC",   "DC" => "DC",
    "DELAWARE"             => "DE",   "DE" => "DE",
    "FLORIDA"              => "FL",   "FL" => "FL",
    "GEORGIA"              => "GA",   "GA" => "GA",
    "GUAM"                 => "GU",   "GU" => "GU",
    "HAWAII"               => "HI",   "HI" => "HI",
    "IOWA"                 => "IA",   "IA" => "IA",
    "IDAHO"                => "ID",   "ID" => "ID",
    "ILLINOIS"             => "IL",   "IL" => "IL",
    "INDIANA"              => "IN",   "IN" => "IN",
    "KANSAS"               => "KS",   "KS" => "KS",
    "KENTUCKY"             => "KY",   "KY" => "KY",
    "LOUISIANA"            => "LA",   "LA" => "LA",
    "MASSACHUSETTS"        => "MA",   "MA" => "MA",
    "MARYLAND"             => "MD",   "MD" => "MD",
    "MAINE"                => "ME",   "ME" => "ME",
    "MICHIGAN"             => "MI",   "MI" => "MI",
    "MINNESOTA"            => "MN",   "MN" => "MN",
    "MISSOURI"             => "MO",   "MO" => "MO",
    "MISSISSIPPI"          => "MS",   "MS" => "MS",
    "MONTANA"              => "MT",   "MT" => "MT",
    "NORTH CAROLINA"       => "NC",   "NC" => "NC",
    "NORTH DAKOTA"         => "ND",   "ND" => "ND",
    "NEBRASKA"             => "NE",   "NE" => "NE",
    "NEW HAMPSHIRE"        => "NH",   "NH" => "NH",
    "NEW JERSEY"           => "NJ",   "NJ" => "NJ",
    "NEW MEXICO"           => "NM",   "NM" => "NM",
    "NEVADA"               => "NV",   "NV" => "NV",
    "NEW YORK"             => "NY",   "NY" => "NY",
    "OHIO"                 => "OH",   "OH" => "OH",
    "OKLAHOMA"             => "OK",   "OK" => "OK",
    "OREGON"               => "OR",   "OR" => "OR",
    "PENNSYLVANIA"         => "PA",   "PA" => "PA",
    "PUERTO RICO"          => "PR",   "PR" => "PR",
    "RHODE ISLAND"         => "RI",   "RI" => "RI",
    "SOUTH CAROLINA"       => "SC",   "SC" => "SC",
    "SOUTH DAKOTA"         => "SD",   "SD" => "SD",
    "TENNESSEE"            => "TN",   "TN" => "TN",
    "TEXAS"                => "TX",   "TX" => "TX",
    "UTAH"                 => "UT",   "UT" => "UT",
    "VIRGINIA"             => "VA",   "VA" => "VA",
    "VIRGIN ISLANDS"       => "VI",   "VI" => "VI",
    "VERMONT"              => "VT",   "VT" => "VT",
    "WASHINGTON"           => "WA",   "WA" => "WA",
    "WISCONSIN"            => "WI",   "WI" => "WI",
    "WEST VIRGINIA"        => "WV",   "WV" => "WV",
    "WYOMING"              => "WY",   "WY" => "WY",
  }

  ZIPS = { 
    "AA" => [ 34000..34099                             ],
    "AE" => [  9000..9999                              ],
    "AK" => [ 99500..99929                             ], 
    "AL" => [ 35000..36999                             ],
    "AP" => [ 96200..96599                             ], 
    "AR" => [ 71600..72999, 75502..75505               ], 
    "AZ" => [ 85000..86599                             ], 
    "CA" => [ 90000..96199                             ], 
    "CO" => [ 80000..81699                             ], 
    "CT" => [  6000..6999                              ], 
    "DC" => [ 20000..20099, 20200..20599               ], 
    "DE" => [ 19700..19999                             ], 
    "FL" => [ 32000..33999, 34100..34999               ], 
    "GA" => [ 30000..31999                             ], 
    "HI" => [ 96700..96798, 96800..96899               ], 
    "IA" => [ 50000..52999                             ], 
    "ID" => [ 83200..83899                             ], 
    "IL" => [ 60000..62999                             ], 
    "IN" => [ 46000..47999                             ], 
    "KS" => [ 66000..67999                             ], 
    "KY" => [ 40000..42799, 45275..45275               ], 
    "LA" => [ 70000..71499, 71749..71749               ], 
    "MA" => [  1000..2799                              ], 
    "MD" => [ 20331..20331, 20600..21999               ], 
    "ME" => [  3801..3801,  3804..3804,  3900..4999 ], 
    "MI" => [ 48000..49999                             ], 
    "MN" => [ 55000..56799                             ], 
    "MO" => [ 63000..65899                             ], 
    "MS" => [ 38600..39799                             ], 
    "MT" => [ 59000..59999                             ], 
    "NC" => [ 27000..28999                             ], 
    "ND" => [ 58000..58899                             ], 
    "NE" => [ 68000..69399                             ], 
    "NH" => [  3000..3803,   3809..3899                ], 
    "NJ" => [  7000..8999                              ], 
    "NM" => [ 87000..88499                             ], 
    "NV" => [ 89000..89899                             ], 
    "NY" => [   400..599,    6390..6390,   9000..14999 ], 
    "OH" => [ 43000..45999                             ], 
    "OK" => [ 73000..73199, 73400..74999               ], 
    "OR" => [ 97000..97999                             ], 
    "PA" => [ 15000..19699                             ], 
    "RI" => [  2800..2999,   6379..6379                ], 
    "SC" => [ 29000..29999                             ], 
    "SD" => [ 57000..57799                             ], 
    "TN" => [ 37000..38599, 72395..72395               ], 
    "TX" => [ 73300..73399, 73949..73949, 75000..79999, 88501..88599 ], 
    "UT" => [ 84000..84799                             ], 
    "VA" => [ 20105..20199, 20301..20301, 20370..20370, 22000..24699 ], 
    "VT" => [  5000..5999                              ],  
    "WA" => [ 98000..99499                             ], 
    "WI" => [ 49936..49936, 53000..54999               ], 
    "WV" => [ 24700..26899                             ], 
    "WY" => [ 82000..83199                             ]
  } 

  def valid_zip(state, zip)
    zip = zip.to_i
    zips = ZIPS[state]
    if zips
      zips.each {|range| return true if range === zip }
    end
    false
  end

  def Address.with_id(add_id)
    maybe_return($store.select_one(AddressTable, "add_id=?", add_id))
  end


  def initialize(data_object=nil)
    if data_object
      @data_object = data_object
    else
      @data_object = AddressTable.new
      @data_object.add_line1 = 
        @data_object.add_line2 =
        @data_object.add_city =
        @data_object.add_county =
        @data_object.add_state =
        @data_object.add_zip =
        @data_object.add_country = ''
      @data_object.add_commercial = false
      @data_object.reset_changed
    end
  end


  def from_hash(values, prefix=nil)
    prefix ||= ""
    @data_object.add_line1   = values[prefix + "add_line1"]
    @data_object.add_line2   = values[prefix + "add_line2"]
    @data_object.add_city    = values[prefix + "add_city"]
    @data_object.add_county  = values[prefix + "add_county"]
    @data_object.add_state   = values[prefix + "add_state"]
    @data_object.add_zip     = values[prefix + "add_zip"]
    @data_object.add_country = values[prefix + "add_country"]
    @data_object.add_commercial = bool(values[prefix + "add_commercial"])
  end

  # Dont save away an empty address
  def save
#    if empty?
#      nil
#    else
      super
#    end
  end

  # Is this address empty?

  def empty?
    a = @data_object

    (a.add_line1.nil? || a.add_line1.empty?) &&
     (a.add_line2.nil? || a.add_line2.empty?) &&
     (a.add_city.nil? || a.add_city.empty?) &&
     (a.add_county.nil? || a.add_county.empty?) &&
     (a.add_state.nil? || a.add_state.empty?) &&
     (a.add_zip.nil? || a.add_zip.empty?) &&
     (a.add_country.nil? || a.add_country.empty?)
  end

  # Check for any errors in the address.

  def error_list(strict, add_type)
    res = []

    unless self.empty?
      a = @data_object

      res << "Missing #{add_type} address line 1" if a.add_line1.empty?
      res << "Missing #{add_type} city" if a.add_city.empty?
      res << "Missing #{add_type} state" if a.add_state.empty?

      normalize_country

      if a.add_country == USA
        
        state = a.add_state.strip.upcase
        
        state = STATE_TO_ABBREV[state]

        if state.nil?
          res << "Unknown state #{a.add_state} in #{add_type} address"
        else
          zip = a.add_zip.strip
          if zip.empty?
            res << "Missing #{add_type} zip code" 
          else
            if zip =~ /^(\d{5})(-\d{4})?$/
              unless valid_zip(state, $1)
                res << "Zip code #{zip} does not belong in #{state}"
              end
            else
              res << "Invalid format for #{add_type} zip code (five digits expected)"
            end
          end
        end
      end

      check_length(res, a.add_line1,   100, "address line 1")
      check_length(res, a.add_line2,   100, "address line 2")
      check_length(res, a.add_city,    100, "city")
      check_length(res, a.add_county,  100, "county")
      check_length(res, a.add_state,    20, "address line 1")
      check_length(res, a.add_zip,      12, "zip/postal code")
      check_length(res, a.add_country, 100, "zip/postal code")
    end

    res
  end


  # If the country is missing, assume U.S.A. Otherwise,
  # see if it's a variant of USA and normalize it

  def normalize_country
    c =  @data_object.add_country.strip

    c = c.downcase.gsub(/[\. ]/, '').sub(/^the/, '')
   
    if US_MAP[c]
      @data_object.add_country = USA
    end

  end


  # Return an address as a single string

  def to_s
    add = ""
    
    if add_line1 || !add_line1.empty?
      add << add_line1 << "\r\n"
    end
      
    if add_line2 || !add_line2.empty?
      add << add_line2 << "\r\n"
    end
      
    if add_city
      add << add_city << ", "
    end

    add << add_state if add_state

    if add_zip
      add << " " << add_zip << "\r\n" 
    end

    if add_country
      add << add_country << "\r\n"
    end

    add
  end
end
