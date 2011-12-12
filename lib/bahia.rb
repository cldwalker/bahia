require 'open3'

module Bahia
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

    define_method(command_method) do |cmd|
      args = cmd.split(/\s+/)
      args.unshift Bahia.command
      args.unshift({'RUBYLIB' => "#{Bahia.project_directory}/lib:" +
                   ENV['RUBYLIB']})
      @stdout, @stderr, @process = Open3.capture3(*args)
    end
  end

  def self.set_project_directory(arr)
    arr[0][/^([^:]+):\d+/] or raise DetectionError.new(:project_directory)
    file = $1
    raise DetectionError.new(:project_directory) unless File.exists?(file)
    # Assume include happens in {spec,test}/helper.rb
    File.dirname File.dirname(file)
  end
end
