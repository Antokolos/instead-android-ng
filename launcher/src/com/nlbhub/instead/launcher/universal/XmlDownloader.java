package com.nlbhub.instead.launcher.universal;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;

import com.nlbhub.instead.PropertiesBean;
import com.nlbhub.instead.PropertyManager;
import com.nlbhub.instead.launcher.R;
import com.nlbhub.instead.launcher.simple.Globals;
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

	protected String getGameListDownloadUrl(PropertiesBean properties) {
        return properties.getGameListDownloadUrl();
    }

    protected String getGameListAltDownloadUrl(PropertiesBean properties) {
		return properties.getGameListAltDownloadUrl();
    }

    protected String getGameListFileName() {
        return Globals.GameListFileName;
    }

    protected String getGameListAltFileName() {
        return Globals.GameListAltFileName;
    }

    public XmlDownloader(GameManager GameManager, ProgressDialog _Status, int src) {
		final PropertiesBean properties = PropertyManager.getProperties(GameManager);
		switch (src) {
			case Globals.BASIC:
			case Globals.NLBPROJECT_GAMES:
				gameListUrl = getGameListDownloadUrl(properties);
				gameListFileName = getGameListFileName();
				break;
			case Globals.ALTER:
			case Globals.COMMUNITY_GAMES:
				gameListUrl = getGameListAltDownloadUrl(properties);
				gameListFileName = getGameListAltFileName();
				break;
			default:
				gameListUrl = getGameListDownloadUrl(properties);
				gameListFileName = getGameListFileName();
		}

		Parent = GameManager;
		DownloadComplete = false;
		if (!Parent.onpause) {
			Status = new StatusWriter(_Status, GameManager);
		}
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

		HttpURLConnection conn = null;
		try {
			URL url = new URL(gameListUrl);
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
			// See https://stackoverflow.com/questions/18126372/safely-fixing-javax-net-ssl-sslpeerunverifiedexception-no-peer-certificate
			// in case of javax.net.ssl.SSLPeerUnverifiedException: No peer certificate
			// This can mean that your server has incorrect certificate chain and you must fix it

			if (!Parent.onpause)
				Status.setMessage(Parent.getString(R.string.conerror) + " "
						+ gameListUrl);
			Parent.onError(Parent.getString(R.string.conerror) + " "
					+ gameListUrl);
			return;
		}

		//(new File(Globals.getOutFilePath(gameListFileName))).delete();
		(new File(Parent.getFilesDir(), gameListFileName)).delete();
			
		try {
			if (!Parent.onpause)
				Status.setMessage(Parent.getString(R.string.downdata) + " "
						+ gameListUrl);
		} catch (NullPointerException e) {
		}

		BufferedReader input = null;
		try {
			int responseCode = conn.getResponseCode();
			if (responseCode == HttpURLConnection.HTTP_OK) {
				input = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
			}
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
