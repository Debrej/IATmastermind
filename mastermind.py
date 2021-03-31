CS = [1,3,7,7]
solutionsJouees = []

def score(p,m):
    return 2*p+m

def compare(c1, c2):
    cVerif = ["r","r","r","r"]
    for i in c2:
         for j in c1:
             if c2[i] == c1[j]:
                 if i == j:
                     cVerif[j] = "p"
                     break
                 elif cVerif[j] == "r":
                     cVerif[j] = "m"
                     break
    p = 0
    m = 0
    for i in cVerif:
        if cVerif[i] == "p":
            p+=1
        elif cVerif[i] == "m":
            m+=1
    return (p,m)

def eval(c, cj):
    (pVirtuel, mVirtuel) = compare(c,cj)
    scoreVirtuel = score(pVirtuel, mVirtuel)
    (pReel, mReel) = compare(CS, cj)
    scoreReel = score(pReel, mReel)
    return scoreReel - scoreVirtuel

def fitness(c):
    fit = 0
    for j in solutionsJouees:
        fit += eval(c,solutionsJouees[j])
    return fit/len(solutionsJouees)
