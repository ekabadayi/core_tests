RAILS_ENV = "test" unless defined? RAILS_ENV

require 'spec/spec_helper'
require 'identical_ext'
require 'redmine_factory_girl'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

