require "buildr/xmlbeans"
#require "buildr/cobertura"
require "install.rb"

# Keep this structure to allow the build system to update version numbers.

VERSION_NUMBER = "7.0.0-SNAPSHOT"

AXIS2_LIB = [
  AXIS2[:kernel],
  AXIS2[:adb],
  AXIS2[:xmlbeans],
  AXIS2[:json],
  BACKPORT,
  NEETHI,
  SUNMAIL
]

desc "Deployment Service"
define "deploy" do
  project.version = VERSION_NUMBER
  project.group = "org.intalio.deploy"
  
  compile.options.source = "1.5"
  compile.options.target = "1.5"

  define "registry" do
    compile.with SLF4J.values
    package :jar
  end

  desc "Deployment API"
  define "api" do
    compile.with project("registry"), SLF4J.values
    package :jar
  end

  desc "Deployment Service Implementation"
  define "impl" do
    compile.with projects("api", "registry"), SECURITY.values, SERVLET_API, SHOAL, SLF4J.values, SPRING[:core]
    test.with AXIS2_LIB, APACHE_COMMONS[:dbcp], APACHE_COMMONS[:pool], LOG4J, XERCES.values, APACHE_DERBY, APACHE_DERBY_NET, APACHE_DERBY_CLIENT
    test.exclude '*TestUtils*'
    package :jar
  end

  desc "Deployment Web-Service Common Library"
  define "ws-common" do
    compile.with projects("api", "impl", "registry"), AXIOM, AXIS2_LIB, SUNMAIL, SLF4J.values, SPRING[:core], STAX_API 
    package :jar
  end
  
  desc "Deployment Web-Service Client"
  define "ws-client" do
    compile.with projects("api", "ws-common"), 
                 AXIOM, AXIS2_LIB, SLF4J.values, STAX_API, SPRING[:core]
    test.with project("impl"), project("impl").test.compile.target, project("registry"), APACHE_COMMONS[:httpclient], APACHE_COMMONS[:codec], APACHE_COMMONS[:dbcp], APACHE_COMMONS[:pool], LOG4J, SUNMAIL, XERCES.values, WS_COMMONS_SCHEMA, WSDL4J, WOODSTOX, APACHE_DERBY, APACHE_DERBY_NET, APACHE_DERBY_CLIENT 

    # Remember to set JAVA_OPTIONS before starting Jetty
    # export JAVA_OPTIONS=-Dorg.intalio.tempo.configDirectory=/home/boisvert/svn/tempo/security-ws2/src/test/resources
    
    # require live Axis2 instance
    if ENV["LIVE"] == 'yes'
      LIVE_ENDPOINT = "http://localhost:8080/axis2/services/DeploymentService"
    end
    
    if defined? LIVE_ENDPOINT
      test.using :properties => 
        { "org.intalio.tempo.deploy.ws.endpoint" => LIVE_ENDPOINT,
          "org.intalio.tempo.configDirectory" => _("src/test/resources") }
    end

    package(:jar).tap do |jar|
      jar.with :meta_inf => project("ws-service").path_to("src/main/axis2/*.wsdl")
    end
  end

  desc "Deployment Web-Service"
  define "ws-service" do
#    compile.with projects("api", "ws-common"), AXIOM, AXIS2_LIB, SLF4J.values, SPRING[:core], STAX_API
    package(:aar).with :libs => [ projects("api", "impl", "ws-common"), SLF4J.values, SPRING[:core], SHOAL, APACHE_COMMONS[:dbcp], APACHE_COMMONS[:pool], APACHE_DERBY, APACHE_DERBY_NET ]
  end
end
