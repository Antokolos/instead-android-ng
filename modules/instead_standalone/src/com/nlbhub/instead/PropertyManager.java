package com.nlbhub.instead;

import android.app.Activity;
import android.util.Log;
import com.nlbhub.instead.standalone.InsteadApplication;
import com.nlbhub.instead.standalone.StorageResolver;
import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * @author Anton P. Kolosov
 * @version 1.0
 */
public class PropertyManager {

    public static PropertiesBean getProperties(Activity parent) {
        File configDir = new File(StorageResolver.getDefaultProgramDir());
        try {
            return readProperties(parent, configDir);
        } catch (IOException e) {
            Log.e(InsteadApplication.ApplicationName, e.getMessage());
            return new PropertiesBean();
        }
    }

    private static PropertiesBean readProperties(Activity parent, File configDir) throws IOException {
        PropertiesBean result = new PropertiesBean();
        Properties prop = new Properties();
        InputStream input = null;

        try {
            if (!configDir.exists()) {
                throw new IOException("Config dir " + configDir.getCanonicalPath()  + " does not exist!");
            }
            File configFile = new File(configDir, "config.properties");
            if (!configFile.exists()) {
                Log.i(InsteadApplication.ApplicationName, "Config file " + configFile.getCanonicalPath() + " does not exist! Default config file will be created.");
                FileUtils.copyInputStreamToFile(parent.getResources().openRawResource(R.raw.config), configFile);
                return result;
            }

            input = new FileInputStream(configFile);

            // load a properties file
            prop.load(input);

            String standalone = getTrimmedProperty(prop, "instead-ng.parameters.standalone");
            String gameListDownloadUrl = getTrimmedProperty(prop, "instead-ng.parameters.game-list-download-url");
            String gameListAltDownloadUrl = getTrimmedProperty(prop, "instead-ng.parameters.game-list-alt-download-url");
            String gameListNLBProjectDownloadUrl = getTrimmedProperty(prop, "instead-ng.parameters.game-list-nlbproject-download-url");
            String gameListCommunityDownloadUrl = getTrimmedProperty(prop, "instead-ng.parameters.game-list-community-download-url");
            result.setStandalone("true".equalsIgnoreCase(standalone));
            result.setGameListDownloadUrl(gameListDownloadUrl);
            result.setGameListAltDownloadUrl(gameListAltDownloadUrl);
            result.setGameListNLBProjectDownloadUrl(gameListNLBProjectDownloadUrl);
            result.setGameListCommunityDownloadUrl(gameListCommunityDownloadUrl);
            return result;
        } finally {
            if (input != null) {
                input.close();
            }
        }
    }

    private static String getTrimmedProperty(Properties prop, String propertyName) {
        String property = prop.getProperty(propertyName);
        if (property == null) {
            return "";
        }
        return property.trim();
    }
}
