# coding: utf-8
class Redis
  module Search
    extend ActiveSupport::Concern

    module ClassMethods
      # Config redis-search index for Model
      # == Params:
      #   title_field   Query field for Search
      #   alias_field   Alias field for search, can accept multi field (String or Array type), it type is String, redis-search will split by comma
      #   prefix_index_enable   Is use prefix index search
      #   ext_fields    What kind fields do you need inlucde to search indexes
      #   score_field   Give a score for search sort, need Integer value, default is `created_at`
      # eg.
      # include Redis::Search
      # redis_search_index(:title_field => :proNr,
      # :alias_field => :alias,
      # :prefix_index_enable => true,
      # :score_field => :rank,
      # :ref=>{:key=>:proKey,:class=>:Project,:fields=>[:full_name,:name,:description]},
      # :ext_fields => [:proNr,:key,:proKey])
      def redis_search_index(options = {})
        title_field = options[:title_field] || :title
        alias_field = options[:alias_field] || nil
        prefix_index_enable = options[:prefix_index_enable] || false
        ext_fields = options[:ext_fields] || []
        score_field = options[:score_field] || :created_at
        condition_fields = options[:condition_fields] || []
        ref=options[:ref]||nil
        # Add score field to ext_fields
        ext_fields |= [score_field]
        # Add condition fields to ext_fields
        ext_fields |= condition_fields

        # store Model name to indexed_models for Rake tasks
        Search.indexed_models = [] if Search.indexed_models == nil
        Search.indexed_models << self
        # bind instance methods and callback events
        class_eval %(
          def redis_search_fields_to_hash(ext_fields,ref=nil)
            exts = {}
            ext_fields.each do |f|
              exts[f] = instance_eval(f.to_s)
            end
            if ref
            refItem=eval(ref[:class].to_s).find(instance_eval(ref[:key].to_s))
              ref[:fields].each do |f|
                exts[f]=instance_eval("refItem.\#{f}")
              end
            end
            exts
          end

          def redis_search_alias_value(field)
            return [] if field.blank? or field == "_was"
            val = instance_eval("self.\#{field}").clone
            return [] if !val.class.in?([String,Array])
            if val.is_a?(String)
              val = val.to_s.split(",")
            end
            val
          end

          def redis_search_index_create
            s = Search::Index.new(:title => self.#{title_field},
                                  :aliases => self.redis_search_alias_value(#{alias_field.inspect}),
                                  :id => self.key,
                                  :exts => self.redis_search_fields_to_hash(#{ext_fields.inspect},#{ref}),
                                  :type => self.class.to_s,
                                  :condition_fields => #{condition_fields},
                                  :score => self.#{score_field}.to_i,
                                  :prefix_index_enable => #{prefix_index_enable})
            s.save
            # release s
            s = nil
            true
          end

          def redis_search_index_delete(titles)
            titles.uniq.each do |title|
              Search::Index.remove(:id => self.key, :title => title, :type => self.class.to_s)
            end
            true
          end

          def redis_search_index_need_reindex
            index_fields_changed = false
            puts     #{ext_fields.inspect}
            #{ext_fields.inspect}.each do |f|
              next if f.to_s == "key"
              field_method = f.to_s + "_changed?"              
              if !self.methods.include?(field_method.to_sym)
                Search.warn("#{self.class.name} model reindex on update need "+field_method+" method.")
                next
              end
              if instance_eval(field_method)
                index_fields_changed = true
              end
            end
            begin
              if self.#{title_field}_changed?
                index_fields_changed = true
              end
              if self.#{alias_field || title_field}_changed?
                index_fields_changed = true
              end
            rescue
            end
            return index_fields_changed
          end

     set_callback :destroy, :before do
           titles = []
            titles = redis_search_alias_value("#{alias_field}")
            titles << self.#{title_field}
            redis_search_index_delete(titles)
            true
          end
          
          set_callback :update, :after do
             if self.redis_search_index_need_reindex
              titles = []
              titles = redis_search_alias_value("#{alias_field}_was")
              titles << self.#{title_field}_was
              redis_search_index_delete(titles)
            end
            true
          end

           set_callback :save, :after do
          #  if self.redis_search_index_need_reindex
              self.redis_search_index_create
           # end
            true
          end

           set_callback :buildRSIndex,:after do
            self.redis_search_index_create
            true
          end

           set_callback :cleanRSIndex,:before do
             titles = []
            titles = redis_search_alias_value("#{alias_field}")
            titles << self.#{title_field}
            redis_search_index_delete(titles)
            true
          end

        )
      end
    end
  end
end