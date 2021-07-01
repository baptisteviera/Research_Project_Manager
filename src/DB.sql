DROP TABLE IF EXISTS employecontact, financeurs,organisme, appelprojet, ville, region, pays, laboratoire, entreprise, membrescomitepersonne, membreslaboratoire, propositionprojet, lignesbudgetaires, membresprojet, projet, depenses, label, cree, estredigeepar  CASCADE ;


CREATE TYPE typesfinancement AS ENUM ( 'fonctionnement','materiel');



CREATE TABLE employecontact (
	id integer PRIMARY KEY,
	titre VARCHAR not null,
	mail VARCHAR UNIQUE NOT NULL CHECK (mail LIKE '%@%.%'),
	telephone INTEGER UNIQUE NOT NULL
	);


CREATE TABLE financeurs (
	id integer primary key,
	datedebut date not null,
	datefin date not null,
	idemployecontact integer  REFERENCES  employecontact(id) not null
);

	

CREATE TABLE organisme (
	nom VARCHAR PRIMARY KEY,
	datecreation date NOT NULL,
	datedisparition date CHECK(datecreation<datedisparition)
);

create table appelprojet (
	id integer primary key,
	datelancement date not null,
	datefin date not null check(datelancement<datefin),
	theme varchar not null,
	description varchar not null,
	idorganisme varchar references organisme(nom) not null

); 

create table membrescomitepersonne (
	id integer not null,
	idappelprojet integer references appelprojet(id) not null,
	primary key(id,idappelprojet),
	nom varchar unique not null,
	mail varchar unique not null

);


create table ville (
	idfinanceur integer primary key references financeurs(id),
	nom varchar not null unique
);

create table region (
	idfinanceur integer primary key references financeurs(id),
	nom varchar not null unique
);

create table entreprise (
	idfinanceur integer primary key references financeurs(id),
	nom varchar not null unique
);

create table pays (
	idfinanceur integer primary key references financeurs(id) ,
	nom varchar not null unique
);

create table laboratoire (
	idfinanceur integer primary key references financeurs(id) ,
	nom varchar not null unique
);

create table membreslaboratoire (
	id integer not null,
	idlaboratoire integer references laboratoire(idfinanceur) not null,
	quotitetempsrecherche integer ,
	etablissement varchar ,
	datedebutthese date ,
	datefinthese date,
	sujetthese varchar,
	domainespecialite varchar,
	type varchar check(type in ('enseignantchercheur','doctorant', 'ingenieurderecherche')),
	check((quotitetempsrecherche is not null and etablissement is not null and datedebutthese is null and datefinthese is null and sujetthese is null and domainespecialite is null and type='enseignantchercheur')
	or(quotitetempsrecherche is null and etablissement is null and datedebutthese is not null and (datefinthese is null or datefinthese is not null) and sujetthese is not null and domainespecialite is null and type='doctorant')
	or(quotitetempsrecherche is  null and etablissement is null and datedebutthese is null and datefinthese is null and sujetthese is null and domainespecialite is not null and type='ingenieurderecherche')),
	primary key(id,idlaboratoire)
);


create table propositionprojet(
	id integer primary key,
	budget integer not null,
	datedeposition date not null,
	datereponse date,
	reponse varchar check(reponse in ('refus','acceptation',null)),
	idappelprojet integer references appelprojet(id) not null
);

create table lignesbudgetaires(
	montant integer not null,
	objetglobal varchar not null,
	typefinancement typesfinancement not null,
	idpropositionprojet integer not null,
	foreign key(idpropositionprojet) references propositionprojet(id) ,	
	primary key(montant,objetglobal,typefinancement,idpropositionprojet)
);

create table projet (
	id integer primary key,
	datedebut date not null,
	datefin date not null,
	budget integer not null,
	idpropositionprojet integer not null,
	foreign key(idpropositionprojet) references propositionprojet(id) 

);

create table membresprojet(
	id integer not null,
	idprojet integer references projet(id),
	primary key(id,idprojet),
	nom varchar not null,
	fonction varchar not null,
	mail varchar unique not null CHECK (mail LIKE '%@%.%'),
	idmembrelaboratoire integer,
	idlaboratoire integer,
	foreign key (idmembrelaboratoire,idlaboratoire) references membreslaboratoire(id,idlaboratoire),
	idfinanceurexterne integer references financeurs(id),
	type varchar check(type in ('membresinternes','membresexternes')),
	check((idmembrelaboratoire is not null and idlaboratoire is not null and idfinanceurexterne is null and type='membresinternes')
	or(idmembrelaboratoire is null and idlaboratoire is null and idfinanceurexterne is not null and type='membresexternes'))
);


create table depenses (
	id integer primary key,
	montant integer not null,
	typefinancement typesfinancement not null,
	daterealisation date not null,
	iddemandemembreprojet integer not null,
	iddemandeprojet integer not null,
	idvalidemembreprojet integer not null,
	idvalideprojet integer not null,
	foreign key (iddemandemembreprojet,iddemandeprojet) references membresprojet(id,idprojet),
	foreign key (idvalidemembreprojet,idvalideprojet) references membresprojet(id,idprojet),

	check((idDemandeMembreProjet!=idValideMembreProjet) and (idDemandeProjet=idValideProjet))
	
);

create table label (
	idpropositionprojet integer not null,
	foreign key(idpropositionprojet) references propositionprojet(id),
	idfinanceur integer references financeurs(id),
	nom varchar not null,
	primary key (idpropositionprojet,idfinanceur,nom)
);


create table cree (
	idfinanceur integer references financeurs(id) not null,
	nom varchar references organisme(nom) not null,
	primary key(idfinanceur,nom)
);


create table estredigeepar (
	idpropositionprojet integer not null,
	foreign key(idpropositionprojet) references propositionprojet(id),
	idmembrelaboratoire integer not null,
	idlaboratoire integer not null,
	foreign key (idmembrelaboratoire,idlaboratoire) references membreslaboratoire(id,idlaboratoire),
	primary key(idpropositionprojet,idlaboratoire,idmembrelaboratoire)
);


/*Creation de users et gestion des droits

CREATE USER membreslaboratoire;
CREATE USER financeurs;
CREATE USER membresprojet;
CREATE USER organisme;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE employecontact, organisme, ville, region, pays, laboratoire, entreprise, label, cree TO financeurs;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE appelprojet, membrescomitepersonne TO organisme; 

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE lignesbudgetaires, membresprojet, estredigeepar TO membreslaboratoire; 

GRANT SELECT ON TABLE employecontact, financeurs,organisme, appelprojet, ville, region, pays, laboratoire, entreprise
, membrescomitepersonne, membreslaboratoire, propositionprojet,lignesbudgetaires, membresprojet, projet, depenses, label, cree, estredigeepar TO membreslaboratoire; 

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE depenses,projet TO membresprojet;

*/

/*Afficher les appels d'offre en cours non répondus*/
create view appel_offre_non_repondues_en_cours as select appelprojet.id from appelprojet left outer join propositionprojet on appelprojet.id=propositionprojet.idappelprojet where propositionprojet.idappelprojet is null and appelprojet.datefin > CURRENT_DATE;


/*Afficher les porjet en cours*/

create view projet_en_cours as select id from projet where datedebut <= current_date and datefin > current_date;

/*Afficher la somme d'argent dépensée par projet ordonné par numero de projet*/
create view somme_argent_depense_projet as select projet.id, SUM(depenses.montant) from depenses inner join projet on depenses.idvalideprojet=projet.id group by projet.id order by projet.id;


/*Afficher les projets pour lesquels il reste du budget et afficher leur budget restant ordonne par numero de projet */
create view somme_argent_restant_depense_projet as select projet.id, (projet.budget-SUM(depenses.montant)) from depenses inner join projet 
on depenses.idvalideprojet=projet.id 
group by projet.id having (projet.budget-SUM(depenses.montant)) > 0 order by projet.id;

/*Afficher le nombre de propositions repondues par type d'organisme*/
create view propositions_repondues as select  appelprojet.idorganisme, count(datereponse) as nb_proposition_repondue
from propositionprojet inner join appelprojet on
propositionprojet.idappelprojet=appelprojet.id 
where datereponse is not null group by appelprojet.idorganisme;

/*Afficher le nombre de projets acceptés par type d'organisme*/
create view proposition_acceptee as select  appelprojet.idorganisme, count(propositionprojet.reponse) as nb_proposition_acceptee
from propositionprojet inner join appelprojet on
propositionprojet.idappelprojet=appelprojet.id 
where propositionprojet.reponse = 'acceptation' group by appelprojet;

/*Afficher le nombre de propositions répondues par type d'organisme projet avec le nombre de projet accepté*/
create view nb_propositionsrepondues_par_organisme_avec_nb_projet_accepte as select propositions_repondues.idorganisme, propositions_repondues.nb_proposition_repondue, 
proposition_acceptee.nb_proposition_acceptee as nb_projet_accepte from propositions_repondues 
inner join proposition_acceptee on proposition_acceptee.idorganisme=propositions_repondues.idorganisme;

/*Afficher le total des dépenses effectueés  de chaque mois de chaque année*/
create view depenses_par_mois_annee as select DATE_PART('month', depenses.daterealisation) as mois, 
DATE_PART ('year', depenses.daterealisation) as annee, SUM(depenses.montant) as depensestotales
from depenses group by mois, annee order by depensestotales ;

/*Afficher le mois de l'année où on fait le plus de dépenses de projets*/
create view mois_annee_max_depense as select mois, annee from depenses_par_mois_annee
WHERE  depensestotales = (SELECT max(depensestotales) FROM depenses_par_mois_annee);

/*Afficher le mois de l'année où on fait le plus de dépenses de projets avec la valeur de la dépense */
create view mois_annee_avec_max_depense as select mois_annee_max_depense.mois,mois_annee_max_depense.annee, depenses_par_mois_annee.depensestotales
from mois_annee_max_depense inner join depenses_par_mois_annee on 
(depenses_par_mois_annee.mois = mois_annee_max_depense.mois and depenses_par_mois_annee.annee = mois_annee_max_depense.annee);

/*Vérification qu'une date de deposition se situe entre la date de lancement et la date de fin d'un appel à projet (la requête suivante ne renvoie rien si OK)*/
create view vdatedeposition select * from appelprojet inner join propositionprojet on
appelprojet.id=propositionprojet.idappelprojet
where propositionprojet.datedeposition < appelprojet.datelancement or propositionprojet.datedeposition > appelprojet.datefin;

/*Vérification que la somme des lignes budgétaires correspond bien au budget global de la proposition de projet (la requete ne doit rien renvoyer*/
create vbudget as select propositionprojet.id, SUM(LignesBudgetaires.montant) as budget from propositionprojet inner join LignesBudgetaires 
on propositionprojet.id=LignesBudgetaires.idpropositionprojet
where budget!=propositionprojet.budget group by propositionprojet.id order by propositionprojet.id;

/* INSERT */

insert into employecontact (id, titre, mail, telephone) values (1, 'Paralegal', 'ekubiczek0@comsenz.com', 0630303030);
insert into employecontact (id, titre, mail, telephone) values (2, 'Human Resources Manager', 'vizaac1@example.com', 0630743030);
insert into employecontact (id, titre, mail, telephone) values (3, 'Electrical Engineer', 'mbartos2@businessweek.com',0630309130);
insert into employecontact (id, titre, mail, telephone) values (4, 'Registered Nurse', 'lbaumadier3@webmd.com', 0619303030);
insert into employecontact (id, titre, mail, telephone) values (5, 'Biostatistician III', 'lpury4@taobao.com', 0630593030);
insert into employecontact (id, titre, mail, telephone) values (6, 'Recruiting Manager', 'salibone5@cbslocal.com', 0630307630);
insert into employecontact (id, titre, mail, telephone) values (7, 'Assistant Media Planner', 'cduran6@craigslist.org', 0630237630);


insert into financeurs (id, datedebut, datefin, idemployecontact) values (1, '2018-02-04', '2021-10-15', 2);
insert into financeurs (id, datedebut, datefin, idemployecontact) values (2, '2018-11-30', '2021-07-17', 1);
insert into financeurs (id, datedebut, datefin, idemployecontact) values (3, '2019-03-02', '2021-10-23', 6);
insert into financeurs (id, datedebut, datefin, idemployecontact) values (4, '2018-09-20', '2022-09-24', 4);
insert into financeurs (id, datedebut, datefin, idemployecontact) values (5, '2019-01-04', '2021-12-12', 5);
insert into financeurs (id, datedebut, datefin, idemployecontact) values (6, '2019-01-06', '2022-08-30', 3);


insert into organisme (nom, datecreation, datedisparition) values ('Reilly LLC', '2020-03-07', '2020-10-31');
insert into organisme (nom, datecreation, datedisparition) values ('HaagKihn', '2020-01-04',null);
insert into organisme (nom, datecreation, datedisparition) values ('Kovacek-Russel', '2020-03-19', '2020-08-20');
insert into organisme (nom, datecreation, datedisparition) values ('Runte-Schroeder', '2020-02-24', null);
insert into organisme (nom, datecreation, datedisparition) values ('Bahringer, Goyette and Kunze', '2019-12-11', '2021-01-19');
insert into organisme (nom, datecreation, datedisparition) values ('Dietrich Inc', '2019-12-05', '2021-04-02');
insert into organisme (nom, datecreation, datedisparition) values ('Huels LLC', '2019-12-29', null);


insert into appelprojet (id, datelancement, datefin, theme, description, idorganisme) values (1, '2020-01-28', '2020-07-04', 'Accounting', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 'Dietrich Inc');
insert into appelprojet (id, datelancement, datefin, theme, description, idorganisme) values (2, '2020-04-30', '2020-08-16', 'Training', 'Fusce consequat. Nulla nisl. Nunc nisl.', 'HaagKihn');
insert into appelprojet (id, datelancement, datefin, theme, description, idorganisme) values (3, '2020-05-25', '2020-08-13', 'Services', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', 'Reilly LLC');
insert into appelprojet (id, datelancement, datefin, theme, description, idorganisme) values (4, '2020-03-22', '2020-07-07', 'Human Resources', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', 'Runte-Schroeder');
insert into appelprojet (id, datelancement, datefin, theme, description, idorganisme) values (5, '2020-03-14', '2020-07-02', 'Marketing', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', 'Bahringer, Goyette and Kunze');
insert into appelprojet (id, datelancement, datefin, theme, description, idorganisme) values (6, '2020-04-23', '2020-07-19', 'Research and Development', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', 'Dietrich Inc');
insert into appelprojet (id, datelancement, datefin, theme, description, idorganisme) values (7, '2020-02-03', '2020-08-04', 'Support', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', 'HaagKihn');


insert into membrescomitepersonne (id, idappelprojet, nom, mail) values (1, 1, 'Allingham', 'jallingham0@youku.com');
insert into membrescomitepersonne (id, idappelprojet, nom, mail) values (2, 1, 'Kerr', 'wkerr1@e-recht24.de');
insert into membrescomitepersonne (id, idappelprojet, nom, mail) values (1, 2, 'Flahy', 'nflahy2@wikispaces.com');
insert into membrescomitepersonne (id, idappelprojet, nom, mail) values (2, 2, 'Enoksson', 'aenoksson3@pen.io');
insert into membrescomitepersonne (id, idappelprojet, nom, mail) values (1, 3, 'Gisbourn', 'dgisbourn4@usnews.com');
insert into membrescomitepersonne (id, idappelprojet, nom, mail) values (1, 4, 'Mayte', 'kmayte5@spotify.com');
insert into membrescomitepersonne (id, idappelprojet, nom, mail) values (2, 4, 'MacIlraith', 'amacilraith6@wikimedia.org');
insert into membrescomitepersonne (id, idappelprojet, nom, mail) values (1, 5, 'McGuiney', 'emcguiney7@people.com.cn');
insert into membrescomitepersonne (id, idappelprojet, nom, mail) values (2, 5, 'Cain', 'scain8@zdnet.com');
insert into membrescomitepersonne (id, idappelprojet, nom, mail) values (3, 5, 'Northgraves', 'cnorthgraves9@livejournal.com');
insert into membrescomitepersonne (id, idappelprojet, nom, mail) values (1, 6, 'Berntsson', 'aberntssona@amazon.com');
insert into membrescomitepersonne (id, idappelprojet, nom, mail) values (2, 6, 'Coleford', 'ccolefordb@mail.ru');
insert into membrescomitepersonne (id, idappelprojet, nom, mail) values (1, 7, 'Petracchi', 'mpetracchic@skype.com');
insert into membrescomitepersonne (id, idappelprojet, nom, mail) values (2, 7, 'Purry', 'epurryd@ox.ac.uk');


insert into laboratoire (idfinanceur, nom) values (1, 'Klein Inc');
insert into laboratoire (idfinanceur, nom) values (2, 'VonRueden-Daniel');


insert into membreslaboratoire (id, idlaboratoire, quotitetempsrecherche, etablissement, datedebutthese, datefinthese, sujetthese, domainespecialite, type) values (1, 1, 80, 'Institute of Teachers Education', null, null, null, null, 'enseignantchercheur');
insert into membreslaboratoire (id, idlaboratoire, quotitetempsrecherche, etablissement, datedebutthese, datefinthese, sujetthese, domainespecialite, type) values (2, 1, 55, 'Mount Saint Vincent University', null, null, null, null, 'enseignantchercheur');
insert into membreslaboratoire (id, idlaboratoire, quotitetempsrecherche, etablissement, datedebutthese, datefinthese, sujetthese, domainespecialite, type) values (3, 1, 76, 'Universidad Dr. Rafael Belloso Chacín', null, null, null, null, 'enseignantchercheur');
insert into membreslaboratoire (id, idlaboratoire, quotitetempsrecherche, etablissement, datedebutthese, datefinthese, sujetthese, domainespecialite, type) values (4, 1, null, null, '2019-02-18', '2022-10-18', 'jQuery', null,'doctorant');
insert into membreslaboratoire (id, idlaboratoire, quotitetempsrecherche, etablissement, datedebutthese, datefinthese, sujetthese, domainespecialite, type) values (5, 1, null, null, '2019-05-16', '2022-11-23', 'Cross Functional Team Building', null,'doctorant');
insert into membreslaboratoire (id, idlaboratoire, quotitetempsrecherche, etablissement, datedebutthese, datefinthese, sujetthese, domainespecialite, type) values (6, 1, null, null, '2020-05-05', NULL, 'Psychodynamic Psychotherapy', null,'doctorant');
insert into membreslaboratoire (id, idlaboratoire, quotitetempsrecherche, etablissement, datedebutthese, datefinthese, sujetthese, domainespecialite, type) values (7, 1, null, null, null, null, null, 'Marketing', 'ingenieurderecherche');
insert into membreslaboratoire (id, idlaboratoire, quotitetempsrecherche, etablissement, datedebutthese, datefinthese, sujetthese, domainespecialite, type) values (8, 1, null, null, null, null, null, 'Support', 'ingenieurderecherche');
insert into membreslaboratoire (id, idlaboratoire, quotitetempsrecherche, etablissement, datedebutthese, datefinthese, sujetthese, domainespecialite, type) values (9, 1, null, null, null, null, null, 'Research and Development', 'ingenieurderecherche');
insert into membreslaboratoire (id, idlaboratoire, quotitetempsrecherche, etablissement, datedebutthese, datefinthese, sujetthese, domainespecialite, type) values (1, 2, 135, 'University of Salford', null, null, null, null, 'enseignantchercheur');
insert into membreslaboratoire (id, idlaboratoire, quotitetempsrecherche, etablissement, datedebutthese, datefinthese, sujetthese, domainespecialite, type) values (2, 2, 173, 'University of South Carolina - Aiken', null, null, null, null, 'enseignantchercheur');
insert into membreslaboratoire (id, idlaboratoire, quotitetempsrecherche, etablissement, datedebutthese, datefinthese, sujetthese, domainespecialite, type) values (3, 2, null, null, '2019-01-05', '2023-05-17', 'Avaya AES', null,'doctorant');
insert into membreslaboratoire (id, idlaboratoire, quotitetempsrecherche, etablissement, datedebutthese, datefinthese, sujetthese, domainespecialite, type) values (4, 2, null, null, '2020-03-28', NULL, 'Retail', null,'doctorant');
insert into membreslaboratoire (id, idlaboratoire, quotitetempsrecherche, etablissement, datedebutthese, datefinthese, sujetthese, domainespecialite, type) values (5, 2, null, null, null, null, null, 'Human Resources', 'ingenieurderecherche');
insert into membreslaboratoire (id, idlaboratoire, quotitetempsrecherche, etablissement, datedebutthese, datefinthese, sujetthese, domainespecialite, type) values (6, 2, null, null, null, null, null, 'Accounting', 'ingenieurderecherche');



insert into propositionprojet (id, budget, datedeposition , datereponse , reponse , idappelprojet ) values (1, 82454, '2020-02-07', '2020-04-11', 'acceptation', 1);
insert into propositionprojet (id, budget, datedeposition , datereponse , reponse , idappelprojet ) values (4, 86690, '2020-03-07', '2020-03-25', 'refus', 1);
insert into propositionprojet (id, budget, datedeposition , datereponse , reponse , idappelprojet ) values (5, 77426, '2020-05-23', '2020-06-07', 'acceptation', 6);
insert into propositionprojet (id, budget, datedeposition , datereponse , reponse , idappelprojet ) values (3, 64934, '2020-05-20', '2020-06-05', 'refus', 2);
insert into propositionprojet (id, budget, datedeposition , datereponse , reponse , idappelprojet ) values (6, 61952, '2020-04-11', '2020-05-28', 'acceptation', 7);
insert into propositionprojet (id, budget, datedeposition , datereponse , reponse , idappelprojet ) values (2, 52591, '2020-06-06', NULL, NULL, 3);

insert into lignesbudgetaires (montant , objetglobal , typefinancement , idpropositionprojet ) values (80000, 'nunc', 'fonctionnement', 1);
insert into lignesbudgetaires (montant , objetglobal , typefinancement , idpropositionprojet ) values (2454, 'tempus', 'materiel', 1);
insert into lignesbudgetaires (montant , objetglobal , typefinancement , idpropositionprojet ) values (43345, 'in', 'fonctionnement', 4);
insert into lignesbudgetaires (montant , objetglobal , typefinancement , idpropositionprojet ) values (43345, 'leo', 'materiel', 4);
insert into lignesbudgetaires (montant , objetglobal , typefinancement , idpropositionprojet ) values (70000, 'etiam', 'fonctionnement', 5);
insert into lignesbudgetaires (montant , objetglobal , typefinancement , idpropositionprojet ) values (7426, 'arcu', 'materiel', 5);
insert into lignesbudgetaires (montant , objetglobal , typefinancement , idpropositionprojet ) values (60000, 'in', 'fonctionnement', 3);
insert into lignesbudgetaires (montant , objetglobal , typefinancement , idpropositionprojet ) values (4934, 'cum', 'materiel', 3);
insert into lignesbudgetaires (montant , objetglobal , typefinancement , idpropositionprojet ) values (60000, 'nullam', 'fonctionnement', 6);
insert into lignesbudgetaires (montant , objetglobal , typefinancement , idpropositionprojet ) values (1952, 'fermentum', 'materiel', 6);
insert into lignesbudgetaires (montant , objetglobal , typefinancement , idpropositionprojet ) values (2591, 'mattis', 'fonctionnement', 2);
insert into lignesbudgetaires (montant , objetglobal , typefinancement , idpropositionprojet ) values (50000, 'elit', 'materiel', 2);


insert into projet  (id , datedebut, datefin , budget , idpropositionprojet ) values (1, '2020-05-07', '2021-04-25', 82454, 1);
insert into projet  (id , datedebut, datefin , budget , idpropositionprojet ) values (2, '2020-03-09', '2021-09-03', 77426, 5);
insert into projet  (id , datedebut, datefin , budget , idpropositionprojet ) values (3, '2020-04-03', '2021-08-24', 61952, 6);

insert into membresprojet (id , idprojet , nom , fonction , mail, idmembrelaboratoire , idlaboratoire , idfinanceurexterne , type ) values (1, 1, 'Mantram', 'Editor', 'vmantram0@earthlink.net', 1, 1, null, 'membresinternes');
insert into membresprojet (id , idprojet , nom , fonction , mail, idmembrelaboratoire , idlaboratoire , idfinanceurexterne , type ) values (2, 1, 'Llewelly', 'Executive Secretary', 'ellewelly1@vimeo.com', 2, 1, NULL, 'membresinternes');
insert into membresprojet (id , idprojet , nom , fonction , mail, idmembrelaboratoire , idlaboratoire , idfinanceurexterne , type ) values (3, 1, 'Latimer', 'Environmental Specialist', 'slatimer2@china.com.cn',NULL , NULL, 3, 'membresexternes');
insert into membresprojet (id , idprojet , nom , fonction , mail, idmembrelaboratoire , idlaboratoire , idfinanceurexterne , type ) values (4, 1, 'Ebbens', 'Chief Design Engineer', 'cebbens3@techcrunch.com', NULL, NULL, 4, 'membresexternes');
insert into membresprojet (id , idprojet , nom , fonction , mail, idmembrelaboratoire , idlaboratoire , idfinanceurexterne , type ) values (5, 2, 'Conrad', 'Developer IV', 'mconrad4@yahoo.co.jp', 1, 1, NULL, 'membresinternes');
insert into membresprojet (id , idprojet , nom , fonction , mail, idmembrelaboratoire , idlaboratoire , idfinanceurexterne , type ) values (6, 2, 'McNeice', 'Accountant IV', 'dmcneice5@wunderground.com', 2, 1, NULL, 'membresinternes');
insert into membresprojet (id , idprojet , nom , fonction , mail, idmembrelaboratoire , idlaboratoire , idfinanceurexterne , type ) values (7, 2, 'Wingar', 'Automation Specialist III', 'cwingar6@cpanel.net', 3, 1, NULL, 'membresinternes');
insert into membresprojet (id , idprojet , nom , fonction , mail, idmembrelaboratoire , idlaboratoire , idfinanceurexterne , type ) values (8, 2, 'Imlin', 'Senior Cost Accountant', 'bimlin7@i2i.jp', 4, 1, NULL, 'membresinternes');
insert into membresprojet (id , idprojet , nom , fonction , mail, idmembrelaboratoire , idlaboratoire , idfinanceurexterne , type ) values (9, 3, 'Greeson', 'Research Nurse', 'dgreeson8@senate.gov', 1, 1, NULL, 'membresinternes');
insert into membresprojet (id , idprojet , nom , fonction , mail, idmembrelaboratoire , idlaboratoire , idfinanceurexterne , type ) values (10, 3, 'Salzberg', 'Cost Accountant', 'fsalzberg9@hp.com', 5, 1, NULL, 'membresinternes');
insert into membresprojet (id , idprojet , nom , fonction , mail, idmembrelaboratoire , idlaboratoire , idfinanceurexterne , type ) values (11, 3, 'Baudone', 'Software Engineer IV', 'ibaudonea@ibm.com', 6, 1, NULL, 'membresinternes');
insert into membresprojet (id , idprojet , nom , fonction , mail, idmembrelaboratoire , idlaboratoire , idfinanceurexterne , type ) values (12, 3, 'Dorking', 'Cost Accountant', 'vdorkingb@topsy.com', NULL,NULL,2, 'membresexternes');


insert into depenses  (id , montant , typefinancement , daterealisation, iddemandemembreprojet , iddemandeprojet , idvalidemembreprojet , idvalideprojet ) values (1, 80000, 'fonctionnement','2020-06-07' 1, 1, 4, 1);
insert into depenses  (id , montant , typefinancement , daterealisation, iddemandemembreprojet , iddemandeprojet , idvalidemembreprojet , idvalideprojet ) values (2, 2454, 'materiel','2020-05-13', 3, 1, 2, 1);
insert into depenses  (id , montant , typefinancement , daterealisation, iddemandemembreprojet , iddemandeprojet , idvalidemembreprojet , idvalideprojet ) values (3, 25000, 'fonctionnement','2020-06-12', 5, 2, 7, 2);
insert into depenses  (id , montant , typefinancement , daterealisation, iddemandemembreprojet , iddemandeprojet , idvalidemembreprojet , idvalideprojet ) values (4, 500, 'materiel','2020-05-07', 5, 2, 6, 2);
insert into depenses  (id , montant , typefinancement , daterealisation, iddemandemembreprojet , iddemandeprojet , idvalidemembreprojet , idvalideprojet ) values (5, 1100, 'fonctionnement', '2020-04-07', 10 , 3, 12, 3);
insert into depenses  (id , montant , typefinancement , daterealisation, iddemandemembreprojet , iddemandeprojet , idvalidemembreprojet , idvalideprojet ) values (6, 14500, 'materiel','2020-04-07', 11, 3, 12, 3);


insert into label (idpropositionprojet , idfinanceur , nom  ) values (1, 3, 'adipiscing');
insert into label (idpropositionprojet , idfinanceur , nom  ) values (1, 3, 'luctus');
insert into label (idpropositionprojet , idfinanceur , nom  ) values (1, 4, 'libero');
insert into label (idpropositionprojet , idfinanceur , nom  ) values (4, 4, 'fusce');
insert into label (idpropositionprojet , idfinanceur , nom  ) values (4, 5, 'iaculis');
insert into label (idpropositionprojet , idfinanceur , nom  ) values (6, 6, 'vitae');


insert into cree (idfinanceur , nom ) values (3, 'Reilly LLC');
insert into cree (idfinanceur , nom ) values (3, 'HaagKihn');
insert into cree (idfinanceur , nom ) values (3, 'Kovacek-Russel');
insert into cree (idfinanceur , nom ) values (3, 'Runte-Schroeder');
insert into cree (idfinanceur , nom ) values (4, 'Bahringer, Goyette and Kunze');
insert into cree (idfinanceur , nom ) values (4, 'Dietrich Inc');
insert into cree (idfinanceur , nom ) values (4, 'HaagKihn');
insert into cree (idfinanceur , nom ) values (4, 'Huels LLC');
insert into cree (idfinanceur , nom ) values (5, 'Huels LLC');
insert into cree (idfinanceur , nom ) values (5, 'Dietrich Inc');
insert into cree (idfinanceur , nom ) values (5, 'HaagKihn');


insert into estredigeepar  (idpropositionprojet , idmembrelaboratoire , idlaboratoire ) values (1, 1, 1);
insert into estredigeepar  (idpropositionprojet , idmembrelaboratoire , idlaboratoire ) values (1, 7, 1);
insert into estredigeepar  (idpropositionprojet , idmembrelaboratoire , idlaboratoire ) values (4, 8, 1);
insert into estredigeepar  (idpropositionprojet , idmembrelaboratoire , idlaboratoire ) values (4, 9, 1);
insert into estredigeepar  (idpropositionprojet , idmembrelaboratoire , idlaboratoire ) values (5, 3, 1);
insert into estredigeepar  (idpropositionprojet , idmembrelaboratoire , idlaboratoire ) values (5, 4, 1);
insert into estredigeepar  (idpropositionprojet , idmembrelaboratoire , idlaboratoire ) values (3, 5, 1);
insert into estredigeepar  (idpropositionprojet , idmembrelaboratoire , idlaboratoire ) values (3, 6, 1);
insert into estredigeepar  (idpropositionprojet , idmembrelaboratoire , idlaboratoire ) values (6, 1, 1);
insert into estredigeepar  (idpropositionprojet , idmembrelaboratoire , idlaboratoire ) values (6, 5, 1);
insert into estredigeepar  (idpropositionprojet , idmembrelaboratoire , idlaboratoire ) values (2, 8, 1);
insert into estredigeepar  (idpropositionprojet , idmembrelaboratoire , idlaboratoire ) values (2, 3, 1);
