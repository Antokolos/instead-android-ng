package com.nlbhub.instead.input;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.text.InputType;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.BaseInputConnection;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
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
    private GameEditText editText;

    public InputLayout(Context context) {
        super(context);
        activity = ((Activity) context);
        view = activity.getLayoutInflater().inflate(R.layout.inputlayout, null, false);
        view.setFocusable(false);
        view.setFocusableInTouchMode(false);
        setLayoutParams(getParams());
        setGravity(Gravity.CENTER_HORIZONTAL | Gravity.BOTTOM);

        // The IME needs a real text editor for composing text and language
        // switching (Russian, etc.). Its input connection forwards committed
        // text to the game, so composing updates do not duplicate characters.
        editText = new GameEditText(activity);
        editText.setBackgroundColor(Color.TRANSPARENT);
        editText.setTextColor(Color.TRANSPARENT);
        editText.setCursorVisible(false);
        editText.setAlpha(0f);
        editText.setVisibility(View.GONE);
        editText.setFocusable(true);
        editText.setFocusableInTouchMode(true);
        editText.setInputType(InputType.TYPE_CLASS_TEXT
                | InputType.TYPE_TEXT_FLAG_MULTI_LINE
                | InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
        editText.setImeOptions(EditorInfo.IME_FLAG_NO_EXTRACT_UI
                | EditorInfo.IME_FLAG_NO_FULLSCREEN);

        addView(editText, new RelativeLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        RelativeLayout.LayoutParams viewParams = new RelativeLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        viewParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        addView(view, viewParams);

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
        InputMethodManager im = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        editText.setText("");
        editText.setVisibility(View.VISIBLE);
        editText.requestFocus();
        im.showSoftInput(editText, InputMethodManager.SHOW_FORCED);
        activity.onWindowFocusChanged(true);  // keyboard input not working bug
    }

    public void close() {
        InputMethodManager im = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        im.hideSoftInputFromWindow(editText.getWindowToken(), 0);
        editText.setVisibility(View.GONE);
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

    /**
     * A transparent EditText used only as an IME target. Committed text is
     * forwarded to INSTEAD through Keys.inputText(), while composing text is
     * deliberately ignored to avoid duplicate characters.
     */
    private static class GameEditText extends EditText {
        GameEditText(Context context) {
            super(context);
        }

        @Override
        public InputConnection onCreateInputConnection(EditorInfo outAttrs) {
            outAttrs.inputType = InputType.TYPE_CLASS_TEXT
                    | InputType.TYPE_TEXT_FLAG_MULTI_LINE
                    | InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS;
            outAttrs.imeOptions = EditorInfo.IME_FLAG_NO_EXTRACT_UI
                    | EditorInfo.IME_FLAG_NO_FULLSCREEN;
            return new BaseInputConnection(this, true) {
                @Override
                public boolean commitText(CharSequence text, int newCursorPosition) {
                    if (text != null && text.length() > 0) {
                        Keys.inputText(text.toString(), IN_MAX);
                    }
                    return true;
                }

                @Override
                public boolean setComposingText(CharSequence text, int newCursorPosition) {
                    // The game is not an editor: wait for commitText().
                    return true;
                }

                @Override
                public boolean finishComposingText() {
                    return true;
                }

                @Override
                public boolean deleteSurroundingText(int beforeLength, int afterLength) {
                    for (int i = 0; i < beforeLength; i++) {
                        Keys.down(KeyEvent.KEYCODE_DEL, false);
                    }
                    return true;
                }

                @Override
                public boolean sendKeyEvent(KeyEvent event) {
                    if (event.getAction() == KeyEvent.ACTION_DOWN) {
                        int keyCode = event.getKeyCode();
                        if (keyCode == KeyEvent.KEYCODE_ENTER
                                || keyCode == KeyEvent.KEYCODE_DEL) {
                            Keys.down(keyCode, false);
                        }
                    }
                    return true;
                }
            };
        }
    }
}
