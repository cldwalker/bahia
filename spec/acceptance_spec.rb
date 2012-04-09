require 'fileutils'
require 'bahia'
require 'rspec'

describe "Acceptance test Bahia" do
  def run_command(cmd='')
    @stdout, @stderr, @process = Bahia.run_command(cmd)
  end

  before(:all) do
    dir = File.dirname(__FILE__) + '/tmpdir'
    FileUtils.mkdir_p("#{dir}/bin")
    executable = "#{dir}/bin/zzzz"
    File.open(executable, 'w') do |f|
      f.write <<-STR.gsub(/^\s*/, '')
      #!/usr/bin/env ruby
      if ARGV[0]
        warn "I'm sleeping!"
      else
        puts "ZZZZZ"
      end
      STR
    end
    FileUtils.chmod 0755, executable
    Bahia.project_directory = dir
    Bahia.command = executable
  end
  after(:all) { FileUtils.rm_rf File.dirname(__FILE__) + '/tmpdir' }
  at_exit { FileUtils.rm_rf File.dirname(__FILE__) + '/tmpdir' }

  it "detects stdout" do
    run_command
    @stdout.should =~ /^ZZZZZ/
  end

  it "detects stderr" do
    run_command "hello"
    @stderr.should =~ /^I'm sleeping!/
  end
end
