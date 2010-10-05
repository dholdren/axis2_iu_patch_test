require "rake/testtask"

Rake::TestTask.new do |t|
  #t.libs << "test"
  #t.libs << "lib"
  t.test_files = FileList["*_test.rb"]
  t.verbose = true
end

desc "build the axis2 patch itself"
task :build_axis2_patch do
  #cd ../axis2_patch
  #mvn install
  system("cd ../axis2_patch && mvn -Dmaven.test.skip=true -DskipTests=true install")
end

desc "create all the Axis JavaBeans from the patched axis"
task :generate_artifacts do
  axis2_patch_home = "../axis2_patch/target"
  v1_artifact_location = File.dirname(".")+"/java-artifacts/v1"
  v2_artifact_location = File.dirname(".")+"/java-artifacts/v2"
  
  system("rm -rf #{@v1_artifact_location}/*")
  system("rm -rf #{@v2_artifact_location}/*")
  
  v1_wsdl = File.dirname(".")+"/resources/wsdls/v1.wsdl"
  v2_wsdl = File.dirname(".")+"/resources/wsdls/v2.wsdl"
    
  build_jars = [ 
      "#{axis2_patch_home}/lib/axis2-1.5.3-SNAPSHOT.jar",
      "./lib/XmlSchema-1.4.3.jar",
      "./lib/activation-1.1.jar",
      "./lib/axiom-api-1.2.9.jar",
      "./lib/axiom-dom-1.2.9.jar",
      "./lib/axiom-impl-1.2.9.jar",
      "./lib/commons-codec-1.3.jar",
      "./lib/commons-httpclient-3.1.jar",
      "./lib/commons-logging-1.1.1.jar",
      "./lib/geronimo-stax-api_1.0_spec-1.0.1.jar",
      "./lib/httpcore-4.0.jar",
      "./lib/neethi-2.0.4.jar",
      "./lib/wsdl4j-1.6.2.jar",
      "./lib/wstx-asl-3.2.9.jar",
      "./lib/xalan-2.7.0.jar",
      "./lib/xmlbeans-2.3.0.jar"      
  ]
  cp = build_jars.join(":")
  
  #generate Axis JavaBean classes from wsdl, -Eiu is our new flag to ignore unexpected
  system("export AXIS2_HOME=#{axis2_patch_home} && java -cp #{cp} org.apache.axis2.wsdl.WSDL2Java -uri #{v1_wsdl} -u -Eosv -Eiu -o #{v1_artifact_location}")
  #compile Axis JavaBean classes
  system("export AXIS2_HOME=#{axis2_patch_home} && cd #{v1_artifact_location} && export CLASSPATH=#{cp} && ant")

  #generate Axis JavaBean classes from wsdl, -Eiu is our new flag to ignore unexpected
  system("export AXIS2_HOME=#{axis2_patch_home} && java -cp #{cp} org.apache.axis2.wsdl.WSDL2Java -uri #{v2_wsdl} -u -Eosv -Eiu -o #{v2_artifact_location}")
  #compile Axis JavaBean classes
  system("export AXIS2_HOME=#{axis2_patch_home} && cd #{v2_artifact_location} && export CLASSPATH=#{cp} && ant")

end

desc "call build_axis2_patch, generate_artifacts, test"
task :default => [:build_axis2_patch,:generate_artifacts,:test]