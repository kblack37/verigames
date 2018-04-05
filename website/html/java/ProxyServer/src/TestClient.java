import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
 
import javax.net.ssl.HttpsURLConnection;
 
public class TestClient {
 
	private final String USER_AGENT = "Mozilla/5.0";
 
	public static void main(String[] args) throws Exception {
 
		TestClient http = new TestClient();
 
		System.out.println("Testing 1 - Send Http GET request");
		http.sendGet();
 
	//	System.out.println("\nTesting 2 - Send Http POST request");
	//	http.sendPost();
 
	}
 
	// HTTP GET request
	private void sendGet() throws Exception {
 
		String url = "http://flowjam.verigames.com/proxy/crossdomain";
 
		URL obj = new URL(url);
		HttpURLConnection con = (HttpURLConnection) obj.openConnection();
 
		// optional default is GET
		con.setRequestMethod("GET");
 
		//add request header
		con.setRequestProperty("User-Agent", USER_AGENT);
 
		int responseCode = con.getResponseCode();
		System.out.println("\nSending 'GET' request to URL : " + url);
		System.out.println("Response Code : " + responseCode);
 
		BufferedReader in = new BufferedReader(
		        new InputStreamReader(con.getInputStream()));
		String inputLine;
		StringBuffer response = new StringBuffer();
 
		while ((inputLine = in.readLine()) != null) {
			response.append(inputLine);
		}
		in.close();
 
		//print result
		System.out.println(response.toString());
 
	}
 
	// HTTP POST request
	private void sendPost() throws Exception {
 
		String url = "https://selfsolve.apple.com/wcResults.do";
		URL obj = new URL(url);
		HttpsURLConnection con = (HttpsURLConnection) obj.openConnection();
 
		//add reuqest header
		con.setRequestMethod("POST");
		con.setRequestProperty("User-Agent", USER_AGENT);
		con.setRequestProperty("Accept-Language", "en-US,en;q=0.5");
 
		String urlParameters = "sn=C02G8416DRJM&cn=&locale=&caller=&num=12345";
 
		// Send post request
		con.setDoOutput(true);
		DataOutputStream wr = new DataOutputStream(con.getOutputStream());
		wr.writeBytes(urlParameters);
		wr.flush();
		wr.close();
 
		int responseCode = con.getResponseCode();
		System.out.println("\nSending 'POST' request to URL : " + url);
		System.out.println("Post parameters : " + urlParameters);
		System.out.println("Response Code : " + responseCode);
 
		BufferedReader in = new BufferedReader(
		        new InputStreamReader(con.getInputStream()));
		String inputLine;
		StringBuffer response = new StringBuffer();
 
		while ((inputLine = in.readLine()) != null) {
			response.append(inputLine);
		}
		in.close();
 
		//print result
		System.out.println(response.toString());
 
	}
 
}


/*import java.io.*;
import java.net.*;
import java.util.Timer;
import java.util.TimerTask;

public class TestClient {
	public static void main(String[] args) throws IOException {
		 
		Timer timer = new Timer();
		
		timer.scheduleAtFixedRate(new TimerTask() {
			  @Override
			  public void run()  
			  {
				  try{
					  sendMessage();
				  }
				  catch(Exception e) {}
			  }
			}, 5*1000, 5*1000);
	}
	
	static void sendMessage() throws IOException
	{
        Socket kkSocket = null;
        PrintWriter out = null;
        BufferedReader in = null;
 
        try {
            kkSocket = new Socket("flowjam", 80);
            System.out.println("Connecting");
            out = new PrintWriter(kkSocket.getOutputStream(), true);
            System.out.println("Sending");
            in = new BufferedReader(new InputStreamReader(kkSocket.getInputStream()));
        } catch (UnknownHostException e) {
            System.err.println("Don't know about host: localhost.");
            System.exit(1);
        } catch (IOException e) {
            System.err.println("Couldn't get I/O for the connection to: localhost.");
            System.exit(1);
        }
 
     //   BufferedReader stdIn = new BufferedReader(new InputStreamReader(System.in));
        String fromServer;
//        String fromUser;
 
        if ((fromServer = in.readLine()) != null) {
            System.out.println("Server: " + fromServer);
//            if (fromServer.equals("quit"))
//                break;
             
//            fromUser = stdIn.readLine();
//        if (fromUser != null) {
//                System.out.println("Client: " + fromUser);
//                out.println(fromUser);
//        }
        }
 
        out.close();
        in.close();
 //       stdIn.close();
        kkSocket.close();
    }
}*/
