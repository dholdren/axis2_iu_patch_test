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

class BwardsTests < Test::Unit::TestCase


  #asume new version of wsdl defines an optional element, and the new service returns it in response
  #test that a client generated against old wsdl is still compatible
  #(ignore unexpected optional element for backwards compatibility of new service)
  
  def setup
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
  
  def test_foo_service_matching_javabeans_response_works
    require "java-artifacts/foo_v1/build/lib/Foo-test-client.jar"
    get_and_test_foo_service_response("foo_v1")
    #weirdly, we need to do this or we don't get the test output sometimes... something with threads and IO
    puts
  end
  
  def test_foo_service_old_javabeans_new_response_works
    require "java-artifacts/foo_v1/build/lib/Foo-test-client.jar"
    get_and_test_foo_service_response("foo_v2")
    #weirdly, we need to do this or we don't get the test output sometimes... something with threads and IO    
    puts
  end
  
  def test_foo_service_old_javabeans_new_complex_response_works
    require "java-artifacts/foo_v1/build/lib/Foo-test-client.jar"
    res = get_and_test_foo_service_response("foo_v2_complex")
    assert_equal "afirstname", res.fullname.first
    assert_equal "alastname", res.fullname.last
    
    
    puts
  end
  
  def test_names_service_matching_javabeans_response_works
    require "java-artifacts/names_v1/build/lib/Names-test-client.jar"
    get_and_test_names_service_response("names_v1")
    puts
  end
  
  def test_names_service_old_javabeans_new_response_works
    require "java-artifacts/names_v1/build/lib/Names-test-client.jar"
    get_and_test_names_service_response("names_v2")
    puts
  end
  
  private
    
    def get_and_test_foo_service_response(response)
      res = nil
      assert_nothing_raised do
        include_class 'sample.foo.bar.FooStub'
        include_class 'sample.foo.bar.GetFooRequest'
        stub = FooStub.new("http://127.0.0.1:9009/?response=#{response}")
        req = GetFooRequest.new()
        req.aparam = "avalue"
        res = stub.getFoo(req)
        #puts res.inspect
      end
      assert res, "response is nil"
      assert_equal "bar_one", res.retval_one, "retval_one incorrect"
      assert_equal "bar_two", res.retval_two, "retval_two incorrect"
      res
    end
    
    def get_and_test_names_service_response(response)
      res = nil
      assert_nothing_raised do
        include_class 'com.test.names.NamesStub'
        include_class 'com.test.names.GetNamesRequest'
        stub = NamesStub.new("http://127.0.0.1:9009/?response=#{response}")
        req = GetNamesRequest.new()
        req.aparam = "avalue"
        res = stub.getNames(req)
      end
      assert res, "response is nil"
      assert_equal 3, res.fullnames.length, "size of fullnames list is incorrect"
      assert_equal "Afirstname1", res.fullnames[0].first, "fullnames[0].first incorrect"
      assert_equal "Alastname1", res.fullnames[0].last, "fullnames[0].last incorrect"
      assert_equal "Afirstname2", res.fullnames[1].first, "fullnames[1].first incorrect"
      assert_equal "Alastname2", res.fullnames[1].last, "fullnames[1].last incorrect"
      assert_equal "Afirstname3", res.fullnames[2].first, "fullnames[2].first incorrect"
      assert_equal "Alastname3", res.fullnames[2].last, "fullnames[2].last incorrect"
      res
    end

end