-- $Name:Return of Red Hood$
-- $Version:1.05$
-- $Author:NLB project$
instead_version "1.9.1"
require "cutscene"
require "fonts"
require "theme"
game.codepage="UTF-8"

function init()
    s1 = font('fonts/sb.ttf', 30);
    s2 = font('fonts/sb.ttf', 25);
    back_to_menu = s1:txt "Back to Menu";
    theme.win.geom(150, 100, 500, 400);
    theme.inv.mode('disabled');
end

main = room {
    nam = "main",
    enter = function (s)
        set_music('sound/init/a_la_mozart.ogg', 1);
        walk(r1);
    end
} 

r1 = cutscene {
    nam = true,
    dsc = function(s)
        pn (txtc(img('images/init/NLBLogo.png')))
        pn "{fading 50}"
        pn "{cls}"
        pn "{fading 50}"
        pn ("{walk r2}")
    end
}

r2 = cutscene {
    nam = true,
    dsc = function(s)
        pn (txtc(img('images/init/presents.png')))
        pn "{fading 25}"
        pn "{cls}"
        pn "{fading 50}"
        pn ("{walk r3}")
    end
}
 
r3 = room {
    dsc = function(s)
        startgametxt_en = s2:txt "Start English version";
        startgametxt_ru = s2:txt "Start Russian version";
        usedsoftwaretxt = s2:txt "Used software";
        creditstxt = s2:txt "Credits";
        pn (txtc(s1:txt "Menu"));
        p("^{start_game_en|"..startgametxt_en.."}^");
        p("^{start_game_ru|"..startgametxt_ru.."}^");
        p("^{used_software|"..usedsoftwaretxt.."}^");
        p("^{credits|"..creditstxt.."}^");
    end,
    nam = ' ',
    entered = function(s)
        theme.win.geom(18, 36, 344, 410);
        theme.win.color("#ffffff", "#00ff00", "#0000ff");
        theme.gfx.bg('images/init/bookcover.png');
        set_music('sound/init/a_la_mozart.ogg', 1);
    end,
    left = function(s)
        theme.win.geom(400, 18, 350, 550);
        theme.win.color("#000000", "#a02c00", "#606060");
        theme.gfx.bg('images/init/justbook.png');
    end,
    obj =  {
        xact(
            "start_game_en",
            function(s)
                theme.win.geom(400, 18, 350, 550);
                theme.win.color("#000000", "#a02c00", "#606060");
                theme.gfx.bg('images/init/justbook.png');
                theme.inv.mode('horizontal');
                gamefile('module_en.lua', true);
            end
        ),
        xact(
            "start_game_ru",
            function(s)
                theme.win.geom(400, 18, 350, 550);
                theme.win.color("#000000", "#a02c00", "#606060");
                theme.gfx.bg('images/init/justbook.png');
                theme.inv.mode('horizontal');                
                gamefile('module_ru.lua', true);
            end
        ),
        xact("used_software", function(s) walk("r4") end),
        xact("credits", function(s) walk("r5") end)
    }
}

r4 = room {
    nam = " ",
    entered = function(s)
        theme.win.geom(18, 18, 694, 550);
        theme.gfx.bg('images/init/justbook2.png');
        set_music('sound/init/a_la_mozart.ogg', 1);
    end,
    left = function(s)
        theme.win.geom(400, 18, 350, 550);
        theme.gfx.bg('images/init/justbook.png');
    end,
    dsc = function(s) pn(s1:txt "Used software"); p [[
^
Audacity, software for recording and editing sounds http://audacity.sourceforge.net/^
Blender, 3D modeling suite http://www.blender.org/^
Inkscape, professional vector graphics editor https://inkscape.org^
INSTEAD, INterpreter of Simple TExt ADventure by Peter Kosyh http://instead.syscall.ru/^
MakeHuman, Open Source tool for making 3D characters http://www.makehuman.org/^
MuseScore, music creation program http://musescore.org/^^

Non-Linear Book Builder by NLB project, Interactive Fiction creation program^
http://nlbproject.com/^^

]]; p("{to_menu|"..back_to_menu.."}^"); p "^^"; end,
    obj =  {xact("to_menu", function(s) walk("r3") end)}
}

r5 = room {
    nam = " ",
    entered = function(s)
        theme.win.geom(18, 18, 694, 550);
        theme.gfx.bg('images/init/justbook2.png');
        set_music('sound/init/a_la_mozart.ogg', 1);
    end,
    left = function(s)
        theme.win.geom(400, 18, 350, 550);
        theme.gfx.bg('images/init/justbook.png');
    end,
    dsc = function(s) p(txtc("{to_menu|"..back_to_menu.."}^")); p "^"; p(s1:txt "Text"); p [[
^^By NLB project team.^
]]; p "^"; p(s1:txt "Font"); p [[
^^"Shadowed Black" font by Paul Lloyd^
http://moorstation.org/typoasis/designers/lloyd/blackjewels/index.htm^^
]]; p "^"; p(s1:txt "Music"); p [[
^^Some tracks were written by NLB project team.

^^http://musescore.org/^^

"Flight of the Bumblebee", orchestral interlude originally written by Nikolai Rimsky-Korsakov^
Submitted by users Austin, Entire Music^^

Studies on Chopin's Etudes No.1, Leopold Godowsky^
Submitted by seungtae.kim.712^^

Symphony No. 5, originally written by Ludwig van Beethoven^
Submitted by ScH^^

Beethoven Silence, submitted by Maycon Luccas^^

Excerpt from Movement 1 of Tchaikovsky Symphony no. 4^
Submitted by PT8475^^

In the Halls of the Frost Giant Jarl by John Arthur Wolfrey^
(based on the Edvard Grieg's Mountain King)^
Submitted by joakimwo^^

Piano Sonata No. 16 (K 545) Allegro by W.A. Mozart^
Submitted by J.S.G. Fernandez^^

Mozart - Violin Concerto No.3 , 1st Mov.^
Submitted by PetraV^^

Sonata No. 14 "Moonlight" by Ludwig van Beethoven^^

La Marmotte "A Merry Song" Op. 52 No. 7 by Ludwig van Beethoven^
Submitted by RochesterLoki^^

Etude, arr. P. Stanchev^
Submitted by lordegor^^

Bourne Vivaldi (orchestral score), arr. by Teresa Mejias^
Submitted by thmejias1^^

Chanson Triste, by Pyotr Ilyich Tchaikovsky^
Submitted by Jenne Van Antwerpen^^

Musette D major BMW Anh 126 by Johann Sebastian Bach^
Submitted by horydadr^^

Flohwalzer variations^^

Toccata and Fugue in D minor, BWV 565 by Johann Sebastian Bach^
Performed by Paul Pitman https://musopen.org/^^
]]; p(s1:txt "3D models and graphics"); p [[
^^Textures http://cgtextures.com/^^

Tree models by Yorik http://blender-archi.tuxfamily.org/Greenhouse^^

Background images http://www.pexels.com/^^

Mushroom texture from unknown author^^

anonymous: Pillow http://www.blendswap.com/blends/view/4443^^

hilux: Axe http://www.blendswap.com/blends/view/72119^^

Kator Legaz (http://3dmodels.katorlegaz.com)^
Folding Table, Bedroom, Coffee Mug, Pedestal Vase Lamp, Mid-Century Living Room Set^^

OOLE: Book http://www.blendswap.com/blends/view/53477^^

Onni Heik: Basket http://archive3d.net/?a=download&id=5907328a^^

Paul Spooner: Butterfly http://www.peripheralarbor.com/butterfly/^^

Toby: Cabbage http://archive3d.net/?a=download&id=337e61ff^^

Umar Muzammil aka umar6419: Salmon http://tf3dm.com/3d-model/salmon-44387.html^^

VladGl: Jug@cup http://www.blendswap.com/blends/view/73628^^

And special thanks for the awesome model of Wolf:^
Dennis Haupt aka DennisH2010^
http://www.blendswap.com/blends/view/24800^^
]]; p(txtc("{to_menu|"..back_to_menu.."}^")); p "^^"; end,
    obj =  {xact("to_menu", function(s) walk("r3") end)}
}