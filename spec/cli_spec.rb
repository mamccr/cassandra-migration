$: << "#{File.dirname(File.dirname(__FILE__))}"
require "cli"

class CliImpl
	include Cli
end

describe Cli do

	describe Cli, "#wrap" do
		it "should correctly wrap lines at the given boundary when the boundary point is whitespace" do
			Cli.wrap("foo foo foo", 8).should == "foo foo\nfoo"
		end

		it "should correctly wrap lines when the boundary point is in the middle of a word" do
			Cli.wrap("fooooo foo foo", 9).should == "fooooo\nfoo foo"
		end

		it "should even split long words" do
			Cli.wrap("fooooooooo", 5).should == "foooo\nooooo"
		end
	end

	describe Cli, ".say" do
		it "should word wrap whatever it is asked to say" do
			Cli.should_receive(:wrap).with("foo", Cli::LINE_WIDTH)
			CliImpl.new.say("foo")
		end
	end

	describe Cli, ".ask" do

		before :each do
			@cli = CliImpl.new
			@cli.stub :puts
			@cli.stub :print
		end

		it "should return input given by the user" do
			@cli.should_receive(:gets).and_return "foo"
			@cli.ask("a", "b", "c").should == "foo"
		end

		it "should return the default answer if the input given by the user is empty" do
			@cli.should_receive(:gets).and_return "\n"
			@cli.ask("a", "b", "c").should == "b"
		end
	end

end