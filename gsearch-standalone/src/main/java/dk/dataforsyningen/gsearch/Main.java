package dk.dataforsyningen.gsearch;

import org.glassfish.grizzly.http.server.HttpServer;
import org.glassfish.jersey.grizzly2.servlet.GrizzlyWebContainerFactory;
import org.slf4j.bridge.SLF4JBridgeHandler;

import java.io.IOException;
import java.net.URI;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.LogManager;

public class Main {
    public static final String BASE_URI = "http://0.0.0.0:8080/";

    public static HttpServer startServer() throws IOException {
        LogManager.getLogManager().reset();
        SLF4JBridgeHandler.install();
        DatabaseManager.start();
        Map<String, String> initParams = new HashMap<>();
        initParams.put("javax.ws.rs.Application", "dk.dataforsyningen.gsearch.GSearchApplication");
        HttpServer server = GrizzlyWebContainerFactory.create(URI.create(BASE_URI), initParams);
        return server;
    }

    public static void main(String[] args) throws IOException {
        startServer();
    }
}
