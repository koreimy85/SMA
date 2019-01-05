/**
 *  modele2
 *  Author: Groupe 2
 *  Description: 
 */
model modele2


global
{
/** Insert the global definitions, variables and actions here */

// Importation des fichiers
	file fichier_shapefile_cadre <- file("../includes/input/cadre.shp");
	file fichier_shapefile_champs <- file("../includes/input/champ.shp");
	file fichier_shapefile_zone_riz <- file("../includes/input/zoneplantation.shp");
	file fichier_shapefile_zone_abre <- file("../includes/input/arbre.shp");
	//file fichier_shapefile_zone_protection <- file("../includes/input/");
	geometry shape <- envelope(fichier_shapefile_cadre);
	init
	{
		int nb_riz <- 50;
		int nb_oiseaux <- 20;
		int nb_protecteur <- 4;
		create cadre from: fichier_shapefile_cadre;
		create champ from: fichier_shapefile_champs;
		create zone_riz from: fichier_shapefile_zone_riz;
		create zone_arbre from: fichier_shapefile_zone_abre;
		create riz number: nb_riz
		{
			location <- any_location_in(one_of(zone_riz));
		}

		create oiseaux number: nb_oiseaux
		{
			location <- any_location_in(one_of(zone_arbre));
		}

		create protecteur number: rnd(nb_protecteur)
		{
			location <- any_location_in(one_of(zone_riz));
		}

	}

}

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

species zone_riz
{
	rgb couleur_zone_riz <- # lightblue;
	aspect base
	{
		draw shape color: couleur_zone_riz;
	}

}

species zone_arbre
{
	rgb couleur_zone_arbre <- # blue;
	aspect base
	{
		draw shape color: couleur_zone_arbre;
	}

}
species arbre{
	
}

species riz
{
	rgb couleur_riz <- # green;
	float taille_riz <- rnd(5) + 1.0;
	aspect base
	{
		draw triangle(taille_riz) color: couleur_riz;
	}

}

species oiseaux skills: [moving]
{
	rgb couleur_oiseaux <- # yellow;
	float taille_oiseaux <- rnd(10) + 1.0;
	point le_target <- nil;
	float rayon_observation <- rnd(5) + 1.0;
	float quantite_resistance <- rnd(4) + 1.0;
	float quantite_max <- 7.0;
	float capacite_destruction <- rnd(1) + 1.0;
	zone_arbre nid<-nil;
	reflex se_deplacer
	{
		if (le_target = nil)
		{
			do wander;
		} else
		{
			do goto target: le_target;
		}

	}

	reflex trouver_riz
	{
		loop r over: riz
		{
			if ((self distance_to r) <= rayon_observation)
			{
				le_target <- point(r);
			}

		}

	}
	
	reflex manger when: quantite_resistance < quantite_max
	{
		write("QteR: " +quantite_resistance +", QteMax: " +quantite_max);
		write("position: " +location);
				if(location=le_target){
					quantite_resistance <- quantite_resistance + capacite_destruction;
				}
				
				
				if(quantite_resistance = quantite_max)
				{
					couleur_oiseaux<-#red;
					nid<-zone_arbre(any_location_in(one_of(zone_arbre)));
					quantite_resistance<-0.0;
				}
			}
			
			reflex courir when:nid!=nil{
				do goto target:nid;
				
			}
	
	
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
		draw sphere(taille_oiseaux) color: couleur_oiseaux;
	}

}

species protecteur
{
	rgb couleur_protecteur <- # red;
	float taille_protecteur <- rnd(7) + 1.0;
	aspect base
	{
		draw sphere(taille_protecteur) color: couleur_protecteur;
	}

}

experiment modele2 type: gui
{
/** Insert here the definition of the input and output of the model */
	output
	{
		display model2
		{
			species champ aspect: base;
			species zone_arbre aspect: base;
			species zone_riz aspect: base;
			species riz aspect: base;
			species oiseaux aspect: base;
			//species protecteur aspect: base;
		}

	}

}
