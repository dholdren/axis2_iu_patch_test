#!/usr/bin/env jruby

require 'test/unit'
#require 'fakeweb'
include Java

class BwardsTests < Test::Unit::TestCase


  #asume new version of wsdl defines an optional element, and the new service returns it in response
  #test that a client generated against old wsdl is still compatible
  #(ignore unexpected optional element for backwards compatibility of new service)
  
  def setup
    #generate stubs from wsdls
    axis2_home = "/Users/holdrend/projects/axis2-1.5.1/target"
    old_axis2_home = "/usr/local/axis2-1.5.1"
    @v1_artifact_location = File.dirname(".")+"/java-artifacts/v1"
    @v2_artifact_location = File.dirname(".")+"/java-artifacts/v2"

    if !ARGV.include?("nogen")
      `rm -rf #{@v1_artifact_location}/*`
      `rm -rf #{@v2_artifact_location}/*`
    
      v1_wsdl = File.dirname(".")+"/resources/wsdls/v1.wsdl"
      v2_wsdl = File.dirname(".")+"/resources/wsdls/v2.wsdl"
      build_jars = [ 
        "#{axis2_home}/lib/axis2-1.5.1.jar",
        "#{old_axis2_home}/lib/XmlSchema-1.4.3.jar",
        "#{old_axis2_home}/lib/activation-1.1.jar",
        "#{old_axis2_home}/lib/axiom-api-1.2.8.jar",
        "#{old_axis2_home}/lib/axiom-dom-1.2.8.jar",
        "#{old_axis2_home}/lib/axiom-impl-1.2.8.jar",
        #"#{old_axis2_home}/lib/backport-util-concurrent-3.1.jar",
        "#{old_axis2_home}/lib/commons-codec-1.3.jar",
        "#{old_axis2_home}/lib/commons-httpclient-3.1.jar",
        "#{old_axis2_home}/lib/commons-logging-1.1.1.jar",
        "#{old_axis2_home}/lib/geronimo-stax-api_1.0_spec-1.0.1.jar",
        "#{old_axis2_home}/lib/httpcore-4.0.jar",
        "#{old_axis2_home}/lib/neethi-2.0.4.jar",
        "#{old_axis2_home}/lib/wsdl4j-1.6.2.jar",
        "#{old_axis2_home}/lib/wstx-asl-3.2.4.jar",
        "#{old_axis2_home}/lib/xalan-2.7.0.jar",
        "#{old_axis2_home}/lib/xmlbeans-2.3.0.jar"      
      ]
      cp = build_jars.join(":")
    
      #output1a = `export AXIS2_HOME=#{axis2_home} && java -cp #{cp} org.apache.axis2.wsdl.WSDL2Java -uri #{v1_wsdl} -u -Eosv -o #{@v1_artifact_location}`
      output1a = `export AXIS2_HOME=#{axis2_home} && java -cp #{cp} org.apache.axis2.wsdl.WSDL2Java -uri #{v1_wsdl} -u -Eosv -Eiu -o #{@v1_artifact_location}`
      puts output1a
      output1b = `export AXIS2_HOME=#{axis2_home} && cd #{@v1_artifact_location} && export CLASSPATH=#{cp} && ant`
      puts output1b
      #output2a = `export AXIS2_HOME=#{axis2_home} && java -cp #{cp} org.apache.axis2.wsdl.WSDL2Java -uri #{v2_wsdl} -u -Eosv -o #{@v2_artifact_location}`
      output2a = `export AXIS2_HOME=#{axis2_home} && java -cp #{cp} org.apache.axis2.wsdl.WSDL2Java -uri #{v2_wsdl} -u -Eosv -Eiu -o #{@v2_artifact_location}`
      puts output2a
      output2b = `export AXIS2_HOME=#{axis2_home} && cd #{@v2_artifact_location} && export CLASSPATH=#{cp} && ant`
      puts output2b
    end
        
    require "#{axis2_home}/lib/axis2-1.5.1.jar"
    run_jars = [
      "axiom-api-1.2.8.jar",
      "axiom-dom-1.2.8.jar",
      "axiom-impl-1.2.8.jar",
      "commons-logging-1.1.1.jar",
      "wsdl4j-1.6.2.jar",
      "XmlSchema-1.4.3.jar",
      "neethi-2.0.4.jar",
      "axis2-transport-local-1.5.1.jar",
      "axis2-transport-http-1.5.1.jar",
      "commons-httpclient-3.1.jar",
      "mail-1.4.jar",
      "httpcore-4.0.jar",
      "commons-httpclient-3.1.jar",
      "woden-api-1.0M8.jar",
      'commons-codec-1.3.jar'
    ]
    run_jars.each {|jar_name|
      require "#{old_axis2_home}/lib/#{jar_name}"
    }
  end
  
  
  def test_matching_wsdl_response_works
    require @v1_artifact_location+"/build/lib/Foo-test-client.jar"
    client_version = "v1"
    response_version = "v1"
    get_and_test_response(client_version, response_version)
  end
  
  def test_old_wsdl_new_response_works
    require @v1_artifact_location+"/build/lib/Foo-test-client.jar"
    client_version = "v1"
    response_version = "v2"
    get_and_test_response(client_version, response_version)
  end

  private
    def get_and_test_response(client_version, response_version)
      #call method, but mock response, may have to mock java http
      #mock the envelope getBody method to return a specified response
      #mock the operationClient execute method to do nothing
      res = nil
      assert_nothing_raised do
        include_class 'sample.foo.xsd.FooStub'
        include_class 'sample.foo.xsd.GetFooRequest'
        stub = FooStub.new("http://127.0.0.1:7001/mockFooSOAP11Binding?response_version=#{response_version}")
        req = GetFooRequest.new()
        req.aparam = "avalue"
        res = stub.getFoo(req)
        #puts res.inspect
      end
      assert res, "response is nil"
      assert_equal "bar_one", res.retval_one, "retval_one incorrect"
      assert_equal "bar_two", res.retval_two, "retval_two incorrect"
    end

end