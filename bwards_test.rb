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