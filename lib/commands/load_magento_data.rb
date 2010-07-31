class AdminUser < ActiveRecord::Base 
 set_primary_key "user_id" 
end

puts AdminUser.count
