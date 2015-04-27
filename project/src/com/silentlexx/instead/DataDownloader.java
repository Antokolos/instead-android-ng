package com.silentlexx.instead;

import java.util.zip.*;
import java.io.*;

import android.app.ProgressDialog;
import android.util.Log;

class DataDownloader extends Thread {
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

	public DataDownloader(MainMenu mainMenu, ProgressDialog _Status) {
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
		
		(new File(Globals.getStorage() + Globals.ApplicationName)).mkdir();
		
		Globals.delete(new File(Globals.getOutFilePath("stead")));
		Globals.delete(new File(Globals.getOutFilePath("themes")));
		Globals.delete(new File(Globals.getOutFilePath("languages")));
		Globals.delete(new File(Globals.getOutFilePath("lang")));
		(new File(Globals.getOutFilePath(Globals.DataFlag))).delete();

		ZipInputStream zip = null;
		zip = new ZipInputStream(Parent.getResources().openRawResource(
				R.raw.data));

		byte[] buf = new byte[1024];

		ZipEntry entry = null;

		while (true) {
			entry = null;
			try {
				entry = zip.getNextEntry();
			} catch (java.io.IOException e) {
				if (!Parent.onpause)
					Status.setMessage(Parent.getString(R.string.dataerror));
				Parent.onError(Parent.getString(R.string.dataerror));
				return;
			}
			if (entry == null)
				break;
			if (entry.isDirectory()) {
				try {
					(new File(Globals.getOutFilePath(entry.getName()))).mkdirs();
				} catch (SecurityException e) {
				}
				;
				continue;
			}

			OutputStream out = null;
			path = Globals.getOutFilePath(entry.getName());

			try {
				out = new FileOutputStream(path);
			} catch (FileNotFoundException e) {
			} catch (SecurityException e) {
			}
			;
			if (out == null) {
				if (!Parent.onpause)
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
			}

			try {
				int len;
				while ((len = zip.read(buf)) > 0) {
					out.write(buf, 0, len);
				}
				out.flush();
			} catch (java.io.IOException e) {
				if (!Parent.onpause)
					Status.setMessage(Parent.getString(R.string.writefile)
							+ " " + path);
				Parent.onError(Parent.getString(R.string.writefile) + " "
						+ path);
				return;
			}

		}

		path = Globals.getOutFilePath(Globals.DataFlag);

		OutputStream out = null;
		byte buff[] = Globals.AppVer(Parent).getBytes();
		try {
			out = new FileOutputStream(path);
			out.write(buff);
			out.close();
		} catch (FileNotFoundException e) {
		} catch (SecurityException e) {
		} catch (java.io.IOException e) {
			Log.e("Instead ERROR", "Error writing file " + path);
			return;
		}
		;

		if (!Parent.onpause)
			Status.setMessage(Parent.getString(R.string.finish));
		DownloadComplete = true;

		Parent.setDownGood();
		if (!Parent.onpause)
			initParent();
	};

	private void initParent() {
		class Callback implements Runnable {
			public MainMenu Parent;

			public void run() {
				Parent.showRun();
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
