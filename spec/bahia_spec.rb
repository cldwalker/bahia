require 'bahia'
require 'rspec'

describe Bahia do
  let(:test_class) { Class.new }

  before do
    Bahia.command = Bahia.project_directory = Bahia.command_method = nil
  end

  def stub_directory(dir)
    Bahia.should_receive(:caller).at_least(1).and_return(["#{dir}/helper.rb:5"])
    File.should_receive(:exists?).at_least(1).and_return(true)
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

  context "when overriding project_directory" do
    it "sets the override" do
      Dir.stub(:[]).with('/blah/bin/*').and_return(["/blah/bin/blah"])
      Bahia.project_directory = "/blah"
      subject
      Bahia.project_directory.should == "/blah"
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

    context "helper method blarg correctly executes command" do
      def command_executes(*args)
        Bahia.should_receive(:exec_command).with(
          {'RUBYLIB' => "/dir/lib:#{ENV['RUBYLIB']}".sub(/:\s*$/, '')},
          executable, *args)
      end

      it "with no arguments" do
        command_executes
        test_class.new.blarg
      end

      it "with word arguments" do
        command_executes 'is', 'blarg'
        test_class.new.blarg('is blarg')
      end

      it "with single quoted arguments" do
        command_executes 'this', 'single quoteness'
        test_class.new.blarg("this 'single quoteness'")
      end

      it "with double quoted arguments" do
        command_executes 'this', 'double quoteness'
        test_class.new.blarg('this "double quoteness"')
      end

      it "with escaped quote arguments" do
        command_executes "can't", 'be', 'stopped'
        test_class.new.blarg("can\\'t be stopped")
      end

      context "when $RUBYLIB" do
        before { @rubylib = ENV.delete('RUBYLIB') }
        after { ENV['RUBYLIB'] = @rubylib }

        it "is nil" do
          command_executes
          test_class.new.blarg
        end

        it "is blank" do
          ENV['RUBYLIB'] = ''
          command_executes
          test_class.new.blarg
        end
      end
    end
  end
end
