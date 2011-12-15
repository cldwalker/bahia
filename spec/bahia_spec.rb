require 'bahia'
require 'rspec'

describe Bahia do

  before do
    Bahia.command = Bahia.project_directory = Bahia.command_method = nil
  end

  subject do
    Module.new.send :include, Bahia
  end

  it "raises DetectionError if directory not detected" do
    Bahia.should_receive(:caller).and_return(["(eval)"])
    msg = Bahia::DetectionError.new(:project_directory).message
    expect { subject }.to raise_error(msg)
  end

  it "raises DetectionError if directory does not exist" do
    Bahia.should_receive(:caller).and_return(["(irb):5"])
    msg = Bahia::DetectionError.new(:project_directory).message
    expect { subject }.to raise_error(msg)
  end

  it "raises DetectionError if command isn't detected" do
    Bahia.should_receive(:set_project_directory).and_return('/dir')
    Dir.should_receive(:[]).with('/dir/bin/*').and_return([])
    msg = Bahia::DetectionError.new(:command).message
    expect { subject }.to raise_error(msg)
  end

  context "on inclusion" do
    before do
      Bahia.stub(:set_project_directory).and_return('/dir')
      Dir.stub(:[]).with('/dir/bin/*').and_return(['/dir/bin/blarg'])
      subject
    end

    it "sets project_directory" do
      Bahia.project_directory.should == '/dir'
    end

    it "sets command" do
      Bahia.command.should == '/dir/bin/blarg'
    end

    it "sets command_method" do
      Bahia.command_method.should == 'blarg'
    end

    it "defines helper method named blarg" do
      Bahia.instance_method(:blarg).should_not be_nil
    end
  end
end
