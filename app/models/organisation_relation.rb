class OrganisationRelation < ActiveRecord::Base
  attr_accessible :supplierNr, :clientNr
  belongs_to :origin_supplier, :class_name=>"Organisation"#, :foreign_key=>"origin_supplier_id"
  belongs_to :origin_client, :class_name=>"Organisation"#, :foreign_key=>"origin_client_id"
  has_many :client_parts
  has_many :supplier_parts
  
  attr_accessor :cs_key,:orgrelNr
  
  # include Redis::Search

  # redis_search_index(:title_field => :orgrelNr,
                                         # :alias_field => :alias,
                                         # :prefix_index_enable => true,
                                         # :condition_fields => [:cs_key],
                                         # # :score_field => :date,
                                         # :ext_fields => [:name, :address, :id])
#     
      # @@arrs = [ :name, :address, :id ]
      # @@arrs.each do |arr|
        # class_eval %(
          # def #{arr}
            # self.organ.#{arr}
          # end
        # )
      # end
#       
    # def alias
      # [self.name, self.address]
    # end
#     
    # def organ
      # orgId = 1
      # Organisation.find_by_id( orgId )
    # end
    
    def save_index
      run_callbacks :save
    end
    
end