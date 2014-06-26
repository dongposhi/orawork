from  java.io import FileWriter, IOException, PrintWriter
from  java.util import Iterator,Properties,Vector

from com.octetstring.vde import Attribute,Entry,EntryChange
from com.octetstring.vde.backend import BackendHandler
from com.octetstring.vde.backend.standard import BackendStandard,DataFile
from com.octetstring.vde.replication import Replication
from com.octetstring.vde.syntax import DirectoryString
from com.octetstring.vde.util import ServerConfig


from java.lang import System


WL_HOME="/scratch/doshi/workspace/soap_web_services/itest/install-server/target/middleware/wlserver"
domainName = "dc=domain1"
domainHome = "/scratch/doshi/workspace/wls-domains/domain1/"


TARGET_DN = "cn=urn@Lbea@Lxacml@L2.0@Lentitlement@Lrole@LAdmin@L+xacmlVersion=1.0,ou=Policies,ou=XACMLRole,ou=myrealm,dc=domain1"
TARGET_ATTR = "xacmlDocument"

System.getProperties().put("vde.home",domainHome + "/servers/AdminServer/data/ldap")

config = ServerConfig.getInstance()        
config.init()
config.setProperty(ServerConfig.VDE_DEBUG, "1")
config.setProperty(ServerConfig.VDE_STDSCHEMA, WL_HOME + "/server/lib/schema.core.xml")
config.setProperty(ServerConfig.VDE_BACKENDTYPES, WL_HOME + "/server/lib/adaptertypes.prop")
config.setProperty(ServerConfig.VDE_SERVER_BACKENDS, WL_HOME + "/server/lib/adapters.prop")
config.setProperty(ServerConfig.VDE_ACLFILE, WL_HOME + "/server/lib/acls.prop")

		
backendProps = Properties()
		
backendProps.setProperty("backend.0.root", domainName)
backendProps.setProperty("backend.0.config.backup-hour",Integer.toString(10))
backendProps.setProperty("backend.0.config.backup-minute",Integer.toString(10))
backendProps.setProperty("backend.0.config.backup-max",Integer.toString(10))

handler = BackendHandler.getInstance(backendProps)
backend = handler.getBackend(DirectoryString(domainName))
df = backend.getDataFile()					
entry = backend.getByDN(DirectoryString(""), DirectoryString (TARGET_DN))

#attrs = filter(lambda x : x.type.equals(DirectoryString(TARGET_ATTR)),entry.getAttributes())
#nv = Vector()
#for value in attrs[0].values:
#	nv.add(DirectoryString(value.toString().replace("SDP","AppTesters")))

for attr in entry.getAttributes():
	print("+++++++++++++++++++")
	if attr.type.equals(DirectoryString(TARGET_ATTR)):
		nv = Vector()
		for value in attr.values:
			print (value.toString())
			#str = value.toString()
			#str = str.replace("SDP","AppTesters")
			#nv.add(DirectoryString(str))
		
		entry.put(DirectoryString(TARGET_ATTR),nv,false)					
		break
			
#df.modifyEntry(entry)
			
print("==========")
entry = backend.getByDN(DirectoryString(""), DirectoryString (TARGET_DN))
print(entry.toLDIF())			
