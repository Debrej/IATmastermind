# Méta-heuristiques du Mastermind

*Gaétan FALCAND & Thibaut BELLANGER, projet d'IAT*

## Introduction

Ce projet a pour but d'implémenter une résolution du jeu Mastermind avec un algorithme génétique.

## Étape 1 : Modélisation du Mastermind

1. *Proposer une représentation (un codage) pour toute combinaison de pions.*

Pour représenter toutes les combinaisons possibles, nous avons deux informations à associer : la couleur choisie ainsi que sa position. Chaque pion est donc un couple (position, couleur), et une combinaison est l'association de 4 pions.
La position $i \in [0,3]$ et la couleur $y \in [0,7]$ et la solution est de la forme $(x_0,x_1,...,x_i)$
Un exemple de solution :
$$ s_0 = (1,3,7,7) $$
Pour avoir une représentation simple à manipuler, on utilise un tableau, où l'indice de la case représente la position, et la valeur stockée dans la case représente la couleur.
```python=
CS = [1,3,7,7]
```

2. *Combien de solutions candidates existe-t-il pour des combinaisons de N pions avec k couleurs? En déduire le nombre de combinaisons pour des combinaisons de 4 pions avec 8 couleurs.*

Le nombre de solutions candidates est de $k^N$. Dans notre cas, on a donc $8^4 = 4096$ possibilités.

3. *Proposer une fonction **score**$(p\in\mathbb{N}, m\in\mathbb{N})\rightarrow\mathbb{N}^+$ convertissant le nombre de couleurs correctement placées ($p$) et le nombre de couleurs présentes mais mal placées ($m$) en un entier positif exprimant un score.*

On considère qu'une couleur placée correctement vaut $3$ points tandis qu'une couleur présente mais mal placée vaut $1$ points. On a donc le score qui vaut $3p+m$.
```python
def score(p,m):
    return COEF_P*p+COEF_M*m
```

4. *On  veut  maintenant  être  capable  d’évaluer  la  qualité  d’une  combinaison candidate, notée $c$, en fonction d’une combinaison déjà jouée $c_j$. Pour évaluer la qualité de $c$, on va supposer que c’est la combinaison recherchée. Dans ce cas, le score virtuel de $c_j$ par rapport à $c$ doit être aussi proche que possible du score déjà obtenu par $c_j$ noté $sc_j$. En déduire une fonction simple **eval**$(c,c_j)\rightarrow\mathbb{N}^+$ calculant la différence entre le score virtuel de $c_j$ par rapport à $c$ et le score déjà obtenu pour $c_j$. Pour cela vous aurez besoin de la fonction **compare**$(c_1,c_2)\rightarrow(p\in\mathbb{N}, m\in\mathbb{N})$, qui retourne le nombre de couleurs de $c_2$ bien placées dans $c_1(p)$ et le nombre de couleurs de $c_2$ présentes mais mal placées dans $c_1(m)$.*

La fonction ***compare*** :
```python
def compare(c1, c2):
    cVerif = ["r","r","r","r"]
    for i, valC1 in enumerate(c2):
      for j, valC2 in enumerate(c1):
          if valC2 == valC1:
              if i == j:
                  cVerif[j] = "p"
                  break
              elif cVerif[j] == "r":
                  cVerif[j] = "m"
                  break
    p = 0
    m = 0
    for i, val in enumerate(cVerif):
        if val == "p":
            p+=1
        elif val == "m":
            m+=1
    return (p,m)
```

La fonction ***eval*** : 
```python
def eval(c, cj, cs):
    (pVirtuel, mVirtuel) = compare(c,cj)
    scoreVirtuel = score(pVirtuel, mVirtuel)
    (pReel, mReel) = compare(cj, cs)
    scoreReel = score(pReel, mReel)
    return abs(scoreReel - scoreVirtuel)
```

5. *En déduire la fonction de **Fitness** qui compare une combinaison candidate $c$ avec l’historique de tous les couples (question, réponse), que l’on cherche à minimiser.*

La fonction ***fitness***:
```python
def fitness(c, solutionsJouees, cs):
    fit = 0
    for j, solution in enumerate(solutionsJouees):
        fit += eval(c, solution, cs)
    return fit/len(solutionsJouees)
```

## Étape 2 : Résolution par algorithme génétique (AG)

1. *Proposer un algorithme ou une approche pour la sélection des $m$ “meilleurs” candidats ($m < N$) afin de constituer la nouvelle génération des solutions candidates.*

Le but que nous voulons avec cette sélection est de garantir un minimum d'aléatoire pour garder une exploration correcte, tout en s'assurant de garder les meilleurs solutions (celles avec la fitness la plus basse). La solution pour laquelle nous avons opté est la suivante : nous gardons toujours le meilleur individu de la population, puis remplissons le reste de la population grâce à un tirage avec roulette biaisée.

Nous l'avons implémenté de telle façon : 
Pour garder les $m$ meilleurs solutions candidates, on ordonne les solutions par ordre croissant de *fitness* :

```python
pop.sort(key=extractFitness)
```

Ensuite, on garde la meilleure, et on effectue un tirage avec une roue biaisée sur les suivantes :

```python
def selection(pop):
    bests = []
    bests.append(pop[0])
    sumFitness = sum(list(map(extractFitness, pop[1:])))
    maxFitness = extractFitness(max(pop[1:], key=extractFitness))
    weights = [(maxFitness - x[1])/(sumFitness) for x in pop[1:]]
    bests.extend(random.choices(pop[1:], weights=weights, k=int(len(pop[1:])/2)))
    return(bests)
```

Dans la fonction ***selection***, premièrement on fait la somme des *fitness* des solutions restantes : $s_{fitness} = \sum_{i=1}^{n-1}{fitness(s_i)}$. Ensuite on extrait la *fitness* maximum : $max_{fitness}$. Chaque solution a un poids qui dépend de sa *fitness*, de la somme et du maximum telle que $poids = \frac{max_{fitness} - fitness(s_i)}{s_{fitness}}$. Ceci va nous assurer que les solutions les moins adaptées aient le moins de chance d'être sélectionnées. Enfin, on utilise la fonction `random.choices()` pour sélectionner de manière aléatoire mais biaisée les solutions que l'on va garder.

2. *Proposer une ou des opérations simples de mutation sur une solution candidate.*

Une opération simple de mutation est de choisir aléatoirement un des 4 pions de la solution, puis de choisir une nouvelle couleur (i.e. une couleur différente de celle actuelle) et de lui affecter.
Ensuite, il convient de fixer un taux de mutation. En effet, on ne veut pas que la mutation changent les meilleurs solutions à chaque tour. On veut seulement qu'elle permette une exploration sans gâcher tous les efforts précédents.

La fonction de ***mutation***:
```python
def mutation(sol):
    c = sol[0]
    chance = random.randrange(100)
    if(chance < TAUX_MUTATION):
        while(True):
            mute = random.randrange(8)
            position = random.randrange(4)
            if(c[position] != mute):
                c[position] = mute
                return [c, -1]
    return sol
```

3. *Proposer une ou des opérations de croisement transformant 2 solutions candidates en 1 nouvelle solution candidate. Assurez-vous que les solutions candidates construites sont valides.*

Une première approche serait de garder deux pions de la première solution et deux de la deuxième. Cependant, cette méthode est trop statique. Elle ne permet pas une bonne exploration de toutes les possibilités. Pour une cela, on pose trois possibilités : 
- les 3 premiers pions de la première solution et le dernier de la seconde;
- 2 pions de chaque solution;
- le premier pion de la première solution et les 3 derniers de la seconde;

On choisit alors aléatoirement une de ces trois possibilités.

La fonction de ***croisement***:

```python
def croisement(c1, c2):
    chance = random.randrange(3)
    if(chance == 0):
        return([[c1[0], c1[1], c1[2], c2[3]], -1])
    if(chance == 1):
        return([[c1[0], c1[1], c2[2], c2[3]], -1])
    if(chance == 2):
        return([[c1[0], c2[1], c2[2], c2[3]],-1])
```

### Choix et structures proposées

Nous allons détaillé ici tous les choix que nous avons fait pour notre algorithme.

### Implémentation et résultats

Nous avons donc compilé toutes ces fonctions afin d'implémenter l'algorithme génétique. L'algorithme a la forme suivante :

```flow
st=>start: Début
e=>end: Fin
gen=>operation: Génération de la population
sel=>operation: Sélection
cross=>operation: Croisement
mute=>operation: Mutation
eval=>operation: Réévaluation
play=>condition: Solution trouvée ?

st->gen->sel->cross->mute->eval->play
play(yes)->e
play(no)->sel
```

Une fois l'algorithme implémenté, nous avons lancé des tests afin de trouver les meilleurs valeurs de paramètres. Ces paramètres sont :

+ ***ratio***: le ratio vaut $\frac{Coef_P}{Coef_M}$, il représente la différence entre une couleur mal placée mais présente et une couleur bien placée. En l'augmentant, on mets plus de poids sur les solutions présentant des couleurs bien placées.
+ ***pop***: la taille de la population influe beaucoup sur les résultats, en effet, plus le pool de solutions est grands plus on a de chances de voir apparaître une solution qui tends vers la vraie solution
+ ***taux***: le taux de mutation est la chance que va avoir une solution de muter. Plus ce taux est grand, plus on va explorer des solutions différentes et donc possiblement tenter d'autres approches qui seraient gagnantes. Toutefois, trop l’augmenter peut nous faire diverger de la solution.

Nous avons donc lancé des tests en faisant varier ces différents paramètres :

+ ***ratio***: $2,3,4,5,6$
+ ***taux***: $3,5,15,30$
+ ***pop***: $50,100,200$

Nous avons fait 50 tests pour chacune de ces combinaisons soit $5*4*3*50 = 3000$

Les résultats que nous obtenons sont représentés ci-après: 

<img src="https://i.imgur.com/qc73IFk.png" style="zoom:40%;" />

<img src="https://i.imgur.com/2qmS6CH.png" style="zoom:40%;" />

Le graphique qui nous a aidé à trouver les paramètres optimaux est le suivant :

<img src="https://i.imgur.com/Yjvz3yP.png" style="zoom:40%;" />

On veux éviter un taux de mutation trop haut, on va donc choisir un taux inférieur à $10$%. On a donc la combinaison $ratio = 3, pop = 200, taux = 5$.

Avec cette combinaison on effectue 500 tests et on obtient : 

<img src="https://i.imgur.com/27rrph6.png" style="zoom:40%;" />

On voit que la répartition du nombre de tours requis est concentré autour de $8$ tours.

Si on veut augmenter notre réussite, il semble que le paramètre important est le ***taux***. En effet, en portant celui ci à $15$%, et en effectuant les même tests qu'auparavant on obtient :

<img src="https://i.imgur.com/CeWk80w.png" style="zoom:40%;" />

<img src="https://i.imgur.com/gbA8xCK.png" style="zoom:40%;" />


On voit que le taux de mutation plus élevé permet de trouver plus rapidement que avec celui plus bas.

## Etape 3 : Autres approches pour la résolution

*Dans cette 3eme étape, qu’il faut voir comme un bonus, vous êtes libre d’explorer d’autres méta-heuristiques pour proposer des algorithmes de résolution alternatifs à l’approche algo. génétique. Ces autres approches sont potentiellement :
—  Recherche locale (tabou, hill climbing)
—  PSO (Particle Swarm Optimization)!?
Attention, toute nouvelle approche proposée devra être implémentée dans votre programme pour démontrer son bon fonctionnement, et également présentée dans le rapport final. Le plus sera d’analyser et comparer les performances entre vos différentes approches.*

Nous n'avons pas utilisé d'autres approches pour résoudre le Mastermind.

## Conclusion

On a vu lors de ce projet comment utiliser les méta-heuristiques ainsi qu'un algorithme génétique pour trouver la solution du Mastermind. Les améliorations que l'on pourrait apporter à ce projet serait d'augmenter le nombre de tests. En effet, ici on ne teste que 60 combinaisons donc on peut rater une combinaison optimale. De plus, on pourrait tester d'autres approches pour la mutation ainsi que le croisement pour évaluer si celle que l'on a implémentés sont optimales.