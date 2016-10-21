require './app'
require 'sinatra/activerecord/rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test/unit_tests"
  t.test_files = FileList['test/unit_tests/test*.rb']
  t.verbose = true
end
