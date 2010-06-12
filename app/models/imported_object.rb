class ImportedObject < ActiveRecord::Base
  scope :items, :conditions => ['importable_type = ?', 'Item']
  scope :manifestations, :conditions => ['importable_type = ?', 'Manifestation']
  scope :patrons, :conditions => ['importable_type = ?', 'Patron']
  scope :events, :conditions => ['importable_type = ?', 'Event']

  belongs_to :importable, :polymorphic => true #, :validate => true
  belongs_to :imported_file, :polymorphic => true #, :validate => true

  validates_associated :importable, :imported_file
  validates_presence_of :importable, :imported_file

end
