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

class TeamLevel

  Primary    = "1"
  Elementary = "2"
  Middle     = "3"
  Secondary  = "4"
  University = "5"
  DiLater    = "6"

  MinLevel = Primary
#  MinLevel = Elementary
  MaxLevel = DiLater

  OptionList = [
    [ Primary,    "Rising Star" ],
    [ Elementary, "Elementary"  ],
    [ Middle,     "Middle"      ],
    [ Secondary,  "Secondary"   ],
    [ University, "University"  ],
    [ DiLater,    "DI Later"    ]
  ]

  Options = {}
  OptionList.each { |k,v| Options[k] = v }

  RestrictedOptions = Options.dup
  RestrictedOptions.delete(University)
  RestrictedOptions.delete(DiLater)
  
  RuleData = Struct.new(:min_age, :max_age, :min_grade, :max_grade)

  Rules = {
    Primary    => RuleData.new( 4,   9,  0,  2),
    Elementary => RuleData.new( 5,  11,  0,  5),
    Middle     => RuleData.new(12,  14,  6,  8),
    Secondary  => RuleData.new(15,  18,  9, 12),
    University => RuleData.new(999, 13, 13),
    DiLater    => RuleData.new(999, 14, 14)
  }

  # Options array for ddlb's
  def TeamLevel.options(include_higher=true)
    if include_higher
      Options
    else
      RestrictedOptions
    end
  end

  # Is the given level primary?
  def TeamLevel.is_primary?(level)
    level.to_s == TeamLevel::Primary
  end


  # Verify that a team with a given maximum age and min and max school
  # grades can compete at a given level. If the age is < 0, then
  # don't check based on it

  def TeamLevel.verify(level, max_age, min_grade, max_grade)
    level = level.to_s

    rule = Rules[level] or raise "Invalid level #{level.inspect}"

    # University level - no check on age, but everyone must
    # be in a university
    if level == University
      if min_grade < rule.min_grade || max_grade < rule.min_grade
        return "All team members must be in university/military at this level"
      else
        return nil
      end
    end

    # DI Later level - no check on age, but everyone must
    # be in a university
    if level == DiLater
      if min_grade < rule.min_grade || max_grade < rule.min_grade
        return "All team members must be adults who aren't in university or the military"
      else
        return nil
      end
    end

    # otherwise, either the age or the grade must be ok
    return nil if max_grade <= rule.max_grade && max_grade >= rule.min_grade

    return nil if max_age > 0 && max_age >= rule.min_age && max_age <= rule.max_age

    # Or try and give some guidance
    min = rule.min_grade
    min = 'K' if min == 0

    return  "To participate at #{Options[level]} level: " +
      " (1) The oldest team member must be between #{rule.min_age} and " +
      "#{rule.max_age} years old, or " +
      " (2) The highest grade of any team member must be between grades " +
      "#{min} and #{rule.max_grade}. This team doesn't seem to follow these rules. " +
      "We have registered it, but you might want to contact your AD to discuss " +
      "whether it can compete at this level."
    
  end

end
