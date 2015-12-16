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

    public static final int IN_MAX = 16;
    private ImageButton kbdButton;
    private View view;

    public InputLayout(Context context) {
        super(context);
        view = ((Activity) context).getLayoutInflater().inflate(R.layout.inputlayout, null, false);
        view.setFocusable(true);
        view.setFocusableInTouchMode(true);
        setLayoutParams(getParams());
        setGravity(Gravity.CENTER_HORIZONTAL | Gravity.BOTTOM);
        addView(view);
        kbdButton = (ImageButton) findViewById(R.id.kbdButton);
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
    }

    public void close() {
        InputMethodManager im = (InputMethodManager)getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        im.hideSoftInputFromWindow(view.getWindowToken(), 0);
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        int action = event.getAction();
        if (action == KeyEvent.ACTION_DOWN || action == KeyEvent.ACTION_MULTIPLE) {
            int keyCode = event.getKeyCode();
            if (keyCode != KeyEvent.KEYCODE_UNKNOWN) {
                Keys.keyPress(keyCode, false);
            } else {
                String characters = event.getCharacters();
                if (characters != null && characters.length() > 0) {
                    Keys.inputText(characters, IN_MAX);
                }
            }
        }
        return super.dispatchKeyEvent(event);
    }
}
