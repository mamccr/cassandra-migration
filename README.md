cassandra-migration
===================

Introduction
------------
A general purpose tool for migrating cassandra config files from an earlier version to a later version.  It prompts the user for only the new property values necessary to get to the later version, and preserves all of the non-changed properties from the previous version.  All properties from the old version that are no longer relevent in the new version get dropped.

Users specify a start and end version, and point the script to their existing cassandra.yaml file and the location to write the updated cassandra.yaml file.  cassandra-migrate determines what properties changed between the two versions by applying a set of migrations to the original version (note that we can skip multiple versions, so long as we have adequate migration data).  

Migration data is specified via a very simple DSL, consisting of two statements:

1. add_property [name], [type: "string", "number", "hash", "array"], [default value], [description]
2. remove_property [name]

Note that names, default values that are strings, and descriptions should all be quoted.  Migrations are stored in the migrations folder at the root of the project, and are identified by a naming convention that includes the version of cassandra achieved by applying that migration.  So to get to version 14.0 from the previous version, cassandra-migration would look for 'migrations/cassandra_14.0'.

Requirements and Execution
--------------------------
To run cassandra-migration, you must have ruby 1.9 or greater.  You can type 'ruby -v' at the command line to check.  If you don't have ruby, but do have java, you can run the application using jruby by downloading the jruby-complete jar from http://jruby.org/download.  Choose the latest JRuby 1.7.x Complete jar.  Once the jar is downloaded, run 'java -jar /path/to/jruby-complete-1.7.x.jar -S /path/to/cassandra-migrate --help'.  Note that starting up the application via JVM with untuned parameters is extremely slow (5-10 seconds).

### Command-Line ###
Use the '--help' command line switch to list all options

To run the application using standard MRI (C-based) ruby, simply execute the cassandra-migrate script at the root of the project (you may need to make it executable).  There are required options.  Run cassandra-migrate --help for the full set of options.

Example: To migrate cassandra.yaml from version 13.0 to version 14.0, you can invoke the script like this:

cassandra_migrate --original-config test_data/cassandra_13.yaml --final-config test_data/cassandra_14.yaml --original-version 13.0 --final-version 14.0

or the more succinct

cassandra_migrate -o test_data/cassandra_13.yaml -f test_data/cassandra_14.yaml -r 13.0 -i 14.0

Testing
-------
To run unit tests, you must have the rspec and simplecov gems installed.  The easiest way to do this is to install bundler ('gem install bundler') and then run 'bundle install' from the project root.  Once the appropriate gems have been installed, simply run 'rspec' to execute all tests.  Coverage reports are at coverage/index.html, and the test report is at doc/report.html.

Future Enhancements
-------------------
* The purpose of the program is to save users from the pain points of upgrading Cassandra on a single machine.  Users only have to think about the properties that are newly required, and each property is documented for them with easy access to default values as they go (this information is captured in the migrations).  Currently there is no option to automatically override properties with a new default answer that differs from the old answer, but this may be a nice feature.

* It would also be nice to be able to upgrade multiple machines at once.  The functionality of determining the correct set of migrations and prompting was intentionally decoupled from the architectural parts that actually write out the configurations so that in the future, the application could be easily enhanced to loop through multiple configuration files, writing to different network filesystem locations or streaming content to be written to agents running on multiple nodes.  For homogeneous clusters, the user could specify that the properties be applied to all nodes the same way, so that they would only have to answer the migration questions once, and all configurations in the cluster would be updated uniformly at once.

* Currently, only simple types (string, number) are supported as input, and even though we have type information, we aren't using it to validate user input.  Figuring out (and parsing) an easy-to-enter-at-a-prompt format for collections needs to be added (maybe something like "keep adding options one per line... enter 'c' on a line by itself when done").

* It would be quite easy to replace the command line interface with a light web server that could prompt the user through a clean and simple web interface, if there are users who aren't as comfortable with the command line.

