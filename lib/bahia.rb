require 'open3'
require 'shellwords'

module Bahia
  VERSION = '0.4.0'

  class DetectionError < StandardError
    def initialize(name)
      super "Unable to detect #{name}. Set it with Bahia.#{name}"
    end
  end

  class << self; attr_accessor :command, :project_directory, :command_method; end
  attr_reader :stdout, :stderr, :process

  def self.included(mod)
    self.project_directory = set_project_directory(caller)
    self.command = Dir[self.project_directory + '/bin/*'][0] or
      raise DetectionError.new(:command)
    self.command_method ||= File.basename(command)

    # We want only want ane optional arg, thank 1.8.7 for the splat
    define_method(command_method) do |*cmd|
      @stdout, @stderr, @process = Bahia.run_command(cmd.shift || '')
    end
  end

  def self.run_command(cmd)
    args = Shellwords.split(cmd)
    args.unshift Bahia.command
    args.unshift('RUBYLIB' =>
     "#{Bahia.project_directory}/lib:#{ENV['RUBYLIB']}".sub(/:\s*$/, ''))
    exec_command *args
  end

  def self.exec_command(*args)
    return Open3.capture3(*args) unless RUBY_DESCRIPTION.include?('rubinius')

    require 'open4'
    pid, stdin, stdout, stderr = Open4.open4(*args)
    _, status = Process.wait2(pid)
    out, err = stdout.read, stderr.read
    [stdin, stdout, stderr].map(&:close)
    [out, err, status]
  end

  def self.set_project_directory(arr)
    arr[0][/^([^:]+):\d+/] or raise DetectionError.new(:project_directory)
    file = $1
    raise DetectionError.new(:project_directory) unless File.exists?(file)

    dir = File.dirname(file)
    # Assume test directory called spec or test
    until dir[%r{/(spec|test)$}]
      raise DetectionError.new(:project_directory) if dir == '/'
      dir = File.dirname(dir)
    end
    File.dirname dir
  end
end
