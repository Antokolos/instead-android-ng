package com.nlbhub.instead.launcher.universal;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;

import com.nlbhub.instead.launcher.R;
import com.nlbhub.instead.launcher.simple.Globals;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import android.app.ProgressDialog;

public class XmlDownloader extends Thread {

	private String gameListUrl;
	private String gameListFileName;

	class StatusWriter {
		private ProgressDialog Status;
		private GameManager Parent;

		public StatusWriter(ProgressDialog _Status, GameManager GameManager) {
			Status = _Status;
			Parent = GameManager;
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

	protected String getGameListDownloadUrl() {
        return Globals.GameListDownloadUrl;
    }

    protected String getGameListAltDownloadUrl() {
        return Globals.GameListAltDownloadUrl;
    }

    protected String getGameListFileName() {
        return Globals.GameListFileName;
    }

    protected String getGameListAltFileName() {
        return Globals.GameListAltFileName;
    }

    public XmlDownloader(GameManager GameManager, ProgressDialog _Status,
			int src) {

		switch (src) {
		case Globals.BASIC:
		case Globals.NLBDEMO:
			gameListUrl = getGameListDownloadUrl();
			gameListFileName = getGameListFileName();
			break;
		case Globals.ALTER:
		case Globals.NLBFULL:
			gameListUrl = getGameListAltDownloadUrl();
			gameListFileName = getGameListAltFileName();
			break;
		default:
            gameListUrl = getGameListDownloadUrl();
            gameListFileName = getGameListFileName();
		}

		Parent = GameManager;
		DownloadComplete = false;
		if (!Parent.onpause)
			Status = new StatusWriter(_Status, GameManager);
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

		// TODO: all this code should be rewritten...
		Parent.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				Parent.checkCurrentList();
			}
		});

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
			Status.setMessage(Parent.getString(com.nlbhub.instead.R.string.writefileerror) + " "
					+ path);
			Parent.onError(Parent.getString(com.nlbhub.instead.R.string.writefileerror) + " "
					+ path);
			(new File(Globals.getOutFilePath(Globals.GameListFileName)))
					.delete();
			return;
		}
		

	}

	private void initParent() {
		class Callback implements Runnable {
			public GameManager Parent;

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
	private GameManager Parent;
}
