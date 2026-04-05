class AddForeignKeyToCreatesOnWorkId < ActiveRecord::Migration[7.2]
  def change
    Create.find_each do |i|
      i.destroy unless i.agent
      i.destroy unless i.work
    end
    Realize.find_each do |i|
      i.destroy unless i.agent
      i.destroy unless i.expression
    end
    Produce.find_each do |i|
      i.destroy unless i.agent
      i.destroy unless i.expression
    end
    Own.find_each do |i|
      i.destroy unless i.agent
      i.destroy unless i.item
    end

    add_foreign_key :creates, :agents
    add_foreign_key :creates, :manifestations, column: :work_id
    add_foreign_key :realizes, :agents
    add_foreign_key :realizes, :manifestations, column: :expression_id
    add_foreign_key :produces, :agents
    add_foreign_key :produces, :manifestations
    add_foreign_key :owns, :agents
    add_foreign_key :owns, :items
  end
end
