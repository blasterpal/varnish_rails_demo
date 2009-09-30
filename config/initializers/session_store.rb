# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_varnish_demo_session',
  :secret      => '9b0d5653efbf7060aa95204ab7e86b2fefffe6376c851edaef18c5684cc4c8e6fedbebdf9b4740ceefccea7747e3aad302b9acb79e368c14cc667d028e4922d2'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
