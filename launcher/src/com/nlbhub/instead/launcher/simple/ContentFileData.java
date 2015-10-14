package com.nlbhub.instead.launcher.simple;

import android.content.ContentResolver;
import android.database.Cursor;
import android.net.Uri;
import android.provider.OpenableColumns;
import android.util.Log;
import com.nlbhub.instead.standalone.InsteadApplication;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;

/**
 * See http://stackoverflow.com/questions/14364091/retrieve-file-path-from-caught-downloadmanager-intent
 * I just want to add to the answer from @erickok as it took me several hours to figure this out. As stated by @jcesarmobile, you are only guaranteed to be able to get the name and size of the file, not the full path.
 *
 * You can get the name and size as follows, and then save to a temp file:
 */
public class ContentFileData {
    private InputStream inputStream = null;
    private String filename = "";
    private ContentResolver contentResolver;
    private Uri uri;

    public ContentFileData(ContentResolver contentResolver, Uri uri) {
        this.contentResolver = contentResolver;
        this.uri = uri;
        Cursor cursor = null;
        try {
            cursor = (
                    contentResolver.query(
                            uri,
                            new String[] {OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE},
                            null,
                            null,
                            null
                    )
            );
            if (cursor != null && cursor.moveToFirst()) {
                filename = cursor.getString(0);
                //filesize = cursor.getLong(1);
            } else {
                filename = uri.getLastPathSegment();
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }
    }

    public ContentFileData open() {
        try {
            inputStream = contentResolver.openInputStream(uri);
            return this;
        } catch (FileNotFoundException e) {
            Log.e(InsteadApplication.ApplicationName, "File not found", e);
        }
        return null;
    }

    public InputStream getInputStream() {
        return inputStream;
    }

    public String getFilename() {
        return filename;
    }

    public boolean isIdf() {
        return filename.toLowerCase().endsWith(".idf");
    }

    public boolean isZip() {
        return filename.toLowerCase().endsWith(".zip");
    }

    public boolean isQm() {
        return filename.toLowerCase().endsWith(".qm");
    }

    public void close() {
        try {
            if (inputStream != null) {
                inputStream.close();
            }
        } catch (IOException e) {
            Log.e(InsteadApplication.ApplicationName, "Error while closing stream", e);
        }
    }
}