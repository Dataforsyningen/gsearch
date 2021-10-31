package dk.dataforsyningen.gsearch;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;

import javax.sql.DataSource;

import org.jdbi.v3.core.Jdbi;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

class Listener extends Thread
{
    static Logger logger = LoggerFactory.getLogger(Listener.class);

    private Connection conn;
    private org.postgresql.PGConnection pgconn;
    private Jdbi jdbi;
    private JdbiConfiguration jdbiConfiguration;

    Listener(DataSource ds, Jdbi jdbi, JdbiConfiguration jdbiConfiguration) throws SQLException
    {
        this.jdbi = jdbi;
        this.jdbiConfiguration = jdbiConfiguration;
        this.conn = ds.getConnection();
        this.pgconn = conn.unwrap(org.postgresql.PGConnection.class);
        Statement stmt = conn.createStatement();
        stmt.execute("LISTEN gsearch");
        stmt.close();
        logger.info("Started");
    }

    public void run()
    {
        try
        {
            while (true)
            {
                org.postgresql.PGNotification notifications[] = pgconn.getNotifications(0);

                if (notifications != null)
                {
                    for (int i=0; i < notifications.length; i++) {
                        logger.info("Got notification: " + notifications[i].getName() + " param: " + notifications[i].getParameter());
                        if (notifications[i].getName().equals("gsearch") && notifications[i].getParameter().equals("reload"))
                            jdbiConfiguration.determineTypes(jdbi);
                    }
                }
            }
        }
        catch (SQLException e)
        {
            logger.error("Unexpected error in Listener", e);
        }
    }
}