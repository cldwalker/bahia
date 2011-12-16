Description
===========

Bahia - where commandline acceptance tests are easy, the people are festive and
onde nasceu capoeira. In other words, aruba for any non-cucumber test framework.

Usage
=====

Say you want to test your gem's executable, blarg. So in your
{test,spec}/helper.rb, you:

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

Now acceptance test away your executable:

    describe "blarg" do
      it "prints usage without args" do
        blarg ""
        stdout.should == 'Usage: blarg COMMAND'
        process.success?.should == true
      end

      it 'prints error for double blarging' do
        blarg "blarg"
        stderr.should == "Bad human! No double blarging allowed"
        process.success?.should == false
      end
    end

As you can see, bahia provided helpers stdout, stderr and process as well as
automatically creates a blarg method.

If the above doesn't automagically work for you, configure Bahia before
including it:

    Bahia.command = 'blarg 3.0'
    Bahia.command_method = 'not blarg'
    Bahia.project_directory = '/path/to/gem/root/dir'

About
=====

Bahia uses open3 and is dead simple - so simple that you probably should've read
the source instead of this readme. Ha!

Contributing
============
[See here](http://tagaholic.me/contributing.html)

Credits
=======

* @spicycode
