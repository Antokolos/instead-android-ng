package com.nlbhub.instead.standalone;

import android.app.ProgressDialog;
import android.os.Build;
import android.util.Log;
import com.nlbhub.instead.R;
import com.nlbhub.instead.standalone.fs.PathResolver;
import com.nlbhub.instead.standalone.fs.SDPathResolver;
import com.nlbhub.instead.standalone.fs.SystemPathResolver;

import java.io.*;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.apache.commons.io.FileUtils;

public class DataDownloader extends Thread {
	class StatusWriter {
		private ProgressDialog Status;
		private MainMenuAbstract Parent;

		public StatusWriter(ProgressDialog _Status, MainMenuAbstract mainMenu) {
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

	public DataDownloader(MainMenuAbstract mainMenu, ProgressDialog _Status) {
		Parent = mainMenu;
		DownloadComplete = false;
		Status = new StatusWriter(_Status, mainMenu);
		// Status.setMessage( Parent.getString(R.string.connect) +" "+
		// Globals.DataDownloadUrl );
		this.start();
	}

	public void extractArchive(InputStream stream, PathResolver pathResolver) throws IOException {
		String path = null;
		ZipInputStream zip = null;
		zip = new ZipInputStream(stream);

		byte[] buf = new byte[1024];

		ZipEntry entry = null;

		while (true) {
			entry = null;
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
					(new File(pathResolver.resolvePath(entry.getName()))).mkdirs();
				} catch (SecurityException e) {
				}
				;
				continue;
			}

			OutputStream out = null;
			path = pathResolver.resolvePath(entry.getName());

			try {
				out = new FileOutputStream(path);
			} catch (FileNotFoundException e) {
			} catch (SecurityException e) {
			}
			;
			if (out == null) {
				if (!Parent.isOnpause())
					Status.setMessage(Parent.getString(R.string.writefileerror)
							+ " " + path);
				Parent.onError(Parent.getString(R.string.writefileerror) + " "
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
				if (!Parent.isOnpause())
					Status.setMessage(Parent.getString(R.string.writefile)
							+ " " + path);
				Parent.onError(Parent.getString(R.string.writefile) + " "
						+ path);
				return;
			}

		}
	}

	public static boolean isArmv7() {
		try {
			return Build.VERSION.SDK_INT >= 4 && Build.class.getField("CPU_ABI").get(null).toString().startsWith("armeabi-v7");
		} catch (Throwable ignore) {}

		return false;
	}

	public static boolean isX86() {
		try {
			return Build.VERSION.SDK_INT >= 4 && Build.class.getField("CPU_ABI").get(null).toString().startsWith("x86");
		} catch (Throwable ignore) {}

		return false;
	}

	private InputStream getAppropriateLibsStream() {
		if (isArmv7()) {
			return Parent.getResources().openRawResource(R.raw.libs_armeabi_v7a);
		} else if (isX86()) {
			return Parent.getResources().openRawResource(R.raw.libs_x86);
		} else {
			return Parent.getResources().openRawResource(R.raw.libs_armeabi);
		}
	}

	@Override
	public void run() {
		String path = null;
		SystemPathResolver dataResolver = new SystemPathResolver("data", Parent.getApplicationContext());

		File programDirOnSD = new File(StorageResolver.getProgramDirOnSD());
		programDirOnSD.mkdir();
		(new File(programDirOnSD, "appdata")).mkdir();

		try {
			StorageResolver.delete(dataResolver.getPath() + "stead");
			StorageResolver.delete(dataResolver.getPath() + "themes");
			StorageResolver.delete(dataResolver.getPath() + "languages");
			StorageResolver.delete(dataResolver.getPath() + "lang");
			StorageResolver.delete(dataResolver.getPath() + StorageResolver.DataFlag);
			extractArchive(Parent.getResources().openRawResource(R.raw.games), new SDPathResolver("appdata"));
			extractArchive(Parent.getResources().openRawResource(R.raw.data), dataResolver);
			extractArchive(getAppropriateLibsStream(), new SystemPathResolver("libs", Parent.getApplicationContext()));
		} catch (IOException e) {
			Log.e("Instead-NG ERROR", "IOException");
		}

		OutputStream out = null;
		byte buff[] = InsteadApplication.AppVer(Parent).getBytes();
		try {
			try {
                path = dataResolver.getPath() + StorageResolver.DataFlag;
				out = new FileOutputStream(path);
				out.write(buff);
			} finally {
				if (out != null) {
					out.close();
				}
			}
		} catch (FileNotFoundException e) {
		} catch (SecurityException e) {
		} catch (java.io.IOException e) {
			Log.e("Instead-NG ERROR", "Error writing file " + path);
			return;
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
			public MainMenuAbstract Parent;

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
	private MainMenuAbstract Parent;
}
