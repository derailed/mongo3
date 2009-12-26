module CrumbHelper
  
  helpers do    
    def crumbs_from_path( path_ids, path_names )
      path_id_tokens   = path_ids.split( "|" )      
      path_name_tokens = path_names.split( "|" )
      
      @crumbs = []
      count   = 0
      path_name_tokens.each do |crumb|
        @crumbs << [crumb, "/explore/center/#{path_id_tokens[count]}"]
        count += 1
      end
      session[:crumbs] = @crumbs
    end
    
    def pop_crumb!( node_id )
      path  = "/explore/center/#{node_id}"
      level = 0
      range = nil
      @crumbs.each do |pair|
        if pair.last == path
          range = level
          break
        end
        level += 1
      end
      @crumbs = ( range > 0 ? @crumbs[0..range] : [@crumbs[0]] )
      session[:crumbs] = @crumbs
    end
  
    def reset_crumbs!
      @crumbs = [ ["home", '/explore/center/home'] ]
      session[:crumbs] = @crumbs     
    end
  
    def add_crumb( title, url )
      titles = @crumbs.map{ |p| p.first }
      unless titles.include?( title )
        @crumbs.pop if @crumbs.size == 3
        @crumbs << [title, url]
        session[:crumbs] = @crumbs
      end
    end
  end
end