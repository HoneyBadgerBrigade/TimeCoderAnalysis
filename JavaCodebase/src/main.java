import com.google.api.client.auth.oauth2.Credential;
import com.google.api.client.http.HttpTransport;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.jackson2.JacksonFactory;
//import com.google.api.services.samples.youtube.cmdline.Auth;
import com.google.api.services.youtube.YouTube;
import com.google.api.services.youtube.model.Channel;
import com.google.api.services.youtube.model.ChannelListResponse;
import com.google.api.services.youtubeAnalytics.YouTubeAnalytics;
import com.google.api.services.youtubeAnalytics.model.ResultTable;
import com.google.api.services.youtubeAnalytics.model.ResultTable.ColumnHeaders;
import com.google.common.collect.Lists;

import java.io.*;
import java.io.FileInputStream;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * This example uses the YouTube Data and YouTube Analytics APIs to retrieve
 * YouTube Analytics data. It also uses OAuth 2.0 for authorization.
 *
 * @author Christoph Schwab-Ganser and Jeremy Walker
 */
public class main {

    /**
     * Define a global instance of the HTTP transport.
     */
    private static final HttpTransport HTTP_TRANSPORT = new NetHttpTransport();

    /**
     * Define a global instance of the JSON factory.
     */
    private static final JsonFactory JSON_FACTORY = new JacksonFactory();

    /**
     * Define a global instance of a Youtube object, which will be used
     * to make YouTube Data API requests.
     */
    private static YouTube youtube;

    /**
     * Define a global instance of a YoutubeAnalytics object, which will be
     * used to make YouTube Analytics API requests.
     */
    private static YouTubeAnalytics analytics;

    public static String COMMA = ",";
    public static String ENDL  = "\n";
    public static String UNDERSCORE = "_";

    private static List<String>  TimeCoderList = new ArrayList<String>();
    private static List<String>  ShowId = new ArrayList<String>();
    private static List<String>  ShowType = new ArrayList<String>();
    private static List<Integer> ShowNumber = new ArrayList<Integer>();

    /**
     * This code authorizes the user, uses the YouTube Data API to retrieve
     * information about the user's YouTube channel, and then fetches and
     * prints statistics for the user's channel using the YouTube Analytics API.
     *
     * @param args command line args (not used).
     */
    public static void main(String[] args) {

        // These scopes are required to access information about the
        // authenticated user's YouTube channel as well as Analytics
        // data for that channel.
        List<String> scopes = Lists.newArrayList(
                "https://www.googleapis.com/auth/yt-analytics.readonly",
                "https://www.googleapis.com/auth/youtube.readonly"
        );

        try {
            // Authorize the request.
            Credential credential = Auth.authorize(scopes, "analyticsreports");

            // This object is used to make YouTube Data API requests.
            youtube = new YouTube.Builder(HTTP_TRANSPORT, JSON_FACTORY, credential)
                    .setApplicationName("youtube-analytics-api-report-example")
                    .build();

            // This object is used to make YouTube Analytics API requests.
            analytics = new YouTubeAnalytics.Builder(HTTP_TRANSPORT, JSON_FACTORY, credential)
                    .setApplicationName("youtube-analytics-api-report-example")
                    .build();

            // Construct a request to retrieve the current user's channel ID.
            YouTube.Channels.List channelRequest = youtube.channels().list("id,snippet");
            channelRequest.setMine(true);
            channelRequest.setFields("items(id,snippet/title)");
            ChannelListResponse channels = channelRequest.execute();

            // List channels associated with the user.
            List<Channel> listOfChannels = channels.getItems();

            // The user's default channel is the first item in the list.
            Channel defaultChannel = listOfChannels.get(0);
            String channelId = "UC595wqznMGuY2mi6DKx-qnQ"; //hbr channeld id//defaultChannel.getId();
            String videoId = "";

            //get all of the lines from the csv file
            readShowListFile();

            //loop over all the shows we want to analyze
            for(int ii = 0; ii < ShowId.size(); ii++) {

                PrintStream writerToScreen = System.out;
                //get the video data
                videoId = ShowId.get(ii);
                ResultTable resultTable = executeAudienceWatchRationOverTime(analytics, channelId, videoId);
                ResultTable viewResultTable = executeVideoViews(analytics,channelId,videoId);

                Object column = viewResultTable.getRows().get(0).get(1);
                String views = column.toString();

                column = viewResultTable.getRows().get(0).get(0);
                String publishedDate = column.toString();

                //file name will be ShowType_ShowNumber_TimeCoder_Views_DateUpdloaded
                String fileName = ShowType.get(ii) + UNDERSCORE +  ShowNumber.get(ii) + UNDERSCORE + TimeCoderList.get(ii) + UNDERSCORE + views + UNDERSCORE + publishedDate;
                PrintWriter writer = new PrintWriter(new FileOutputStream("OutputFiles/" + fileName + ".csv", false));
                printToScreen(writerToScreen, fileName, resultTable);
                printData(writer, resultTable);
                writer.close();
            }
        } catch (IOException e) {
            System.err.println("IOException: " + e.getMessage());
            e.printStackTrace();
        } catch (Throwable t) {
            System.err.println("Throwable: " + t.getMessage());
            t.printStackTrace();
        }
    }

    /**
     * Retrieve the views and unique viewers per day for the channel.
     *
     * @param analytics The service object used to access the Analytics API.
     * @param channelId        The channel ID from which to retrieve data.
     * @param videoId          The video ID from which to retrieve data.
     * @return The API response.
     * @throws IOException if an API error occurred.
     */
    private static ResultTable executeAudienceWatchRationOverTime(YouTubeAnalytics analytics, String channelId, String videoId) throws IOException {

        return analytics.reports()
                .query("channel==" + channelId,     // channel id
                        "2015-08-01",         // Start date.
                        "2017-08-10",         // End date.
                        "audienceWatchRatio")      // Metrics.
                .setDimensions("elapsedVideoTimeRatio")
                .setFilters("video==" + videoId)
                .execute();
    }

    private static ResultTable executeVideoViews(YouTubeAnalytics analytics, String channelId, String videoId) throws IOException {

        return analytics.reports()
                .query("channel==" + channelId,     // channel id
                        "2015-08-01",         // Start date.
                        "2017-08-10",         // End date.
                        "views")      // Metrics.
                .setFilters("video==" + videoId)
                .setDimensions("day")
                .execute();

    }

    /**
     * Prints the API response. The channel name is printed along with
     * each column name and all the data in the rows.
     *
     * @param writer  stream to output to
     * @param results data returned from the API.
     */
    private static void printData(PrintWriter writer, ResultTable results) {
        //print the header
        writer.println("TimePercentage" + COMMA + "WatchPercentage");
        if (results.getRows() == null || results.getRows().isEmpty()) {
            writer.println("No results Found.");
        } else {
            // Print data

            for (List<Object> row : results.getRows()) {
                StringBuilder stringBuilder = new StringBuilder();
                for (int colNum = 0; colNum < results.getColumnHeaders().size(); colNum++) {
                    ColumnHeaders header = results.getColumnHeaders().get(colNum);
                    Object column = row.get(colNum);
                    stringBuilder.append(column);
                    if(colNum != results.getColumnHeaders().size()-1) {
                        stringBuilder.append(COMMA);
                    }
                }
                writer.println(stringBuilder.toString());
            }
        }
    }


    /**
     * Prints the API response. The channel name is printed along with
     * each column name and all the data in the rows.
     *
     * @param writer  stream to output to
     * @param title   title of the report
     * @param results data returned from the API.
     */
    private static void printToScreen(PrintStream writer, String title, ResultTable results) {
        writer.println("Report: " + title);
        if (results.getRows() == null || results.getRows().isEmpty()) {
            writer.println("No results Found.");
        } else {

            // Print column headers.
            for (ColumnHeaders header : results.getColumnHeaders()) {
                writer.printf("%30s", header.getName());
            }
            writer.println();

            // Print actual data.
            for (List<Object> row : results.getRows()) {
                for (int colNum = 0; colNum < results.getColumnHeaders().size(); colNum++) {
                    ColumnHeaders header = results.getColumnHeaders().get(colNum);
                    Object column = row.get(colNum);
                    if ("INTEGER".equals(header.getUnknownKeys().get("dataType"))) {
                        long l = ((BigDecimal) column).longValue();
                        writer.printf("%30d", l);
                    } else if ("FLOAT".equals(header.getUnknownKeys().get("dataType"))) {
                        writer.printf("%30f", column);
                    } else if ("STRING".equals(header.getUnknownKeys().get("dataType"))) {
                        writer.printf("%30s", column);
                    } else {
                        // default output.
                        writer.printf("%30s", column);
                    }
                }
                writer.println();
            }
            writer.println();
        }
    }

    private static void readShowListFile()
    {
        try {
            BufferedReader bufferedReader = new BufferedReader(new FileReader("FilesToRead.csv"));

            //read the header
            String line = bufferedReader.readLine();
            //now read the real lines
            line = bufferedReader.readLine();

            //full show name. timecoder, id, showtype, showNumber
            while(line != null)
            {
                //find where comma is

                //remove first column since we don't care about that
                int idx = line.indexOf(COMMA);
                line = line.substring(idx+1);

                //the second column is the timecoder
                idx = line.indexOf(COMMA);
                TimeCoderList.add(line.substring(0,idx));
                line = line.substring(idx+1);

                //the third column is the Show Id
                idx = line.indexOf(COMMA);
                ShowId.add(line.substring(0,idx));
                line = line.substring(idx+1);

                //the fourth column is the Show Type
                idx = line.indexOf(COMMA);
                ShowType.add(line.substring(0,idx));
                line = line.substring(idx+1);

                //the fifth column is the Show Number
                ShowNumber.add(Integer.parseInt(line));

                line = bufferedReader.readLine();
            }
        } catch(FileNotFoundException e)
        {

        }
        catch (IOException e)
        {

        }
    }

}