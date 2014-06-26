import base64
import shutil
import os
import getopt
import sys

def usage():
	usage = """
usage: wlst.sh changerole.py --domain_home <domain home> --role <role name> --group <group name>

     The role name must be in ["Admin", "Deployer", "Operater", "Monitor","Anonymous","AppTester","CrossDomainConnector","AdminChannelUser","OracleSystemRole"]
Note:		
	The script can run only once for each role and only be valid before the very first booting.

	 """
	print usage



def replaceDefaultGroup4Role(role, newGrp):
	if not ROLES.has_key(role) :
		print "cannot support the role: " + role
		return
		
	roleDN = ROLES.get(role)[0]
	oldGrp = ROLES.get(role)[1]

	try:
		flag = False
		fh = open(fileName)
		outfh = open(tmpFile,"w")
		for  line in  fh.readlines():
			if line.startswith(roleDN):
				flag=True
				
			if flag and line.startswith(SYMBOL):
				doc = line[len(SYMBOL):]
				orig = base64.decodestring(doc)
				line = SYMBOL + base64.encodestring(orig.replace(oldGrp,newGrp)).replace('\n','') + "\n"	
				flag=False
				
			outfh.write(line)
			
		outfh.flush()			
		fh.close();
		outfh.close();
		shutil.copy(tmpFile, fileName)
	except IOError , e:
		print e

	if os.path.isfile(tmpFile):
		os.remove(tmpFile)
	return

	
############# main #########################
try:
	options,remainder = getopt.getopt(sys.argv[1:],'', ['domain_home=', 'role=', 'group=',"help"])
except getopt.error, msg:
    usage()
    sys.exit()

newGrp=None
domainName=None
role=None

for opt, arg in options:
	if opt == "--domain_home":
		domainName = arg
	elif opt == "--role":
		role = arg
	elif opt == "--group":
		newGrp = arg
	elif opt == "--help":
		usage()
		sys.exit()
		
if domainName is None or role is None or newGrp is None:
	usage()
	sys.exit()
			
fileName = domainName + "/security/XACMLRoleMapperInit.ldift"
tmpFile = domainName +  "/security/XACMLRoleMapperInit.ldift.tmp"

ROLES = { \
	"Admin" : ["dn: cn=urn@Lbea@Lxacml@L2.0@Lentitlement@Lrole@LAdmin@L+xacmlVersion=1.0,","Administrators"], \
	"Deployer" : ["dn: cn=urn@Lbea@Lxacml@L2.0@Lentitlement@Lrole@LDeployer@L+xacmlVersion=1.0,","Deployers"], \
	"Operator" : ["dn: cn=urn@Lbea@Lxacml@L2.0@Lentitlement@Lrole@LOperator@L+xacmlVersion=1.0,","Operators"], \
	"Monitor" : ["dn: cn=urn@Lbea@Lxacml@L2.0@Lentitlement@Lrole@LMonitor@L+xacmlVersion=1.0,","Monitors"], \
	"Anonymous" : ["dn: cn=urn@Lbea@Lxacml@L2.0@Lentitlement@Lrole@LAnonymous@L+xacmlVersion=1.0,","everyone"], \
	"AppTester" : ["dn: cn=urn@Lbea@Lxacml@L2.0@Lentitlement@Lrole@LAppTester@L+xacmlVersion=1.0,","AppTesters"], \
	"CrossDomainConnector" : ["dn: cn=urn@Lbea@Lxacml@L2.0@Lentitlement@Lrole@LCrossDomainConnector@L+xacmlVersion=1.0,","CrossDomainConnectors"], \
	"AdminChannelUser" : ["dn: cn=urn@Lbea@Lxacml@L2.0@Lentitlement@Lrole@LAdminChannelUser@L+xacmlVersion=1.0,","AdminChannelUsers"],	\
	"OracleSystemRole" : ["dn: cn=urn@Lbea@Lxacml@L2.0@Lentitlement@Lrole@LOracleSystemRole@L+xacmlVersion=1.0","OracleSystemGroup"], \
}
	
SYMBOL="xacmlDocument:: "
		
replaceDefaultGroup4Role(role, newGrp)