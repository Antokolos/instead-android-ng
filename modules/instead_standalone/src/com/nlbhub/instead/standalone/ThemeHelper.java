package com.nlbhub.instead.standalone;

import android.content.Context;
import android.util.Log;
import com.nlbhub.instead.standalone.fs.SystemPathResolver;

import java.io.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by Antokolos on 09.10.15.
 */
public class ThemeHelper {
    public static final String PORTRAIT_KEY = "portrait";
    private static final Pattern SCRW_PATTERN = Pattern.compile("scr\\.w\\s*=\\s*(\\d+)");
    private static final Pattern SCRH_PATTERN = Pattern.compile("scr\\.h\\s*=\\s*(\\d+)");

    public static boolean isPortrait(Context context, ExpansionMounter expansionMounter, Settings settings, String gameName, String idf) {
        if (idf != null) {
            // TODO: workaround for now, support idf in future
            return false;
        }
        if (settings.isOwntheme()) {
            return isPortraitOwnTheme(context, expansionMounter, settings, (gameName != null) ? gameName : StorageResolver.BundledGame);
        } else {
            return isPortraitStandardTheme(context, settings);
        }
    }

    private static boolean isPortraitOwnTheme(final Context context, ExpansionMounter expansionMounter, Settings settings, final String gameName) {
        File gameDir = new File(StorageResolver.getGamesPath(expansionMounter), gameName);
        try {
            return isPortraitByThemeIni(gameDir);
        } catch (IOException e) {
            Log.i(InsteadApplication.ApplicationName, "Error during retrieving portrait flag for the game " + gameName + "; falling back to standard theme");
            return isPortraitStandardTheme(context, settings);
        }
    }

    private static boolean isPortraitStandardTheme(final Context context, Settings settings) {
        SystemPathResolver pathResolver = new SystemPathResolver("data", context);
        try {
            File themesDir = new File(pathResolver.resolvePath("themes"));
            return isPortraitByThemeIni(new File(themesDir, settings.getTheme()));
        } catch (IOException e) {
            Log.i(InsteadApplication.ApplicationName, "Error during retrieving portrait flag for standard theme " + settings.getTheme() + "; falling back to landscape");
            return false;
        }
    }

    private static boolean isPortraitByThemeIni(final File themeDir) throws IOException {
        int scrw = -1;
        int scrh = -1;
        BufferedReader input = null;
        FileInputStream fileInputStream = null;
        InputStreamReader inputStreamReader = null;
        File themeIni = new File(themeDir, "theme.ini");
        if (!themeIni.exists()) {
            throw new FileNotFoundException("File theme.ini was not found in directory " + themeDir.getCanonicalPath());
        }
        try {
            try {
                fileInputStream = new FileInputStream(themeIni);
                inputStreamReader = new InputStreamReader(fileInputStream, "UTF-8");
                input = new BufferedReader(inputStreamReader);

                String line;
                while ((line = input.readLine()) != null) {
                    final String inputLine = line.toLowerCase();
                    Matcher matcherW = SCRW_PATTERN.matcher(inputLine);
                    if (matcherW.find()) {
                        scrw = Integer.parseInt(matcherW.group(1));
                    }

                    Matcher matcherH = SCRH_PATTERN.matcher(inputLine);
                    if (matcherH.find()) {
                        scrh = Integer.parseInt(matcherH.group(1));
                    }
                }
            } finally {
                if (input != null) {
                    input.close();
                }
                if (inputStreamReader != null) {
                    inputStreamReader.close();
                }
                if (fileInputStream != null) {
                    fileInputStream.close();
                }
            }

        } catch (Exception e) {
            // TODO: at least log something...
        }

        return scrw != -1 && scrh != -1 && scrw <= scrh;
    }
}
