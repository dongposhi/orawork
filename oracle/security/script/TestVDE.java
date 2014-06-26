import java.io.*;
import java.util.*;
import com.octetstring.nls.*;
import com.octetstring.vde.*;
import com.octetstring.vde.schema.*;
import com.octetstring.vde.util.*;
import com.octetstring.vde.replication.*;
import com.octetstring.vde.backend.*;
import com.octetstring.vde.backend.standard.*;
import com.octetstring.vde.syntax.*;

import weblogic.server.ServiceFailureException;

public class TestVDE{
    private static Replication replication = null;
    /**
	
			java -cp .:$CLASSPATH -Dvde.home=/scratch/doshi/workspace/wls-domains/domain1/servers/AdminServer/data/ldap TestVDE
	*/
	public static void main(String[] args) throws Exception{	
        initServerConfig();
		initBackEnd();
    }

	private static final String WL_HOME="/scratch/doshi/workspace/soap_web_services/itest/install-server/target/middleware/wlserver";
    private static final String TARGET_DN = "cn=urn@Lbea@Lxacml@L2.0@Lentitlement@Lrole@LAdmin@L+xacmlVersion=1.0,ou=Policies,ou=XACMLRole,ou=myrealm,dc=domain1";
	private static final String TARGET_ATTR =	"xacmlDocument";
	
	private static void initBackEnd(){
	    String domainName = "dc=domain1";
		
		Properties backendProps = new Properties();
		
        backendProps.setProperty("backend.0.root", domainName);
        backendProps.setProperty("backend.0.config.backup-hour",Integer.toString(10));
        backendProps.setProperty("backend.0.config.backup-minute",Integer.toString(10));
        backendProps.setProperty("backend.0.config.backup-max",Integer.toString(10));

   //     debugWriteProperties(WL_HOME + "/server/lib/adaptertypes.prop", backendProps);
        com.octetstring.vde.backend.BackendHandler handler = com.octetstring.vde.backend.BackendHandler.getInstance(backendProps);

        // Enable timed activities trigger
        try {
            BackendStandard backend = (BackendStandard) handler.getBackend(new DirectoryString(domainName));
			DataFile df = backend.getDataFile();
			
			System.out.println("=====================");
						
			Entry entry = backend.getByDN(new DirectoryString(""), new DirectoryString (TARGET_DN));
			
			EntryChange ec = null;
			
			for (Object obj : entry.getAttributes()){
				Attribute attr = (Attribute)obj;
				if(attr.type.equals(new DirectoryString(TARGET_ATTR))){
					Vector nv = new Vector();
					for(Object value : attr.values){
						String str = (String) value.toString();
						str = str.replaceAll("SDP","xxx");
						
						nv.add(new DirectoryString(str));
					}
					entry.put(new DirectoryString(TARGET_ATTR),nv,false);					
					
					ec = new EntryChange(1,new DirectoryString(TARGET_ATTR),nv);
					break;
				}
			}			
			df.deleteEntry(entry.getID());
			//df.addEntry(entry);
			
			//Vector entries = new Vector();
			//entries.add(ec);
			//backend.modify(new DirectoryString(""), new DirectoryString (dn),entries);
			
			entry = backend.getByDN(new DirectoryString(""), new DirectoryString (TARGET_DN));
			System.out.println(entry.toLDIF());			
        } catch (Exception e) {
			e.printStackTrace();
		}
		System.out.println("=====================");
		System.exit(0);
    }

    private static void initServerConfig() throws Exception
    {
        ServerConfig config = ServerConfig.getInstance();        
        config.init();
        config.setProperty(ServerConfig.VDE_DEBUG, "1");
		// Set paths to installed files
		config.setProperty(ServerConfig.VDE_STDSCHEMA, WL_HOME + "/server/lib/schema.core.xml");
        config.setProperty(ServerConfig.VDE_BACKENDTYPES, WL_HOME + "/server/lib/adaptertypes.prop");
        config.setProperty(ServerConfig.VDE_SERVER_BACKENDS, WL_HOME + "/server/lib/adapters.prop");
        config.setProperty(ServerConfig.VDE_ACLFILE, WL_HOME + "/server/lib/acls.prop");
		/*
        config.setProperty(ServerConfig.VDE_SERVER_NAME, "domain1");
        config.setProperty(ServerConfig.VDE_SERVER_LISTENADDR, "10.245.30.194");
        config.setProperty(ServerConfig.VDE_SERVER_PORT, "7001");
        config.setProperty(ServerConfig.VDE_ROOTUSER, "cn=Admin");
		config.setProperty(ServerConfig.VDE_ROOTPW, "1");
        config.setProperty(ServerConfig.VDE_ALLOW_ANONYMOUS_BIND,"false");
        config.setProperty(ServerConfig.VDE_LOGCONSOLE, "0");
        config.setProperty(ServerConfig.VDE_TLS, "0");
        config.setProperty(ServerConfig.VDE_CHANGELOG,"0");
		
		config.setProperty(ServerConfig.VDE_SCHEMACHECK, "0");
		*/

        
    }
	
    static void debugWriteProperties(String propFileName, Properties props) {

        // The vde.prop file is empty
        try {
            PrintWriter out = new PrintWriter(new FileWriter(propFileName, true));
            out.println("# Adding properties set at runtime");
            Iterator it = props.keySet().iterator();
            while (it.hasNext()) {
                String key = (String)it.next();
                out.println(key + "=" + (String)props.getProperty(key));
            }
            out.close();
        } catch (IOException ioe) {
            ioe.printStackTrace();
        }
    }
}
