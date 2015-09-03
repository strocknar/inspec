require 'rake/testtask'

task :default => :test
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.warning = true
  t.verbose = true
  t.ruby_opts = ["--dev"] if defined?(JRUBY_VERSION)
end

namespace :test do
  task :isolated do
    Dir.glob("test/**/*_test.rb").all? do |file|
      sh(Gem.ruby, '-w', '-Ilib:test', file)
    end or raise "Failures"
  end

  task :integration do
    tests = Dir["test/resource/*.rb"]
    return if tests.empty?
    sh(Gem.ruby, '-I', 'lib', 'test/docker.rb', *tests)
  end
end
