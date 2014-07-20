#-------------------------------------------------------------------------------
# routes/promoter.rb
# ------------------------------------------------------------------------------
# Author: 	Elliott Richerson
# Created:  June 23, 2014
# Modified: June 23, 2014
# ------------------------------------------------------------------------------

module Sinatra
  module ProactionaryApp
    module Routing
      module Facebook
 
        def self.registered(app)

          show_facebook_graph = lambda do
            #require_logged_in

            @fb = fb_graph

            erb :"facebook/show"
          end
 
          app.get  '/facebook', &show_facebook_graph

        end
 
      end
    end
  end
end