require 'bahia'
require 'rspec'

describe Bahia do
  let(:test_class) { Class.new }

  before do
    Bahia.command = Bahia.project_directory = Bahia.command_method = nil
  end

  def stub_directory(dir)
    Bahia.should_receive(:caller).and_return(["#{dir}/helper.rb:5"])
    File.should_receive(:exists?).and_return(true)
  end

  subject { test_class.send :include, Bahia }

  context "fails to include and raises DetectionError" do
    it "if directory not detected" do
      Bahia.should_receive(:caller).and_return(["(eval)"])
      msg = Bahia::DetectionError.new(:project_directory).message
      expect { subject }.to raise_error(msg)
    end

    it "if directory does not exist" do
      Bahia.should_receive(:caller).and_return(["(irb):5"])
      msg = Bahia::DetectionError.new(:project_directory).message
      expect { subject }.to raise_error(msg)
    end

    it "if test directory is not test or spec" do
      stub_directory '/dir/my_test'
      msg = Bahia::DetectionError.new(:project_directory).message
      expect { subject }.to raise_error(msg)
    end

    it "if command isn't detected" do
      stub_directory '/dir/spec'
      Dir.should_receive(:[]).with('/dir/bin/*').and_return([])
      msg = Bahia::DetectionError.new(:command).message
      expect { subject }.to raise_error(msg)
    end
  end

  context "on successful inclusion" do
    let(:executable) { '/dir/bin/blarg' }

    before do
      stub_directory '/dir/spec'
      Dir.stub(:[]).with('/dir/bin/*').and_return([executable])
      subject
    end

    it "sets project_directory" do
      Bahia.project_directory.should == '/dir'
    end

    it "sets command" do
      Bahia.command.should == executable
    end

    it "sets command_method" do
      Bahia.command_method.should == 'blarg'
    end

    it "defines helper method named blarg" do
      Bahia.instance_method(:blarg).should_not be_nil
    end

    it "helper method blarg calls Open3.capture with correct args" do
      Open3.should_receive(:capture3).with(
        {'RUBYLIB' => "/dir/lib:#{ENV['RUBYLIB']}"}, executable, 'arg1', 'arg2')
      test_class.new.blarg('arg1 arg2')
    end
  end
end
