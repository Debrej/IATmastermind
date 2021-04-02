import random
COEF_P = 2
COEF_M = 1
CS = [1,3,7,7]
solutionsJouees = []

def createSol():
    sol = []
    for i in range(4):
        sol.append(random.randrange(8))
    return sol

def createPop(taille_pop):
    pop = []
    for i in range(taille_pop):
        pop.append([createSol(), -1])
    return pop

def score(p,m):
    return COEF_P*p+COEF_M*m

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

def eval(c, cj, scoreReel):
    (pVirtuel, mVirtuel) = compare(c,cj)
    scoreVirtuel = score(pVirtuel, mVirtuel)
    return abs(scoreReel - scoreVirtuel)

def fitness(c, solutionsJouees, scoreReel):
    fit = 0
    for j, solution in enumerate(solutionsJouees):
        print()
        fit += eval(c,solution, scoreReel)
    return fit/len(solutionsJouees)

def extractFitness(s):
    return s[1]

if __name__ == "__main__":
    # Creation de la solution
    CS = createSol()
    print(f'Solution : {CS}')

    # Creation de la solution initiale
    CI = createSol()
    scoreReel = score(*compare(CS, CI))
    print(f'Solution initiale : {CI}, score : {scoreReel}')

    # Ajout de la solution aux solutions jouées
    solutionsJouees = [CI]

    # Création de la population
    pop = createPop(4)

    # Evaluation
    for i in range(len(pop)):
        pop[i][1] = fitness(pop[i][0], solutionsJouees, scoreReel)

    # Classement des meilleures solutions
    pop.sort(key=extractFitness)
    print(f'Population : {pop}')

    # Sélection de la solution à jouer
    solutionAJouer = pop[0][0]
    print(f'Solution à jouer {solutionAJouer}')
