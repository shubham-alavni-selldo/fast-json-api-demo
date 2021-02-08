class Section < ApplicationRecord

  # acts_as_list :scope => :subject

  belongs_to :page
  has_many :section_edits
  has_many :admin_users, :through => :section_edits

  scope :visible, lambda { where(:visible => true) }
  scope :invisible, lambda { where(:visible => false) }
  scope :sorted, lambda { order("position ASC") }
  scope :newest_first, lambda { order("created_at DESC") }

  CONTENT_TYPES = ['text', 'HTML']

  validates_presence_of :name
  validates_length_of :name, :maximum => 255
  validates_inclusion_of :content_type, :in => CONTENT_TYPES,
    :message => "must be one of: #{CONTENT_TYPES.join(', ')}"
  validates_presence_of :content

  def self.generate_section
    Section.create!(
    {
      name: Faker::Books::CultureSeries.civ,
      page_id: Page.ids.sample,
      position: Section.pluck(:position).uniq.max.to_i+1,
      visible: true,
      content_type: 'text',
      content: Faker::Quote.famous_last_words
    })
  end

  def self.generate_sections(number_of_sections)
    number_of_sections.times do
      generate_section
    end
  end
end
