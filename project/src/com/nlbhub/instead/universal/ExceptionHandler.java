package com.nlbhub.instead.universal;

import android.content.Context;
import android.os.Build;
import com.nlbhub.instead.standalone.Globals;

import java.io.*;
import java.text.DateFormat;
import java.util.Date;

/**
 * Thread.setDefaultUncaughtExceptionHandler(new ExceptionHandler(this)); // add this to your activity page
 * In my case it is SDLActivity
 * Created by Antokolos on 30.08.15.
 */
public class ExceptionHandler implements
        java.lang.Thread.UncaughtExceptionHandler {
    private final Context myContext;
    private final String LINE_SEPARATOR = "\n";
    Thread.UncaughtExceptionHandler defaultUEH;

    public ExceptionHandler(Context con) {
        myContext = con;
        defaultUEH = Thread.getDefaultUncaughtExceptionHandler();
    }

    @SuppressWarnings("deprecation")
    public void uncaughtException(Thread thread, Throwable exception) {

        StringWriter stackTrace = new StringWriter();
        exception.printStackTrace(new PrintWriter(stackTrace));
        StringBuilder errorReport = new StringBuilder();
        errorReport.append("************ CAUSE OF ERROR ************\n\n");
        errorReport.append(stackTrace.toString());

        errorReport.append("\n************ DEVICE INFORMATION ***********\n");
        errorReport.append("Brand: ");
        errorReport.append(Build.BRAND);
        errorReport.append(LINE_SEPARATOR);
        errorReport.append("Device: ");
        errorReport.append(Build.DEVICE);
        errorReport.append(LINE_SEPARATOR);
        errorReport.append("Model: ");
        errorReport.append(Build.MODEL);
        errorReport.append(LINE_SEPARATOR);

        File root = android.os.Environment.getExternalStorageDirectory();
        String currentDateTimeString = DateFormat.getDateTimeInstance().format(
                new Date());

        File dir = new File(Globals.getStorage() + Globals.ApplicationName);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        File file = new File(dir, "log.txt");

        try {
            BufferedWriter buf = new BufferedWriter(new FileWriter(file, true));
            buf.append(currentDateTimeString + ":" + errorReport.toString());
            buf.newLine();
            buf.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

        defaultUEH.uncaughtException(thread, exception);
        System.exit(0);
    }

}