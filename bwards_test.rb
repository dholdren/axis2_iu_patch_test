#!/usr/bin/env jruby

require 'test/unit'
#require 'fakeweb'
require 'rack'
require 'bwards_livemock'
include Java

class BwardsTests < Test::Unit::TestCase


  #asume new version of wsdl defines an optional element, and the new service returns it in response
  #test that a client generated against old wsdl is still compatible
  #(ignore unexpected optional element for backwards compatibility of new service)
  
  def setup
    axis2_patch_dir = "../axis2_patch"
    @v1_artifact_location = File.dirname(".")+"/java-artifacts/v1"
    @v2_artifact_location = File.dirname(".")+"/java-artifacts/v2"
    
    require "#{axis2_patch_dir}/target/lib/axis2-1.5.3-SNAPSHOT.jar"
    require "#{axis2_patch_dir}/modules/transport/http/target/axis2-transport-http-1.5.3-SNAPSHOT.jar"
    require "#{axis2_patch_dir}/modules/transport/local/target/axis2-transport-local-1.5.3-SNAPSHOT.jar"
    run_jars = [
      "XmlSchema-1.4.3.jar",
      "axiom-api-1.2.9.jar",
      "axiom-dom-1.2.9.jar",
      "axiom-impl-1.2.9.jar",
      "commons-codec-1.3.jar",
      "commons-httpclient-3.1.jar",
      "commons-logging-1.1.1.jar",
      "httpcore-4.0.jar",
      "mail-1.4.jar",
      "neethi-2.0.4.jar",
      "woden-api-1.0M8.jar",
      "wsdl4j-1.6.2.jar"
    ]
    run_jars.each {|jar_name|
      require "./libs/#{jar_name}"
    }
    
    #startup a Webrick::Rack instance for service mock responses
    Rack::Handler::WEBrick.run(BwardsLiveMock.new, :Port => 9009)
  end
  
  def teardown
    Rack::Handler::WEBrick.shutdown
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
        stub = FooStub.new("http://127.0.0.1:9009/?response_version=#{response_version}")
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