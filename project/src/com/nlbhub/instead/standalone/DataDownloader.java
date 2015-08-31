package com.nlbhub.instead.standalone;

import java.util.zip.*;
import java.io.*;

import android.app.ProgressDialog;
import android.content.Context;
import android.os.Build;
import android.util.Log;
import com.nlbhub.instead.R;

public class DataDownloader extends Thread {
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

	private interface PathResolver {
		String resolvePath(String fileName) throws IOException;
	}

	private class SDPathResolver implements PathResolver {
		private String dirName;

		public SDPathResolver(String dirName) {
			this.dirName = dirName;
		}

		@Override
		public String resolvePath(String fileName) throws IOException {
			return Globals.getOutFilePath(dirName, fileName) ;
		}
	}

	private class SystemPathResolver implements PathResolver {
		private String dirName;

		public SystemPathResolver(String dirName) {
			this.dirName = dirName;
		}

		@Override
		public String resolvePath(String fileName) throws IOException {
			// I'm using /data/data/myPackage/app_libs (using Ctx.getDir("libs",Context.MODE_PRIVATE); returns that path).
			return getPath() + fileName;
		}

		public String getPath() throws IOException {
			return Parent.getApplicationContext().getDir(dirName, Context.MODE_PRIVATE).getCanonicalPath() + "/";
		}
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
				if (!Parent.onpause)
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
		SystemPathResolver dataResolver = new SystemPathResolver("data");

		File programDirOnSD = new File(Globals.getStorage() + Globals.ApplicationName);
		programDirOnSD.mkdir();
		(new File(programDirOnSD, "appdata")).mkdir();

		try {
			Globals.delete(dataResolver.getPath() + "stead");
			Globals.delete(dataResolver.getPath() + "themes");
			Globals.delete(dataResolver.getPath() + "languages");
			Globals.delete(dataResolver.getPath() + "lang");
            (new File(Globals.getOutFilePath(Globals.DataFlag))).delete();
			extractArchive(Parent.getResources().openRawResource(R.raw.games), new SDPathResolver("appdata"));
			extractArchive(Parent.getResources().openRawResource(R.raw.data), dataResolver);
			extractArchive(getAppropriateLibsStream(), new SystemPathResolver("libs"));
		} catch (IOException e) {
			Log.e("Instead-NG ERROR", "IOException");
		}

		OutputStream out = null;
		byte buff[] = Globals.AppVer(Parent).getBytes();
		try {
			try {
                path = Globals.getOutFilePath(Globals.DataFlag);
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
