package com.nlbhub.instead.launcher.universal;

import android.util.Log;
import com.nlbhub.instead.launcher.R;
import com.nlbhub.instead.standalone.InsteadApplication;
import com.nlbhub.instead.standalone.StorageResolver;
import com.nlbhub.instead.launcher.simple.Globals;

import java.net.HttpURLConnection;
import java.net.URL;
import java.util.zip.*;
import java.io.*;

import android.app.ProgressDialog;

class GameDownloader extends Thread {
	class StatusWriter {
		private ProgressDialog Status;
		private GameManager Parent;

		public StatusWriter(ProgressDialog _Status, GameManager gameManager) {
			Status = _Status;
			Parent = gameManager;
		}

		public void setMessage(final String str, final int prg) {
			class Callback implements Runnable {
				public ProgressDialog Status;
				public String text;
				public int progress;
				//public int maximum;

				public void run() {
				//	Status.setMax(maximum);
					Status.setProgress(progress);
					Status.setMessage(text);
				}
			}
			Callback cb = new Callback();
			cb.text = new String(str);
			//cb.maximum = max;
			cb.progress = prg;
			cb.Status = Status;
			Parent.runOnUiThread(cb);
		}

		public void setMax(final int max) {
			class Callback implements Runnable {
				public ProgressDialog Status;
				public int maximum;

				public void run() {
					Status.setMax(maximum);
					
				}
			}
			Callback cb = new Callback();
			cb.maximum = max;
			cb.Status = Status;
			Parent.runOnUiThread(cb);
		}
	}

	public GameDownloader(GameManager gameManager, String url, String name,
			ProgressDialog _Status) {
		Parent = gameManager;
		DownloadComplete = false;
		gameUrl = url;
		gameName = name;
		gameDir = StorageResolver.GameDir + gameName;
		Status = new StatusWriter(_Status, gameManager);
		// Status.setMessage( Parent.getString(R.string.connect) +" "+ gameUrl
		// );
		this.start();
	}

	@Override
	public void run() {
		int op = 0;
		String path;
		// Create output directory
		try {
			(new File(Globals.getOutFilePath(gameDir))).mkdirs();
		} catch (SecurityException e) {
		}
		;
		try {
			if (!Parent.onpause)
				Status.setMessage(Parent.getString(R.string.connect) + " "
						+ gameUrl,op);
		} catch (NullPointerException e) {
		}
		
		/*
		   try {
			    HttpURLConnection con = 
			      (HttpURLConnection) new URL(gameUrl).openConnection();
			      con.setRequestMethod("HEAD");
			      con.connect();
			      int numbytes = Integer.parseInt(con.getHeaderField("Content-length"));
					if (!Parent.onpause && numbytes > 0)
						Status.setMax(numbytes);			      
			    } 
			    catch (Exception e) {
			    }
		*/

        HttpURLConnection conn = null;
		try {
			URL url = new URL(gameUrl);
			conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("GET");
			conn.setReadTimeout(5000);
			conn.addRequestProperty("Accept", "*/*");
			boolean redirect = false;
            // normally, 3xx is redirect
            int status = conn.getResponseCode();
            if (status != HttpURLConnection.HTTP_OK) {
                if (status == HttpURLConnection.HTTP_MOVED_TEMP
                        || status == HttpURLConnection.HTTP_MOVED_PERM
                        || status == HttpURLConnection.HTTP_SEE_OTHER)
                    redirect = true;
            }
            if (redirect) {

                // get redirect url from "location" header field
                String newUrl = conn.getHeaderField("Location");

                // get the cookie if need, for login
                String cookies = conn.getHeaderField("Set-Cookie");

                // open the new connnection again
                conn = (HttpURLConnection) new URL(newUrl).openConnection();
                conn.setRequestMethod("GET");
                conn.setReadTimeout(5000);
                conn.setRequestProperty("Cookie", cookies);
                conn.addRequestProperty("Accept", "*/*");
            }
		} catch (Exception e) {
            if (!Parent.onpause)
                Status.setMessage(Parent.getString(R.string.conerror) + " "
                        + gameUrl,op);
            Parent.onError(Parent.getString(R.string.conerror) + " " + gameUrl);
            return;
		}
		
		if (Parent.getStopDwn()) {
			StorageResolver.delete(new File(Globals.getOutFilePath(gameDir)));
			DownloadComplete = true;
			Cancel();
			return;
		}
		
		StorageResolver.delete(new File(Globals.getOutFilePath(gameDir)));
		try {
			if (!Parent.onpause)
				Status.setMessage(Parent.getString(R.string.downdata) + " "
						+ gameUrl,op);
		} catch (NullPointerException e) {
		}
		ZipInputStream zip = null;
		try {
		    int responseCode = conn.getResponseCode();
		    if (responseCode == HttpURLConnection.HTTP_OK) {
                zip = new ZipInputStream(conn.getInputStream());
            } else {
		        String errorString = Parent.getString(R.string.dataerror) + " " + gameUrl + "; Response code = " + responseCode;
                if (!Parent.onpause) {
                    Status.setMessage(errorString, op);
                }
                Parent.onError(errorString);
                return;
            }
		} catch (java.io.IOException e) {
			if (!Parent.onpause)
				Status.setMessage(Parent.getString(R.string.dataerror) + " "
						+ gameUrl,op);
			Parent.onError(Parent.getString(R.string.dataerror) + " " + gameUrl);
			return;
		}

		
		byte[] buf = new byte[1024];
		
		ZipEntry entry = null;

		while (true) {
			/*
			 * try { if (!Parent.onpause)
			 * Status.setMessage(Parent.getString(R.string.downfile) +
			 * " "+gameUrl); } catch (NullPointerException e) { }
			 */

			entry = null;
			try {
				entry = zip.getNextEntry();

			} catch (java.io.IOException e) {
				if (!Parent.onpause)
					Status.setMessage(Parent.getString(R.string.dataerror),op);
				Parent.onError(Parent.getString(R.string.dataerror));
				return;
			}
			if (entry == null)
				break;
			if (entry.isDirectory()) {
				try {
					(new File(Globals.getOutFilePath(StorageResolver.GameDir
							+ entry.getName()))).mkdirs();
				} catch (SecurityException e) {
				}
				;
				continue;
			}

			OutputStream out = null;
			path = Globals.getOutFilePath(StorageResolver.GameDir + entry.getName());

			createEntryDirs(path);

			try {
				out = new FileOutputStream(path);
			} catch (FileNotFoundException e) {
			} catch (SecurityException e) {
			}

			if (out == null) {
				if (!Parent.onpause)
					Status.setMessage(Parent.getString(com.nlbhub.instead.R.string.writefileerror)
							+ " " + path,op);
				Parent.onError(Parent.getString(com.nlbhub.instead.R.string.writefileerror) + " "
						+ path);
				return;
			}

			if (Parent.getStopDwn()) {
				StorageResolver.delete(new File(Globals.getOutFilePath(gameDir)));
				Cancel();
				return;
			}

			try {
				if (!Parent.onpause)
					Status.setMessage(Parent.getString(R.string.downfile) + " "
							+ path,op);
			} catch (NullPointerException e) {
			}

			try {

				int len;
				while ((len = zip.read(buf)) > 0) {
					out.write(buf, 0, len);
					op=op+len;
				}
				out.flush();
			} catch (java.io.IOException e) {
				if (!Parent.onpause)
					Status.setMessage(Parent.getString(R.string.writefile)
							+ " " + path,op);
				Parent.onError(Parent.getString(R.string.writefile) + " "
						+ path);
				return;
			}

		}

		DownloadComplete = true;
		Parent.setDownGood();
		if (!Parent.onpause)
			initParent();
	}

	private void createEntryDirs(String path) {
		try {
            new File((new File(path).getParentFile().getCanonicalPath())).mkdirs();
        } catch (IOException e) {
            Log.e(InsteadApplication.ApplicationName, "Cannot mkdirs for path = " + path, e);
        }
	}

	private void initParent() {
		class Callback implements Runnable {
			public GameManager Parent;

			public void run() {

				Parent.gameIsDownload();
			}
		}
		Callback cb = new Callback();
		cb.Parent = Parent;
		Parent.runOnUiThread(cb);
	}

	private void Cancel() {
		class Callback implements Runnable {
			public GameManager Parent;

			public void run() {

				Parent.sayCancel();
			}
		}
		Callback cb = new Callback();
		cb.Parent = Parent;
		Parent.runOnUiThread(cb);
	}

	public boolean DownloadComplete;
	public StatusWriter Status;
	private GameManager Parent;
	private String gameUrl;
	private String gameName;
	private String gameDir;

}
