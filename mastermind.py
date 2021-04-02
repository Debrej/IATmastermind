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
    return scoreReel - scoreVirtuel

def fitness(c):
    fit = 0
    for j, solution in enumerate(solutionsJouees):
        fit += eval(c,solution)
    return fit/len(solutionsJouees)

if __name__ == "__main__":
  (p,m) = compare(CS, [1,4,7,3])
  print(f'score de (1,4,7,3) : {score(p,m)}')
  s = createSol()
  print(s)
