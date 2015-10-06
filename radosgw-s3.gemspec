# -*- encoding: utf-8 -*-

# Load version requiring the canonical "s3/version", otherwise Ruby will think
# is a different file and complaint about a double declaration of S3::VERSION.
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "s3/version"

Gem::Specification.new do |s|
  s.name        = "radosgw-s3"
  s.version     = S3::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Thomas Alrin, Kishorekumar Neelamegam, Rajthilak, Kuba Kuźma"]
  s.email       = ["thomasalrin@megam.io", "nkishore@megam.io", "rajthilak@megam.io", "kuba@jah.pl"]
  s.homepage    = "http://github.com/megamsys/radosgw-s3"
  s.summary     = "Library for accessing ceph objects and buckets"
  s.description = "radosgw-s3 library provides access to your ceph-radosgw. It supports both: radosgw user creation and bucket operation using REST API."
  s.license = "Apache V2"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "s3"

  s.add_dependency "proxies", "~> 0.2.0"
  s.add_dependency "net-ssh"
  s.add_development_dependency "rake"
  s.add_development_dependency "json"
  s.add_development_dependency "test-unit"
  s.add_development_dependency "mocha"
  s.add_development_dependency "bundler"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = "lib"
end

