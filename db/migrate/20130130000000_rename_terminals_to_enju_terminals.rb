class RenameTerminalsToEnjuTerminals < ActiveRecord::Migration
  def change
    rename_table :terminals, :enju_terminals
  end
end
