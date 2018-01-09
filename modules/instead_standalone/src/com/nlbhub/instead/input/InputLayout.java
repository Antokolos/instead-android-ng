package com.nlbhub.instead.input;

import android.app.Activity;
import android.content.Context;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import com.nlbhub.instead.R;

/**
 * Created by Antokolos on 10.10.15.
 */
public class InputLayout extends RelativeLayout {

    private static boolean shift = false;
    public static final int IN_MAX = 16;
    private ImageButton kbdButton;
    private View view;
    private Activity activity;

    public InputLayout(Context context) {
        super(context);
        activity = ((Activity) context);
        view = activity.getLayoutInflater().inflate(R.layout.inputlayout, null, false);
        view.setFocusable(true);
        view.setFocusableInTouchMode(true);
        setLayoutParams(getParams());
        setGravity(Gravity.CENTER_HORIZONTAL | Gravity.BOTTOM);
        addView(view);
        kbdButton = (ImageButton) findViewById(R.id.kbdButton);
        kbdButton.setBackgroundResource(R.drawable.kbd32);
        kbdButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                open();
            }
        });
    }

    public static ViewGroup.LayoutParams getParams() {
        return new ViewGroup.LayoutParams(-1, -1);
    }

    public void open() {
        InputMethodManager im = (InputMethodManager)getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        view.requestFocus();
        im.showSoftInput(view, InputMethodManager.SHOW_FORCED);
        activity.onWindowFocusChanged(true);  // keyboard input not working bug
    }

    public void close() {
        InputMethodManager im = (InputMethodManager)getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        im.hideSoftInputFromWindow(view.getWindowToken(), 0);
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        int action = event.getAction();
        int keyCode = event.getKeyCode();
        switch (action) {
            case KeyEvent.ACTION_DOWN:
            case KeyEvent.ACTION_MULTIPLE:
                if (keyCode != KeyEvent.KEYCODE_UNKNOWN) {
                    if ((keyCode == KeyEvent.KEYCODE_SHIFT_LEFT) || (keyCode == KeyEvent.KEYCODE_SHIFT_RIGHT)) {
                        shift = true;
                    } else {
                        // Keys.keyPress(keyCode, false); -- do nothing, will be handled on keyup
                    }
                } else {
                    String characters = event.getCharacters();
                    if (characters != null && characters.length() > 0) {
                        Keys.inputText(characters, IN_MAX);
                    }
                }
                return true;
            case KeyEvent.ACTION_UP:
                if (keyCode != KeyEvent.KEYCODE_UNKNOWN) {
                    if ((keyCode == KeyEvent.KEYCODE_SHIFT_LEFT) || (keyCode == KeyEvent.KEYCODE_SHIFT_RIGHT)) {
                        shift = false;
                    } else {
                        // Simulate press-release cycle on keyup
                        Keys.down(keyCode, shift);
                    }
                    return true;
                }
                break;
        }
        return false;
    }
}
