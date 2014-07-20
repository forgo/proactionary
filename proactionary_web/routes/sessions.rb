#-------------------------------------------------------------------------------
# PROACTIONARY.COM
#-------------------------------------------------------------------------------
# routes/sessions.rb
# ------------------------------------------------------------------------------
# Author:   Elliott Richerson
# Created:  July 20, 2014
# Modified: July 20, 2014
# ------------------------------------------------------------------------------

module Sinatra
  module ProactionaryApp
    module Routing
      module Sessions
 
        def self.registered(app)
 
          login = lambda do
            # generate a new oauth object with your app data and your callback url
            session['oauth'] = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, "#{request.base_url}/callback")
            # redirect to facebook to get your code
            redirect session['oauth'].url_for_oauth_code()
          end

          callback = lambda do
            #get the access token from facebook with your code
            session['access_token'] = session['oauth'].get_access_token(params[:code])
            redirect '/'
          end

          logout = lambda do
            session['oauth'] = nil
            session['access_token'] = nil
            redirect '/'
          end

          # Routes
          app.get  '/login', &login
          app.get  '/callback', &callback
          app.get  '/logout', &logout

        end
 
      end
    end
  end
end