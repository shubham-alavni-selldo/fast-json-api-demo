class Page < ApplicationRecord

  acts_as_list :scope => :subject

  belongs_to :subject, { :optional => false }
  has_many :sections
  has_and_belongs_to_many :admin_users

  scope :visible, lambda { where(:visible => true) }
  scope :invisible, lambda { where(:visible => false) }
  scope :sorted, lambda { order("position ASC") }
  scope :newest_first, lambda { order("created_at DESC") }

  validates_presence_of :name
  validates_length_of :name, :maximum => 255
  validates_presence_of :permalink
  validates_length_of :permalink, :within => 3..255
  # use presence_of with length_of to disallow spaces
  validates_uniqueness_of :permalink
  # for unique values by subject use ":scope => :subject_id"
  # before_create :generate_permalink

  def self.generate_page
    position = Page.pluck(:position).uniq.max.to_i + 1
    Page.create!({
      name: Faker::Book.title,
      position: position,
      visible: [true,false].sample,
      subject_id: Subject.ids.sample,
      permalink: SecureRandom.urlsafe_base64(32)
    })
  end

  def self.generate_pages(number_of_pages)
    number_of_pages.times do
      generate_page
    end
  end

  def generate_permalink
    self.permalink = SecureRandom.urlsafe_base64(32)
  end

end
