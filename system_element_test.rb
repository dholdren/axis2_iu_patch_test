#!/usr/bin/env jruby
$: << File.expand_path(".")
require 'test/unit'
#require 'fakeweb'
require 'rack'
require 'webrick'
require 'bwards_livemock'
include Java

class SystemElementTests < Test::Unit::TestCase


  #asume new version of wsdl defines an optional element, and the new service returns it in response
  #test that a client generated against old wsdl is still compatible
  #(ignore unexpected optional element for backwards compatibility of new service)
  
  def setup
    @currdir = File.expand_path(".")
    axis2_patch_dir = File.expand_path("../axis2_patch")
    
    require "#{axis2_patch_dir}/target/axis2-1.5.3-SNAPSHOT.jar"
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
      require "#{@currdir}/lib/#{jar_name}"
    }
    
    setup_server
  end
  
  def setup_server
    @server = WEBrick::HTTPServer.new(:Port => 9009)
    @server.mount('/', Rack::Handler::WEBrick, BwardsLiveMock.new)
    @server_thread = Thread.new {
      Thread.current.abort_on_exception = true
      @server.start
    }
    #sleep 0.5
  end
    
  def teardown
    @server.shutdown
    @server = nil
    @server_thread.kill
    @server_thread.join
    #Rack::Handler::WEBrick.shutdown
  end

  def test_system_elements_work
    require "#{@currdir}/java-artifacts/system_element/build/lib/SysEle-test-client.jar"
    res = nil
    assert_nothing_raised do
      include_class 'sample.foo.sys.SysEleStub'
      include_class 'sample.foo.sys.GetSysEleRequest'
      stub = SysEleStub.new("http://127.0.0.1:9009/?response=system_element")
      req = GetSysEleRequest.new()
      #req.aparam = "avalue"
      res = stub.getSysEle(req)
      #puts res.inspect
    end
    assert res, "response is nil"
    assert_equal "fsys", res.whatsystem, "whatsystem incorrect"
#    assert_equal "sysfoo", res.aretval, "aretval incorrect"
    #something with the webrick thread...
    puts
  end
end