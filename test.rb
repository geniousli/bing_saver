#! /Users/ios4/.rbenv/versions/2.3.0/bin/ruby
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __FILE__)
require 'bundler/setup'
Bundler.require(:default)
require_relative 'boot'
require_relative 'bing_saver'
require 'json'
# 3.times do |idx|
BingSaver.new().deliver
# end
