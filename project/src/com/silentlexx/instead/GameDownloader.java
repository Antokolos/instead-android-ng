package com.silentlexx.instead;

import org.apache.http.client.methods.*;
import org.apache.http.*;
import org.apache.http.impl.client.*;
import java.util.zip.*;
import java.io.*;

import android.app.ProgressDialog;

class GameDownloader extends Thread {
	class StatusWriter {
		private ProgressDialog Status;
		private GameMananger Parent;

		public StatusWriter(ProgressDialog _Status, GameMananger gameMananger) {
			Status = _Status;
			Parent = gameMananger;
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

	public GameDownloader(GameMananger gameMananger, String url, String name,
			ProgressDialog _Status) {
		Parent = gameMananger;
		DownloadComplete = false;
		gameUrl = url;
		gameName = name;
		gameDir = Globals.GameDir + gameName;
		Status = new StatusWriter(_Status, gameMananger);
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

		HttpGet request = new HttpGet(gameUrl);
		request.addHeader("Accept", "*/*");
		HttpResponse response = null;
		try {
			DefaultHttpClient client = new DefaultHttpClient();
			client.getParams().setBooleanParameter(
					"http.protocol.handle-redirects", true);
			response = client.execute(request);
		} catch (IOException e) {
		} catch (NullPointerException e) {
		}

		if (response == null) {
			if (!Parent.onpause)
				Status.setMessage(Parent.getString(R.string.conerror) + " "
						+ gameUrl,op);
			Parent.onError(Parent.getString(R.string.conerror) + " " + gameUrl);
			return;

		}


		
		if (Parent.getStopDwn()) {
			Globals.delete(new File(Globals.getOutFilePath(gameDir)));
			DownloadComplete = true;
			Cancel();
			return;
		}
		;

		
		
		Globals.delete(new File(Globals.getOutFilePath(gameDir)));
		try {
			if (!Parent.onpause)
				Status.setMessage(Parent.getString(R.string.downdata) + " "
						+ gameUrl,op);
		} catch (NullPointerException e) {
		}
		ZipInputStream zip = null;
		try {
			zip = new ZipInputStream(response.getEntity().getContent());
		
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
					(new File(Globals.getOutFilePath(Globals.GameDir
							+ entry.getName()))).mkdirs();
				} catch (SecurityException e) {
				}
				;
				continue;
			}

			OutputStream out = null;
			path = Globals.getOutFilePath(Globals.GameDir + entry.getName());

			
			try {
				out = new FileOutputStream(path);
			} catch (FileNotFoundException e) {
			} catch (SecurityException e) {
			}

			if (out == null) {
				if (!Parent.onpause)
					Status.setMessage(Parent.getString(R.string.writefileerorr)
							+ " " + path,op);
				Parent.onError(Parent.getString(R.string.writefileerorr) + " "
						+ path);
				return;
			}

			if (Parent.getStopDwn()) {
				Globals.delete(new File(Globals.getOutFilePath(gameDir)));
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
	};

	private void initParent() {
		class Callback implements Runnable {
			public GameMananger Parent;

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
			public GameMananger Parent;

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
	private GameMananger Parent;
	private String gameUrl;
	private String gameName;
	private String gameDir;

}
