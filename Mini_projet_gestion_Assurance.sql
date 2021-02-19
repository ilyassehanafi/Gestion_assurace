-- creation de la base de donnée : 
CREATE DATABASE gestionAssurance ;
-- Ajout de l'extension spatiale : POSTGIS
CREATE EXTENSION postgis;
-- creation des tables : 
CREATE TABLE proprietaire(
	id serial PRIMARY KEY,
	nom CHARACTER varying (30),
	prenom CHARACTER varying (30)
);
CREATE TABLE riviere(
	id serial PRIMARY KEY,
	nom CHARACTER varying (30),
	polyline geometry
);
CREATE TABLE parcelle(
	id serial PRIMARY KEY,
	type_agriculture CHARACTER varying (40),
	polygone geometry,
	remboursement_prix_unitaire double precision,
	id_proprietaire integer,
	id_riviere integer,
	CONSTRAINT fk_proprietaire
	FOREIGN KEY (id_proprietaire) REFERENCES proprietaire(id),
	CONSTRAINT fk_riviere
	FOREIGN KEY (id_riviere) REFERENCES riviere(id)
);

-- Requête d'insertion
insert into proprietaire (id, nom , prenom) 
values ('1', 'hanafi', 'ilyasse');

insert into proprietaire (id, nom , prenom) 
values ('2', 'test', 'test');

insert into proprietaire (id, nom , prenom) 
values ('3', 'geoinfo', 'geoinfo');

insert into public.riviere (id,nom,polyline) 
values ('1', 'oued oum rabie','LINESTRING(-78.6 3.2 , -69.7 -2.6 ,-60.1 -2.6 , -45.2 -18.1 , -27 -23.3 , -9.3 -37.8 , 8.4 -38.4 ,
		13.7 -38.2 , 29.3 -42.9 , 35.7 -47.4 , 42.7 -52.5 , 48.1 -56.1 , 85.8 -56.5)');

insert into parcelle (id,type_agriculture, polygone,id_proprietaire, id_riviere,remboursement_prix_unitaire) 
values (1, 'pomme de terre', 'POLYGON((-37.3 -15.2,-22.5 1.7,9.5 -20.7,-6.1 -35.4,-37.3 -15.2))' ,1,1,100);

insert into parcelle (id,type_agriculture, polygone,id_proprietaire, id_riviere,remboursement_prix_unitaire) 
values (2, 'tomate', 'POLYGON((3.7 -34.8,14.4 -23.3,63.6 -23.7,53 -45.5,3.7 -34.8))' ,2,1,150);

insert into parcelle (id,type_agriculture, polygone,id_proprietaire, id_riviere,remboursement_prix_unitaire) 
values (3, 'onion', 'POLYGON((34.2 -56.1,79 -71.9,66.8 -87.9,16.9 -70.8,34.2 -56.1))' ,3,1,200);

insert into parcelle (id,type_agriculture, polygone,id_proprietaire, remboursement_prix_unitaire) 
values (4, 'poivron', 'POLYGON((-12.3 -49.3,12.7 -58.5,-5.3 -78.3,-28.1 -63.2,-12.3 -49.3))' ,3,220);

insert into parcelle (id,type_agriculture, polygone,id_proprietaire, id_riviere,remboursement_prix_unitaire) 
values (5, 'maïs', 'POLYGON((-12.1 -39.7,-33.8 -59.7,-71.8 -63.2,-84 -46.5,-72.2 -8.8,-53.7 -13.9,-12.1 -39.7))' ,1,1,300);

-- visualiser le buffer :
select ST_BUFFER(polyline,10) as distance_debordement from public.riviere;  
-- visualiser les parcelles et la riviere : 
SELECT DISTINCT  ST_Union(polygone, ST_Buffer(polyline, 10)) AS UNION
FROM public.riviere FULL JOIN public.parcelle ON public.parcelle.id_riviere = public.riviere.id ;
-- visualiser l'intersection entre le buffer et les parcelle :
SELECT DISTINCT st_intersection(polygone, ST_Buffer(polyline, 10)) as intersection_parcelle_riviere
FROM public.riviere FULL JOIN public.parcelle ON public.parcelle.id_riviere = public.riviere.id ; 
-- calculer la surface de l'intersection des parcelles et buffer :
SELECT DISTINCT  ST_Area(st_intersection(polygone, ST_Buffer(polyline, 10))) as surface_endomagé
FROM public.riviere FULL JOIN public.parcelle ON public.parcelle.id_riviere = public.riviere.id ; 
-- calculer le prix de remboursement de chaque parcelle :
SELECT DISTINCT  ST_Area(st_intersection(polygone, ST_Buffer(polyline, 10))) * parcelle.remboursement_prix_unitaire AS montantDedomagement 
FROM public.riviere FULL JOIN public.parcelle ON public.parcelle.id_riviere = public.riviere.id ; 
-- requête rassemblant tout les requêtes precedente :
SELECT DISTINCT proprietaire.nom,
				proprietaire.prenom,
                parcelle.type_agriculture AS agriculture,
                parcelle.polygone AS parcelle,
	  			riviere.polyline AS riviere,
                ST_Union(polygone, ST_Buffer(polyline, 10)) AS UNION,
	  			st_intersection(polygone, ST_Buffer(polyline, 10)) as intersection_parcelle_riviere,
                ST_Area(st_intersection(polygone, ST_Buffer(polyline, 10))) AS surface_Endomagé,
	  parcelle.remboursement_prix_unitaire as remboursement_prix_unitaire,
ST_Area(st_intersection(polygone, ST_Buffer(polyline, 10))) * parcelle.remboursement_prix_unitaire AS REMBOURSEMENT 
FROM public.riviere,public.proprietaire,public.parcelle
where proprietaire.id = parcelle.id_proprietaire


