$: << "#{File.dirname(File.dirname(__FILE__))}"
require "migrator"

describe Migrator do

	describe Migrator, ".find_all_migrations" do
		it "should correctly find the range on systems that return the file list in unsorted order" do
			Dir.should_receive(:glob).and_return ["cassandra_14.0", "cassandra_13.0", "cassandra_13.1", "cassandra_15.0"]
			Migrator.new("13.0", "14.0").find_all_migrations.should == ["cassandra_13.1", "cassandra_14.0"]
		end

		it "should correctly find the range on systems that return the file list in sorted order" do
			Dir.should_receive(:glob).and_return ["cassandra_13.0", "cassandra_14.0"]
			Migrator.new("13.0", "14.0").find_all_migrations.should == ["cassandra_14.0"]
		end
	end

	describe Migrator, ".calculate_changes" do

		before :all do
			@test_contents = <<-EOS
add_property "cluster_name", STRING, "Test Cluster", "The name of the cluster. This is mainly used to prevent machines in one logical cluster from joining another."
add_property "num_tokens", NUMBER, 256, "This defines the number of tokens randomly assigned to this node on the ring The more tokens, relative to other nodes, the larger the proportion of data that this node will store. You probably want all nodes to have the same number of tokens assuming they have equal hardware capability.\n\n If you leave this unspecified, Cassandra will use the default of 1 token for legacy compatibility, and will use the initial_token as described below.\n\n Specifying initial_token will override this setting.\n\n If you already have a cluster with 1 token per node, and wish to migrate to  multiple tokens per node, see http://wiki.apache.org/cassandra/Operations"
add_property "data_file_directories", ARRAY, ["/var/lib/cassandra/data"], "Directories where Cassandra should store data on disk.  Cassandra will spread data evenly across them, subject to the granularity of the configured compaction strategy."
add_property "memtable_flush_queue_size", NUMBER, 4, "The number of full memtables to allow pending flush, that is, waiting for a writer thread.  At a minimum, this should be set to the maximum number of secondary indexes created on a single CF."
remove_property "foo"
EOS
		end

		before :each do
			@migrator = Migrator.new("13.0", "14.0")
			@migrator.should_receive(:find_all_migrations).and_return(["cassandra_13.0"])
			File.should_receive(:read).and_return @test_contents
		end

		it "should evaluate each of the migration files in order when added_properties is called first, collecting the full list of property additions across migrations" do
			@migrator.added_properties.should == [
				{name: "cluster_name", type: Migrator::STRING, default_value: "Test Cluster", description: "The name of the cluster. This is mainly used to prevent machines in one logical cluster from joining another."},
				{name: "num_tokens", type: Migrator::NUMBER, default_value: 256, description: "This defines the number of tokens randomly assigned to this node on the ring The more tokens, relative to other nodes, the larger the proportion of data that this node will store. You probably want all nodes to have the same number of tokens assuming they have equal hardware capability.\n\n If you leave this unspecified, Cassandra will use the default of 1 token for legacy compatibility, and will use the initial_token as described below.\n\n Specifying initial_token will override this setting.\n\n If you already have a cluster with 1 token per node, and wish to migrate to  multiple tokens per node, see http://wiki.apache.org/cassandra/Operations"},
				{name: "data_file_directories", type: Migrator::ARRAY, default_value: ["/var/lib/cassandra/data"], description: "Directories where Cassandra should store data on disk.  Cassandra will spread data evenly across them, subject to the granularity of the configured compaction strategy."},
				{name: "memtable_flush_queue_size", type: Migrator::NUMBER, default_value: 4, description: "The number of full memtables to allow pending flush, that is, waiting for a writer thread.  At a minimum, this should be set to the maximum number of secondary indexes created on a single CF."},
			]
			@migrator.removed_properties.should == ["foo"]
		end

		it "should evaluate each of the migration files in order when removed_properties is called first, collecting the full list of property additions across migrations" do
			@migrator.removed_properties.should == ["foo"]
			@migrator.added_properties.should == [
				{name: "cluster_name", type: Migrator::STRING, default_value: "Test Cluster", description: "The name of the cluster. This is mainly used to prevent machines in one logical cluster from joining another."},
				{name: "num_tokens", type: Migrator::NUMBER, default_value: 256, description: "This defines the number of tokens randomly assigned to this node on the ring The more tokens, relative to other nodes, the larger the proportion of data that this node will store. You probably want all nodes to have the same number of tokens assuming they have equal hardware capability.\n\n If you leave this unspecified, Cassandra will use the default of 1 token for legacy compatibility, and will use the initial_token as described below.\n\n Specifying initial_token will override this setting.\n\n If you already have a cluster with 1 token per node, and wish to migrate to  multiple tokens per node, see http://wiki.apache.org/cassandra/Operations"},
				{name: "data_file_directories", type: Migrator::ARRAY, default_value: ["/var/lib/cassandra/data"], description: "Directories where Cassandra should store data on disk.  Cassandra will spread data evenly across them, subject to the granularity of the configured compaction strategy."},
				{name: "memtable_flush_queue_size", type: Migrator::NUMBER, default_value: 4, description: "The number of full memtables to allow pending flush, that is, waiting for a writer thread.  At a minimum, this should be set to the maximum number of secondary indexes created on a single CF."},
			]
		end

	end

end
