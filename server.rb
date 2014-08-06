# required gem includes
require 'sinatra'
require "sinatra/json"
require_relative 'lib/sesh.rb'

set :bind, '0.0.0.0' # Vagrant fix
set :sessions, true
set :session_secret, 'super secret'

# partial
# layouts