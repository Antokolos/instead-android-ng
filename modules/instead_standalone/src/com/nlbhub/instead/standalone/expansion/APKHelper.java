package com.nlbhub.instead.standalone.expansion;

import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import com.google.android.vending.expansion.downloader.DownloaderClientMarshaller;
import com.google.android.vending.expansion.downloader.Helpers;
import com.google.android.vending.expansion.downloader.IDownloaderClient;
import com.google.android.vending.expansion.downloader.IStub;
import com.nlbhub.instead.standalone.InsteadApplication;

/**
 * Created by Antokolos on 14.10.15.
 */
public class APKHelper {

    private Context context;

    public APKHelper(Context context) {
        this.context = context;
    }

    public IStub createDownloaderStubIfNeeded(InsteadApplication application, IDownloaderClient client) throws PackageManager.NameNotFoundException {
        // Check if expansion files are available before going any further
        if (!application.expansionFilesDelivered()) {
            // Build an Intent to start this activity from the Notification
            Intent notifierIntent = new Intent(context, client.getClass());
            notifierIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);

            PendingIntent pendingIntent = (
                    PendingIntent.getActivity(context, 0, notifierIntent, PendingIntent.FLAG_UPDATE_CURRENT)
            );

            // Start the download service (if required)
            int startResult = (
                    DownloaderClientMarshaller.startDownloadServiceIfRequired(
                            context,
                            pendingIntent,
                            InsteadDownloaderService.class
                    )
            );
            // If download has started, initialize this activity to show
            // download progress
            if (startResult != DownloaderClientMarshaller.NO_DOWNLOAD_REQUIRED) {
                // This is where you do set up to display the download progress
                // Instantiate a member instance of IStub
                return DownloaderClientMarshaller.CreateStub(client, InsteadDownloaderService.class);
                // Inflate layout that shows download progress
                // client.setContentView(R.layout.downloader_ui);
            } // If the download wasn't necessary, fall through to start the app
        }
        return null;
    }
}
