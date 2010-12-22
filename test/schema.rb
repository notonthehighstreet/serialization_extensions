ActiveRecord::Schema.define :version => 0 do
  create_table :people, :force => true do |t|
    t.column :name, :string
    t.column :country, :string
    t.column :birthdate, :date
    t.column :lucky_number, :integer
    t.column :child_id, :integer
    t.column :updated_at, :datetime
    t.column :updated_on, :datetime
  end
end
