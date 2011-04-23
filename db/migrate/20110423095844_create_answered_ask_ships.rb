class CreateAnsweredAskShips < ActiveRecord::Migration
  def self.up
    create_table :answered_ask_ships do |t|
      t.integer :user_id
      t.integer :ask_id
      t.timestamps
    end
  end

  def self.down
    drop_table :answered_ask_ships
  end
end