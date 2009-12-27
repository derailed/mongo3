module FlashHelper
 helpers do
   
   def flash_it!( type, msg )
     @flash = session[:flash] || OrderedHash.new
     @flash[type] = msg
   end
 end
end
