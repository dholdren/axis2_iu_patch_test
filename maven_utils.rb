module MavenUtils
  @@maven_dep_set = {
    '1.5.1' => {
      'axis2' => '1.5.1',
      'XmlSchema' => '1.4.3',
      'axiom-dom' => '1.2.8',
      'axiom-api' => '1.2.8',
      'axiom-impl' => '1.2.8',
      'commons-codec' => '1.3',
      'commons-httpclient' => '3.1',
      'commons-logging' => '1.1.1',
      'httpcore' => '4.0',
      'neethi' => '2.0.4',
      'wsdl4j' => '1.6.2',
    #build-only
      'activation' => '1.1',
      'geronimo-stax-api_1.0_spec' => '1.0.1',
      'wstx-asl' => '3.2.4',
      'xalan' => '2.7.0',
      'xmlbeans' => '2.3.0',
    #test-only
      'axis2-transport-http' => '1.5.1',
      'axis2-transport-local' => '1.5.1',
      'mail' => '1.4',
      'woden-api' => '1.0M8'
    },
    '1.5.3-SNAPSHOT' => {
    #common
      'axis2' => '1.5.3-SNAPSHOT',
      'XmlSchema' => '1.4.3',
      'axiom-dom' => '1.2.9',
      'axiom-api' => '1.2.9',
      'axiom-impl' => '1.2.9',
      'commons-codec' => '1.3',
      'commons-httpclient' => '3.1',
      'commons-logging' => '1.1.1',
      'httpcore' => '4.0',
      'neethi' => '2.0.4',
      'wsdl4j' => '1.6.2',
    #build-only
      'activation' => '1.1',
      'geronimo-stax-api_1.0_spec' => '1.0.1',
      'wstx-asl' => '3.2.9',
      'xalan' => '2.7.0',
      'xmlbeans' => '2.3.0',
    #test-only
      'axis2-transport-http' => '1.5.3-SNAPSHOT',
      'axis2-transport-local' => '1.5.3-SNAPSHOT',
      'mail' => '1.4',
      'woden-api' => '1.0M8'
    },
    'SNAPSHOT' => {
    #common
      'axis2' => 'SNAPSHOT',
      'XmlSchema' => '1.4.7',
      'axiom-dom' => '1.2.10-SNAPSHOT',
      'axiom-api' => '1.2.10-SNAPSHOT',
      'axiom-impl' => '1.2.10-SNAPSHOT',
      'commons-codec' => '1.3',
      'commons-httpclient' => '3.1',
      'commons-logging' => '1.1.1',
      'httpcore' => '4.0',
      'neethi' => '3.0.0-SNAPSHOT',
      'wsdl4j' => '1.6.2',
    #build-only
      'activation' => '1.1',
      'geronimo-stax-api_1.0_spec' => '1.0.1',
      'wstx-asl' => '3.2.9',
      'xalan' => '2.7.0',
      'xmlbeans' => '2.3.0',
    #test-only
      'axis2-transport-http' => 'SNAPSHOT',
      'axis2-transport-local' => 'SNAPSHOT',
      'mail' => '1.4',
      'woden-api' => '1.0-SNAPSHOT'
    }
  }
  
  def maven_location(h)
    group = h[:group]
    artifact = h[:artifact]
    set = h[:set]
    version = h[:version]
    raise ArgumentError.new("group and artifact are required") unless group && artifact
    raise ArgumentError.new("set or version is required") unless set || version
    version ||= @@maven_dep_set[set][artifact]
    group_dir = group.gsub(/\./, "/")
    user_home = File.expand_path("~")
    "#{user_home}/.m2/repository/#{group_dir}/#{artifact}/#{version}/#{artifact}-#{version}.jar"
  end
  
end