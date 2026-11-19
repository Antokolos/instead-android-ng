package com.nlbhub.instead.standalone;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Зеркала каталогов NLB project / Community и переписывание ссылок из XML
 * на выбранное зеркало.
 */
public final class DownloadMirrors {
    public static final String NLB_DEFAULT = "https://nlbhub.com";
    public static final String NLBPROJECT = "https://nlbproject.com";
    public static final String COMMUNITY_DEFAULT = NLBPROJECT;

    public static final String[] NLB_MIRRORS = { NLB_DEFAULT, NLBPROJECT };
    public static final String[] COMMUNITY_MIRRORS = { COMMUNITY_DEFAULT };

    private static final Pattern NLB_HOST = Pattern.compile(
            "^https?://(?:www\\.)?(?:nlbhub\\.com|nlbproject\\.com)(/.*)?$",
            Pattern.CASE_INSENSITIVE);

    private DownloadMirrors() {
    }

    public static String nlbBase(Settings settings) {
        return normalize(settings != null ? settings.getNlbMirror() : null, NLB_DEFAULT);
    }

    public static String communityBase(Settings settings) {
        return normalize(settings != null ? settings.getCommunityMirror() : null, COMMUNITY_DEFAULT);
    }

    public static String nlbCatalogUrl(Settings settings) {
        return nlbBase(settings) + "/hub/services/nlbproject_games";
    }

    public static String communityCatalogUrl(Settings settings) {
        return communityBase(settings) + "/hub/services/community_games";
    }

    /**
     * Переписывает ссылки nlbhub.com/nlbproject.com на выбранное зеркало.
     * Ссылки на другие домены (например, instead-games.ru) не меняются.
     */
    public static String rewrite(String url, String base) {
        if (url == null || base == null) {
            return url;
        }
        Matcher matcher = NLB_HOST.matcher(url.trim());
        if (!matcher.matches()) {
            return url;
        }
        String path = matcher.group(1);
        return normalize(base, NLB_DEFAULT) + (path == null ? "" : path);
    }

    public static String hostLabel(String base) {
        return normalize(base, NLB_DEFAULT).replaceFirst("^https?://", "");
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
