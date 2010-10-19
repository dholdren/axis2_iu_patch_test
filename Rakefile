require "rake/testtask"

Rake::TestTask.new do |t|
  #t.libs << "test"
  #t.libs << "lib"
  t.test_files = FileList["*_test.rb"]
  t.verbose = true
end

desc "build the axis2 patch itself"
task :build_axis2_patch do
  system("cd ../axis2_patch && mvn -Dmaven.test.skip=true -DskipTests=true install")
end

desc "create all the Axis JavaBeans from the patched axis"
task :generate_artifacts do
  currdir = File.expand_path(".")
  axis2_patch_home = File.expand_path("./../axis2_patch/target")
  
  system("rm -rf ./java-artifacts/*")
  
  wsdls = Dir.glob("./resources/wsdls/*.wsdl")
    
  build_jars = [ 
      "#{axis2_patch_home}/axis2-1.5.3-SNAPSHOT.jar",
      "#{currdir}/lib/XmlSchema-1.4.3.jar",
      "#{currdir}/lib/activation-1.1.jar",
      "#{currdir}/lib/axiom-api-1.2.9.jar",
      "#{currdir}/lib/axiom-dom-1.2.9.jar",
      "#{currdir}/lib/axiom-impl-1.2.9.jar",
      "#{currdir}/lib/commons-codec-1.3.jar",
      "#{currdir}/lib/commons-httpclient-3.1.jar",
      "#{currdir}/lib/commons-logging-1.1.1.jar",
      "#{currdir}/lib/geronimo-stax-api_1.0_spec-1.0.1.jar",
      "#{currdir}/lib/httpcore-4.0.jar",
      "#{currdir}/lib/neethi-2.0.4.jar",
      "#{currdir}/lib/wsdl4j-1.6.2.jar",
      "#{currdir}/lib/wstx-asl-3.2.9.jar",
      "#{currdir}/lib/xalan-2.7.0.jar",
      "#{currdir}/lib/xmlbeans-2.3.0.jar"      
  ]
  cp = build_jars.join(":")
  
  wsdls.each {|wsdl_full_filename|
    wsdl_full_filename =~ /.*\/([^\/]+)\.wsdl/
    slug = $1
    java_artifact_location = "#{currdir}/java-artifacts/#{slug}"

    #generate Axis JavaBean classes from wsdl, -Eiu is our new flag to ignore unexpected
    puts "running wsdl2java command:"
    puts "export AXIS2_HOME=#{axis2_patch_home} && java -cp #{cp} org.apache.axis2.wsdl.WSDL2Java -uri #{wsdl_full_filename} -u -Eosv -Eiu -o #{java_artifact_location}"
    system("export AXIS2_HOME=#{axis2_patch_home} && java -cp #{cp} org.apache.axis2.wsdl.WSDL2Java -uri #{wsdl_full_filename} -u -Eosv -Eiu -o #{java_artifact_location}")
    #compile Axis JavaBean classes
    puts "running ant command:"
    puts "export AXIS2_HOME=#{axis2_patch_home} && cd #{java_artifact_location} && export CLASSPATH=#{cp} && ant"
    system("export AXIS2_HOME=#{axis2_patch_home} && cd #{java_artifact_location} && export CLASSPATH=#{cp} && ant")
  
  }

end

desc "call build_axis2_patch, generate_artifacts, test"
task :default => [:build_axis2_patch,:generate_artifacts,:test]