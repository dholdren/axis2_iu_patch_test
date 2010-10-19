#!/usr/bin/env jruby
$: << File.expand_path(".")
require 'test/unit'
require 'rack'
require 'webrick'
require 'bwards_livemock'

include Java
require "maven_utils"
include MavenUtils
$axis_version = ENV['AXIS_VERSION'] || "1.5.3-SNAPSHOT"
require maven_location(:group => "org.apache.axis2",            :artifact => "axis2",                     :set => $axis_version)
require maven_location(:group => "org.apache.axis2",            :artifact => "axis2-transport-http",      :set => $axis_version)
require maven_location(:group => "org.apache.axis2",            :artifact => "axis2-transport-local",     :set => $axis_version)
require maven_location(:group => "org.apache.ws.commons.schema",:artifact => "XmlSchema",                 :set => $axis_version)
require maven_location(:group => "org.apache.ws.commons.axiom", :artifact => "axiom-api",                 :set => $axis_version)
require maven_location(:group => "org.apache.ws.commons.axiom", :artifact => "axiom-dom",                 :set => $axis_version)
require maven_location(:group => "org.apache.ws.commons.axiom", :artifact => "axiom-impl",                :set => $axis_version)
require maven_location(:group => "commons-codec",               :artifact => "commons-codec",             :set => $axis_version)
require maven_location(:group => "commons-httpclient",          :artifact => "commons-httpclient",        :set => $axis_version)
require maven_location(:group => "commons-logging",             :artifact => "commons-logging",           :set => $axis_version)
require maven_location(:group => "org.apache.httpcomponents",   :artifact => "httpcore",                  :set => $axis_version)
require maven_location(:group => "javax.mail",                  :artifact => "mail",                      :set => $axis_version)
require maven_location(:group => "org.apache.neethi",           :artifact => "neethi",                    :set => $axis_version)
require maven_location(:group => "org.apache.woden",            :artifact => "woden-api",                 :set => $axis_version)
require maven_location(:group => "wsdl4j",                      :artifact => "wsdl4j",                    :set => $axis_version)

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