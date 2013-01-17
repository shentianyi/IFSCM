class ClientPart < MPart
  # attr_accessible :title, :body
  belongs_to :m_organisation_relation
  has_one :partRelMeta, :class_name=>"MPartRelMeta"
end