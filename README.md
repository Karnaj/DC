# Installer CoqInE

CoqInE fonctionne avec la version 8.8.x de Coq. Il nous faut donc installer une telle version de Coq, la 8.8.2, par exemple. Attention, cette version est compatible avec une version de OCaml entre la 4.02.3 et la 4.09.2. Nous pouvons par exemple installer la version 4.09.2 de OCaml et la version 8.8.2 de Coq. Avec Opam, et plus particulièrement [`opam switch`](https://opam.ocaml.org/doc/man/opam-switch.html), nous pouvons assez facilement gérer plusieurs versions de OCaml.

Nous pouvons maintenant utiliser CoqInE en suivant les instructions données sur [le dépôt](https://github.com/Deducteam/CoqInE) (cloner le dépôt, puis `make` pour installer CoqInE). La compilation se lance avec, à la fin, une petite liste de commande de tests. Nous pouvons d'ores et déjà lancer `make test` qui lancera tous les tests, donc la traduction de plusieurs fichiers et bibliothèques Coq situés dans le dossier `run`, puis lancera `dkcheck` sur les fichiers Dedukti générés.   

# Fonctionnement de CoqInE

Comme nous l'avons dit, le dépôt contient quelques exemples de traductions dans le dossier `run`. Normalement, nous les avons lancé tous les tests avec `make test` et ils sont tous au vert. Regardons un exemple simple, celui du fichier `run/main/Test/Identity.v`.

```coq
Definition id1 := fun (A : Type) (x : A) => x.
Definition id2 := fun (A : Type) (x : A) => x.
Definition id3 := fun (A : Type) (x : A) => x.

Definition id4 := id1 (forall (A : Type), A -> A) id2.
```

Sa traduction est dans le dossier `run/main/out`, dans le fichier `Top__Test__Identity.dk` et est en gros la suivante (avec quelques définitions en plus).

```coq
(; --------  Begining of translation  --------- ;)

def id1 :
  A : C.U _2 -> x : C.T _2 A -> C.T _2 A

:= A : C.U _2 => x : C.T _2 A => x.

def id2 :
  A : C.U _1 -> x : C.T _1 A -> C.T _1 A

:= A : C.U _1 => x : C.T _1 A => x.

def id3 :
  A : C.U _1 -> x : C.T _1 A -> C.T _1 A

:= A : C.U _1 => x : C.T _1 A => x.

def id4 :
  A : C.U _1 -> __ : C.T _1 A -> C.T _1 A

:= id1
     (C.cast (C.axiom (C.axiom _1)) (C.axiom _2)
        (C.u (C.axiom _1) (C.axiom (C.axiom _1)) C.I)
        (C.u _2 (C.axiom _2) C.I) C.I
        (C.prod (C.axiom _1) (C.rule _1 _1)
           (C.rule (C.axiom _1) (C.rule _1 _1)) C.I (C.u _1 (C.axiom _1) C.I)
           (A : C.U _1 =>
            C.prod _1 _1 (C.rule _1 _1) C.I A (__ : C.T _1 A => A))))
     id2.

(; End of translation. ;)
```

Remarquons en particulier les `C.<nom>`. Il s'agit d'éléments définis dans un autre fichier `C.dk` (présent dans `run/main`). Ces éléments sont les éléments de base de la traduction présentée dans [cet article de Mathieu Boespflug et Guillaume Burel](http://web4.ensiie.fr/~guillaume.burel/download/boespflug12coqine.pdf) et complétée par Gaspard Férey notamment.  Ainsi, `C.U _1` représente un univers.

Ce fichier `C.dk` sur lequel nous reviendrons plus tard est alors nécessaire pour typechecker les fichiers générés pas CoqInE.



Pour traduire un fichier `test.v` à l'aide de CoqInE, voici grossièrement ce qu'il nous faut faire.

1. Compiler les fichier à traduire. CoqInE travaille en effet avec les fichiers `.vo` et pas avec les `.v`.
2. Demander à CoqInE de faire la traduction.

La deuxième étape, bien sûr, n'est pas si simple. Commençons par voir la commande qui correspond à cela (la cible `generate` du Makefile.

```
coqc -nois -init-file ../../.coqrc -verbose -R . Top main_debug.v
```

Le fichier `.coqrc` est un fichier du dossier de CoqInE qui permet de savoir où sont situées les sources de CoqInE. Le fichier `main_debug.v`, lui, est un peu plus complexe.

```coq
(* This script tests the Dedukti plugin by exporting test files and parts
   of the Coq standard library. *)

Declare ML Module "coqine_plugin".

Set Printing Universes.

Dedukti Set Destination "out".

Dedukti Enable Debug.
Dedukti Set Debug "debug.out".

Dedukti Add Debug "Coq.Init.Datatype".

Require Import import_debug.

Load config.

Dedukti Export All.
```

Il permet entre autre de donner le dossier de destination des fichiers Dedukti générés, mais ce qui nous intéresse vraiment, c'est le `Load config`. Ce `Load config` demande à CoqInE d'uiliser une certaine configuration présente dans le fichier `config.v`. Ce fichier, que nous n'allons pas recopier ici, contient plusieurs paramètres utiles pour la traduction. 

Par exemple, `use_cast` permet, d'après le code, de chosir entre ces deux options : *Are we allowed to use casts (for casted lambdas) ? Or should we turn them into lifted lambdas instead ?*.

Le paramètre `encoding_file` permet de donner le nom du fichier contenant les éléments de l'encodage (le fameux fichier `C.dk`). C'est comme cela que CoqInE sait comment préfixer les objets (si on avait donné la valeur "Conf" à ce paramètre, on aurait eu des `CC.U` au lieu des `C.U` dans les fichiers Dedukti générés).

Et le paramètres `Univ` (comme d'autres paramètres du même type) permettent d'indiquer le nom qu'a l'élément `Univ` dans le fichier d'encodage (donc `U` vu que dans notre `C.dk` c'est un élément `U` qui est défini pour les univers).

Ce que ces deux derniers exemples de paramètres nous montrent, c'est que les fichiers `config.v` et `C.dk` sont assez liés. En fait, ces fichiers n'ont pas besoin d'être écrit à la main ; CoqInE nous permet d'en générer !

## Les encodages

Les différents encodages peuvent être générés avec `make -C encodings`. Ils seront alors dans `encodings/_build`. Dans chaque dossier, il y a un encodage différent. Le fichier `C.config` correspond au `config.v` nécessaire à la traduction, et le `C.dk` au fichier nécessaire pour typechecker les fichiers générés par CoqInE.

### TODO 

- Regarder les différentes options et les différents encodages.
- Certains encodages ne fonctionnent pas.
    - `constructors` => pas (plus) d'option `cumul_trans`, options `axiom` et `rule` manquantes, si on les rajoute, ne typechecke pas tout.
    - manque le paramètre `encoding_name`
- Trouver les bons encodages.


# Avec GeoCoq 

Pour traduire GeoCoq, il nous faut donc suivre les différentes étapes que nous avons données. [Ce dépôt](https://github.com/Deducteam/GeoCoqInE-Euclid) nous permet d'avoir des résultats plus facilement.

Attention, `dkcheck` peut prendre plusieurs heures sur les fichiers générés. En particulier, l'option `simpl_letins` (*Translate let-in as simpl beta redices or not ?*) est activée et elle donne des termes plus longs à typechecker. Sans elle, l'étape de typechecking est beaucoup plus rapide (quelques minutes). 
