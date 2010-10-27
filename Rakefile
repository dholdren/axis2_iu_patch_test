require "rake/testtask"
$: << File.expand_path(".")
require "maven_utils"
include MavenUtils

$axis_version = ENV['AXIS_VERSION'] || '1.5.3-SNAPSHOT'

Rake::TestTask.new do |t|
  #t.libs << "test"
  #t.libs << "lib"
  t.test_files = FileList["*_test.rb"]
  t.verbose = true
end

desc "build the axis2 patch itself"
task :build_axis2 do
  if File.exists? "../axis2_br_1_5"
    system("cd ../axis2_br_1_5 && mvn -Dmaven.test.skip=true -DskipTests=true install")
  else
    puts "WARNING: ../axis2_br_1_5 does not exist"
  end
  
  if File.exists? "../axis2_trunk"
    system("cd ../axis2_trunk && mvn -Dmaven.test.skip=true -DskipTests=true install")
  else
    puts "WARNING: ../axis2_trunk does not exist"
  end
end

desc "create all the Axis JavaBeans from the patched axis"
task :generate_artifacts do
  currdir = File.expand_path(".")
  
  system("rm -rf ./java-artifacts/*")
  
  wsdls = Dir.glob("./resources/wsdls/*.wsdl")
    
  build_jars = [
    maven_location(:group => "org.apache.axis2",            :artifact => "axis2",                     :set => $axis_version),
    maven_location(:group => "org.apache.ws.commons.schema",:artifact => "XmlSchema",                 :set => $axis_version),
    maven_location(:group => "javax.activation",            :artifact => "activation",                :set => $axis_version),
    maven_location(:group => "org.apache.ws.commons.axiom", :artifact => "axiom-api",                 :set => $axis_version),
    maven_location(:group => "org.apache.ws.commons.axiom", :artifact => "axiom-dom",                 :set => $axis_version),
    maven_location(:group => "org.apache.ws.commons.axiom", :artifact => "axiom-impl",                :set => $axis_version),
    maven_location(:group => "commons-codec",               :artifact => "commons-codec",             :set => $axis_version),
    maven_location(:group => "commons-httpclient",          :artifact => "commons-httpclient",        :set => $axis_version),
    maven_location(:group => "commons-logging",             :artifact => "commons-logging",           :set => $axis_version),
    maven_location(:group => "org.apache.geronimo.specs",   :artifact => "geronimo-stax-api_1.0_spec",:set => $axis_version),
    maven_location(:group => "org.apache.httpcomponents",   :artifact => "httpcore",                  :set => $axis_version),
    maven_location(:group => "org.apache.neethi",           :artifact => "neethi",                    :set => $axis_version),
    maven_location(:group => "wsdl4j",                      :artifact => "wsdl4j",                    :set => $axis_version),
    maven_location(:group => "org.codehaus.woodstox",       :artifact => "wstx-asl",                  :set => $axis_version),
    maven_location(:group => "xalan",                       :artifact => "xalan",                     :set => $axis_version),
    maven_location(:group => "org.apache.xmlbeans",         :artifact => "xmlbeans",                  :set => $axis_version)
  ]
  cp = build_jars.join(":")
  
  wsdls.each {|wsdl_full_filename|
    wsdl_full_filename =~ /.*\/([^\/]+)\.wsdl/
    slug = $1
    java_artifact_location = "#{currdir}/java-artifacts/#{slug}"

    #generate Axis JavaBean classes from wsdl, -Eiu is our new flag to ignore unexpected
    puts "running wsdl2java command:"
    puts "export AXIS2_HOME= && java -cp #{cp} org.apache.axis2.wsdl.WSDL2Java -uri #{wsdl_full_filename} -u -Eosv -Eiu -o #{java_artifact_location}"
    system("export AXIS2_HOME= && java -cp #{cp} org.apache.axis2.wsdl.WSDL2Java -uri #{wsdl_full_filename} -u -Eosv -Eiu -o #{java_artifact_location}")
    #compile Axis JavaBean classes
    puts "running ant command:"
    puts "export AXIS2_HOME= && cd #{java_artifact_location} && export CLASSPATH=#{cp} && ant"
    system("export AXIS2_HOME= && cd #{java_artifact_location} && export CLASSPATH=#{cp} && ant")
  
  }

end

desc "call build_axis2_patch, generate_artifacts, test"
task :default => [:build_axis2,:generate_artifacts,:test]