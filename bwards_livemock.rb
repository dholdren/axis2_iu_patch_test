#!/usr/bin/env jruby
require 'rack/request'
require 'rack/response'

class BwardsLiveMock
  
  def call(env)
    req = Rack::Request.new(env)
#    puts req.inspect
    response = req.params["response"]
    if response
      #open response file that matches response_version
      file_name = File.join(File.dirname("."),"resources","responses","#{response}.response")
      puts "file_name is: #{file_name}"
      if File.exists?(file_name)
        puts "file exists"
        file_contents = ""
        File.open(file_name,"r") do |f|
          f.each {|line|
            file_contents << line
          }
        end
#        file_contents = "<Envelope>\n</Envelope>"
        #puts "\nreturning file_contents:\n #{file_contents}"
        [200,{"Content-Type" => "text/xml"},file_contents]
      else
        puts "file does not exist"
        res = Rack::Response.new
        res.status = 500
        res.write "File not found: #{file_name}"
        res.finish
#        [500,{"Content-Type" => "text/html"},["File not found: #{file_name}"]]
      end
    else
      puts "no response version parameter"
      res = Rack::Response.new
      res.status = 500
      res.write "No response version parameter"
      res.finish
#      [500,{},["No response version parameter"]]
    end
  end
  
end

if $0 == __FILE__
  require 'rack'
  require 'rack/showexceptions'
  Rack::Handler::WEBrick.run \
    Rack::ShowExceptions.new(Rack::Lint.new(BwardsLiveMock.new)),
    :Port => 9009
end
