module FlashHelper
 helpers do
   
   # clear out flash object
   def clear_it!
     @flash = session[:flash] || BSON::OrderedHash.new     
     @flash.clear
   end
   
   # add flash message
   def flash_it!( type, msg )
     @flash = session[:flash] || BSON::OrderedHash.new
     @flash[type] = msg
   end
 end
end
