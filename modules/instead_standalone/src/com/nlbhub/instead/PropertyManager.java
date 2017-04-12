package com.nlbhub.instead;

import com.nlbhub.instead.standalone.MainMenuAbstract;
import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author Anton P. Kolosov
 * @version 1.0
 */
public class PropertyManager {
    private static final Logger LOG = Logger.getLogger("com.nlbhub.instead.PropertyManager");
    private static PropertiesBean properties;

    public static void init(MainMenuAbstract parent, File configDir) {
        try {
            properties = readProperties(parent, configDir);
        } catch (IOException e) {
            LOG.log(Level.SEVERE, e.getMessage());
            properties = new PropertiesBean();
        }
    }

    public static PropertiesBean getProperties() {
        return properties;
    }

    private static PropertiesBean readProperties(MainMenuAbstract parent, File configDir) throws IOException {
        PropertiesBean result = new PropertiesBean();
        Properties prop = new Properties();
        InputStream input = null;

        try {
            if (!configDir.exists()) {
                throw new IOException("Config dir " + configDir.getCanonicalPath()  + " does not exist!");
            }
            File configFile = new File(configDir, "config.properties");
            if (!configFile.exists()) {
                LOG.log(Level.INFO, "Config file " + configFile.getCanonicalPath() + " does not exist! Default config file will be created.");
                FileUtils.copyInputStreamToFile(parent.getResources().openRawResource(R.raw.config), configFile);
                return result;
            }

            input = new FileInputStream(configFile);

            // load a properties file
            prop.load(input);

            String ffi = getTrimmedProperty(prop, "instead-ng.parameters.ffi");
            String gameListDownloadUrl = getTrimmedProperty(prop, "instead-ng.parameters.game-list-download-url");
            String gameListAltDownloadUrl = getTrimmedProperty(prop, "instead-ng.parameters.game-list-alt-download-url");
            String gameListNLBDemoDownloadUrl = getTrimmedProperty(prop, "instead-ng.parameters.game-list-nlb-demo-download-url");
            String gameListNLBFullDownloadUrl = getTrimmedProperty(prop, "instead-ng.parameters.game-list-nlb-full-download-url");
            result.setFfi("true".equalsIgnoreCase(ffi));
            result.setGameListDownloadUrl(gameListDownloadUrl);
            result.setGameListAltDownloadUrl(gameListAltDownloadUrl);
            result.setGameListNLBDemoDownloadUrl(gameListNLBDemoDownloadUrl);
            result.setGameListNLBFullDownloadUrl(gameListNLBFullDownloadUrl);
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
