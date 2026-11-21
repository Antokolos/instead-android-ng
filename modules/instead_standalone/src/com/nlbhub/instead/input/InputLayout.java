package com.nlbhub.instead.input;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.os.Build;
import android.text.InputType;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowInsets;
import android.view.inputmethod.BaseInputConnection;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import com.nlbhub.instead.R;
import org.libsdl.app.SDLActivity;

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
    private final StringBuilder composing = new StringBuilder();
    private final StringBuilder committed = new StringBuilder();

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
                | InputType.TYPE_TEXT_FLAG_MULTI_LINE);
        editText.setImeOptions(EditorInfo.IME_ACTION_GO
                | EditorInfo.IME_FLAG_NO_EXTRACT_UI
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

        setOnApplyWindowInsetsListener((v, insets) -> {
            int imeBottom;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                imeBottom = insets.getInsets(WindowInsets.Type.ime()).bottom;
            } else {
                imeBottom = insets.getSystemWindowInsetBottom();
            }
            // Move the SDL game surface up, so the game's own input line and
            // the hints below it remain visible above the keyboard.
            SDLActivity.setImeBottomInset(imeBottom);
            return insets;
        });
        requestApplyInsets();
    }

    public static ViewGroup.LayoutParams getParams() {
        return new ViewGroup.LayoutParams(-1, -1);
    }

    public void open() {
        InputMethodManager im = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        editText.setText("");
        composing.setLength(0);
        editText.setVisibility(View.VISIBLE);
        editText.requestFocus();
        im.showSoftInput(editText, InputMethodManager.SHOW_FORCED);
        activity.onWindowFocusChanged(true);  // keyboard input not working bug
    }

    public void close() {
        InputMethodManager im = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        im.hideSoftInputFromWindow(editText.getWindowToken(), 0);
        SDLActivity.setImeBottomInset(0);
        editText.setVisibility(View.GONE);
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        int action = event.getAction();
        int keyCode = event.getKeyCode();
        switch (action) {
            case KeyEvent.ACTION_MULTIPLE:
                String characters = event.getCharacters();
                if (characters != null && characters.length() > 0) {
                    commitText(characters);
                }
                return true;
            case KeyEvent.ACTION_DOWN:
                if (isTextInputEvent(event)) {
                    String text = unicodeText(event);
                    if (!text.isEmpty()) {
                        commitText(text);
                        return true;
                    }
                }
                if (keyCode != KeyEvent.KEYCODE_UNKNOWN) {
                    if ((keyCode == KeyEvent.KEYCODE_SHIFT_LEFT) || (keyCode == KeyEvent.KEYCODE_SHIFT_RIGHT)) {
                        shift = true;
                    }
                }
                return true;
            case KeyEvent.ACTION_UP:
                if (isTextInputEvent(event)) {
                    return true;
                }
                if (keyCode != KeyEvent.KEYCODE_UNKNOWN) {
                    if ((keyCode == KeyEvent.KEYCODE_SHIFT_LEFT) || (keyCode == KeyEvent.KEYCODE_SHIFT_RIGHT)) {
                        shift = false;
                    } else if (keyCode == KeyEvent.KEYCODE_ENTER
                            || keyCode == KeyEvent.KEYCODE_NUMPAD_ENTER) {
                        submit();
                    } else {
                        Keys.down(keyCode, shift);
                    }
                    return true;
                }
                break;
        }
        return false;
    }

    private static boolean isTextInputEvent(KeyEvent event) {
        // Ctrl-only shortcuts stay on the keycode path. AltGr (Ctrl+Alt)
        // still produces printable text and is allowed through.
        if (event.isCtrlPressed() && !event.isAltPressed()) {
            return false;
        }
        return event.isPrintingKey() || event.getKeyCode() == KeyEvent.KEYCODE_SPACE;
    }

    private static String unicodeText(KeyEvent event) {
        int codePoint = event.getUnicodeChar(event.getMetaState());
        if (codePoint == 0) {
            String characters = event.getCharacters();
            return characters == null ? "" : characters;
        }
        return new String(Character.toChars(codePoint));
    }

    private void commitText(String text) {
        if (text == null || text.isEmpty()) {
            return;
        }
        // Some IMEs send a non-breaking space instead of U+0020. INSTEAD's
        // command parser does not treat NBSP as a word separator.
        text = text.replace('\u00A0', ' ').replace('\u202F', ' ').replace('\u2007', ' ');
        // Some IMEs deliver Enter as "\n" through commitText instead of a
        // key event. Treat it as the game's Enter command, not as text.
        int newline = text.indexOf('\n');
        if (newline >= 0) {
            String before = text.substring(0, newline);
            if (!before.isEmpty()) {
                sendText(before);
            }
            composing.setLength(0);
            submit();
            String after = text.substring(newline + 1);
            if (!after.isEmpty()) {
                sendText(after);
            }
            return;
        }
        sendText(text);
        // commitText supersedes the composing text; do not send it again from
        // finishComposingText (that produced duplicated words on Gboard).
        composing.setLength(0);
    }

    private void sendText(String text) {
        String toSend = text;
        // Some IMEs (notably Samsung/Gboard variants) pass the whole editable
        // contents to commitText/setComposingText instead of the new part.
        // Remove the already committed prefix to avoid duplicating words.
        String committedText = committed.toString();
        if (!committedText.isEmpty() && text.startsWith(committedText)) {
            toSend = text.substring(committedText.length());
        }
        if (!toSend.isEmpty()) {
            StringBuilder run = new StringBuilder();
            for (int i = 0; i < toSend.length(); i++) {
                char c = toSend.charAt(i);
                if (c == ' ') {
                    if (run.length() > 0) {
                        SDLActivity.commitTextToGame(run.toString());
                        run.setLength(0);
                    }
                    // INSTEAD's text-input path drops spaces from IME text;
                    // the scancode path inserts them correctly.
                    Keys.down(KeyEvent.KEYCODE_SPACE, false);
                } else {
                    run.append(c);
                }
            }
            if (run.length() > 0) {
                SDLActivity.commitTextToGame(run.toString());
            }
            committed.append(toSend);
        }
    }

    private void commitComposing() {
        if (composing.length() > 0) {
            sendText(composing.toString());
            composing.setLength(0);
        }
    }

    private void submit() {
        commitComposing();
        // SDL's soft-return helper only hides the IME. The game itself expects
        // a real Enter key event to submit the console line.
        Keys.down(KeyEvent.KEYCODE_ENTER, false);
        composing.setLength(0);
        committed.setLength(0);
        // Clear the IME's editor as well. Otherwise Gboard keeps the previous
        // line and prepends it to the next word ("да" + "закрыть").
        editText.setText("");
    }

    private void backspace() {
        if (composing.length() > 0) {
            composing.deleteCharAt(composing.length() - 1);
        } else {
            if (committed.length() > 0) {
                committed.deleteCharAt(committed.length() - 1);
            }
            Keys.down(KeyEvent.KEYCODE_DEL, false);
        }
    }

    /**
     * A transparent EditText used only as an IME target. Committed text is
     * forwarded to INSTEAD natively; composing text is sent when committed.
     */
    private class GameEditText extends EditText {
        GameEditText(Context context) {
            super(context);
        }

        @Override
        public InputConnection onCreateInputConnection(EditorInfo outAttrs) {
            outAttrs.inputType = InputType.TYPE_CLASS_TEXT
                    | InputType.TYPE_TEXT_FLAG_MULTI_LINE;
            outAttrs.imeOptions = EditorInfo.IME_ACTION_GO
                    | EditorInfo.IME_FLAG_NO_EXTRACT_UI
                    | EditorInfo.IME_FLAG_NO_FULLSCREEN;
            return new BaseInputConnection(this, true) {
                @Override
                public boolean commitText(CharSequence text, int newCursorPosition) {
                    if (text != null && text.length() > 0) {
                        InputLayout.this.commitText(text.toString());
                    }
                    return true;
                }

                @Override
                public boolean setComposingText(CharSequence text, int newCursorPosition) {
                    String value = text == null ? "" : text.toString();
                    String committedText = committed.toString();
                    if (!committedText.isEmpty() && value.startsWith(committedText)) {
                        value = value.substring(committedText.length());
                    }
                    composing.setLength(0);
                    composing.append(value);
                    return true;
                }

                @Override
                public boolean finishComposingText() {
                    commitComposing();
                    return true;
                }

                @Override
                public boolean deleteSurroundingText(int beforeLength, int afterLength) {
                    for (int i = 0; i < beforeLength; i++) {
                        backspace();
                    }
                    return true;
                }

                @Override
                public boolean performEditorAction(int editorAction) {
                    submit();
                    return true;
                }

                @Override
                public boolean sendKeyEvent(KeyEvent event) {
                    if (event.getAction() == KeyEvent.ACTION_DOWN) {
                        int keyCode = event.getKeyCode();
                        if (isTextInputEvent(event)) {
                            String text = unicodeText(event);
                            if (!text.isEmpty()) {
                                InputLayout.this.commitText(text);
                                return true;
                            }
                        }
                        if (keyCode == KeyEvent.KEYCODE_ENTER
                                || keyCode == KeyEvent.KEYCODE_NUMPAD_ENTER) {
                            submit();
                        } else if (keyCode == KeyEvent.KEYCODE_DEL) {
                            backspace();
                        }
                    }
                    return true;
                }
            };
        }
    }
}
