package com.nlbhub.instead;


import android.view.KeyEvent;

public class Keys {

	private static void Up(int k){
		SDLActivity.onNativeKeyUp(k);
	}
	
	private static void Down(int k){	
		SDLActivity.onNativeKeyDown(k);
	}
	
	public static void key(char c){
		String str = Character.toString(c);
		if(str.matches("[0-9]")){
			Num(c);
		} else 
			if(str.matches("[a-z]")){
				Eng(c, false);
			}
			else 
				if(str.matches("[A-Z]")){
					Eng(str.toLowerCase().charAt(0), true);
				}
		
				 else 
						if(str.matches("[а-я]")){
							Rus(c, false);
						}
						else 
							if(str.matches("[А-Я]")){
								Rus(str.toLowerCase().charAt(0), true);
							} else {
								Other(c);
							}
		
	}
	

	public static void Enter(){
		Down(KeyEvent.KEYCODE_ENTER);
		Up(KeyEvent.KEYCODE_ENTER);
	}

	public static void Caps(){
		Down(KeyEvent.KEYCODE_CAPS_LOCK);
		Up(KeyEvent.KEYCODE_CAPS_LOCK);
	}

	public static void ShiftDown(){
		Down(KeyEvent.KEYCODE_SHIFT_LEFT);
	}

	
	public static void ShiftUp(){
		Up(KeyEvent.KEYCODE_SHIFT_LEFT);
	}

	public static void Del(){
		Down(KeyEvent.KEYCODE_DEL);
		Up(KeyEvent.KEYCODE_DEL);
	}
	
	
	public static void AltShift(){
	
		Down(KeyEvent.KEYCODE_ALT_LEFT);
		Up(KeyEvent.KEYCODE_ALT_LEFT);		
		Down(KeyEvent.KEYCODE_SHIFT_LEFT);
		Up(KeyEvent.KEYCODE_SHIFT_LEFT);
	}
	
private static void Eng(char s, boolean shift){
		int k=-1;

switch (s) {		

	case 'q': 	k = KeyEvent.KEYCODE_Q; break;
	case 'w': 	k = KeyEvent.KEYCODE_W; break;
	case 'e': 	k = KeyEvent.KEYCODE_E; break;
	case 'r': 	k = KeyEvent.KEYCODE_R; break;
	case 't': 	k = KeyEvent.KEYCODE_T; break;
	case 'y': 	k = KeyEvent.KEYCODE_Y; break;
	case 'u': 	k = KeyEvent.KEYCODE_U; break;
	case 'i': 	k = KeyEvent.KEYCODE_I; break;
	case 'o': 	k = KeyEvent.KEYCODE_O; break;
	case 'p': 	k = KeyEvent.KEYCODE_P; break;

	case 'a': 	k = KeyEvent.KEYCODE_A; break;
	case 's': 	k = KeyEvent.KEYCODE_S; break;
	case 'd': 	k = KeyEvent.KEYCODE_D; break;
	case 'f': 	k = KeyEvent.KEYCODE_F; break;
	case 'g': 	k = KeyEvent.KEYCODE_G; break;
	case 'h': 	k = KeyEvent.KEYCODE_H; break;
	case 'j': 	k = KeyEvent.KEYCODE_J; break;
	case 'k': 	k = KeyEvent.KEYCODE_K; break;
	case 'l': 	k = KeyEvent.KEYCODE_L; break;

	case 'z': 	k = KeyEvent.KEYCODE_Z; break;
	case 'x': 	k = KeyEvent.KEYCODE_X; break;
	case 'c': 	k = KeyEvent.KEYCODE_C; break;
	case 'v': 	k = KeyEvent.KEYCODE_V; break;
	case 'b': 	k = KeyEvent.KEYCODE_B; break;
	case 'n': 	k = KeyEvent.KEYCODE_N; break;
	case 'm': 	k = KeyEvent.KEYCODE_M; break;


}


if(k>0){
	if(shift) ShiftDown();
	Down(k);
	if(shift) ShiftUp();
	Up(k);	
}
}



private static void Rus(char s, boolean shift){
	int k=-1;

switch (s) {		

case 'й': 	k = KeyEvent.KEYCODE_Q; break;
case 'ц': 	k = KeyEvent.KEYCODE_W; break;
case 'у': 	k = KeyEvent.KEYCODE_E; break;
case 'к': 	k = KeyEvent.KEYCODE_R; break;
case 'е': 	k = KeyEvent.KEYCODE_T; break;
case 'н': 	k = KeyEvent.KEYCODE_Y; break;
case 'г': 	k = KeyEvent.KEYCODE_U; break;
case 'ш': 	k = KeyEvent.KEYCODE_I; break;
case 'щ': 	k = KeyEvent.KEYCODE_O; break;
case 'з': 	k = KeyEvent.KEYCODE_P; break;
case 'х': 	k = 71; break;
case 'ъ': 	k = 72; break;


case 'ф': 	k = KeyEvent.KEYCODE_A; break;
case 'ы': 	k = KeyEvent.KEYCODE_S; break;
case 'в': 	k = KeyEvent.KEYCODE_D; break;
case 'а': 	k = KeyEvent.KEYCODE_F; break;
case 'п': 	k = KeyEvent.KEYCODE_G; break;
case 'р': 	k = KeyEvent.KEYCODE_H; break;
case 'о': 	k = KeyEvent.KEYCODE_J; break;
case 'л': 	k = KeyEvent.KEYCODE_K; break;
case 'д': 	k = KeyEvent.KEYCODE_L; break;
case 'ж': 	k = 74; break;
case 'э': 	k = 75; break;

case 'я': 	k = KeyEvent.KEYCODE_Z; break;
case 'ч': 	k = KeyEvent.KEYCODE_X; break;
case 'с': 	k = KeyEvent.KEYCODE_C; break;
case 'м': 	k = KeyEvent.KEYCODE_V; break;
case 'и': 	k = KeyEvent.KEYCODE_B; break;
case 'т': 	k = KeyEvent.KEYCODE_N; break;
case 'ь': 	k = KeyEvent.KEYCODE_M; break;
case 'б': 	k = 55; break;
case 'ю': 	k = 56; break;

case 'ё': 	k = KeyEvent.KEYCODE_T; break;

}


if(k>0){

AltShift();
if(shift) ShiftDown();
Down(k);
if(shift) ShiftUp();
Up(k);
AltShift();

}

}
	
	
	
	private static void Num(char s){
		int k=-1;
		switch (s) {
		case '0': 	k = KeyEvent.KEYCODE_0; break;
		case '1': 	k = KeyEvent.KEYCODE_1; break;
		case '2': 	k = KeyEvent.KEYCODE_2; break;
		case '3': 	k = KeyEvent.KEYCODE_3; break;
		case '4': 	k = KeyEvent.KEYCODE_4; break;
		case '5': 	k = KeyEvent.KEYCODE_5; break;
		case '6': 	k = KeyEvent.KEYCODE_6; break;
		case '7': 	k = KeyEvent.KEYCODE_7; break;
		case '8': 	k = KeyEvent.KEYCODE_8; break;
		case '9': 	k = KeyEvent.KEYCODE_9; break;
		}
		if(k>0){
			Down(k);
			Up(k);	
		}
	}

	
	private static void Other(char s){
		int k=-1;
		boolean shift = false;
		switch (s) {
		case ' ': 	k = KeyEvent.KEYCODE_SPACE; break;
		case '-': 	k = 69; break;
		case '.': 	k = 56; break;
		case ',': 	k = 55; break;
		case '!': 	k = 8; shift = true; break;
		case '?': 	k = 76; shift = true; break;
		case ';': 	k = 74; shift = true; break;
		case ':': 	k = 56; shift = true; break;
		case '*': 	k = 17; break;
		case '/': 	k = 76; break;
		case '(': 	k = 16; shift = true; break;
		case ')': 	k =7 ; shift = true; break;
		case '@': 	k = 77; break;
		case '$': 	k = 11;shift = true; break;
		case '&': 	k = 14;shift = true; break;
		case '%': 	k = 12;shift = true; break;
		case '"': 	k = 75;shift = true; break;
		
		
		}
		if(k>0){
			if(shift) ShiftDown();
			Down(k);
			Up(k);
			if(shift) ShiftUp();
		}
	}
}
