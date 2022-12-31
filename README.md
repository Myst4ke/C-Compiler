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
| Name    | Exemple  |      Opérateurs    |
|:----------:|:----------:|:-------------:|
| Int     | `int a = 1312;` |   | 
| Bool    | `bool b = true;` |   |
| String  | `string s = "Bonjour";` |   |
