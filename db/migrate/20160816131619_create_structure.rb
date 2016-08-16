class CreateStructure < ActiveRecord::Migration
  def change
    # Users table
    create_table :users do |t|
      t.string :username, null: false
      t.string :name, null: false
      t.string :color
      t.string :avatar_url
      t.timestamps
    end
    add_index :users, :username, :unique => true

    # Spaces table
    create_table :spaces do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.timestamps
    end
    add_index :spaces, :name, :unique => true
    add_index :spaces, :code, :unique => true

    # Bookings table
    create_table :bookings do |t|
      t.references :user
      t.references :space, index: true
      t.string :purpose
      t.integer :state
      t.datetime :start_time
      t.datetime :end_time
      t.timestamps
    end
  end
end
