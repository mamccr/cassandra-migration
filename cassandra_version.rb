# As far as I can tell, Cassandra uses an x.x.x versioning scheme.  This allows us
# to quickly and easily sort cassandra versions.
class CassandraVersion < Array
  
  def initialize version_string
    super(version_string.split('.').map { |sub_version| sub_version.to_i })
  end
  
  def < x
    (self <=> x) < 0
  end
  
  def > x
    (self <=> x) > 0
  end
  
  def == x
    (self <=> x) == 0
  end
end
