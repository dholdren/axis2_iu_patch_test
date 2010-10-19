#!/usr/bin/env jruby
$: << File.expand_path(".")
require 'test/unit'
require 'rack'
require 'webrick'
require 'bwards_livemock'

include Java
require "../axis2_patch/target/axis2-1.5.3-SNAPSHOT.jar"
require "../axis2_patch/modules/transport/http/target/axis2-transport-http-1.5.3-SNAPSHOT.jar"
require "../axis2_patch/modules/transport/local/target/axis2-transport-local-1.5.3-SNAPSHOT.jar"
require "lib/XmlSchema-1.4.3.jar"
require "lib/axiom-api-1.2.9.jar"
require "lib/axiom-dom-1.2.9.jar"
require "lib/axiom-impl-1.2.9.jar"
require "lib/commons-codec-1.3.jar"
require "lib/commons-httpclient-3.1.jar"
require "lib/commons-logging-1.1.1.jar"
require "lib/httpcore-4.0.jar"
require "lib/mail-1.4.jar"
require "lib/neethi-2.0.4.jar"
require "lib/woden-api-1.0M8.jar"
require "lib/wsdl4j-1.6.2.jar"

class SystemElementTests < Test::Unit::TestCase


  #Test that an element of xsd type "System" works (broken in 1.5.1)
  
  def setup
    @currdir = File.expand_path(".")
    
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
    assert_equal "fsys", res.whatsystem.getSystem, "whatsystem incorrect"
    #something with the webrick thread...
    puts
  end
end