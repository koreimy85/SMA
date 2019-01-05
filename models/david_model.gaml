/**
 *  modele2
 *  Author: Groupe 2
 *  Description: 
 */
model modele2


global
{
/** Insert the global definitions, variables and actions here */
	//nombre de riz au lancement
	int nb_riz <- 100;
	//nommbre des oiseaux au lancement
	int nb_oiseaux <- 20;
	//nombre de protacteurs au lancement
	int nb_protecteur <- 7;
	// la hauteur des arbres
	int hauteur_arbre<-100;
		

// Importation des fichiers shapes files
	file fichier_shapefile_cadre <- file("../includes/input/cadre.shp");
	file fichier_shapefile_champs <- file("../includes/input/champ.shp");
	file fichier_shapefile_zone_riz <- file("../includes/input/zoneplantation.shp");
	file fichier_shapefile_zone_abre <- file("../includes/input/zoneArbre.shp");
	file fichier_shapefile_zone_protection <- file("../includes/input/zoneprotecteurs.shp");
	//l'environnement de simulation
	geometry shape <- envelope(fichier_shapefile_cadre);
	
	//initialisation
	init
	{
		//creation de l'agent cadre:environnement
		create cadre from: fichier_shapefile_cadre;
		//creation de l'agent champ
		create champ from: fichier_shapefile_champs;
		//creation de l'agent zone_riz
		create zone_riz from: fichier_shapefile_zone_riz;
		//creation de l'agent wone_arbre: la zone où les arbre seront plantés
		create zone_arbre from: fichier_shapefile_zone_abre;
		//creation de l'agent zone_protecteur: la zone où les protecteurs vont être fixer
		create zone_protecteur from: fichier_shapefile_zone_protection;
		//creation de l'agent 
		create riz number: nb_riz
		{
			location <- any_location_in(one_of(zone_riz));
		}

		loop i over:zone_arbre{
			create arbre number: 1
		{
			location <- any_location_in(i);
		}
		}
		
		//creation de l'agent oiseaux
		create oiseaux number: nb_oiseaux
		{
			location <- any_location_in(one_of(arbre ));
			location <- {location.x, location.y, rnd(90)};
			//location <- any_location_in(one_of(zone_arbre));
		}
		
		
		//creation de l'agent protecteur
		loop p over:zone_protecteur{
			create protecteur number: 1
		{
			location <- any_location_in(p);
			location <- {location.x, location.y, 30};
		}
		}

		

	}

}
// les species de differents

//species cadre
species cadre
{
}

species champ
{
	rgb couleur_champ <- # gray;
	aspect base
	{
		draw shape color: couleur_champ;
	}

}
//species zone_protecteur
species zone_protecteur
{
	rgb color_protecteur <- # blue;
	aspect base 
	{
		draw shape color: color_protecteur;
	}
}
//species zone riz
species zone_riz
{
	rgb couleur_zone_riz <- # lightblue;
	aspect base
	{
		draw shape color: couleur_zone_riz;
	}

}
//species zone_arbre
species zone_arbre
{
	rgb couleur_zone_arbre <- # blue;
	float arbre_elevation <-100.0;
	
	aspect base
	{
		draw shape color: couleur_zone_arbre depth:arbre_elevation;
	}

}
//species arbre
species arbre{
	int size<-200;
	file image<-image_file("../images/arbre.jpg");
	int arbre_elevation<-100;
	rgb couleur_arbre<-#green;
	
	aspect image{
		//draw image size:size rotate: 90::{0,1,0} depth:arbre_elevation;
		draw obj_file("../images/lowpolytree.obj") color: couleur_arbre size: size rotate: 180::{0,1,1};//rotate: cycle/rot::{0,1,0} ;
	}
	aspect base{
		draw triangle(size) depth:arbre_elevation;
	}
	
}
//species riz
species riz
{
	rgb couleur_riz <- # green;
	float taille_riz <- rnd(9) + 1.0;
	float taille_max_riz <- 15.0 ;
	float taille_prod <- 10.0 ;
	float vitesse_de_grandir <- rnd (0.1) + 0.1 ;
	float quantite_prod<-0.0;
	int nb_max_riz <- 100;
	float riz_elevation <- 20.0 ;
	file riz_image <- image_file("../images/tiz2.jpg");
	
	//fonction permet de grandir le riz
	reflex grandir when: taille_riz < taille_max_riz 
	{
		taille_riz <- taille_riz + vitesse_de_grandir ;
	}
	//fonction permet de multiplier le riz
	reflex multiplier when: nb_riz < nb_max_riz
	{
		create riz number: 1
		{
			//location <- any_location_in(one_of(zone_riz));
			location <- self.location + 5;
		}
	}
	//fonction permet de produire le riz
	reflex produire when: taille_riz >= taille_prod
	{
		quantite_prod<-rnd(20.0)+1;
		couleur_riz <- # yellow ;
	}
	
	aspect image
	{
		draw riz_image size:taille_riz rotate:45::{1,0,1} depth:riz_elevation;
	}
	
	aspect base
	{
		draw triangle(taille_riz) color: couleur_riz rotate: 180::{0,1,1} depth:riz_elevation;
	}

}
//species oiseaux
species oiseaux skills: [moving]
{
	rgb couleur_oiseaux <- # cadetblue;
	float taille_oiseaux <- rnd(10) + 1.0;
	point le_target <- nil;
	float rayon_observation <- rnd(5) + 1.0;
	float quantite_resistance <- rnd(4) + 1.0;
	float quantite_max <- 100.0;
	float capacite_destruction <- rnd(8) + 1.0;
	float vitesse_oiseaux <- 10.0;
	//point apresM <- {50,100};
	bool retour_au_nid <- false;
	float oiseaux_elevation <- 10.0 ;
	
	zone_arbre nid<-nil;
	
	//fonction permet de deplacer les oiseaux
	reflex se_deplacer
	{
		if ((le_target = nil) and (quantite_resistance < quantite_max))
		{
			do wander amplitude: 180 speed: vitesse_oiseaux;
			if(location.z>0 and !retour_au_nid){
				location<-{location.x,location.y,location.z-rnd(0.8)};
			}
		}
		else
		{
			do goto target: le_target;
		}
		if(retour_au_nid and location.z<90){
				location<-{location.x,location.y,location.z+rnd(1)};
			}
		
	}
	//fonction permet aux oiseaux de se deplacer vers le riz
	reflex aller_manger_riz
	{
		if((quantite_resistance < quantite_max))
		{
			loop r over: riz
			{
				if ((self distance_to r) <= rayon_observation)
				{
					le_target <- point(r);
				}
				
				if ((self distance_to r) <= 0 and r.quantite_prod>0)
				{
					
					
					quantite_resistance <- quantite_resistance + capacite_destruction;
					r.quantite_prod<-r.quantite_prod-capacite_destruction; //aprés les remarques
					
				}
	
			}	
		}
		
//		if(quantite_resistance >= quantite_max)
//		{
//			if(quantite_resistance = quantite_max)
//				{
//					couleur_oiseaux<-#red;
//					//le_target <- apresM;
//					le_target <- any_location_in(one_of(zone_arbre));
//					//quantite_resistance<-0.0;
//				}
//		}
			
	}
	//action permet aux oiseaux de quitter les riz
	action quitter_riz
	{
		if(not retour_au_nid )
		{
			couleur_oiseaux<- # beige;
			le_target <- point(one_of(zone_arbre));
			le_target<-{le_target.x,le_target.y,rnd(90)};
			retour_au_nid <- true ;
		}
		//else{
			//le_target<-nil;
		//}
	}
	
	/*reflex quitter_riz {
		if(not retour_au_nid and quantite_resistance=quantite_max){
			//do wander amplitude: 180 speed: vitesse_oiseaux;
			le_target<-{le_target.x,le_target.y,rnd(90)};
			couleur_oiseaux<-#red;
			do goto target:le_target;
		}
	}*/
	//fonction permet de mourir 
	reflex mourrir when: quantite_resistance = 0
	{
		do die;
	}
	
	reflex quitter_nid
	{
		if(retour_au_nid and quantite_resistance <= 0)
		{
			couleur_oiseaux<- # cadetblue;
			le_target <- nil;
			//le_target<-{le_target.x,le_target.y,rnd(90)};
			retour_au_nid <- true ;
		}
		else{
			//le_target<-nil;
		}
	}
	
//	reflex manger when: quantite_resistance < quantite_max
//	{
//		write("QteR: " +quantite_resistance +", QteMax: " +quantite_max);
//		write("position: " +location);
//				if(location=le_target){
//					quantite_resistance <- quantite_resistance + capacite_destruction;
//				}
//				
//				
//				if(quantite_resistance = quantite_max)
//				{
//					couleur_oiseaux<-#red;
//					nid<-zone_arbre(any_location_in(one_of(zone_arbre)));
//					quantite_resistance<-0.0;
//				}
//			}
//			
//			reflex courir when:nid!=nil{
//				do goto target:nid;
//				
//			}
	
	
//	reflex quitter_riz
//	{
//		if (quantite_resistance = quantite_max)
//			{
//				//do wander;
//				le_target<-nil;
//				couleur_oiseaux<-#red;
//			}
//	}

	aspect base
	{
		draw sphere(taille_oiseaux) color: couleur_oiseaux depth:oiseaux_elevation;
	}

}

//species protecteur
species protecteur
{
	rgb couleur_protecteur <- # black;
	float taille_protecteur <- 30.0;
	oiseaux oiseau ;
	int count <- 0 ;
	bool alarme_active <- false;
	float rayon_couverture <- 50.0 ;
	list<oiseaux> mes_oiseaux ;
	
	//fonction permet aux protecteurs de chasser les oiseaux
	reflex chasser_oiseaux
	{
		count <- count + 1 ;
		if(alarme_active)
		{
			couleur_protecteur <- # red ;
			
			loop o over: oiseaux
			{
				if(self distance_to o <= rayon_couverture)
				{
					add o to: mes_oiseaux;
				}
			}
			
			ask mes_oiseaux
			{
				do quitter_riz;
			}
		}
	}
	
	//fonction permet aux protecteurs d'activer alarme
	reflex alarme when: (count > 5 and count <= 15)
	{
		alarme_active <- true ;
		count <- 0 ;
		couleur_protecteur <- # black ;
	} 
	
	aspect base
	{
		draw square(taille_protecteur) rotate:120::{1,1,1} color: couleur_protecteur;
	}

}

experiment modele2 type: gui
{
/** Insert here the definition of the input and output of the model */

//parametres
parameter "Initial number of riz: " var: nb_riz min: 100 max: 1000 category: "Riz" ;
parameter "Initial number of oiseaux: " var: nb_oiseaux min: 20 max: 100 category: "oiseaux" ;
	output
	{
		display model2 type: opengl //z_fighting:false
		{
			
			species champ aspect: base;
			//species zone_arbre aspect: base;
			species arbre aspect: image;
			species zone_riz aspect: base;
			species riz aspect: image;
			//species zone_protecteur aspect: base;
			//species riz aspect: image;
			species oiseaux aspect: base;
			species protecteur aspect: base;
		}
		display informations_de_la_protection refresh: every(5#cycles) {
			chart "chasse des oiseaux" type: series size: {1,0.5} position: {0, 0} {
				data "oiseaux non chassés" value: oiseaux count ((each.couleur_oiseaux=#beige)) color:#blue;
				data "oiseaux chassés" value: oiseaux count ((each.couleur_oiseaux=#cadetblue and not each.retour_au_nid)) color:#green;
			}
		chart "quantite du riz" type: histogram background: #lightgray size: {0.5,0.5} position: {0, 0.5} {
				data "les riz completement detruits" value: riz count ((each.quantite_prod <= 0) and (each.taille_riz>=each.taille_prod)) color:#blue;
				data "les riz détruits à moitiers" value: riz count ((each.quantite_prod >0) and (each.quantite_prod <20)) color:#yellow;
				data "les riz proteges" value: riz count ( (each.quantite_prod >=20)) color:#red;
				//data "]0.75;1]" value: prey count (each.energy > 5) color:#blue;
			}
	
		}

	}

}
