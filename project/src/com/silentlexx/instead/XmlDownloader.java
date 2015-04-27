package com.silentlexx.instead;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;

import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import android.app.ProgressDialog;

class XmlDownloader extends Thread {

	private String gameListUrl;
	private String gameListFileName;

	class StatusWriter {
		private ProgressDialog Status;
		private GameMananger Parent;

		public StatusWriter(ProgressDialog _Status, GameMananger GameMananger) {
			Status = _Status;
			Parent = GameMananger;
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

	public XmlDownloader(GameMananger GameMananger, ProgressDialog _Status,
			int src) {

		switch (src) {
		case Globals.BASIC:
			gameListUrl = Globals.GameListDownloadUrl;
			gameListFileName = Globals.GameListFileName;
			break;
		case Globals.ALTER:
			gameListUrl = Globals.GameListAltDownloadUrl;
			gameListFileName = Globals.GameListAltFileName;
			break;
		default:
			gameListUrl = Globals.GameListDownloadUrl;
			gameListFileName = Globals.GameListFileName;
		}

		Parent = GameMananger;
		DownloadComplete = false;
		if (!Parent.onpause)
			Status = new StatusWriter(_Status, GameMananger);
		// Status.setMessage(
		// Parent.getString(R.string.connect)+" "+gameListUrl);
		this.start();
	}

	@Override
	public void run() {
	
		try {
			if (!Parent.onpause)
				Status.setMessage(Parent.getString(R.string.connect) + " "
						+ gameListUrl);
		} catch (NullPointerException e) {
		}
		// Parent.ShowDialog();

		HttpGet request = new HttpGet(gameListUrl);
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
						+ gameListUrl);
			Parent.onError(Parent.getString(R.string.conerror) + " "
					+ gameListUrl);
			return;
		}

		//(new File(Globals.getOutFilePath(gameListFileName))).delete();
		(new File(Parent.getFilesDir()+"/"+gameListFileName)).delete();
			
		try {
			if (!Parent.onpause)
				Status.setMessage(Parent.getString(R.string.downdata) + " "
						+ gameListUrl);
		} catch (NullPointerException e) {
		}

		BufferedReader input = null;
		try {
			input = new BufferedReader(new InputStreamReader(response
					.getEntity().getContent(), "UTF-8"));
		} catch (UnsupportedEncodingException e) {
		} catch (IllegalStateException e) {
		} catch (IOException e) {
		}
		String line;
		String buff = "";
		try {
			while ((line = input.readLine()) != null) {
				buff = buff + line;
			}
		} catch (IOException e) {
		}
		// Log.d(Globals.TAG,buff);
		writeFile(buff);

		// Status.setMessage( Parent.getString(R.string.finish));
		DownloadComplete = true;

		Parent.setXmlGood();
		if (!Parent.onpause)
			initParent();
	};

	private void writeFile(String s) {

		String path = Parent.getFilesDir()+"/"+gameListFileName;

		OutputStream out = null;

		byte buf[] = s.getBytes();
		try {
			out = new FileOutputStream(path);
			out.write(buf);
			out.close();
		} catch (FileNotFoundException e) {
		} catch (SecurityException e) {
		} catch (java.io.IOException e) {
			Status.setMessage(Parent.getString(R.string.writefileerorr) + " "
					+ path);
			Parent.onError(Parent.getString(R.string.writefileerorr) + " "
					+ path);
			(new File(Globals.getOutFilePath(Globals.GameListFileName)))
					.delete();
			return;
		}
		

	}

	private void initParent() {
		class Callback implements Runnable {
			public GameMananger Parent;

			public void run() {
		
				Parent.listIsDownload();
				Parent.listUpdate();
			}
		}
		Callback cb = new Callback();
		cb.Parent = Parent;
		Parent.runOnUiThread(cb);
	}

	public boolean DownloadComplete;
	public StatusWriter Status;
	private GameMananger Parent;
}
