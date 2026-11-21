package com.nlbhub.instead.input;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.os.Build;
import android.view.ViewGroup;
import android.view.WindowInsets;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.View;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import com.nlbhub.instead.R;
import org.libsdl.app.SDLActivity;

/**
 * On-screen keyboard button, ported from btimofeev/instead-launcher-android.
 *
 * INSTEAD itself owns the text-input mode and the Android IME. The button only
 * sends F12, which toggles SDL_StartTextInput/StopTextInput in the engine. This
 * keeps the game's own console line, cursor, hints, space and Enter handling
 * intact and lets the system IME do language switching.
 */
public class InputLayout extends RelativeLayout {

    private ImageButton kbdButton;

    public InputLayout(Context context) {
        super(context);
        Activity activity = (Activity) context;

        setLayoutParams(getParams());
        setGravity(Gravity.CENTER_HORIZONTAL | Gravity.BOTTOM);

        kbdButton = new ImageButton(activity);
        kbdButton.setBackgroundColor(Color.TRANSPARENT);
        kbdButton.setImageResource(R.drawable.kbd32);
        kbdButton.setContentDescription("Keyboard");
        kbdButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                open();
            }
        });

        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT);
        params.addRule(RelativeLayout.CENTER_HORIZONTAL);
        params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        params.bottomMargin = dp(24);
        addView(kbdButton, params);

        setOnApplyWindowInsetsListener((v, insets) -> {
            int imeBottom;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                imeBottom = insets.getInsets(WindowInsets.Type.ime()).bottom;
            } else {
                imeBottom = insets.getSystemWindowInsetBottom();
            }
            // Keep the game's own console line and hints above the stock IME.
            SDLActivity.setImeBottomInset(imeBottom);
            return insets;
        });
        requestApplyInsets();
    }

    public static ViewGroup.LayoutParams getParams() {
        return new ViewGroup.LayoutParams(-1, -1);
    }

    public void open() {
        // INSTEAD's F12 handler toggles SDL text input; SDL then shows the
        // stock Android IME with its own DummyEdit input connection.
        SDLActivity.onNativeKeyDown(KeyEvent.KEYCODE_F12);
    }

    public void close() {
        // Text input is toggled by the engine; nothing to release here.
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }
}
