require 'test/unit/testsuite'
require 'test/unit/testcase'

$KCODE = 'UTF8'

rcsid = %w$Id: 16runner.rb,v 1.1 2004/07/03 04:37:02 nahi Exp $
Version = rcsid[2].scan(/\d+/).collect!(&method(:Integer)).freeze
Release = rcsid[3].freeze

class BulkTestSuite < Test::Unit::TestSuite
  def self.suite
    suite = Test::Unit::TestSuite.new
    ObjectSpace.each_object(Class) do |klass|
      suite << klass.suite if (Test::Unit::TestCase > klass)
    end
    suite
  end
end

runners_map = {
  'console' => proc do |suite|
    require 'test/unit/ui/console/testrunner'
    passed = Test::Unit::UI::Console::TestRunner.run(suite).passed?
    exit(passed ? 0 : 1)
  end,
  'gtk' => proc do |suite|
    require 'test/unit/ui/gtk/testrunner'
    Test::Unit::UI::GTK::TestRunner.run(suite)
  end,
  'fox' => proc do |suite|
    require 'test/unit/ui/fox/testrunner'
    Test::Unit::UI::Fox::TestRunner.run(suite)
  end,
}

argv = ARGV
if argv.empty?
  argv = Dir.glob(File.join(File.dirname(__FILE__), "**", "test_*.rb")).sort
end

argv.each do |tc_name|
  dir = File.expand_path(File.dirname(tc_name))
  backup = $:.dup
  $:.push(dir)
  require tc_name
  $:.replace(backup)
end

runner = 'console'
GC.start
runners_map[runner].call(BulkTestSuite.suite)