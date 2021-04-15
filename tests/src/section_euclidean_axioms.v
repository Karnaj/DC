(** The following axiom systems are used to formalize
    Euclid's proofs of Euclid's Elements.OriginalProofs.statements. *)

Section EuclidAxiom.

(** First, we define an axiom system for neutral geometry,
    i.e. geometry without continuity axioms nor parallel postulate.
 *)

Variable Point: Type.
Variable Circle: Type.
Variable Cong : Point -> Point -> Point -> Point -> Prop.
Variable  BetS : Point -> Point -> Point -> Prop.
Variable  PA : Point.
Variable  PB : Point.
Variable  PC : Point.
Variable  CI : Circle -> Point -> Point -> Point -> Prop.
Definition eq := @eq Point.
Definition neq A B := ~ eq A B.
Definition  TE A B C := ~ (neq A B /\ neq B C /\ ~ BetS A B C).
Definition  nCol A B C := neq A B /\ neq A C /\ neq B C /\ ~ BetS A B C /\ ~ BetS A C B /\ ~ BetS B A C.
Definition  Col A B C := (eq A B \/ eq A C \/ eq B C \/ BetS B A C \/ BetS A B C \/ BetS A C B).
Definition  Cong_3 A B C a b c := Cong A B a b /\ Cong B C b c /\ Cong A C a c.
Definition  TS P A B Q := exists X, BetS P X Q /\ Col A B X /\ nCol A B P.
Definition  Triangle A B C := nCol A B C.

Definition  OnCirc B J := exists X Y U, CI J U X Y /\ Cong U B X Y.
Definition  InCirc P J := exists X Y U V W, CI J U V W /\ (eq P U \/ (BetS U Y X /\ Cong U X V W /\ Cong U P U Y)).
Definition  OutCirc P J := exists X U V W, CI J U V W /\ BetS U X P /\ Cong U X V W.

Axiom  cn_congruencetransitive :
   forall B C D E P Q, Cong P Q B C -> Cong P Q D E -> Cong B C D E.
Axiom  cn_congruencereflexive :
   forall A B, Cong A B A B.
Axiom  cn_equalityreverse :
   forall A B, Cong A B B A.
Axiom  cn_sumofparts :
   forall A B C a b c, Cong A B a b -> Cong B C b c -> BetS A B C -> BetS a b c -> Cong A C a c.
Axiom  cn_stability :
   forall A B, ~ neq A B -> eq A B.
Axiom  axiom_circle_center_radius :
   forall A B C J P, CI J A B C -> OnCirc P J -> Cong A P B C.
Axiom  axiom_lower_dim : nCol PA PB PC.
Axiom  axiom_betweennessidentity :
   forall A B, ~ BetS A B A.
Axiom  axiom_betweennesssymmetry :
   forall A B C, BetS A B C -> BetS C B A.
Axiom  axiom_innertransitivity :
   forall A B C D,
    BetS A B D -> BetS B C D -> BetS A B C.
Axiom  axiom_connectivity :
   forall A B C D,
    BetS A B D -> BetS A C D -> ~ BetS A B C -> ~ BetS A C B ->
    eq B C.
Axiom  axiom_nocollapse :
   forall A B C D, neq A B -> Cong A B C D -> neq C D.
Axiom  axiom_5_line :
   forall A B C D a b c d,
    Cong B C b c -> Cong A D a d -> Cong B D b d ->
    BetS A B C -> BetS a b c -> Cong A B a b ->
    Cong D C d c.

Axiom   postulate_Pasch_inner :
   forall A B C P Q,
    BetS A P C -> BetS B Q C -> nCol A C B ->
    exists X, BetS A X Q /\ BetS B X P.
Axiom   postulate_Pasch_outer :
   forall A B C P Q,
    BetS A P C -> BetS B C Q -> nCol B Q A ->
    exists X, BetS A X Q /\ BetS B P X.
Axiom   postulate_Euclid2 : forall A B, neq A B -> exists X, BetS A B X.
Axiom   postulate_Euclid3 : forall A B, neq A B -> exists X, CI X A A B.

(** Second, we enrich the axiom system with line-circle
     and circle-circle continuity axioms.
    Those two axioms state that we allow ruler and compass
    constructions.
*)

Axiom   postulate_line_circle :
   forall A B C K P Q,
    CI K C P Q -> InCirc B K -> neq A B ->
    exists X Y, Col A B X /\ BetS A B Y /\ OnCirc X K /\ OnCirc Y K /\ BetS X B Y.
Axiom   postulate_circle_circle :
   forall C D F G J K P Q R S,
    CI J C R S -> InCirc P J ->
    OutCirc Q J -> CI K D F G ->
    OnCirc P K -> OnCirc Q K ->
    exists X, OnCirc X J /\ OnCirc X K.

(** Third, we introduce the famous fifth postulate of Euclid,
    which ensures that the geometry is
    Euclidean (i.e. not hyperbolic).
 *)

Axiom   postulate_Euclid5 :
   forall a p q r s t,
    BetS r t s -> BetS p t q -> BetS r a q ->
    Cong p t q t -> Cong t r t s -> nCol p q s ->
    exists X, BetS p a X /\ BetS s q X.

(** Last, we enrich the axiom system with axioms for equality of areas. *)

Variable  EF : Point -> Point -> Point -> Point -> Point -> Point -> Point -> Point -> Prop.
Variable  ET : Point -> Point -> Point -> Point -> Point -> Point -> Prop.
Axiom   axiom_congruentequal :
   forall A B C a b c, Cong_3 A B C a b c -> ET A B C a b c.
Axiom   axiom_ETpermutation :
   forall A B C a b c,
    ET A B C a b c ->
    ET A B C b c a /\
    ET A B C a c b /\
    ET A B C b a c /\
    ET A B C c b a /\
    ET A B C c a b.
Axiom   axiom_ETsymmetric :
   forall A B C a b c, ET A B C a b c -> ET a b c A B C.
Axiom   axiom_EFpermutation :
   forall A B C D a b c d,
   EF A B C D a b c d ->
     EF A B C D b c d a /\
     EF A B C D d c b a /\
     EF A B C D c d a b /\
     EF A B C D b a d c /\
     EF A B C D d a b c /\
     EF A B C D c b a d /\
     EF A B C D a d c b.
Axiom   axiom_halvesofequals :
   forall A B C D a b c d, ET A B C B C D ->
                           TS A B C D -> ET a b c b c d ->
                           TS a b c d -> EF A B D C a b d c -> ET A B C a b c.
Axiom   axiom_EFsymmetric :
   forall A B C D a b c d, EF A B C D a b c d ->
                           EF a b c d A B C D.
Axiom   axiom_EFtransitive :
   forall A B C D P Q R S a b c d,
     EF A B C D a b c d -> EF a b c d P Q R S ->
     EF A B C D P Q R S.
Axiom   axiom_ETtransitive :
   forall A B C P Q R a b c,
    ET A B C a b c -> ET a b c P Q R -> ET A B C P Q R.
Axiom   axiom_cutoff1 :
   forall A B C D E a b c d e,
    BetS A B C -> BetS a b c -> BetS E D C -> BetS e d c ->
    ET B C D b c d -> ET A C E a c e ->
    EF A B D E a b d e.
Axiom   axiom_cutoff2 :
   forall A B C D E a b c d e,
    BetS B C D -> BetS b c d -> ET C D E c d e -> EF A B D E a b d e ->
    EF A B C E a b c e.
Axiom   axiom_paste1 :
   forall A B C D E a b c d e,
    BetS A B C -> BetS a b c -> BetS E D C -> BetS e d c ->
    ET B C D b c d -> EF A B D E a b d e ->
    ET A C E a c e.
Axiom   axiom_deZolt1 :
   forall B C D E, BetS B E D -> ~ ET D B C E B C.
Axiom   axiom_deZolt2 :
   forall A B C E F,
    Triangle A B C -> BetS B E A -> BetS B F C ->
  ~ ET A B C E B F.
Axiom   axiom_paste2 :
   forall A B C D E M a b c d e m,
    BetS B C D -> BetS b c d -> ET C D E c d e ->
    EF A B C E a b c e ->
    BetS A M D -> BetS B M E ->
    BetS a m d -> BetS b m e ->
    EF A B D E a b d e.
Axiom   axiom_paste3 :
   forall A B C D M a b c d m,
    ET A B C a b c -> ET A B D a b d ->
    BetS C M D ->
    (BetS A M B \/ eq A M \/ eq M B) ->
    BetS c m d ->
    (BetS a m b \/ eq a m \/ eq m b) ->
    EF A C B D a c b d.
Axiom   axiom_paste4 :
   forall A B C D F G H J K L M P e m,
    EF A B m D F K H G -> EF D B e C G H M L ->
    BetS A P C -> BetS B P D -> BetS K H M -> BetS F G L ->
    BetS B m D -> BetS B e C -> BetS F J M -> BetS K J L ->
    EF A B C D F K M L.

End EuclidAxiom.