$: << "#{File.dirname(File.dirname(__FILE__))}"
require "cassandra_version"

describe CassandraVersion do

	describe CassandraVersion, ".<" do
		it "should correctly identify smaller version numbers by evaluating their components individually" do
			(CassandraVersion.new("1.1.0") < CassandraVersion.new("1.10.0")).should be_true
			(CassandraVersion.new("1.1") < CassandraVersion.new("1.10")).should be_true
			(CassandraVersion.new("1.1.1") < CassandraVersion.new("1.1.2")).should be_true
		end
	end

	describe CassandraVersion, ".>" do
		it "should correctly identify larger version numbers by evaluating their components individually" do
			(CassandraVersion.new("1.8.54") > CassandraVersion.new("1.8.53")).should be_true
			(CassandraVersion.new("1.8.53") > CassandraVersion.new("1.8.54")).should be_false
			(CassandraVersion.new("5") > CassandraVersion.new("1")).should be_true
		end
	end

	describe CassandraVersion, ".==" do
		it "should correctly identify equal version numbers by evaluating their components individually" do
			(CassandraVersion.new("1.1.0") == CassandraVersion.new("1.10.0")).should be_false
			(CassandraVersion.new("1.1") == CassandraVersion.new("1.1")).should be_true
		end
	end

end
