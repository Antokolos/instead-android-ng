package com.silentlexx.instead;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;

public class Favorites {
    private final String TAG = "-favorites";
    private final String GAME = "game";
    private final String TITLE = "title";
    private final String SIZE = "size";
    private MyPrefs p;
	private List<String> game = new ArrayList<String>();
	private List<String> title = new ArrayList<String>();	
    private String TitleTutorial;

	Favorites(Context c){
		p = new MyPrefs(c, Globals.ApplicationName+TAG);
		TitleTutorial = c.getString(R.string.tutorial);
		sync();
	}
	
	public void sync(){
		game.clear();
		title.clear();
		int n = p.get(SIZE, 0);
		for(int i=0; i<n;i++){
			game.add(p.get(GAME+Integer.toString(i), Globals.TutorialGame));
			title.add(p.get(TITLE+Integer.toString(i), TitleTutorial));
		}
	}
	

	public void commit(){
		int n = game.size();
		for(int i=0; i<n;i++){
			p.set(GAME+Integer.toString(i), game.get(i));
			p.set(TITLE+Integer.toString(i), title.get(i));
		}
		p.set(SIZE, n);
		p.commit();
	}
	
	public int size(){
		return game.size();
	}
	
	public String getGame(int pos){
	  return game.get(pos);
	}

	public String getTitle(int pos){
		  return title.get(pos);
		}
	
	
	public void add(String g, String t){
		if(isFavorite(g)) return;
		game.add(g);
		title.add(t);
		commit();		
	}
	
	public boolean isFavorite(String g){
		for(int i=0; i < game.size(); i++){
			if(game.get(i).equals(g)){
				return true;
			}
		}
		return false;
	}
	
	public void remove(int pos){
		game.remove(pos);
		title.remove(pos);
		commit();
	}
	
	public void remove(String g){
		for(int i=0; i < game.size(); i++){
			if(game.get(i).equals(g)){
				remove(i);
			}
		}		
	}
	
	public void clear(){
		game.clear();
		title.clear();
		commit();
	}
	
}
