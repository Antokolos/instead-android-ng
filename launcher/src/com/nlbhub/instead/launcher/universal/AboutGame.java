package com.nlbhub.instead.launcher.universal;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
//import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import com.nlbhub.instead.launcher.R;
import com.nlbhub.instead.standalone.ExceptionHandler;

public class AboutGame extends Activity {
	private TextView tstatus;
	private TextView ttitle;
	private TextView tname;
	private TextView tver;
	private TextView tfile;
	private TextView turl;
	private TextView tlang;
	private TextView tsize;
	private String file;
	private String url;
	private String name;
	private ImageView logo;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		Thread.setDefaultUncaughtExceptionHandler(new ExceptionHandler(this));
		super.onCreate(savedInstanceState);

		setContentView(R.layout.about);

		Bundle b = getIntent().getExtras();
		if (b == null) {
			finish();
		}

		name = b.getString("name");
		String title = b.getString("title");
		String ver = b.getString("ver");
		if(ver==null) ver = getString(R.string.na);
		String size = b.getString("size");
		if(size==null) size = getString(R.string.na);
		file = b.getString("file");
		url = b.getString("url");
		String lang = b.getString("lang");
		int flag = b.getInt("flag");
		int INSTALLED = b.getInt("INSTALLED");
		int UPDATE = b.getInt("UPDATE");
		int NEW = b.getInt("NEW");
		int logoid = R.drawable.newinstall;

		//Log.d(Globals.TAG, "About: " + name);

		String status = "";
		if (flag == INSTALLED) {
			status = getString(R.string.ag_installed);
			logoid = R.drawable.installed;
		}
		if (flag == UPDATE) {
			status = getString(R.string.ag_update);
			logoid = R.drawable.update;
		}
		if (flag == NEW) {
			status = getString(R.string.ag_new);
			logoid = R.drawable.newinstall;
		}

		logo = (ImageView) findViewById(R.id.logo);
		logo.setImageDrawable(this.getResources().getDrawable(logoid));

		ttitle = (TextView) findViewById(R.id.title);
		ttitle.setText(title);

		tname = (TextView) findViewById(R.id.name);
		tname.setText(name);

		tsize = (TextView) findViewById(R.id.size);
		tsize.setText(size);

		tstatus = (TextView) findViewById(R.id.status);
		tstatus.setText(status);

		tver = (TextView) findViewById(R.id.ver);
		tver.setText(ver);

		tlang = (TextView) findViewById(R.id.lang);
		tlang.setText(lang);

		turl = (TextView) findViewById(R.id.url);
		turl.setText(url);

		tfile = (TextView) findViewById(R.id.file);
		tfile.setText(file);
		/*
		 * tname.setOnClickListener(new View.OnClickListener() {
		 * 
		 * @Override public void onClick(View arg0) {
		 * startUrl(getFile("file"+name)); } });
		 */
		tfile.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View arg0) {
				startUrl(file);
			}
		});

		turl.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View arg0) {
				startUrl(url);
			}
		});

	}

	private void startUrl(String url) {
		Intent i = new Intent(Intent.ACTION_VIEW);
		i.setData(Uri.parse(url));
		startActivity(i);
	}
}
