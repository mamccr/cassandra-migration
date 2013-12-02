$: << "#{File.dirname(File.dirname(__FILE__))}"
require "main"

describe Main do

	before :all do
		# Monkey patch an additional constructor so setup is easier for some tests
		class Main
			def initialize(options=nil)
				@opts = options
			end
		end
	end

	describe Main, ".process_params" do
		it "should exit with an appropriate message if all required options aren't given" do
			opts = {:original_version => "a", :final_version => "b", :original_config => "c"}
			Trollop.should_receive(:options).and_return opts
			Trollop.should_receive(:die).with(Main::MISSING_OPTION)

			# for any subsequent checks, since we mocked the first one which otherwise would have exited
			Trollop.stub :die
			Main.new.process_params
		end

		it "should exit with an appropriate message if the original configuration file given doesn't exist" do
			opts = {:original_version => "a", :final_version => "b", :original_config => "c", :final_config => "d"}
			Trollop.should_receive(:options).and_return opts
			Trollop.should_receive(:die) =~ /#{Main::MISSING_FILE}/
			# for any subsequent checks, since we mocked the first one which otherwise would have exited
			Trollop.stub :die 
			Main.new.process_params
		end

		it "should return without exiting if all parameters are given and the original config file exists" do
			opts = {:original_version => "a", :final_version => "b", :original_config => "c", :final_config => "d"}
			Trollop.should_receive(:options).and_return opts
			File.should_receive(:exist?).and_return true
			Trollop.should_not_receive :die
			Main.new.process_params
		end
	end

	describe Main, ".identify_migrations" do
		it "should exit with an appropriate message if migration data is missing for the source version" do
			main = Main.new({:original_version => "13"})
			File.should_receive(:exists?).with("#{Main::MIGRATIONS_DIR}/cassandra_13").and_return false
			Trollop.should_receive(:die) =~ /#{Main::MISSING_MIGRATION}/
			# for any subsequent checks, since we mocked the first one which otherwise would have exited
			Trollop.stub :die 
			File.stub :exists?
			main.identify_migrations
		end
	end

	describe Main, ".modify_config" do

		before :each do
			@props = {
				foo1: "bar1",
				foo2: "bar2",
				foo3: "bar3"
			}
		end

		it "should remove all properties that need to be removed" do
			Main.modify_config(@props, {}, [:foo2]).should == {foo1: "bar1", foo3: "bar3"}
		end

		it "should add all properties that need to be added" do
			Main.modify_config(@props, {foo4: "bar4"}, []).should == @props.merge({foo4: "bar4"})
		end
	end

end
