package com.nlbhub.instead.standalone;

import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.os.Environment;
import com.nlbhub.instead.standalone.fs.SystemPathResolver;

import java.io.File;
import java.io.IOException;

/**
 * Created by Antokolos on 09.10.15.
 */
public class StorageResolver {
    public static final String GameDir = "appdata/games/";
    public static final String SaveDir = "appdata/saves/";
    public static final String Options = "appdata/insteadrc";
    public static final String ThemesDir = "appdata/themes/";
    public static final String[] MainLuaFiles = {"main.lua", "main3.lua"};
    public static final String DataFlag = ".version";
    public static final String BundledGame = "bundled";

    public static String getStorage() {
        Settings settings = SettingsFactory.create(InsteadApplication.getAppContext());
        String result = getExternalStorage();

        String extStorageState = Environment.getExternalStorageState();
        boolean canRead;
        boolean canWrite;
        if (Environment.MEDIA_MOUNTED.equals(extStorageState)) {
            canWrite = true;
            canRead = true;
        } else if (Environment.MEDIA_MOUNTED_READ_ONLY.equals(extStorageState)) {
            canRead = true;
            canWrite = false;
        } else {
            canWrite = false;
            canRead = false;
        }
        if (!canRead || !canWrite || settings.isEnforceSystemStorage()) {
            result = getSystemStorage();
        }
        File dir = new File(result);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        return result;
    }

    public static String getExternalStorage() {
        return Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS) + "/";
    }

    public static String getSystemStorage() {
        final Context context = InsteadApplication.getAppContext();
        try {
            SystemPathResolver downloadResolver = new SystemPathResolver("dwn", context);
            return downloadResolver.getPath();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    public static String getDefaultProgramDir() {
        return getStorage() + InsteadApplication.ApplicationName;
    }

    public static String getProgramDirOnSDCard() {
        return getExternalStorage() + InsteadApplication.ApplicationName;
    }

    public static String getProgramDirInSystemMemory() {
        return getSystemStorage() + InsteadApplication.ApplicationName;
    }

    public static String getThemesDirectoryPath() {
        return getOutFilePath(ThemesDir);
    }

    public static File getThemesDirectory() throws IOException {
        return new File(getThemesDirectoryPath());
    }

    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    public static String getObbFilePath(final String filename, Context context) {
        return context.getObbDir() + "/" + filename;
    };

    public static String getOutFilePath(final String filename) {
        return getDefaultProgramDir() + "/" + filename;
    };

    public static String getOutFilePath(final String subDir, final String filename) {
        return getDefaultProgramDir() + "/" + subDir + "/" + filename;
    };

    public static boolean isWorking(String f){
        for (String mainLuaFile : MainLuaFiles) {
            String path = getOutFilePath(GameDir + "/" + f, mainLuaFile);
            if (new File(path).isFile()) {
                return true;
            }
        }
        return false;
    }

    public static String getGamesPath(ExpansionMounter expansionMounter) {
        final String expansionFilePath = (expansionMounter != null) ? expansionMounter.getExpansionFilePath() : null;
        final String appdata = getAppDataPath(expansionMounter);
        return (expansionFilePath != null) ? expansionFilePath + "/games" : appdata + "/games";
    }

    public static String getAppDataPath(ExpansionMounter expansionMounter) {
        final String expansionFilePath = (expansionMounter != null) ? expansionMounter.getExpansionFilePath() : null;
        final File bundledGameDirParent = (expansionFilePath != null) ? new File(expansionFilePath, "games") : null;
        String resultPath = StorageResolver.getDefaultProgramDir() + "/" + getAppDataFolderName(bundledGameDirParent);
        File resultDir = new File(resultPath);
        if (!resultDir.exists()) {
            // TODO: directories creation should be moved somewhere, this metod should only get things
            resultDir.mkdir();
        }
        return resultPath;
    }

    private static String getAppDataFolderName(File bundledGameDirParent) {
        if (bundledGameDirParent == null || !bundledGameDirParent.isDirectory()) {
            return "appdata";
        } else {
            return bundledGameDirParent.list()[0];
        }
    }

    public static void delete(String path) {
        delete(new File(path));
    }

    public static void delete(File file) {

        if (file.isDirectory()) {

            if (file.list().length == 0) {

                file.delete();

            } else {

                String files[] = file.list();

                for (String temp : files) {
                    File fileDelete = new File(file, temp);
                    delete(fileDelete);
                }
                if (file.list().length == 0) {

                    try{
                        file.delete();
                    } catch(NullPointerException e){

                    }
                }
            }

        } else {

            try{
                file.delete();
            } catch(NullPointerException e){

            }
        }
    }

}
