# Compilateur C en Ocaml

### Description
Ce projet est un compilateur C écrit en `OCaml`. Il est séparé en plusieur parties :
* L'analyse syntaxique (`Lexer.ml & Parser.ml`): Transforme le fichier.c en représentation intermédiaire en vérifiant qu'il n'y a pas d'erreurs de syntaxe.
* L'analyse semantique (`Semantics.ml`): Vérifie que le code est correct et qu'aucune erreur n'est présente.
* La compilation (`Compiler.ml`): Compile la représentation en code mips

### Compilation : 
* Pour compiler le code et l'exécuter en une seule commande :

`ocamlbuild -use-menhir main.byte && ./main.byte tests/fichier.test > test.s && spim -f test.s `

* `ocamlbuild -use-menhir main.byte` : Compile le code ocaml et créé un executable.

* `./main.byte tests/fichier.test > test.s` : Lance l'executable sur un fichier `.test` choisi et écrit le résultat de l'execution dans un fichier `.s`

* `spim -f test.s` : Lance Spim sur le fichier `.s` choisi

### Langage : 
Le langage compilé est basé sur le **C** avec quelques différences.
#### Les types :
Contrairement au **C** seuls trois types sont disponibles :
| Nom     | Exemple                |    Opérateurs    |
|:-------:|:----------------------:|:----------------:|
| Int     | `int i = 1312`         | **tous**         | 
| Bool    | `bool b = true`        | **==** et **!=** |
| String  | `string s = "Bonjour"` | **aucun**        |

#### Les opérateurs :
Liste des opérateurs disponibles :

| Nom     | Exemple          |      Types    |
|:-------:|:----------------:|:-------------------:|
| **==**  | `13 == 12`       | **int** et **bool** | 
| **!=**  | `false != true`  | **int** et **bool** |
| **>**   | `13 > 12`        | **int**             |
| **>=**  | `13 >= 12`       | **int**             |
| **<**   | `13 < 12`        | **int**             |
| **<=**  | `13 <= 12`       | **int**             |
| *       | `13 * 12`        | **int**             |
| **+**   | `13 + 12`        | **int**             |
| **/**   | `13 / 12`        | **int**             |
| **-**   | `13 - 12`        | **int**             |

#### Les Conditions/Boucles : 
Les conditions et les boucles s'écrivent comme en **C** à la différence qu'il est nécessaire de les terminer par un **`;`**

##### Exemple : 
**If**
```c
if(true == false){
  puti(13);
}else{
 puti(12);
};
```
ou 
```c
if(true == false){
  puti(13);
};
puti(12);
```
**While**
```c
int x = 0;
while(x<10){
  x = x + 1;
};
```

#### Les optimisations : 
##### Quelques optimisations sont effectuées :
* **Optimisation des types des arguments :** Chaque fonction de la baselib possède une liste de type correspondant au type d'arguments qui peuvent être passés à l'appel de la fonction. Ces types étants uniques un opérateur tel que **==** ne pouvait marcher que sur un seul type (soit int, soit bool). L'optimisation consiste à prendre non pas **des types uniques** pour chaque argument mais **une liste de types** pouvant être acceptés par la fonction. L'opérateur **==** marche donc pour les int et les bool en même temps. Les fonctions d'erreur liste maintenant la liste des types possibles.
* **Optimisation des strings multiples :** Le `Simplifier.ml` permet d'éviter la présence de chaine de caractère multiples.

