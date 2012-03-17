Description
===========

Bahia - where commandline acceptance tests are easy, the people are festive and
onde nasceu capoeira. In other words, aruba for any non-cucumber test framework.
Works across rubies on 1.8 and 1.9.

Usage
=====

Say you want to test your gem's executable, blarg:

    describe "blarg" do
      it "prints usage without args" do
        blarg
        stdout.should == 'Usage: blarg COMMAND'
      end

      it 'prints error for double blarging' do
        blarg "blarg"
        stderr.should == "Bad human! No double blarging allowed"
        process.success?.should == false
      end

      it "prints message for quoted args" do
        blarg %[please handle 'blarg multiple' "blarg words"]
        stdout.should == "Why u like quote so much?"
        process.success?.should == true
      end
    end

As you can see, bahia provided helpers stdout, stderr and process as well as
automatically creates a method to invoke your executable.

Setting it up in your {test,spec}/helper.rb is just a simple include:

    require 'bahia'

    # for rspec
    Rspec.configure {|c| c.include Bahia }

    # for minitest
    class MiniTest::Unit::TestCase
      include Bahia
    end

    # for bacon
    class Bacon::Context
      include Bahia
    end

    # for your preferred framework
    include some shit ...

If the above doesn't automagically work for you, configure Bahia before
including it:

    Bahia.command = 'blarg 3.0'
    Bahia.command_method = 'not blarg'
    Bahia.project_directory = '/path/to/gem/root/dir'

About
=====
Bahia uses open3 and is dead simple - so simple that you probably should've read
the source instead of this readme. Ha!

Edit: open3 don't work for 1.9 rubies so the joke is on me.

Limitations
===========
Can't capture process in jruby yet.

Contributing
============
[See here](http://tagaholic.me/contributing.html)

Credits
=======

* @spicycode - initial testing
* @rsanheim - allow project\_directory override
