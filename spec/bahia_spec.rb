require 'bahia'
require 'rspec'

describe Bahia do
  let(:test_class) { Class.new }

  before do
    Bahia.command = Bahia.project_directory = Bahia.command_method = nil
  end

  def stub_directory(dir, options = {})
    stack = options[:stack] || ["#{dir}/helper.rb:5"]
    Bahia.should_receive(:caller).at_least(1).and_return(stack)
    File.should_receive(:exists?).at_least(1).and_return(true)
  end

  subject { test_class.send :include, Bahia }

  context "fails to include and raises DetectionError" do
    def error(ivar)
      msg = "bahia: " + Bahia::DetectionError.new(ivar).message
      "\n" + "*" * msg.size + "\n#{msg}\n" + "*" * msg.size + "\n\n"
    end

    it "if directory not detected" do
      Bahia.should_receive(:caller).at_least(1).and_return(["(eval)"])
      Bahia.should_receive(:abort).with error(:project_directory)
      subject
    end

    it "if directory does not exist" do
      Bahia.should_receive(:caller).at_least(1).and_return(["(irb):5"])
      Bahia.should_receive(:abort).with error(:project_directory)
      subject
    end

    it "if test directory is not test or spec" do
      stub_directory '/dir/my_test'
      Bahia.should_receive(:abort).with error(:project_directory)
      subject
    end

    it "if command isn't detected" do
      stub_directory '/dir/spec'
      Dir.should_receive(:[]).with('/dir/bin/*').and_return([])
      Bahia.should_receive(:abort).with error(:command)
      subject
    end
  end

  context "when overriding" do
    before do
      Dir.stub(:[]).with('/blah/bin/*').and_return(["/blah/bin/blah"])
    end

    it "sets project_directory" do
      Bahia.project_directory = "/blah"

      subject
      Bahia.project_directory.should == "/blah"
    end

    it "sets command" do
      stub_directory '/blah/spec'
      Bahia.command = 'blarg'

      subject
      Bahia.command.should == "blarg"
    end

    it "sets command_method" do
      stub_directory '/blah/spec'
      Bahia.command_method = 'derp'

      subject
      Bahia.command_method.should == 'derp'
    end
  end

  context "on successful inclusion" do
    let(:executable) { '/dir/bin/blarg' }
    let(:stub_directory_options) { {} }

    before do
      stub_directory '/dir/spec', stub_directory_options
      Dir.stub(:[]).with('/dir/bin/*').and_return([executable])
      subject
    end

    context "for normal backtrace" do
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
    end

    context "for rspec backtrace" do
      let(:stub_directory_options) {
        {
          :stack => [
            "/gems/rspec-core-2.8.0/lib/rspec/core/configuration.rb:680: in `include'",
            "/gems/rspec-core-2.8.0/lib/rspec/core/configuration.rb:680: in `block in configure_group'",
            '/dir/spec/helper.rb:5'
          ]
        }
      }

      it "sets project_directory" do
        Bahia.project_directory.should == '/dir'
      end
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
