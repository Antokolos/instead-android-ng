package com.nlbhub.instead.universal;

import java.util.zip.*;
import java.io.*;

import android.app.ProgressDialog;
import com.nlbhub.instead.R;
import com.nlbhub.instead.simple.Globals;
import com.nlbhub.instead.simple.MainMenu;

class ZipGame extends Thread {
	class StatusWriter {
		private ProgressDialog Status;
		private MainMenu Parent;

		public StatusWriter(ProgressDialog _Status, MainMenu mainMenu) {
			Status = _Status;
			Parent = mainMenu;
		}

		public void setMessage(final String str) {
			class Callback implements Runnable {
				public ProgressDialog Status;
				public String text;

				public void run() {
					Status.setMessage(text);
				}
			}
			Callback cb = new Callback();
			cb.text = new String(str);
			cb.Status = Status;
			Parent.runOnUiThread(cb);
		}

	}

	public ZipGame(MainMenu mainMenu, ProgressDialog _Status) {
		Parent = mainMenu;
		DownloadComplete = false;
		Status = new StatusWriter(_Status, mainMenu);
		// Status.setMessage( Parent.getString(R.string.connect) +" "+
		// Globals.DataDownloadUrl );
		this.start();
	}

	@Override
	public void run() {
		String path = null;
		InputStream in = Globals.zip.getInputStream();
		
		if (in == null) {
			if (!Parent.isOnpause())
				Status.setMessage(Parent.getString(R.string.dataerror));
			Parent.onError(Parent.getString(R.string.dataerror));
			return;
		}
		ZipInputStream zip = new ZipInputStream(in);

		byte[] buf = new byte[1024];

		ZipEntry entry = null;

		while (true) {
			try {
				entry = zip.getNextEntry();
			} catch (java.io.IOException e) {
				if (!Parent.isOnpause())
					Status.setMessage(Parent.getString(R.string.dataerror));
				Parent.onError(Parent.getString(R.string.dataerror));
				return;
			}
			if (entry == null)
				break;
			if (entry.isDirectory()) {
				try {
					(new File(Globals.getOutGamePath(entry.getName()))).mkdirs();
				} catch (SecurityException e) {
				};
				continue;
			}

			OutputStream out = null;
			path = Globals.getOutGamePath(entry.getName());

			try {
				out = new FileOutputStream(path);
			} catch (FileNotFoundException e) {
			} catch (SecurityException e) {
			};
			if (out == null) {
				if (!Parent.isOnpause())
					Status.setMessage(Parent.getString(R.string.writefileerorr)
							+ " " + path);
				Parent.onError(Parent.getString(R.string.writefileerorr) + " "
						+ path);
				return;
			}

			try {
				Status.setMessage(Parent.getString(R.string.instdata) + " "
						+ path);
			} catch (NullPointerException e) {
				// TODO: I don't understand the point of this code :) Should rewrite later...
			}

			try {
				int len;
				while ((len = zip.read(buf)) > 0) {
					out.write(buf, 0, len);
				}
				out.flush();
			} catch (java.io.IOException e) {
				if (!Parent.isOnpause())
					Status.setMessage(Parent.getString(R.string.writefile)
							+ " " + path);
				Parent.onError(Parent.getString(R.string.writefile) + " "
						+ path);
				return;
			}

		}

		if (!Parent.isOnpause())
			Status.setMessage(Parent.getString(R.string.finish));
		DownloadComplete = true;

		Parent.setDownGood();
		if (!Parent.isOnpause())
			initParent();
	};

	private void initParent() {
		class Callback implements Runnable {
			public MainMenu Parent;

			public void run() {
				Parent.showRunB();
			}
		}
		Callback cb = new Callback();
		cb.Parent = Parent;
		Parent.runOnUiThread(cb);
	}

	public boolean DownloadComplete;
	public StatusWriter Status;
	private MainMenu Parent;
}
