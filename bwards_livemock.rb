require 'rack/request'
require 'rack/response'

class BwardsLiveMock
  
  def call(env)
    req = Rack::Request.new(env)
    
    response_version = req.GET["response_version"]
    #open response file that matches response_version
    file_name = File.join(File.dirname("."),"resources","responses","#{response_version}.response")
    res = Response.new
    if File.exists?(file_name)
      File.open(file_name,"r") do |f|
        f.each {|line| res.write line}
      end
      res.finish
    else
      raise "File not found: #{file_name}"
    end
    res
  end
  
end