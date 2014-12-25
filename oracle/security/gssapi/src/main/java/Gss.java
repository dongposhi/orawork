import java.io.*;
import org.ietf.jgss.*;
import org.bouncycastle.asn1.*;
import org.bouncycastle.asn1.util.*;
import sun.security.util.*;

public class Gss{
    protected final static String KERBEROS_V5_PRINNAMTYP_OID_NAME = "1.2.840.113554.1.2.2.1";
    protected final static String KERBEROS_V5_OID_NAME = "1.2.840.113554.1.2.2";

    public Gss(){
    }

    private static GSSCredential createCredential(GSSManager manager,String ownName, int type) throws GSSException{
        GSSName name = manager.createName(ownName,new Oid(KERBEROS_V5_PRINNAMTYP_OID_NAME));
        GSSCredential c = manager.createCredential(
                name,
                GSSCredential.INDEFINITE_LIFETIME,
                new Oid(KERBEROS_V5_OID_NAME),
                type
                );
        if(c != null){
            System.out.println("==>create credential for " + ownName + ": " + c.toString() );
        }
        else{
            System.out.println("failed to create credential for " + ownName);
        }
        return c;        
    }

    private static GSSContext createContext(GSSManager manager, String ownName, String peerName) throws GSSException{
        int type = (peerName == null)?GSSCredential.ACCEPT_ONLY:GSSCredential.INITIATE_ONLY;
        GSSCredential c = createCredential(manager,ownName,type);
        GSSName peerServiceName = null;
        if(peerName != null){
            peerServiceName = manager.createName(peerName,new Oid(KERBEROS_V5_PRINNAMTYP_OID_NAME));
        }
        
        GSSContext ctx = (peerName == null)?manager.createContext(c):manager.createContext(peerServiceName,new Oid(KERBEROS_V5_OID_NAME),c,GSSContext.DEFAULT_LIFETIME);

        if(ctx == null){
            System.out.println("Failed to create " + ((peerName == null)?"acceptor ":"initator ") +
                               "context for " + ownName + ((peerName == null)?"":"to " + peerName));
        }
        else{
            System.out.println("==>create " + ((peerName == null)?"acceptor ":"initator ") +
                               "context for " + ownName + ((peerName == null)?"":"to " + peerName));
        }
        return ctx;
    }

    private static void test1(){
        try
        {
            GSSManager manager = GSSManager.getInstance();

            GSSCredential c = null;
            createCredential(manager,"doshi@DEV.ORACLE.COM",GSSCredential.INITIATE_ONLY);
            createCredential(manager,"doshi@DEV.ORACLE.COM",GSSCredential.INITIATE_ONLY);
            createCredential(manager,"negotiatetester@SECURITYQA.COM",GSSCredential.INITIATE_ONLY);


            createCredential(manager,"linguo",GSSCredential.ACCEPT_ONLY);
            createCredential(manager,"doshi",GSSCredential.ACCEPT_ONLY);
            createCredential(manager,"negotiatetestserver@SECURITYQA.COM",GSSCredential.ACCEPT_ONLY);

        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    private static void parseServiceTicket(byte[] ticket) throws Exception {        
        try {
            // I didn't find a better way how to parse this Kerberos Message...
            ASN1InputStream asn1InputStream =
                    new ASN1InputStream(new ByteArrayInputStream(ticket));
            DERApplicationSpecific derToken =
                    (DERApplicationSpecific) asn1InputStream.readObject();
            if (derToken == null || !derToken.isConstructed()) {
                asn1InputStream.close();
                throw new Exception("invalid kerberos token");
            }
            asn1InputStream.close();

            asn1InputStream = new ASN1InputStream(new ByteArrayInputStream(derToken.getContents()));
            ASN1ObjectIdentifier kerberosOid =
                    (ASN1ObjectIdentifier) asn1InputStream.readObject();

            int readLowByte = asn1InputStream.read() & 0xff;
            int readHighByte = asn1InputStream.read() & 0xff;
            int read = (readHighByte << 8) + readLowByte; //NOPMD
            if (read != 0x01) {
                throw new Exception("invalid kerberos token");
            }
            
            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
            int re;
            byte[] b = new byte[1024];
            while ((re = asn1InputStream.read(b)) != -1) {
                byteArrayOutputStream.write(b, 0, re);
            }
            b =  byteArrayOutputStream.toByteArray();

            DerValue dv = new DerValue(b);
            System.out.println("====" + dv.toString());



        } catch (Exception e) {
            throw e;
        }
    }

    private static void test2(){
        try {
            GSSManager manager = GSSManager.getInstance();

            //creat initator conetxt
            String initName = "doshi@DEV.ORACLE.COM";
            String accName  = "linguo@DEV.ORACLE.COM";
            GSSContext initCtx = createContext(manager,initName,accName);
            if(initCtx == null){
                System.out.println("failed to create init context");
                return;
            }
            System.out.println("initiator is " + initName + " for " + accName);

            //creat acceptor conetxt
/*            accName = "negotiatetestserver@SECURITYQA.COM";*/
            //GSSContext accCtx = createContext(manager,accName,null);
            //if(accCtx == null){
                //System.out.println("failed to create acc context");
                //return;
            //}

            //System.out.println("acceptor is " + accName);
            //create init ticket
            byte[] buf = initCtx.initSecContext(new byte[]{},0,0);
            //System.out.println("init ticket:" + new String(buf));

            //parse the ticket with bcprov lib
            //
            parseServiceTicket(buf);
/*            sun.security.util.DerValue d = new sun.security.util.DerValue(buf);*/


            //System.out.println("dervalue is :" + d.toString()+" isApplication:" + d.isApplication() + 
                    //" isConstructed:" + d.isConstructed() + 
                    //" isContextSpecific:" + d.isContextSpecific());

                //sun.security.util.DerValue d1 = d.getData().getDerValue();
                //int tag = d1.getTag();
                //System.out.println("tag is " + tag);
                //if(d.getTag() == 6)
                    //System.out.println(d1.getOID());
                //if(d1.getTag() == 1)
                    //System.out.println(d1.getBoolean());
/*            sun.security.util.DerValue d2 = d.getData().getDerValue();*/
            //System.out.println(d2.toString());
            //System.out.println("get integer : " + d.getInteger());

            //ASN1InputStream bIn = new ASN1InputStream(new ByteArrayInputStream(buf));
            //System.out.println("********************");
            //System.out.println(ASN1Dump.dumpAsString(bIn.readObject()));
            //System.out.println("********************");

            ////accept sec ticket
            //buf = accCtx.acceptSecContext(buf,0,buf.length);
            ////System.out.println("accept ticket:" + new String(buf));

        } catch(Exception e) {
            e.printStackTrace();
        }
    }

    private static void generateToken(String serverName)
    {
    
        try
        {
            GSSManager manager = GSSManager.getInstance();

            // Make sure the JCE configuration is correct. If there are no mechs for the Oid, then they may not
            // have the jgss prvider configured.
            Oid prinOid = new Oid(KERBEROS_V5_PRINNAMTYP_OID_NAME);
            Oid [] mechs = manager.getMechsForName(prinOid);
            if ((mechs == null) || (mechs.length == 0))
            {
                System.out.println("mechs is null");
                return ;
            }


            GSSName name = manager.createName("linguo@DEV.ORACLE.COM",prinOid);
            GSSCredential c = manager.createCredential(
                     name,
                     GSSCredential.INDEFINITE_LIFETIME,
                     new Oid(KERBEROS_V5_OID_NAME),
                     GSSCredential.INITIATE_ONLY
                    );
            if(c != null){
                System.out.println("credential is for " + c.toString());
            }

            c = manager.createCredential(
                     manager.createName("linguo@DEV.ORACLE.COM",prinOid),
                     GSSCredential.INDEFINITE_LIFETIME,
                     new Oid(KERBEROS_V5_OID_NAME),
                     GSSCredential.ACCEPT_ONLY
                    );
            if(c != null){
                System.out.println("credential is for " + c.toString());
            }
            c = manager.createCredential(
                     manager.createName("negotiatetestserver@SECURITYQA.COM",prinOid),
                     GSSCredential.INDEFINITE_LIFETIME,
                     new Oid(KERBEROS_V5_OID_NAME),
                     GSSCredential.ACCEPT_ONLY
                    );
            if(c != null){
                System.out.println("credential is for " + c.toString());
            }
            GSSContext ctx = manager.createContext(
                    c
                    );
            if(ctx != null){
                System.out.println("context is " + ctx.toString());
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
    public static void main(String[] args){
        try {
            //test1();
            test2();
            //generateToken("");
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}
