program qwirkle;

uses crt,sysutils;
{ici, l'on va tout d'abord déclarer les types importants du programme comme 'cases' qui est comme une case du plateau de jeu qui contient donc une 'cl' (couleur) et une 'fm' (forme) | 'tab' est le plateau de jeu de 217 par 217 cases car la première case est placer au centre en 0,0 | 'ptr_cases' est un pointeur de cases, cela  sert à créer la pioche qui pourra ainsi être vidée facilement | quand au 'tabcoord' il sert uniquement lors du comptage des points, il garde en mémoire les cases posées par le joueur durant son  tour}
type cases=record
	cl,fm:char;
end;
	tab=array[-108..108,-108..108] of cases;
	main=array[1..6] of cases;
	ptr_cases=^pioche;
	pioche=record
		c:cases;
		p:ptr_cases;
	end;
	ptr_main=^hand;
	hand=record
		c:cases;
		num:integer;
		sui:ptr_main;
	end;
	couleurs=array[1..6] of char;
	formes=array[1..6] of char;
	joueur=record
		n:string;
		p:integer;
	end;
	coord=record
		x,y:integer;
	end;
	instruct=record
		x,y,n:integer;
	end;
	tabcoord=array[1..6] of coord;
	tabinstr=array[1..6] of instruct;
{cette fonction initialise une grille qui sera celle du jeu de qwirkle}

function initableau():tab;
var a,b:integer;t:tab;
begin
	for a:=-108 to 108 do
		for b:=-108 to 108 do
			begin	
				t[a,b].cl:='.';
				t[a,b].fm:='.';
			end;
	initableau:=t;
end;
{ces 2 fonctions permettent de créer toutes le couleurs et les formes dont les pions sont constitués}
function couleur():couleurs;
var c:couleurs;
begin
	c[1]:='r';
	c[2]:='o';
	c[3]:='j';
	c[4]:='v';
	c[5]:='b';
	c[6]:='m';
	couleur:=c;
end;

function forme():formes;
var f:formes;
begin
	f[1]:='c';
	f[2]:='x';
	f[3]:='l';
	f[4]:='a';
	f[5]:='*';
	f[6]:='t';
	forme:=f;
end;

(****************************************************)
{cette fonction permet de placer un pion sur la grille si la cases en question n'est pas déjà occupée et si les autres règles du jeu concernant le placement des cases sont respectées}

function placercases(x,y,premierx,premiery:integer;u,v:char;ta:tab;var nrbcases:integer;var hor,ver,IA:boolean):tab;
var error,n,a,b,i,j,vide:integer;pcase:boolean;
begin
	error:=0;
	pcase:=false;
	if (ta[x,y].cl='.') and (ta[x,y].fm='.') then
	begin	
			pcase:=false;
			a:=1;
			b:=0;
			error:=0;
			n:=1;
			i:=1;
			j:=1;
			vide:=0;
			repeat 
				if ta[x+a,y+b].cl<>'.' then
				begin
					while (ta[x+n*a,y+n*b].cl<>'.') and (error=0) do
					begin
						if ((ta[x+n*a,y+n*b].cl=u) and (ta[x+n*a,y+n*b].fm<>v)) or ((ta[x+n*a,y+n*b].cl<>u) and (ta[x+n*a,y+n*b].fm=v)) then
						begin
							n:=n+1;
						end
						else if (ta[x+n*a,y+n*b].cl=u) and (ta[x+n*a,y+n*b].fm=v) then
						begin
							error:=error+1;
						end
						else if (ta[x+a,y+b].cl<>ta[x,y].cl) and (ta[x+a,y+b].fm<>ta[x,y].fm) then
							error:=error+1;		
					end;
					n:=1;
					while ta[x+i*a,y+i*b].cl<>'.' do
					begin
						while ta[x-j*a,y-j*b].cl<>'.' do
						begin
							if (ta[x+i*a,y+i*b].cl=ta[x-j*a,y-j*b].cl) and (ta[x+i*a,y+i*b].fm=ta[x-j*a,y-j*b].fm) then
								error:=error+1;
							j:=j+1;
						end;
						j:=1;
						i:=i+1;
					end; 	
				end;
				if (premierx=x) and (premiery=y) then
					pcase:=true;
				while (ta[premierx+n*a-a,premiery+n*b-b].cl<>'.') do
				begin
					if (premierx+n*a=x) and (premiery+n*b=y) then
						pcase:=true;
					n:=n+1;
				end;
					n:=1;
				if ta[x+a,y+b].cl='.' then
					vide:=vide+1;
				if (a=0) and (b=-1) then
				begin
					a:=0;
					b:=0;
				end;
				if (a=0) and (b=1) then
				begin
					a:=0;
					b:=-1;
				end;
				if (a=-1) and (b=0) then
				begin
				a:=0;
				b:=1;
				end;
				if (a=1) and (b=0) then
				begin
					a:=-1;
					b:=0;
				end;
		until (a=0) and (b=0) ;
		if IA=false then
		begin
			if ver=true then
			begin
				if x<>premierx then
					error:=error+1;
			end;
			if hor=true then
			begin
				if y<>premiery then
					error:=error+1;
			end;
		end;
		if (premierx<>x) and (premiery<>y) then
			error:=error+1;
		if (vide=4) then
			error:=error+1;
	end;
	if (error=0) and (pcase=true) then
	begin
		ta[x,y].cl:=u;
		ta[x,y].fm:=v;
		nrbcases:=nrbcases+1;
		if (premierx=x) and (premiery<>y) then
		begin
			ver:=true;
			hor:=false;
		end;
		if (premiery=y) and (premierx<>x) then
			hor:=true;
			ver:=false;
	end;
	
	placercases:=ta;
end;
{bibliotèque est une fonction qui permet de mettre en couleur les cases de la couleur dont elles sont censées être}
procedure biblioteque(c:cases);
begin	
	if c.cl='r' then
	begin
		highvideo;
		textbackground(red);
		write(c.fm);
		normvideo;
	end;
	if c.cl='o' then
	begin
		highvideo;
		textbackground(brown);
		write(c.fm);
		normvideo;
	end;
	if c.cl='j' then
	begin
		highvideo;
		textbackground(lightcyan);
		write(c.fm);
		normvideo;
	end;
	if c.cl='v' then
	begin
		highvideo;
		textbackground(green);
		write(c.fm);
		normvideo;
	end;
	if c.cl='b' then
	begin
		highvideo;
		textbackground(blue);
		write(c.fm);
		normvideo;
	end;
	if c.cl='m' then
	begin
		highvideo;
		textbackground(magenta);
		write(c.fm);
		normvideo;
	end;
	if c.cl='.' then
	begin	
		highvideo;
		write(c.fm);
		normvideo;
	end;
end;
{Affichage affiche le plateau de jeu existant }
procedure affichage(grille:tab;var droite,gauche,haut,bas:integer);
var i,j,k,error:integer;
begin
		error:=1;
		i:=0;
		{l'on va définir ici le domaine de la grille dans lequel sont situés les pions}
		while error<>0 do 
		begin	
			error:=0;
			for k:=-108 to 108 do
				if grille[i,k].cl<>'.' then 
					error:=error+1;
			i:=i+1;		
		end;
		droite:=i;
		i:=0;
		error:=1;
		while error<>0 do
		begin
			error:=0;
			for k:=-108 to 108 do
				if grille[i,k].cl<>'.' then 
					error:=error+1;
			i:=i-1;		
		end;
		gauche:=i;
		i:=0;
		error:=1;
		while error<>0 do 
		begin
			error:=0;
			for k:=-108 to 108 do
				if grille[k,i].cl<>'.' then 
					error:=error+1;
			i:=i+1;		
		end;
		haut:=i;
		i:=0;
		error:=1;
		while error<>0 do
		begin
			error:=0;
			for k:=-108 to 108 do
				if grille[k,i].cl<>'.' then 
					error:=error+1;
			i:=i-1;		
		end;
		bas:=i;
		{ensuite, l'on va afficher le tableau qui est situé dans le domaine défini précedemment}
		write('   ');
		for i:=gauche+1 to droite-1 do
		begin
			if i<0 then
			begin	
				write('|');
				write(i);
			end
			else
			begin
			write('|');
			write(i);
			write('|');
			end;
		end;
		highvideo;
		textbackground(white);
		textcolor(black);
		write('X');
		normvideo;
		writeln();
		for j:=bas+1 to haut-1 do
		begin
			if j<0 then
			begin
				write(j);
				write('|');
			end
			else
			begin
				write(' ');
				write(j);
				write('|');
			end;
			for i:=gauche+1 to droite-1 do
			begin
				write('|');
				biblioteque(grille[i,j]);
				write('|');
			end;
		writeln();
		end;
		write(' ');
		highvideo;
		textbackground(white);
		textcolor(black);
		write('Y');
		normvideo;
		writeln();
		writeln();
end;
{comptagedepoints va compter les points d'un joueur durant son tour, à chaque pose d'un pion, elle enregistre les coordonnées de ce pion et compte les points du joueur en fonction de ces coordonnées}
function comptagedepoints(x,y:integer;t:tab;var ta:tabcoord;nbrcases:integer):integer;
var n,m,grand,petit,p,p2,s:integer;
begin
	ta[nbrcases].x:=x;
	ta[nbrcases].y:=y;
	if ta[1].x=ta[nbrcases].x then
	begin
		p2:=0;
		grand:=1;
		petit:=1;
		for n:=1 to nbrcases do
		begin
			if ta[grand].y<ta[n].y then
				grand:=n;
		end;
		for n:=1 to nbrcases do
		begin
			if ta[petit].y>ta[n].y then
				petit:=n;
		end;
		n:=1;
		while t[ta[petit].x,ta[petit].y-n].cl<>'.' do
		begin
			p2:=p2+1;
			n:=n+1;	
		end;
		n:=1;
		while t[ta[grand].x,ta[grand].y+n].cl<>'.' do
		begin
			p2:=p2+1;
			n:=n+1;	
		end;
		if (p2<>0) or (nbrcases<>1) then
			p2:=p2+ta[grand].y-ta[petit].y+1;
		if p2=6 then
			p2:=p2+6;
		p:=p2;
		p2:=0;
		for m:=1 to nbrcases do
		begin
			s:=0;
			n:=1;
			while t[ta[m].x+n,ta[m].y].cl<>'.' do
			begin
				p2:=p2+1;
				n:=n+1;
			end;
			if n<>1 then 
				s:=s+1;
			n:=1;
			while t[ta[m].x-n,ta[m].y].cl<>'.' do
			begin
				p2:=p2+1;
				n:=n+1;
			end;
			if n<>1 then 
				s:=s+1;
			if p2= 6 then
				p2:=p2+6;
			if s<>0 then
				p2:=p2+1;
			p:=p+p2;
			p2:=0;
		end;
	end
	else if ta[1].y=ta[nbrcases].y then
	begin
		p2:=0;
		grand:=1;
		petit:=1;
		for n:=1 to nbrcases do
		begin
			if ta[grand].x<ta[n].x then
				grand:=n;
		end;
		for n:=1 to nbrcases do
		begin
			if ta[petit].x>ta[n].x then
				petit:=n;
		end;
		n:=1;
		while t[ta[petit].x-n,ta[petit].y].cl<>'.' do
		begin
			p2:=p2+1;
			n:=n+1;			
		end;
		n:=1;
		while t[ta[grand].x+n,ta[grand].y].cl<>'.' do
		begin
			p2:=p2+1;
			n:=n+1;	
		end;
		p2:=p2+ta[grand].x-ta[petit].x+1;
		if p2=6 then
			p2:=p2+6;
		p:=p2;
		p2:=0;
		for m:=1 to nbrcases do
		begin
			s:=0;
			n:=1;
			while t[ta[m].x,ta[m].y+n].cl<>'.' do
			begin
				p2:=p2+1;
				n:=n+1;
			end;
			if n<>1 then 
				s:=s+1;
			n:=1;
			while t[ta[m].x,ta[m].y-n].cl<>'.' do
			begin
				p2:=p2+1;
				n:=n+1;
			end;
			if n<>1 then 
				s:=s+1;
			if p2= 6 then
				p2:=p2+6;
			if s<>0 then
				p2:=p2+1;
			p:=p+p2;
			p2:=0;
		end;
	end;
	if (t[ta[1].x+1,ta[1].y].cl='.') and (t[ta[1].x-1,ta[1].y].cl='.') and (t[ta[1].x,ta[1].y+1].cl='.') and (t[ta[1].x,ta[1].y-1].cl='.') and (t[ta[1].x,ta[1].y].cl<>'.') then
	begin
		p:=nbrcases;
	end;
comptagedepoints:=p;
end;

{cette fonction va permettre de créer la pioche du jeu contenant tous les pions}
function creerpioche():ptr_cases;
var tete,q,z:ptr_cases;a,b,c:integer;co:couleurs;fo:formes;
begin	
	new(tete);
	new(q);
	new(z);
	q:=tete;
	co:=couleur();
	fo:=forme();
	for a:=1 to 3 do
	begin
		for b:=1 to 6 do
		begin
			for c:=1 to 6 do
			begin
				q^.c.cl:=co[b];
				q^.c.fm:=fo[c];
				q^.p:=z;
				q:=z;
				new(z);
			end;
		end;
	end;
	dispose(q);
	dispose(z);
	creerpioche:=tete;
end;

{initmain crée tout simplement une main pour un joueur dans laquelle il aura 6 pions}
function initmain():main;
var M:main;a:integer;
begin
	for a:=1 to 6 do
	begin
		M[a].cl:='.';
		M[a].fm:='.';
	end;
	initmain:=M;
end;

{cette fonction remplie la main du joueur prenant compte du nombre de pions dont il manque}
function remplirmain(m:main;var pi:ptr_cases):main;
var N,L,i,a:integer;pioch,pioch2,pioch3,pi2:ptr_cases;
begin
	randomize;
	L:=1;
	repeat
		new(pioch);
		new(pioch2);
		new(pioch3);
		new(pi2);
		pi2:=pi^.p;
		N:=0;
		pioch:=pi;
		while pioch^.p<>nil do
		begin
			pioch:=pioch^.p;
			N:=N+1;
		end;
		new(pioch);
		pioch^.p:=pi;
		a:=random(N)+1;
		for i:=1 to a do
		begin
			if pioch^.p<>nil then
			begin
				new(pioch2);
				new(pioch3);
				pioch2:=pioch;
				pioch3:=pioch^.p^.p;
				pioch:=pioch^.p;
			end;
		end;
		while m[L].cl<>'.' do
			L:=L+1;
		if L<7 then
		begin
			m[L].cl:=pioch^.c.cl;
			m[L].fm:=pioch^.c.fm;
			pioch2^.p:=pioch3;
			dispose(pioch);
		end;
		if pi^.p=nil then
			pi:=pi2;
	until (L>=6) or (pi^.p=nil);
	remplirmain:=m;
end;

{affichermain affiche la main d'un joueur mise en paramètre }
procedure affichermain(m:main);
var a:integer;
begin
	for a:=1 to 6 do
	begin
		write('|');
		biblioteque(m[a]);
	end;
	write('|');
	writeln();
	for a:=1 to 6 do
	begin	
		textbackground(white);
		textcolor(black);
		write('|');
		write(a);
	end;
	write('|');
	normvideo;
end;

{cette procedure va demander au joueur d'indiquer la case de sa main ou se situe le pions qu'il veut jouer et va appler la fonction placercases }
procedure jouer(var joueur:joueur;var ma:main;var grille2:tab;var points:integer;var premierx,premiery,nbrcases,x,y:integer;var hor,ver,IA:boolean);
var r,c,d,g,h,ba,error:integer;k,l:char;userinput:string;
begin
	{writeln('premierx :',premierx);
	writeln('premiery :',premiery);}
	c:=nbrcases;
	affichage(grille2,d,g,h,ba);
	writeln('-- Voici votre main  : ');
	affichermain(ma);
	writeln();
	repeat 
	repeat 
	writeln('quel pion souhaitez-vous jouer ? (indiquez le numéro de la case correspondante dans votre main)  :');
	readln(userinput);
	val(userinput,r,error);
	until error=0;
	until (r<7) and (r>0) and (ma[r].cl<>'.') ;
	k:=ma[r].cl;
	l:=ma[r].fm;
	writeln('À présent, choisissez à quel position vous souhaitez placer votre pion :');
	repeat
	writeln('En x :');
	readln(userinput);
	val(userinput,x,error);
	until error=0;
	repeat
	writeln('En y :');
	readln(userinput);
	val(userinput,y,error);
	until error=0;
	grille2:=placercases(x,y,premierx,premiery,k,l,grille2,nbrcases,hor,ver,IA);
	affichage(grille2,d,g,h,ba);
	if c<>nbrcases then
	begin
		ma[r].cl:='.';
		ma[r].fm:='.';
	end;
end;

{cette procedure supprime un noeud d'une liste chainée à une position donnée}
procedure supprimernoeud(n:integer;var p:ptr_main);
var p1,p2,p3,pfinal:ptr_main;a:integer;
begin
	new(p1);
	new(p2);
	new(p3);
	new(pfinal);
	p1:=p;
	if n=1 then 
	begin
		p2:=p^.sui;
		p1^.sui:=nil;
		pfinal:=p2;
		p:=pfinal;
	end;
	if n>1 then
	begin
		pfinal:=p1;
		for a:=1 to n-1 do
		begin
			p3:=p1;
			p1:=p1^.sui;
		end;	
		if p1^.sui=nil then
		begin
			dispose(p1);
		end
		else
		begin
			p2:=p1^.sui;
			p3^.sui:=p2;
			dispose(p1);
		end;	
		p:=pfinal;
	end;	
end;

{cette fonction crée une liste chainée à partir de la main d'un joueur}
function transformation(m:main):ptr_main;
var suivant,que,tete:ptr_main;a:integer;
begin	
	new(tete);
	new(suivant);
	new(que);
	que:=tete;
	for a:=1 to 6 do
	begin
		new(suivant);
		tete^.num:=a;
		tete^.c.cl:=m[a].cl;
		tete^.c.fm:=m[a].fm;
		tete^.sui:=suivant;
		new(tete);
		tete:=suivant;
	end;
	dispose(tete);
	transformation:=que;
end;

{cette fonction va rechercher la meilleur position en laquelle posée un pion c'est-à-dire la position qui rapporte le plus de points}	
function recherche(c:cases;h,b,g,d:integer;var nbrpoints1,nbrcases:integer;var tabc:tabcoord;var t:tab;hor,ver,IA:boolean;premierx,premiery:integer):coord;
var colonnes,lignes,nbrcases2,nbrcases3,nbrpoints2,nbrpoints3:integer;t2,t3:tab;tabc2,tabc3:tabcoord;
begin
	nbrpoints2:=0;
	nbrpoints3:=0;
	nbrcases2:=nbrcases;
	nbrcases3:=nbrcases;
	t2:=t;
	t3:=t;
	recherche.x:=0;
	recherche.y:=0;
	tabc2:=tabc;
	tabc3:=tabc;
	for colonnes:=b+1 to h-1 do
	begin
		for lignes:=g+1 to d-1 do
		begin
			t2:=t;
			nbrcases2:=nbrcases;
			hor:=false;
			ver:=false;
			tabc2:=tabc;
			if (premierx=0) and (premiery=0) then
				t2:=placercases(lignes,colonnes,lignes,colonnes,c.cl,c.fm,t2,nbrcases2,hor,ver,IA)
			else
				t2:=placercases(lignes,colonnes,tabc[1].x,tabc[1].y,c.cl,c.fm,t2,nbrcases2,hor,ver,IA);
			if nbrcases2=nbrcases+1 then
			begin
				nbrpoints2:=comptagedepoints(lignes,colonnes,t2,tabc2,nbrcases2);
				if nbrpoints2>nbrpoints3 then
				begin
					nbrpoints3:=nbrpoints2;
					recherche.x:=lignes;
					recherche.y:=colonnes;
					t3:=t2;
					tabc3:=tabc2;
					nbrcases3:=nbrcases2;
				end;
			end;	
		end;
	end;
	t:=t3;
	tabc:=tabc3;
	nbrcases:=nbrcases3;
	nbrpoints1:=nbrpoints1+nbrpoints3;
end;

{cette fonction va à une position donnée dans la liste chainée}
function allera(n:integer;p:ptr_main):ptr_main;
var a:integer;ptr:ptr_main;
begin
	ptr:=p;
	if n=1 then
	begin
		allera:=p;
	end
	else if n>1 then
	begin
		for a:=1 to n-1 do
			ptr:=ptr^.sui;
		allera:=ptr;
	end;
end;

{cette fonction va chercher grâce à la fonction recherche le meilleur 'coup' à faire avec la main qu'elle a et le plateau présent }
function IA(m:main;t:tab;h,b,d,g:integer;var hor,ver,iaa:boolean):tabinstr;
var nbrcases,nbrpoints,nbrpoints2,c,a1,a2,a3,a4,a5,a6,b1,b2,b3,premierx,premiery,mo:integer;k,t2:tab;instr,instr2:tabinstr;tabc:tabcoord;pt,pt2:ptr_main;co:coord;
begin
	nbrpoints2:=0;
	nbrpoints:=0;
	for a1:=1 to 6 do
	begin
		tabc[a1].x:=0;
		tabc[a1].y:=0;
	end;
	for a1:=1 to 6 do
	begin
		instr[a1].x:=0;
		instr[a1].y:=0;
		instr[a1].n:=0;
	end;
	for a1:=1 to 6 do
	begin
		instr2[a1].x:=0;
		instr2[a1].y:=0;
		instr2[a1].n:=0;
	end;
	k:=t;
	for a1:=1 to 6 do
		for a2:=1 to 5 do
			for a3:=1 to 4 do
				for a4:=1 to 3 do
					for a5:=1 to 2 do
					begin
						for b3:=1 to 6 do
						begin
							tabc[b3].x:=0;
							tabc[b3].y:=0;
						end;
						new(pt);
						new(pt2);
						pt2:=transformation(m);
						a6:=1;
						nbrcases:=0;
						nbrpoints:=0;
						pt:=allera(a1,pt2);
						premierx:=0;
						premiery:=0;
						co:=recherche(pt^.c,h,b,g,d,nbrpoints,nbrcases,tabc,k,hor,ver,iaa,premierx,premiery);
						instr2[1].x:=co.x;
						instr2[1].y:=co.y;
						if (instr2[1].x<>0) or (instr2[1].y<>0) then
						begin
							premierx:=co.x;
							premiery:=co.y;
							instr2[1].n:=pt^.num;
							supprimernoeud(a1,pt2);
							new(pt);
							pt:=allera(a2,pt2);
						end;
						if  (instr2[1].x<>0) or (instr2[1].y<>0) then 
						begin
							co:=recherche(pt^.c,h,b,g,d,nbrpoints,nbrcases,tabc,k,hor,ver,iaa,premierx,premiery);
							instr2[2].x:=co.x;
							instr2[2].y:=co.y;
							instr2[2].n:=pt^.num;
							supprimernoeud(a2,pt2);
							new(pt);
							pt:=allera(a3,pt2);	
						end;
						if (instr2[2].x<>0) or (instr2[2].y<>0) then 
						begin
							co:=recherche(pt^.c,h,b,g,d,nbrpoints,nbrcases,tabc,k,hor,ver,iaa,premierx,premiery);
							instr2[3].x:=co.x;
							instr2[3].y:=co.y;
							instr2[3].n:=pt^.num;
							supprimernoeud(a3,pt2);
							new(pt);
							pt:=allera(a4,pt2);
						end;
						if (instr2[3].x<>0) or (instr2[3].y<>0) then 
						begin	
							co:=recherche(pt^.c,h,b,g,d,nbrpoints,nbrcases,tabc,k,hor,ver,iaa,premierx,premiery);
							instr2[4].x:=co.x;
							instr2[4].y:=co.y;
							instr2[4].n:=pt^.num;
							supprimernoeud(a4,pt2);
							new(pt);
							pt:=allera(a5,pt2);
						end;
						if (instr2[4].x<>0) or (instr2[4].y<>0) then 
						begin	
							co:=recherche(pt^.c,h,b,g,d,nbrpoints,nbrcases,tabc,k,hor,ver,iaa,premierx,premiery);
							instr2[5].x:=co.x;
							instr2[5].y:=co.y;
							instr2[5].n:=pt^.num;
							supprimernoeud(a5,pt2);
							new(pt);
							pt:=allera(a6,pt2);
						end;
						if (instr2[5].x<>0) or (instr2[5].y<>0) then 
						begin	
							co:=recherche(pt^.c,h,b,g,d,nbrpoints,nbrcases,tabc,k,hor,ver,iaa,premierx,premiery);
							instr2[6].x:=co.x;
							instr2[6].y:=co.y;
							instr2[6].n:=pt^.num;
							supprimernoeud(a6,pt2);
						end;
						mo:=0;
						b1:=0;
						for b2:=2 to 6 do
						begin
							if (instr2[b2].x<>0) or (instr2[b2].y<>0)  then 
							begin
								if (instr2[b2].x=premierx) then
									mo:=mo+1;
								if (instr2[b2].y=premiery) then
									b1:=b1+1;
							end;
						end;
						if ((mo=0) and (b1<>0)) or ((mo<>0) and (b1=0)) then
						begin
							if nbrpoints2<nbrpoints then
							begin
								for c:=1 to 6 do
								begin
									instr[c].x:=instr2[c].x;
									instr[c].y:=instr2[c].y;
									instr[c].n:=instr2[c].n;
								end;
								t2:=k;
								nbrpoints2:=nbrpoints;
							end;
						end;
						k:=t;
					end; 
	t:=t2;
	IA:=instr;
end;

{cette procedure va permettre à une IA de placer une case ou bien de passer son tour }
procedure jouerIA(var joueur:joueur;var ma:main;var grille2:tab;hor,ver,iaa:boolean;var p:ptr_cases);
var tabinst:tabinstr;d,g,h,b,nbrc,nbrc2,m,joueurpoints:integer;tcoord:tabcoord;P2,P3:ptr_cases;
begin
	joueurpoints:=0;
	new(P2);
	new(P3);
	P2:=p;
	nbrc:=0;
	nbrc2:=0;
	affichage(grille2,d,g,h,b);
	tabinst:=IA(ma,grille2,h,b,d,g,hor,ver,iaa);
	writeln();
	if (tabinst[1].x<>0) or (tabinst[1].y<>0) then
	begin	
		grille2:=placercases(tabinst[1].x,tabinst[1].y,tabinst[1].x,tabinst[1].y,ma[tabinst[1].n].cl,ma[tabinst[1].n].fm,grille2,nbrc,hor,ver,iaa);
		joueurpoints:=comptagedepoints(tabinst[1].x,tabinst[1].y,grille2,tcoord,nbrc);
		affichage(grille2,d,g,h,b);
		if nbrc<>0 then
		begin
			ma[tabinst[1].n].cl:='.';
			ma[tabinst[1].n].fm:='.';
		end;
	end
	else if (tabinst[1].x=0) or (tabinst[1].y=0) then
	begin
		for m:=1 to 6  do
		begin
			if ma[m].cl<>'.' then
				begin
					while P2^.p<>nil do
						P2:=P2^.p;
					P3^.c.cl:=ma[m].cl;
					P3^.c.fm:=ma[m].fm;
					P2^.p:=P3;
					new(P3);
					ma[m].cl:='.';
					ma[m].fm:='.';
				end;
		end;
		remplirmain(ma,p);
	end;
	for m:=2 to 6 do
	begin
		if tabinst[m].n<>0 then
			begin	
					nbrc2:=nbrc;
				grille2:=placercases(tabinst[m].x,tabinst[m].y,tabinst[1].x,tabinst[1].y,ma[tabinst[m].n].cl,ma[tabinst[m].n].fm,grille2,nbrc,hor,ver,iaa);	
				if nbrc2<>nbrc then
				begin
					joueurpoints:=comptagedepoints(tabinst[m].x,tabinst[m].y,grille2,tcoord,nbrc);
					ma[tabinst[m].n].cl:='.';
					ma[tabinst[m].n].fm:='.';
				end;
				affichage(grille2,d,g,h,b);
				
			end;		
		end;	
	joueur.p:=joueur.p+joueurpoints;
end;

{cette procedure va proposer au joueur de soit échanger des pions, soit placer des pions sur la grille de jeu, soit de passer son tour,  elle prend en paramètre la première case qu'a posé le joueur car l'on sait qu'il s'agit de (0,0), en effet, c'est le tout premier joueur qui va utiliser cette procédure }
procedure menu(var joueur:joueur;var ma:main;var T:tab;var P:ptr_cases;var points,nbrcases,premierx,premiery:integer;var ta:tabcoord;var hor,ver,iaa:boolean);
var a,xcases,ycases,d,g,h,ba,point,verif:integer;q,s:char;P2,P3:ptr_cases;
begin	
	new(P2);
	new(P3);
	P2:=P;
	point:=0;
	repeat 
		writeln('Souhaitez-vous placer un/des pion/s ou bien changer des pions de votre main ou alors passer votre tour ?  J/E/P ( jouer/échanger/passer)  :');
		readln(q);
	until (q='J') or (q='E') or (q='j') or (q='e') or (q='p') or (q='P');
	if (q='J') or (q='j')  then
	begin	
		verif:=nbrcases;
		jouer(joueur,ma,T,points,premierx,premiery,nbrcases,xcases,ycases,hor,ver,iaa);
		if verif<>nbrcases then
			point:=comptagedepoints(xcases,ycases,T,ta,nbrcases);
		writeln('Voulez-vous continuer à placer des pions ? Y/N :');
		repeat 
			readln(s);
		until (s='Y') or (s='N') or (s='y') or (s='n');
		if (s='Y') or (s='y') then
			repeat
				verif:=nbrcases;
				jouer(joueur,ma,T,points,premierx,premiery,nbrcases,xcases,ycases,hor,ver,iaa);
				if verif<>nbrcases then
					point:=comptagedepoints(xcases,ycases,T,ta,nbrcases);
				writeln('Voulez-vous continuer à placer des pions ? Y/N :');
				readln(s);
			until (s='N') or (s='n');
				points:=joueur.p+point;
		ma:=remplirmain(ma,P);
	end;
	if (q='E') or (q='e') then
	begin
		repeat
			writeln('Quel pion de votre pioche souhaitez-vous échanger ? (indiquez le numéro de la case correspondante dans votre main)  :');
			readln(a);
			if (a<7) and (a>0) then
			begin
				if ma[a].cl<>'.' then
				begin
					while P2^.p<>nil do
						P2:=P2^.p;
					P3^.c.cl:=ma[a].cl;
					P3^.c.fm:=ma[a].fm;
					P2^.p:=P3;
					new(P3);
					ma[a].cl:='.';
					ma[a].fm:='.';
				end
				else
				writeln('Entrez un numéro de case contenant un pion');
			end
			else
			writeln('Entrez un numéro de case valide');
			writeln('Voulez-vous continuer à échanger des pions ? Y/N :');
			readln(s);
		until (s='N') or (s='n');
		ma:=remplirmain(ma,P);
	end;
	ma:=remplirmain(ma,P);
	affichage(T,d,g,h,ba);
end;

{cette procedure va proposer au joueur de soit échanger des pions, soit placer des pions sur la grille de jeu, soit de passer son tour , à la difference de la précédente, elle ne prend pas en paramètre les coordonées de la première case qu'a posé le joueur}
procedure menu2(var joueur:joueur;var ma:main;var T:tab;var P:ptr_cases;var points,nbrcases:integer; var ta:tabcoord;var hor,ver,iaa:boolean);
var a,xcases,ycases,d,g,h,ba,premierx,premiery,point,verif:integer;q,s:char;P2,P3:ptr_cases;
begin	
	point:=0;
	new(P2);
	new(P3);
	P2:=P;
	repeat 
		writeln('Souhaitez-vous placer un/des pion/s ou bien changer des pions de votre main  ou alors de passer votre tour?  J/E/P ( jouer/échanger/passer)  :');
		readln(q);
	until (q='J') or (q='E') or (q='j') or (q='e') or (q='p') or (q='P');
	if (q='J') or (q='j')  then
	begin	
		repeat
		verif:=nbrcases;
		jouer(joueur,ma,T,points,xcases,ycases,nbrcases,xcases,ycases,hor,ver,iaa);
		premierx:=xcases;
		premiery:=ycases;
		if verif<>nbrcases then 
			point:=comptagedepoints(xcases,ycases,T,ta,nbrcases);
		writeln('Voulez-vous continuer à placer des pions ? Y/N :');
		repeat 
			readln(s);
		until (s='Y') or (s='N') or (s='y') or (s='n');
		until (nbrcases=1) or (s='N') or (s='n');
		if (s='Y') or (s='y') then
			repeat
				verif:=nbrcases;
				jouer(joueur,ma,T,points,premierx,premiery,nbrcases,xcases,ycases,hor,ver,iaa);
				if verif<>nbrcases then
					point:=comptagedepoints(xcases,ycases,T,ta,nbrcases);
				writeln('Voulez-vous continuer à placer des pions ? Y/N :');
				readln(s);
			until (s='N') or (s='n');
			points:=joueur.p+point;
		ma:=remplirmain(ma,P);
	end;
	if (q='E') or (q='e') then
	begin
		repeat
			writeln('Quel pion de votre pioche souhaitez-vous échanger ? (indiquez le numéro de la case correspondante dans votre main)  :');
			readln(a);
			if (a<7) and (a>0) then
			begin
				if ma[a].cl<>'.' then
				begin
					while P2^.p<>nil do
						P2:=P2^.p;
					P3^.c.cl:=ma[a].cl;
					P3^.c.fm:=ma[a].fm;
					P2^.p:=P3;
					new(P3);
					ma[a].cl:='.';
					ma[a].fm:='.';
				end
				else
				writeln('Entrez un numéro de case contenant un pion');
			end
			else
			writeln('Entrez un numéro de case valide');
			writeln('Voulez-vous continuer à échanger des pions ? Y/N :');
			readln(s);
		until (s='N') or (s='n');
		ma:=remplirmain(ma,P);
	end;
	ma:=remplirmain(ma,P);
	affichage(T,d,g,h,ba);
end;

{cette fonction compte le nombre de pions que contient une main de joueur}
function nbrpions(j:main):integer;
var a,b:integer;
begin
	b:=0;
	for a:=1 to 6 do
	begin
		if j[a].cl<>'.' then
			b:=b+1;
	end;
	nbrpions:=b;
end;

{cette fonction donne le nom du gagnant dans le jeu à 2 joueurs}
function gagnant2(name1,name2:string;points1,points2:integer):string;
begin 
	if points1<points2 then
		gagnant2:=name2;
	if points1>points2 then
		gagnant2:=name1;
	if points1=points2 then
		gagnant2:=name1+','+name2;
end;

{cette fonction donne le nom du gagnant dans le jeu à 4 joueurs}
function gagnant4(name1,name2,name3,name4:string;points1,points2,points3,points4:integer):string;
var a:array[1..4] of joueur;i:integer;
begin
	a[1].p:=points1;
	a[2].p:=points2;
	a[3].p:=points3;
	a[4].p:=points4;
	a[1].n:=name1;
	a[2].n:=name2;
	a[3].n:=name3;
	a[4].n:=name4;
	for i:=1 to 3 do
		if a[i].p>a[i+1].p then
			a[i+1]:=a[i];
	if a[3].p=a[4].p then
		gagnant4:=a[3].n+','+a[4].n
	else
		gagnant4:=a[4].n;
end;

{cette fonction permet de vérifier que les joueurs peuvent encore jouer afin de savoir si la partie est ou non terminée}
function check(t:tab;m:main;h,b,d,g:integer;var hor,ver,iaa:boolean):boolean;
var error,a,c,w,i,j,nrbcases:integer;k:tab;
begin
	error:=0;
	for w:=1 to 6 do
	begin
	for a:=b+1 to h-1 do
		begin
			for c:=g+1 to d-1 do
			begin
				k:=placercases(a,c,a,c,m[w].cl,m[w].fm,t,nrbcases,hor,ver,iaa);
				for i:=b+1 to h-1 do
					for j:=g+1 to d-1 do
					begin
						if (k[i,j].cl=t[i,j].cl) and (k[i,j].cl=t[i,j].cl) then
							error:=error+1;
					end;
			end;
		end;
	end;
	if error=(h-b-2)*(d-g-2)*(h-b-2)*(d-g-2)*6 then
		check:=false
	else
		check:=true;
end;

{afficherNbrPoints2j affiche le nombre de points de chaque joueur dans le jeu à 2 joueurs}
procedure afficherNbrPoints2j(joueur1,joueur2:joueur);
begin
	writeln('-- Nombre de points :');
	writeln('-- ',joueur1.n,'  :',joueur1.p);
	writeln('-- ',joueur2.n,'  :',joueur2.p);
end;

{afficherNbrPoints4j affiche le nombre de points de chaque joueur dans le jeu à 4 joueurs}
procedure afficherNbrPoints4j(joueur1,joueur2,joueur3,joueur4:joueur);
begin
	writeln('-- Nombre de points :');
	writeln('-- ',joueur1.n,'  :',joueur1.p);
	writeln('-- ',joueur2.n,'  :',joueur2.p);
	writeln('-- ',joueur3.n,'  :',joueur3.p);
	writeln('-- ',joueur4.n,'  :',joueur4.p);
end;

{cette procedure fait le jeu à 2 joueurs}
procedure Init2j();
var ma1,ma2:main;f1,f2:boolean;nbrcases,d,g,h,b,x,error1:integer;plateau:tab;p:ptr_cases;joueur1,joueur2:joueur;premiex,premiey:integer;ta:tabcoord;userinput1:string;var hor,ver,iaa:boolean;
begin
	hor:=false;
	ver:=false;
	iaa:=false;
	writeln('----------------------------------------------------------------------------------------------------------------------------------');
	writeln('-- Ensuite, entrez votre pseudo en tant que joueur, il faut savoir que le joueur 1 commence en premier... Hein faut le savoir : --');	
	writeln('----------------------------------------------------------------------------------------------------------------------------------');
	readln();
	clrscr;
	writeln('-- Pseudo joueur 1 :');
	repeat
		readln(joueur1.n);
	until joueur1.n<>'';
	writeln('-- Pseudo joueur 2 :');
	repeat
		readln(joueur2.n);
	until joueur2.n<>'';
	writeln('--------------');
	readln();
	ClrScr;
	writeln('------------------------------------------');
	writeln('-- Bien nous pouvons commencer a present, ');
	writeln('------------------------------------------');
	readln();
	ClrScr;
	nbrcases:=0;
	joueur1.p:=0;
	joueur2.p:=0;
	d:=0;
	g:=0;
	h:=0;
	b:=0;
	ma1:=initmain;
	ma2:=initmain;
	plateau:=initableau;
	p:=creerpioche;
	ma1:=remplirmain(ma1,p);
	premiex:=0;
	premiey:=0;
	writeln('------------------------------------------------');
	writeln('-- ',joueur1.n,', c"est a vous de commencer !!');
	readln();
	writeln('-- Pour commencer, veuillez choisir un pion de votre main qui sera placé au centre de la grille, (entez son numéro de case) :');
	writeln('---------------------------------------------------------------------------------------------------');
	writeln('-- Voici votre main : ');
	affichermain(ma1);
	writeln();
	repeat
		readln(userinput1);
		val(userinput1,x,error1);
	until (x<7) and (x>0) and (error1=0);
	plateau[0,0].cl:=ma1[x].cl;
	plateau[0,0].fm:=ma1[x].fm;
	ma1[x].cl:='.';
	ma1[x].fm:='.';
	nbrcases:=1;
	comptagedepoints(0,0,plateau,ta,nbrcases);
	writeln();
	affichage(plateau,d,g,h,b);
	menu(joueur1,ma1,plateau,p,joueur1.p,nbrcases,premiex,premiey,ta,hor,ver,iaa);	
	if joueur1.p=0 then
		joueur1.p:=1;
	hor:=false;
	ver:=false;
	readln();
	afficherNbrPoints2j(joueur1,joueur2);
	nbrcases:=0;
	readln();
	repeat
		ClrScr;
		d:=0;
		g:=0;
		h:=0;
		b:=0;
		ma2:=remplirmain(ma2,p);
		hor:=false;
		ver:=false;
		f2:=check(plateau,ma2,h,b,d,g,hor,ver,iaa);
		hor:=false;
		ver:=false;
		writeln('-------------------------------------------');
		writeln('-- ',joueur2.n,', c"est a vous de jouer :');
		readln();
		nbrcases:=0;
		affichage(plateau,d,g,h,b);
		writeln();
		affichermain(ma2);
		writeln();
		menu2(joueur2,ma2,plateau,p,joueur2.p,nbrcases,ta,hor,ver,iaa);
		afficherNbrPoints2j(joueur1,joueur2);
		nbrcases:=0;
		readln();
		hor:=false;
		ver:=false;
		f2:=check(plateau,ma2,h,b,d,g,hor,ver,iaa);
		hor:=false;
		ver:=false;
		readln();
		ClrScr;
		writeln('-------------------------------------------');
		writeln('-- ',joueur1.n,', c"est a vous de jouer :');
		readln();
		nbrcases:=0;
		affichage(plateau,d,g,h,b);
		writeln();
		affichermain(ma1);
		writeln();
		menu2(joueur1,ma1,plateau,p,joueur1.p,nbrcases,ta,hor,ver,iaa);
		afficherNbrPoints2j(joueur1,joueur2);
		ma1:=remplirmain(ma1,p);
		nbrcases:=0;
		hor:=false;
		ver:=false;
		f1:=check(plateau,ma1,h,b,d,g,hor,ver,iaa);
		hor:=false;
		ver:=false;
		readln();
	until ((p^.p=nil) or ((f1=false) and (f2=false))) or ((nbrpions(ma1)=0) and (nbrpions(ma2)=0)) ;
	clrscr;
	writeln('--------------------------------');
	writeln('---- FIN DE LA PARTIE ----');
	writeln('--------------------------------');
	writeln();
	writeln('Le gagnant est .............................');
	readln();
	writeln('------',gagnant2(joueur1.n,joueur2.n,joueur1.p,joueur2.p));
end;

{cette procedure fait le jeu à 4 joueurs}
procedure Init4j();
var ma1,ma2,ma3,ma4:main;f1,f2,f3,f4:boolean;nbrcases,d,g,h,b,x,error1:integer;plateau:tab;p:ptr_cases;joueur1,joueur2,joueur3,joueur4:joueur;premiex,premiey:integer;ta:tabcoord;userinput1:string;var hor,ver,iaa:boolean;
begin 
	hor:=false;
	ver:=false;
	iaa:=false;
	writeln('----------------------------------------------------------------------------------------------------------------------------------');
	writeln('-- Ensuite, entrez votre pseudo en tant que joueur, il faut savoir que le joueur 1 commence en premier... Hein faut le savoir : --');	
	writeln('----------------------------------------------------------------------------------------------------------------------------------');
	readln();
	clrscr;
	writeln('-- Pseudo joueur 1 :');
	repeat
		readln(joueur1.n);
	until joueur1.n<>'';
	writeln('-- Pseudo joueur 2 :');
	repeat
		readln(joueur2.n);
	until joueur2.n<>'';
	writeln('-- Pseudo joueur 3 :');
	repeat
		readln(joueur3.n);
	until joueur3.n<>'';
	writeln('-- Pseudo joueur 4 :');
	repeat
		readln(joueur4.n);
	until joueur4.n<>'';
	writeln('--------------');
	readln();
	ClrScr;
	writeln('------------------------------------------');
	writeln('-- Bien nous pouvons commencer a present, ');
	writeln('------------------------------------------');
	readln();
	ClrScr;
	nbrcases:=0;
	joueur1.p:=0;
	joueur2.p:=0;
	joueur3.p:=0;
	joueur4.p:=0;
	d:=0;
	g:=0;
	h:=0;
	b:=0;
	ma1:=initmain;
	ma2:=initmain;
	ma3:=initmain;
	ma4:=initmain;
	plateau:=initableau;
	p:=creerpioche;
	ma1:=remplirmain(ma1,p);
	premiex:=0;
	premiey:=0;
	writeln('------------------------------------------------');
	writeln('-- ',joueur1.n,', c"est a vous de commencer !!');
	readln();
	writeln('-- Pour commencer, veuillez choisir un pion de votre main qui sera placé au centre de la grille, (entez son numéro de case) :');
	writeln('---------------------------------------------------------------------------------------------------');
	writeln('-- Voici votre main : ');
	affichermain(ma1);
	writeln();
	repeat
		readln(userinput1);
		val(userinput1,x,error1);
	until (x<7) and (x>0) and (error1=0);
	plateau[0,0].cl:=ma1[x].cl;
	plateau[0,0].fm:=ma1[x].fm;
	ma1[x].cl:='.';
	ma1[x].fm:='.';
	nbrcases:=1;
	comptagedepoints(0,0,plateau,ta,nbrcases);
	writeln();
	affichage(plateau,d,g,h,b);
	menu(joueur1,ma1,plateau,p,joueur1.p,nbrcases,premiex,premiey,ta,hor,ver,iaa);
	if joueur1.p=0 then
		joueur1.p:=1;
	hor:=false;
	ver:=false;
	readln();
	afficherNbrPoints4j(joueur1,joueur2,joueur3,joueur4);
	readln();
	repeat
		ClrScr;
		d:=0;
		g:=0;
		h:=0;
		b:=0;
		ma2:=remplirmain(ma2,p);
		hor:=false;
		ver:=false;
		f2:=check(plateau,ma2,h,b,d,g,hor,ver,iaa);
		hor:=false;
		ver:=false;
		writeln('-------------------------------------------');
		writeln('-- ',joueur2.n,', c"est a vous de jouer :');
		readln();
		nbrcases:=0;
		affichage(plateau,d,g,h,b);
		writeln();
		affichermain(ma2);
		writeln();
		menu2(joueur2,ma2,plateau,p,joueur2.p,nbrcases,ta,hor,ver,iaa);
		hor:=false;
		ver:=false;
		afficherNbrPoints4j(joueur1,joueur2,joueur3,joueur4);
		readln();
		ClrScr;
		writeln('-------------------------------------------');
		writeln('-- ',joueur3.n,', c"est a vous de jouer :');
		readln();
		ma3:=remplirmain(ma3,p);
		nbrcases:=0;
		affichage(plateau,d,g,h,b);
		writeln();
		affichermain(ma3);
		writeln();
		hor:=false;
		ver:=false;
		menu2(joueur3,ma3,plateau,p,joueur3.p,nbrcases,ta,hor,ver,iaa);
		hor:=false;
		ver:=false;
		afficherNbrPoints4j(joueur1,joueur2,joueur3,joueur4);
		ma3:=remplirmain(ma3,p);
		hor:=false;
		ver:=false;
		f3:=check(plateau,ma3,h,b,d,g,hor,ver,iaa);
		hor:=false;
		ver:=false;
		readln();
		ClrScr;
		writeln('-------------------------------------------');
		writeln('-- ',joueur4.n,', c"est a vous de jouer :');
		readln();
		ma4:=remplirmain(ma4,p);
		nbrcases:=0;
		affichage(plateau,d,g,h,b);
		writeln();
		affichermain(ma4);
		writeln();
		hor:=false;
		ver:=false;
		menu2(joueur4,ma4,plateau,p,joueur4.p,nbrcases,ta,hor,ver,iaa);
		hor:=false;
		ver:=false;
		afficherNbrPoints4j(joueur1,joueur2,joueur3,joueur4);
		ma4:=remplirmain(ma4,p);
		hor:=false;
		ver:=false;
		f4:=check(plateau,ma4,h,b,d,g,hor,ver,iaa);
		hor:=false;
		ver:=false;
		readln();
		ClrScr;
		writeln('-------------------------------------------');
		writeln('-- ',joueur1.n,', c"est a vous de jouer :');
		readln();
		ma1:=remplirmain(ma1,p);
		nbrcases:=0;
		affichage(plateau,d,g,h,b);
		writeln();
		affichermain(ma1);
		writeln();
		hor:=false;
		ver:=false;
		menu2(joueur1,ma1,plateau,p,joueur1.p,nbrcases,ta,hor,ver,iaa);
		hor:=false;
		ver:=false;
		afficherNbrPoints4j(joueur1,joueur2,joueur3,joueur4);
		ma1:=remplirmain(ma1,p);
		hor:=false;
		ver:=false;
		f1:=check(plateau,ma1,h,b,d,g,hor,ver,iaa);
		hor:=false;
		ver:=false;
		readln();
	until ((p^.p=nil) or ((f1=false) and (f3=false) and (f4=false) and (f2=false))) or ((nbrpions(ma1)=0) and (nbrpions(ma2)=0) and (nbrpions(ma3)=0) and (nbrpions(ma4)=0)) ;
	clrscr;
	writeln('--------------------------------');
	writeln('---- FIN DE LA PARTIE ----');
	writeln('--------------------------------');
	writeln();
	writeln('Le gagnant est .............................');
	readln();
	writeln('------',gagnant4(joueur1.n,joueur2.n,joueur3.n,joueur4.n,joueur1.p,joueur2.p,joueur3.p,joueur4.p));
end;

{cette procedure fait combattre le joueur contre l'IA}
procedure InitIA();
var ma1,ma2:main;f1,f2:boolean;nbrcases,d,g,h,b,x,error1:integer;plateau:tab;p:ptr_cases;joueur1,joueur2:joueur;premiex,premiey:integer;ta:tabcoord;userinput1:string;var hor,ver,iaa:boolean;
begin
	hor:=false;
	ver:=false;
	iaa:=false;
	writeln('-------------------------------------------------------------');
	writeln('-- Ensuite, entrez votre pseudo en tant que joueur : --');	
	writeln('-------------------------------------------------------------');
	readln();
	clrscr;
	writeln('-- Votre pseudo  :');
	repeat
		readln(joueur1.n);
	until joueur1.n<>'';
	joueur2.n:='IA';
	writeln('--------------');
	readln();
	ClrScr;
	writeln('------------------------------------------');
	writeln('-- Bien nous pouvons commencer a present, ');
	writeln('------------------------------------------');
	readln();
	ClrScr;
	nbrcases:=0;
	joueur1.p:=0;
	joueur2.p:=0;
	d:=0;
	g:=0;
	h:=0;
	b:=0;
	ma1:=initmain;
	ma2:=initmain;
	plateau:=initableau;
	p:=creerpioche;
	ma1:=remplirmain(ma1,p);
	premiex:=0;
	premiey:=0;
	writeln('------------------------------------------------');
	writeln('-- ',joueur1.n,', c"est a vous de commencer !!');
	readln();
	writeln('-- Pour commencer, veuillez choisir un pion de votre main qui sera placé au centre de la grille, (entez son numéro de case) :');
	writeln('---------------------------------------------------------------------------------------------------');
	writeln('-- Voici votre main : ');
	affichermain(ma1);
	writeln();
	repeat
		readln(userinput1);
		val(userinput1,x,error1);
	until (x<7) and (x>0) and (error1=0);
	plateau[0,0].cl:=ma1[x].cl;
	plateau[0,0].fm:=ma1[x].fm;
	ma1[x].cl:='.';
	ma1[x].fm:='.';
	nbrcases:=1;
	comptagedepoints(0,0,plateau,ta,nbrcases);
	writeln();
	affichage(plateau,d,g,h,b);
	menu(joueur1,ma1,plateau,p,joueur1.p,nbrcases,premiex,premiey,ta,hor,ver,iaa);	
	if joueur1.p=0 then
		joueur1.p:=1;
	hor:=false;
	ver:=false;
	readln();
	afficherNbrPoints2j(joueur1,joueur2);
	nbrcases:=0;
	readln();
	repeat
		ClrScr;
		d:=0;
		g:=0;
		h:=0;
		b:=0;
		ma2:=remplirmain(ma2,p);
		hor:=false;
		ver:=false;
		f2:=check(plateau,ma2,h,b,d,g,hor,ver,iaa);
		hor:=false;
		ver:=false;
		nbrcases:=0;
		affichage(plateau,d,g,h,b);
		writeln();
		affichermain(ma2);
		writeln();
		readln();
		iaa:=true;
		jouerIA(joueur2,ma2,plateau,hor,ver,iaa,p);
		iaa:=false;
		affichermain(ma2);
		afficherNbrPoints2j(joueur1,joueur2);
		nbrcases:=0;
		readln();
		hor:=false;
		ver:=false;
		f2:=check(plateau,ma2,h,b,d,g,hor,ver,iaa);
		hor:=false;
		ver:=false;
		readln();
		ClrScr;
		writeln('-------------------------------------------');
		writeln('-- ',joueur1.n,', c"est a vous de jouer :');
		readln();
		nbrcases:=0;
		affichage(plateau,d,g,h,b);
		writeln();
		affichermain(ma1);
		writeln();
		menu2(joueur1,ma1,plateau,p,joueur1.p,nbrcases,ta,hor,ver,iaa);
		afficherNbrPoints2j(joueur1,joueur2);
		ma1:=remplirmain(ma1,p);
		nbrcases:=0;
		hor:=false;
		ver:=false;
		f1:=check(plateau,ma1,h,b,d,g,hor,ver,iaa);
		hor:=false;
		ver:=false;
		readln();
	until ((p^.p=nil) or ((f1=false) and (f2=false))) or ((nbrpions(ma1)=0) and (nbrpions(ma2)=0)) ;
	clrscr;
	writeln('--------------------------------');
	writeln('---- FIN DE LA PARTIE ----');
	writeln('--------------------------------');
	writeln();
	writeln('Le gagnant est .............................');
	readln();
	writeln('------',gagnant2(joueur1.n,joueur2.n,joueur1.p,joueur2.p));

end;

{cette procedure fait se battre 2 IA}
procedure InitIAvsIA();
var  ma1,ma2:main;f1,f2:boolean;d,g,h,b,x:integer;plateau:tab;p:ptr_cases;joueur1,joueur2:joueur;var hor,ver,iaa:boolean;
begin
	hor:=false;
	ver:=false;
	iaa:=true;
	clrscr;
	joueur1.n:='IA-1';
	joueur2.n:='IA-2';
	ClrScr;
	writeln('------------------------------------------');
	writeln('-- Bien nous pouvons commencer a present, ');
	writeln('------------------------------------------');
	writeln('-- Appuyez sur entrer pour lancer le match d"IA !!  --');
	readln();
	ClrScr;
	joueur1.p:=0;
	joueur2.p:=0;
	d:=0;
	g:=0;
	h:=0;
	b:=0;
	ma1:=initmain;
	ma2:=initmain;
	plateau:=initableau;
	p:=creerpioche;
	ma1:=remplirmain(ma1,p);
	writeln('La main de l"IA qui commence le jeu est la suivante :');
	affichermain(ma1);
	writeln();
	x:=random(5)+1;
	plateau[0,0].cl:=ma1[x].cl;
	plateau[0,0].fm:=ma1[x].fm;
	ma1[x].cl:='.';
	ma1[x].fm:='.';
	writeln('le plateau de jeu initialisé par l"IA est le suivant :');
	writeln();
	affichage(plateau,d,g,h,b);
	joueur1.p:=1;
	hor:=false;
	ver:=false;
	readln();
	afficherNbrPoints2j(joueur1,joueur2);
	readln();
	repeat
		ClrScr;
		d:=0;
		g:=0;
		h:=0;
		b:=0;
		writeln('L"IA-2 joue :');
		ma2:=remplirmain(ma2,p);
		hor:=false;
		ver:=false;
		f2:=check(plateau,ma2,h,b,d,g,hor,ver,iaa);
		hor:=false;
		ver:=false;
		affichage(plateau,d,g,h,b);
		writeln();
		affichermain(ma2);
		writeln();
		iaa:=true;
		jouerIA(joueur2,ma2,plateau,hor,ver,iaa,p);
		iaa:=false;
		affichermain(ma2);
		afficherNbrPoints2j(joueur1,joueur2);
		readln();
		hor:=false;
		ver:=false;
		f2:=check(plateau,ma2,h,b,d,g,hor,ver,iaa);
		hor:=false;
		ver:=false;
		readln();
		ClrScr;
		writeln('L"IA-1 joue :');
		ma1:=remplirmain(ma1,p);
		hor:=false;
		ver:=false;
		f1:=check(plateau,ma1,h,b,d,g,hor,ver,iaa);
		hor:=false;
		ver:=false;
		affichage(plateau,d,g,h,b);
		writeln();
		affichermain(ma1);
		writeln();
		iaa:=true;
		jouerIA(joueur1,ma1,plateau,hor,ver,iaa,p);
		iaa:=false;
		affichermain(ma1);
		afficherNbrPoints2j(joueur1,joueur2);
		readln();
		hor:=false;
		ver:=false;
		f1:=check(plateau,ma1,h,b,d,g,hor,ver,iaa);
		hor:=false;
		ver:=false;
		readln();
	until ((p^.p=nil) or ((f1=false) and (f2=false))) or ((nbrpions(ma1)=0) and (nbrpions(ma2)=0)) ;
	clrscr;
	writeln('--------------------------------');
	writeln('---- FIN DE LA PARTIE ----');
	writeln('--------------------------------');
	writeln();
	writeln('L"IA gagnante est .............................');
	readln();
	writeln('------',gagnant2(joueur1.n,joueur2.n,joueur1.p,joueur2.p));
end;

{la procedure qwirkle va lancer le jeu de QWIRKLE }
procedure qwirkle();
var nbrdejoueur,error2,choix:integer;input:string;
begin
	writeln('------------------------------------------');
	writeln('  Bienvenue dans le jeu de Qwirkle !!!!!!!!');
	writeln('------------------------------------------');
	readln();
	writeln();
	clrscr;
	writeln('---------------------------------------------------------------------------------------------------');
	writeln('---- Voulez-vous au choix : (1)jouer avec des amis, ou bien si vous êtes (malheureusement) seul (2)jouer contre l"IA, ou alors si vous êtes d"humeur à ne rien faire, (3) faire se battre des IA  ? : ');
	writeln('---------------------------------------------------------------------------------------------------');
	repeat
	writeln('              ','---- Veuillez entrer 1, 2 ou 3 : ----');
	readln(input);
	val(input,choix,error2);
	until ((choix=1) or (choix=2)or (choix=3)) and (error2=0);
	if choix=2 then
	begin	
		clrscr;
		InitIA;
	end
	else if choix=1 then
	begin
	clrscr;
	writeln('-----------------------------------------------------------------------------------');
	writeln('--  Dans un premier temps, vous devez specifier le nombre de joueurs present :  --');
	writeln('-------------------------------------------------------------------------------');
	readln();
	clrscr;
	writeln('--------------------------------------------------------');
	writeln('-- Veuillez enter ci-dessous le nombre correspondant  :');
	writeln('--------------------------------------------------------');
	repeat
	writeln('- Veuillez entrer 2 ou 4 :');
	readln(input);
	val(input,nbrdejoueur,error2);
	until ((nbrdejoueur=2) or (nbrdejoueur=4)) and (error2=0);
	writeln(); 
	if nbrdejoueur=2 then
		Init2j();
	if nbrdejoueur=4 then 
		Init4j();
	end
	else if choix=3 then
	begin
		clrscr;
		InitIAvsIA;
	end;
end;


BEGIN
	qwirkle;
END.
