#-------------------------------------------------------------------------------
# PROACTIONARY.COM
#-------------------------------------------------------------------------------
# spec/features/root_spec.rb
# ------------------------------------------------------------------------------
# Author: 	Elliott Richerson
# Created:  July 20, 2014
# Modified: July 20, 2014
# ------------------------------------------------------------------------------

require_relative '../spec_helper'

describe 'Root Path' do
	describe 'GET /' do
		before { get '/' }

		it 'is successful' do
			expect(last_response.status).to eq 200
		end
	end
end