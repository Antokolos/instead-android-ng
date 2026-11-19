package com.nlbhub.instead.standalone;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Зеркала каталогов:
 * - Игры сообщества INSTEAD (Каталог и Песочница) — instead-games.ru;
 * - Non-Linear Text Quests (NLB project и Community) — nlbhub.com / nlbproject.com.
 */
public final class DownloadMirrors {
    public static final String INSTEAD_GAMES_DEFAULT = "https://www.instead-games.ru";
    public static final String NLB_DEFAULT = "https://nlbhub.com";
    public static final String NLBPROJECT = "https://nlbproject.com";

    public static final String[] INSTEAD_GAMES_MIRRORS = { INSTEAD_GAMES_DEFAULT };
    public static final String[] NLB_MIRRORS = { NLB_DEFAULT, NLBPROJECT };

    private static final Pattern INSTEAD_GAMES_HOST = Pattern.compile(
            "^https?://(?:www\\.)?instead-games\\.ru(/.*)?$",
            Pattern.CASE_INSENSITIVE);
    private static final Pattern NLB_HOST = Pattern.compile(
            "^https?://(?:www\\.)?(?:nlbhub\\.com|nlbproject\\.com)(/.*)?$",
            Pattern.CASE_INSENSITIVE);

    private DownloadMirrors() {
    }

    public static String insteadGamesBase(Settings settings) {
        return normalize(settings != null ? settings.getInsteadGamesMirror() : null,
                INSTEAD_GAMES_DEFAULT);
    }

    public static String nlbBase(Settings settings) {
        return normalize(settings != null ? settings.getNlbMirror() : null, NLB_DEFAULT);
    }

    /**
     * @param sandbox true — Песочница (xml2.php), false — Каталог (xml.php)
     */
    public static String insteadGamesCatalogUrl(Settings settings, boolean sandbox) {
        return insteadGamesBase(settings) + (sandbox ? "/xml2.php" : "/xml.php");
    }

    /**
     * @param community true — Community games, false — NLB project games
     */
    public static String nlbCatalogUrl(Settings settings, boolean community) {
        return nlbBase(settings)
                + (community ? "/hub/services/community_games" : "/hub/services/nlbproject_games");
    }

    public static String rewriteInsteadGames(String url, String base) {
        return rewrite(url, base, INSTEAD_GAMES_HOST, INSTEAD_GAMES_DEFAULT);
    }

    public static String rewriteNlb(String url, String base) {
        return rewrite(url, base, NLB_HOST, NLB_DEFAULT);
    }

    private static String rewrite(String url, String base, Pattern sourceHost, String fallback) {
        if (url == null || base == null) {
            return url;
        }
        Matcher matcher = sourceHost.matcher(url.trim());
        if (!matcher.matches()) {
            return url;
        }
        String path = matcher.group(1);
        if (path != null) {
            // В каталогах INSTEAD встречаются двойные слэши: //download/...
            path = "/" + path.replaceFirst("^/+", "");
        }
        return normalize(base, fallback) + (path == null ? "" : path);
    }

    public static String hostLabel(String base) {
        return normalize(base, INSTEAD_GAMES_DEFAULT).replaceFirst("^https?://", "");
    }

    public static String normalize(String value, String fallback) {
        if (value == null) {
            return fallback;
        }
        String result = value.trim();
        if (result.isEmpty()) {
            return fallback;
        }
        if (!result.startsWith("http://") && !result.startsWith("https://")) {
            result = "https://" + result;
        }
        while (result.endsWith("/")) {
            result = result.substring(0, result.length() - 1);
        }
        return result;
    }
}
