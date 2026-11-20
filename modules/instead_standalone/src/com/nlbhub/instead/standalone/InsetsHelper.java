package com.nlbhub.instead.standalone;

import android.app.Activity;
import android.graphics.Insets;
import android.os.Build;
import android.view.View;
import android.view.Window;
import android.view.WindowInsets;

/**
 * Fits an Activity's content between the system bars on Android 15+,
 * where edge-to-edge is enforced for targetSdk 35/36.
 */
public final class InsetsHelper {
    private InsetsHelper() {
    }

    public static void apply(Activity activity) {
        final View content = activity.findViewById(android.R.id.content);
        if (content == null) {
            return;
        }
        final int left = content.getPaddingLeft();
        final int top = content.getPaddingTop();
        final int right = content.getPaddingRight();
        final int bottom = content.getPaddingBottom();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            Window window = activity.getWindow();
            window.setDecorFitsSystemWindows(false);
            content.setOnApplyWindowInsetsListener((view, windowInsets) -> {
                Insets bars = windowInsets.getInsets(
                        WindowInsets.Type.systemBars()
                                | WindowInsets.Type.displayCutout());
                view.setPadding(
                        left + bars.left,
                        top + bars.top,
                        right + bars.right,
                        bottom + bars.bottom);
                return windowInsets;
            });
            content.requestApplyInsets();
        } else {
            content.setFitsSystemWindows(true);
        }
    }
}
