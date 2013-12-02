# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper.rb"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
ENV['SOLSTICE_ENV'] = "test"

require 'rubygems'
require 'simplecov'

SimpleCov.start do
  ENV['SOLSTICE_ENV'] = "test"
  add_filter "/spec/"
  add_filter "/trollop*"

  # don't bother with prompter, because it's just glue code.  It would be a bunch of mocked-up white box
  # testing that wouldn't provide much value
  add_filter "/prompter.rb"

  # don't bother evaluating extremely short files
  add_filter do |source_file|
    source_file.lines.count <= 10 
  end
end