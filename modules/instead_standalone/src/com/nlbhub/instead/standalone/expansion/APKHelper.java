package com.nlbhub.instead.standalone.expansion;

import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import com.google.android.vending.expansion.downloader.DownloaderClientMarshaller;
import com.google.android.vending.expansion.downloader.Helpers;
import com.google.android.vending.expansion.downloader.IDownloaderClient;
import com.google.android.vending.expansion.downloader.IStub;

/**
 * Created by Antokolos on 14.10.15.
 */
public class APKHelper {

    private Context context;

    public APKHelper(Context context) {
        this.context = context;
    }

    /**
     * This is a little helper class that demonstrates simple testing of an
     * Expansion APK file delivered by Market. You may not wish to hard-code
     * things such as file lengths into your executable... and you may wish to
     * turn this code off during application development.
     */
    private static class XAPKFile {
        public final boolean mIsMain;
        public final int mFileVersion;
        public final long mFileSize;

        XAPKFile(boolean isMain, int fileVersion, long fileSize) {
            mIsMain = isMain;
            mFileVersion = fileVersion;
            mFileSize = fileSize;
        }
    }

    /**
     * Here is where you place the data that the validator will use to determine
     * if the file was delivered correctly. This is encoded in the source code
     * so the application can easily determine whether the file has been
     * properly delivered without having to talk to the server. If the
     * application is using LVL for licensing, it may make sense to eliminate
     * these checks and to just rely on the server.
     */
    private static final XAPKFile[] xAPKS = {
            new XAPKFile(
                    true, // true signifies a main file
                    3, // the version of the APK that the file was uploaded
                    // against
                    687801613L // the length of the file in bytes
            ),
            new XAPKFile(
                    false, // false signifies a patch file
                    4, // the version of the APK that the patch file was uploaded
                    // against
                    512860L // the length of the patch file in bytes
            )
    };

    /**
     * Go through each of the APK Expansion files defined in the structure above
     * and determine if the files are present and match the required size. Free
     * applications should definitely consider doing this, as this allows the
     * application to be launched for the first time without having a network
     * connection present. Paid applications that use LVL should probably do at
     * least one LVL check that requires the network to be present, so this is
     * not as necessary.
     *
     * @return true if they are present.
     */
    boolean expansionFilesDelivered() {
        for (XAPKFile xf : xAPKS) {
            String fileName = Helpers.getExpansionAPKFileName(context, xf.mIsMain, xf.mFileVersion);
            if (!Helpers.doesFileExist(context, fileName, xf.mFileSize, false))
                return false;
        }
        return true;
    }

    public IStub createDownloaderStubIfNeeded(IDownloaderClient client) throws PackageManager.NameNotFoundException {
        // Check if expansion files are available before going any further
        if (!expansionFilesDelivered()) {
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
