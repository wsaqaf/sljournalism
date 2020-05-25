class ChangeBountyAmountInClaimsToRewardAmount < ActiveRecord::Migration[5.2]
  def change
    rename_column :claims, :bounty_amount, :reward_amount
  end
end
