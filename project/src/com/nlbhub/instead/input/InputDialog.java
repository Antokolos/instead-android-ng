package com.nlbhub.instead.input;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import com.nlbhub.instead.R;

public class InputDialog extends Dialog {
	public static final int IN_MAX = 16;
	private EditText text;
	private Button ok;
	private Button cancel;
	private Button close;
	private Button sw;
	private String title;
	private final String SW[] = {"EN-RU","RU-EN"};
	
	public InputDialog(Context context, String t) {
		super(context);
		title = t;
	}
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
		setContentView(R.layout.input);
		setTitle(title);
		setCancelable(true);
		ok = (Button) findViewById(R.id.in_ok);
		sw = (Button) findViewById(R.id.in_sw);
		cancel = (Button) findViewById(R.id.in_cancel);
		close = (Button) findViewById(R.id.in_close);
		text = (EditText) findViewById(R.id.in_text);
		
		sw.setText(SW[0]);
		
		sw.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				if(sw.getText().toString().equals(SW[0])){
					sw.setText(SW[1]);
				} else {
					sw.setText(SW[0]);
				}
				Keys.AltShift();
			}

		});
		
		ok.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				Enter();
				Close();
			}

		});
		
		cancel.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				DelAll();
			}
		});

			close.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				Close();
			}
		});
		
	    text.addTextChangedListener(new TextWatcher(){
    		@Override
    		public void afterTextChanged(Editable txt) {
    			String s = txt.toString();
        		
    			if(s.length()> IN_MAX){
    				s = s.substring(0, IN_MAX);
    				text.setText(s);
    				 text.setSelection(s.length());
    			}
  		
    		}

			@Override
			public void beforeTextChanged(CharSequence arg0, int arg1,
					int arg2, int arg3) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {
				// TODO Auto-generated method stub
				
			}
    		
	    });
	    
		text.setOnKeyListener(new View.OnKeyListener() {
			
			@Override
			public boolean onKey(View arg0, int key, KeyEvent ev) {
			
			  if(ev.getAction()==KeyEvent.ACTION_DOWN){
				if(key==KeyEvent.KEYCODE_ENTER){
					Enter();
					Close();										
				}
				  else 
					if(key==KeyEvent.KEYCODE_DEL){
					   Del();
					}  else 
					if(key==KeyEvent.KEYCODE_BACK){
					  Close();
					}
				}				
				return true;
			}
		});

	}



	protected void DelAll(){
	 text.setText("");
		for(int i=0; i< IN_MAX; i++){
			Keys.Del();	
		}
	}
    

	protected void Del(){

	String b = text.getText().toString();
	int len = b.length();
	if(len>0){
	 b = b.substring(0, len-1);
	 text.setText(b);
	 text.setSelection(b.length());
	} else {
		Keys.Del();	 
	}

	
	}
    
	protected void Enter() {
		String txt = text.getText().toString();
		Keys.inputText(txt, IN_MAX);
	}

	protected void Close() {
		text.setText("");
		dismiss();		
	}
	
	public void focus(){
		text.requestFocus();
	}
	
}
