class Subject < ApplicationRecord

  acts_as_list

  has_many :pages
  has_many :sections, through: :pages
  scope :visible, lambda { where(:visible => true) }
  scope :invisible, lambda { where(:visible => false) }
  scope :sorted, lambda { order("position ASC") }
  scope :newest_first, lambda { order("created_at DESC") }
  scope :search, lambda {|query| where(["name LIKE ?", "%#{query}%"]) }

  validates_presence_of :name
  validates_length_of :name, :maximum => 255
  # validates_presence_of vs. validates_length_of :minimum => 1
  # different error messages: "can't be blank" or "is too short"
  # validates_length_of allows strings with only spaces!

  def self.generate_subject
    position = Subject.pluck(:position).uniq.max.to_i + 1
    Subject.create!({
      name: Faker::Book.genre,
      position: position,
      visible: [true,false].sample
    })
  end

  def self.generate_subjects(number_of_subjects)
    number_of_subjects.times do
      generate_subject
    end
  end

end
