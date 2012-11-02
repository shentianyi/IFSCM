require 'digest/sha2'

class Staff < ActiveRecord::Base
    
      Pwd = 0
      attr_accessible :pwd, :salt
      attr_accessible :password, :password_confirmation, :staffNr, :name, :orgId
      validates :staffNr, :presence => true, :uniqueness => true
      validates :password, :confirmation => true
      validate      :password_must_be_present
      
      def password
           @password
      end
      def password=(password)
            @password = password
            if password.present?
                  generate_salt
                  self.pwd = self.class.encrypt_password(password, salt)
            end
      end
      
      class << self
            def authenticate( staffNr, password)
                  if staff = find_by_staffNr(staffNr)
                        if staff.pwd == encrypt_password(password, staff.salt)
                             staff
                        end
                  end
            end
            def encrypt_password(password, salt)
                  Digest::SHA2.hexdigest(password + "wibble" + salt)
            end
      end
  
    
      private
          def password_must_be_present
               errors.add(:password, "Missing password" ) unless pwd.present?
          end
                    
          def generate_salt
                self.salt = self.object_id.to_s + rand.to_s
          end

  
end
