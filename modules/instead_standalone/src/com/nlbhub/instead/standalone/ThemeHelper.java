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
    private static final Pattern INCLUDE_PATTERN = Pattern.compile("include\\s*=\\s*([\\w,\\.-]+)");

    public static boolean isPortrait(Context context, ExpansionMounter expansionMounter, Settings settings, String gameName, String idf) {
        if (idf != null) {
            // TODO: workaround for now, support idf in future
            return false;
        }
        if (settings.isOwntheme()) {
            return isPortraitOwnTheme(context, expansionMounter, settings, (gameName != null) ? gameName : StorageResolver.BundledGame);
        } else {
            return isPortraitStandardTheme(context, settings.getTheme());
        }
    }

    private static boolean isPortraitOwnTheme(final Context context, ExpansionMounter expansionMounter, Settings settings, final String gameName) {
        try {
            ResData resData = isPortraitByThemeIni(new File(StorageResolver.getGamesPath(expansionMounter)), gameName);
            if (resData.isOK()) {
                return resData.isPortrait();
            } else {
                return isPortraitStandardTheme(context, resData.getInclude());
            }
        } catch (IOException e) {
            Log.i(InsteadApplication.ApplicationName, "Error during retrieving portrait flag for the game " + gameName + "; falling back to standard theme");
            return isPortraitStandardTheme(context, settings.getTheme());
        }
    }

    private static boolean isPortraitStandardTheme(final Context context, String theme) {
        if (theme == null) {
            Log.e(InsteadApplication.ApplicationName, "Error during retrieving portrait flag because theme name is undefined; falling back to landscape");
            return false;
        }
        SystemPathResolver pathResolver = new SystemPathResolver("data", context);
        ResData resData = new ResData();
        resData.setInclude(theme);
        try {
            File themesDir = new File(pathResolver.resolvePath("themes"));
            do {
                resData = isPortraitByThemeIni(themesDir, resData.getInclude());
            } while (!resData.isOK());
            return resData.isPortrait();
        } catch (IOException e) {
            Log.i(InsteadApplication.ApplicationName, "Error during retrieving portrait flag for standard theme " + theme + "; falling back to landscape");
            return false;
        }
    }

    private static ResData isPortraitByThemeIni(final File themesDir, String theme) throws IOException {
        if (theme == null) {
            throw new IOException("Cannot find theme, because it is undefined");
        }
        File themeDir = new File(themesDir, theme);
        ResData result = new ResData();
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
                        result.scrw = Integer.parseInt(matcherW.group(1));
                    }

                    Matcher matcherH = SCRH_PATTERN.matcher(inputLine);
                    if (matcherH.find()) {
                        result.scrh = Integer.parseInt(matcherH.group(1));
                    }

                    Matcher matcherI = INCLUDE_PATTERN.matcher(inputLine);
                    if (matcherI.find()) {
                        result.include = matcherI.group(1);
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

        return result;
    }

    private static class ResData {
        private int scrw = -1;
        private int scrh = -1;
        private String include = null;

        public boolean isOK() {
            return scrw != -1 && scrh != -1;
        }

        public boolean isPortrait() {
            return scrw <= scrh;
        }

        public String getInclude() {
            return include;
        }

        public void setInclude(String include) {
            this.include = include;
        }
    }
}
