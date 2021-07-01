# Note de clarification

### Contexte: 

Un laboratoire souhaite mettre en place une base de données lui permettant de gérer facilement ses projets de recherches.
Il cherche ainsi à informatiser si l'on puit dire les relations entre les financeures, les organismes et les laboratoires.
Le laboratoire veut gérer toutes les étapes / informations en amont nécessaires à la création éventuelle d'un projet (appel à projet, proposition de projet...), mais également les informations en avale liées aux projets de recherche (membres, dépenses...)



### Données d’entrées:

Aucune donnée d’entrée.


### Objet du projet: 

Concevoir un système de gestion de projets de recherche pour un laboratoire :

* Gérer les informations liées aux projets et propostions de projet

* Gérer les informations des financeurs, des organismes et des appels à projet

* Gérer les informations des membres internes et/ou externes des projets

* Effectuer plusieurs types de recherches sur les projets (appel à projet et projet en cours, projet dont le budget n'a pas été atteint, appel à projet non répondus et proposition à projet acceptée/refusée )

* Etudes statistiques (nombre de propositions répondues par type d'organisme projet avec le nombre de projet accepté, membres
du laboratoire affectés au plus grand nombre de projet en cours, mois de l'année où on fait le plus de
dépenses de projet au laboratoire)



### Produit du projet: 

* README
* Note de Clarification
* Modèle Conceptuel de Données
* Modèle Logique de Données (relationnelle)
* BDD : base de données, données de test, requêtes


### Objectifs visés:

* Qualité : Un code informatique s'exécute correctement, accompagné de données de test et d’une documentation correctement présentée et correctement écrite en français.
* Délai : 
    * 27 mai 2020 pour la NDC et le MCD
    * 3 mai 2020 pour le MLD, SQL CREATE et INSERT
    * 10 Juin pour le SQL SELECT
    * 17 Juin Livrable final
* Coût : Non défini


#### Maître d’ouvrage: 
* CORREA-VICTORINO Alessandro

#### Maître d’oeuvre: 
* Baptiste VIERA


### Conséquences attendues:

* Faciliter la gestion des projets de recherche pour les laboratoires, la gestion de toutes les parties prenantes du projet, la gestion des dépenses réalisée.
* Faciliter la consultation de projet et des statistiques liés aux projets

**Contraintes à respecter:** 
* Livrable finale à rendre le 17 juin
    * 27 mai 2020 pour la NDC et le MCD
    * 3 mai 2020 pour le MLD, SQL CREATE et INSERT
    * 10 Juin pour le SQL SELECT


**Contraintes de coûts:** 
Aucune 

**Contraintes de performances:** 
Aucune



|**Objet**    |**Propriétés**        |**Contraintes**|
|:-------:|:---------------|:--------|
|EmployeContact | Titre, mail, télephone|<ul><li>Clé articielle</li><li>Contraintes simples sur les types de données mail et téléphone</li><li>Un employé contact peut changer de financeurs</li></ul>|
|Financeurs|Date de début et de fin d'activités|<ul><li>Code unique pour identifier les financeurs (Clé articielle)</li><li>Date de debut < date de fin</li></ul>|
|Region,Pays,Ville,Laboratoire,Entreprise|Nom|<ul><li>Hérite de financeurs</li></ul>|
|Organisme|Nom, date de création, date de disparition (ou durée d'existence) |<ul><li>Nom unique pour identifier l'organisme</li><li>La date de disparition (ou durée d'existence) peut être indéterminée mais si elle existe, elle doit être supérieure à la date de création</li></ul>|
|AppelProjet|Date de lancement, date de fin, theme, description|<ul><li>Code unique pour identifier l' AppelProjet (Clé articielle)</li><li>La date de lancement doit être inférieure à la date de fin et ces deux dates doivent être comprise entre la date de création de l'organisme et la date éventuelle de disparition de l'organisme</li></ul>||
|MembresComitePersonne|Nom, Mail|<ul><li>Code unique pour identifier le membre du ComitePersonne (Clé articielle)</li></u>|
|PropositionProjet|Budget, Objet global,type de financement(fonctionnement ou materiel), date de deposition, date de reponse, reponse|<ul><li>Code unique pour identifier la proposition(Clé articielle)</li><li>La date de deposition doit se situer entre la date de lancement et la date de fin de l'appel à projets</li><li>Les propositions n'ont pas forcément des labels</li><li>Datereponse et reponse peuvent être nulle si la proposition n'a pas été encore répondue</ul>|
|Label (Association)|Nom|<ul><li>Les labels sont possédés ou non par les propositions et ils sont donnés par les entités juridiques</li><li>Nom en local key pour permettre à une propostion d'avoir plusieurs labels d'un même financeur</ul>|
|Projet|Date de debut, date de fin, budget|<ul><li>Code unique pour identifier le projet(Clé articielle)</li><li>Le budget doit être identique à celui de la proposition</li><li>Date de debut < date de fin</li></ul>|
|Dépenses|Date de realisation, montant, type de financement (materiel ou fonctionnement)|<ul><li>Code unique pour identifier les dépenses (Clé articielle)</li><li>Le montant des dépenses ne doit pas dépasser le montant global du budget du projet</li></ul>|
|MembresProjet|Nom, fonction, mail|<ul><li>Classe abstraite qui est définie par les membres externes et les membres internes</li><li>Un projet déposé dans le cadre d'un appel, ne peut pas avoir des membres du comité d'évaluation (comitépersonne) associés à cet appel dans la liste de ces membres (membresprojet)</li><li>(Clé articielle)</ul>|
|MembresInterne||<ul><li>Hérite de MembresProjet</li><li>Un membre interne est forcément un membre du laboratoire</li><li>Ils peuvent demander ou valider des dépenses</li></ul>|
|MembresExterne||<ul><li>Hérite de MembresProjet</li><li>Un membre externe est un employé d'une entité juridique autre que le laboratoire</li><li>Ils peuvent demander ou valider des dépenses</li></ul>|
|EnseignatsChercheurs|Quotite de temps de recherche obligatoire, etablissement |<ul><li>Ils sont membres du laboratoire et peuvent faire partie des membres du projet</li></ul>|
|IngénieurDeRecherche |Domaine de spécialité |<ul><li>Ils sont membres du laboratoire et peuvent faire partis des membres du projet</li></ul>|
|Doctorants|Date de début de la thèse, date de fin de la thèse, sujet de la thèse |<ul><li>Ils sont membres du laboratoire et peuvent faire partie des membres du projet</li><li>La date de fin de la thèse peut être nulle si la thèse n'est pas encore rendue</li><li>date debut < date fin</ul>|
|MembresLaboratoire||<ul><li>Classe abstraite qui est définie par EnseignatsChercheurs, IngénieurDeRecherche,Doctorants</li></ul>|


**Gestion des droits : ** 


|**Utilisateurs**|**Droits**|
|:----------:|:--------|
|MembresProjet|Lecture, Ajout/Suppression/Modification sur les tables depenses,projet,membreprojet, Recherches sur les projets|
|Financeurs|Lecture, Ajout/Suppression/Modification sur les tables financeurs,pays,ville,region,entreprise,laboratoire, oragnisme,employécontact,label, Recherches sur les projets|
|organisme|Lecture, Ajout/Suppression/Modification sur les tables appelprojet,membrescomitepersonne, Recherches sur les projets|
|membreslaboratoire|Lecture, Ajout/Suppression/Modification sur les tables lignesbudgetaires,propositionprojet,membreinterne,membrelaboratoire, Recherches sur les projets|




**Contraintes logique d'association** 

* Publie : Un appel à projet a été forcément publié par un organisme (clé étrangère) et un organisme peut créer plusieurs appels à projet. 1 : *

* Est géré par : Un appel est géré par au moins 1 membre du comité de personne et on peut considérer qu'il s'agit d'une association de composition (notion de cycle de vie) 1-N : 1

* Est déposé sur : Une proposition de projet est forcément déposé sur 1 appel de projet et un appel de projet peut être associé à aucune ou plusieurs proposition 1 : *

* Crée : Une financeur peut créer 0 ou plusieurs organisme et un organisme a plusieurs financeurs 1..N : *

* Label (classe association) : Une proposition possède 0 ou plusieurs labels donnés par un fincanceur et un financeur peut labéliser 0 ou plusieurs proposition de projet * : *

* Emploie : Un financeur emploie exactement un employé contact mais un employé contact peut changer de financeurs (association d'agrégation) 0..1 : 1

* Emploie : Un laboratoire emploie plusieurs membres et un membre est appartient à un laboratoire (composition) 1 : 1..N

* Est rédigée par : Une proposition est rédigé au moins par un membre du laboratoire et un membre du laboratoire peut rédiger 0 ou plusieurs proposition 1..N : *

* Est à l'origine : Un projet provient forcément d'une proposition de projet mais une prosition ne débouche pas forcément sur 1 projet. 1 : 0..1

* Est-un : Une membre du laboratoire peut être ou non un membre interne du projet et un membre interne du projet est forcément un membre du laboratoire 1 : 0..1

* Est composé de : Un projet est composé de 1 ou plusieurs membres et un membre est forcément associé à un projet (composition) 1 : 1..N

* Realise : Un projet réalise plusieurs dépenses et une dépense est associé à un projet 1 : 1..N

* Demande (x2) : Un membre interne / externe peut demander 0 ou plusieurs dépenses et une dépense est demandé par soit un membre interne ou un membre externe 0..1 : * 

* Valide (x2) : Un membre interne / externe peut valider 0 ou plusieurs dépenses et une dépense est validée par soit un membre interne ou un membre externe  0..1 : *

* Est employé par :  Un membre externe est forcément employé par une entité juridique autre que le laboratoire et une entité juridique possède 0 ou plusieurs membres externes * : 1


* CONTRAINTES DE CARDINALITE MINIMALE 1 DANS LES ASSOCIATIONS 1:N A GERER (non nullité de la clé étrangère et/ou contrainte d'existence de tuples référançant pour chaque tuple de la relation référancée)
* CONTRAINTEs DE CARDINALITE MINIMALE 1 DANS LES ASSOCIATIONS N:M A GERER (contrainte d'existence simultanée de tuples)
* CONTRAINTES DE COMPOSITION A GERER

**Contraintes héritage** 
 
* CONTRAINTES LIEES AUX HERITAGES PAR REFERENCE A GERER (TOUS MES HERITAGES SONT EXCLUSIFS)
* CONTRAINTES CLASSES ABSTRAITES

**Création de vues**

* Vue permettant d'afficher toutes les informations des membres internes / externes du projet
* Vue permettant d'afficher tous les membres d'un projet
* Vue permettant d'afficher tous les employés du laboratoire
* Vue permettant d'afficher les projets pour lesquels il reste du budget à dépenser
* Vue permettant d'afficher les projets en cours
* Vue permettant d'afficher les appels d'offre en cours non répondus
* Vue permettant d'afficher le nombre de propositions répondues par type d'organismeprojet avec le nombre de projet accepté
* Vue permettant d'afficher membres du laboratoire affectés au plus grand nombre de projet en cours
* Vue permettant d'afficher mois de l'année où on fait le plus de dépenses de projet au laboratoires
