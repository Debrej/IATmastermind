import random
import sys

COEF_M = 1
RATIO_M_P = int(sys.argv[1])
COEF_P = COEF_M*RATIO_M_P
TAUX_MUTATION = int(sys.argv[2])
SCORE_MAX = 4 * COEF_P
LIMITE_TOUR = int(sys.argv[3])
POPULATION = int(sys.argv[4])

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

def eval(c, cj, cs):
    (pVirtuel, mVirtuel) = compare(c,cj)
    scoreVirtuel = score(pVirtuel, mVirtuel)
    (pReel, mReel) = compare(cj, cs)
    scoreReel = score(pReel, mReel)
    return abs(scoreReel - scoreVirtuel)

def fitness(c, solutionsJouees, cs):
    fit = 0
    for j, solution in enumerate(solutionsJouees):
        fit += eval(c, solution, cs)
    return fit/len(solutionsJouees)

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

def mutePop(pop):
    newPop = []
    for i in range(len(pop)):
        newPop.append(mutation(pop[i]))
    return newPop

def croisement(c1, c2):
    chance = random.randrange(3)
    if(chance == 0):
        return([[c1[0], c1[1], c1[2], c2[3]], -1])
    if(chance == 1):
        return([[c1[0], c1[1], c2[2], c2[3]], -1])
    if(chance == 2):
        return([[c1[0], c2[1], c2[2], c2[3]],-1])

def crossPop(pop):
    newPop = []
    newPop.append(pop[0])
    while(len(newPop) < POPULATION):
        newPop.append(croisement(pop[random.randrange(POPULATION/2)][0], pop[random.randrange(POPULATION/2)][0]))
    return newPop

def extractFitness(s):
    return s[1]

def isEqual(c1, c2):
    for i in range(4):
        if (c1[i] != c2[i]):
            return False
    return True

def selection(pop):
    bests = []
    bests.append(pop[0])
    sumFitness = sum(list(map(extractFitness, pop[1:])))
    maxFitness = extractFitness(max(pop[1:], key=extractFitness))
    weights = [(maxFitness - x[1])/(sumFitness) for x in pop[1:]]
    bests.extend(random.choices(pop[1:], weights=weights, k=int(len(pop[1:])/2)))
    return(bests)

if __name__ == "__main__":

    f = open(sys.argv[5], "a+")

    # Creation de la solution
    CS = createSol()
    # print(f'Solution : {CS}')
    solutionTrouvee = False

    # Creation de la solution initiale
    CI = createSol()
    scoreReel = score(*compare(CS, CI))
    # print(f'Solution initiale : {CI}, score : {scoreReel}')

    # Ajout de la solution aux solutions jouées
    solutionsJouees = [CI]

    # Création de la population
    pop = createPop(POPULATION)

    k = 0

    for i in range(len(pop)):
            pop[i][1] = fitness(pop[i][0], solutionsJouees, CS)

    while not solutionTrouvee and k < LIMITE_TOUR:
        pop.sort(key=extractFitness)
        pop = selection(pop)
        pop.sort(key=extractFitness)
        pop = crossPop(pop)
        pop = mutePop(pop)
        # Evaluation
        for i in range(len(pop)):
            pop[i][1] = fitness(pop[i][0], solutionsJouees, CS)
        pop.sort(key=extractFitness)
        solutionsJouees.append(pop[0][0])
        # print(f'solution proposée : {pop[0]}')
        solutionTrouvee = isEqual(pop[0][0], CS)

        for i in range(len(pop)):
            pop[i][1] = fitness(pop[i][0], solutionsJouees, CS)

        k += 1
    
    # if solutionTrouvee:
        # print(f"Solution trouvée : {solutionsJouees[-1:]} VS {CS} en {len(solutionsJouees)} tours")
    # else:
        # print(f"Solution non trouvée : {solutionsJouees[-1:]} VS {CS} en {len(solutionsJouees)} tours")

    f.write(f'{len(solutionsJouees)},{solutionTrouvee},"{RATIO_M_P}",{TAUX_MUTATION},{POPULATION},{LIMITE_TOUR}\n')
    f.close()
