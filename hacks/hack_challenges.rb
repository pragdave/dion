require 'db/Store'
require 'bo/Affiliate'
require 'bo/ChallengeDesc'
require 'bo/Challenge'

$store = Store.new(*ARGV)

affiliates = Affiliate.list
all_challenges = ChallengeDesc.list

affiliates.each do |aff|
  aff_challenges = Challenge.for_affiliate(aff.aff_id)

  need_to_add = all_challenges.dup

  aff_challenges.each do |aff_cha|
    need_to_add.delete_if {|chd| chd.chd_id == aff_cha.cha_chd_id }
  end

  unless all_challenges.size == need_to_add.size + aff_challenges.size
    raise "Bad counts for affiliate id #{aff.aff_id}"
  end

  need_to_add.each do |chd|
    cha = Challenge.new
    cha.cha_chd_id = chd.chd_id
    cha.cha_aff_id = aff.aff_id
    cha.cha_levels = chd.chd_levels
    puts "#{cha.cha_chd_id} #{cha.cha_aff_id} #{cha.cha_levels}"
    cha.save
  end

end

