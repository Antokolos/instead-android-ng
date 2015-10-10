package com.nlbhub.instead.input;

import android.app.Activity;
import android.content.Context;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import com.nlbhub.instead.R;

/**
 * Created by Antokolos on 10.10.15.
 */
public class InputLayout extends RelativeLayout {

    private static InputDialog input;
    private ImageButton kbdButton;

    public InputLayout(Context context) {
        super(context);
        View view = ((Activity) context).getLayoutInflater().inflate(R.layout.inputlayout, null, false);
        setLayoutParams(getParams());
        setGravity(Gravity.CENTER_HORIZONTAL | Gravity.BOTTOM);
        addView(view);
        input = new InputDialog(context, ((Activity) context).getString(R.string.in_text));
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
        input.show();
    }
}
