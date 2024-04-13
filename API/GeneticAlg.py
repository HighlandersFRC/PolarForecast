import copy
import random
import numpy as np
import pandas as pd


class geneticAlg:
    def __init__(
        self,
        errorFunction,
        functionInputs,
        startingValue: pd.DataFrame,
        mutationPercent: float,
    ) -> None:
        self.errorFunction = errorFunction
        self.startingValue = startingValue
        self.mutationPercent = mutationPercent
        self.numParents = 3
        self.populationSize = 0
        for i in range(self.numParents+1):
            self.populationSize += i
        self.functionInputs = functionInputs

    def mutate_gene(self, current_value, sigma):
        mutated_value = current_value + np.random.normal(0, sigma)
        if mutated_value<0:
            return 0
        else:
            return mutated_value

    def mutateGenes(self, mutant: pd.DataFrame) -> pd.DataFrame:
        mutant = copy.deepcopy(mutant)
        for column in mutant.columns:
            if column != "team_number":
                for index, value in mutant[column].items():
                    rand = random.random()
                    if rand < self.mutationPercent:
                        mutant.at[index, column] = self.mutate_gene(
                            value,
                            1.0,
                        )
        return mutant

    def reproduce(
        self,
        parent1: pd.DataFrame,
        parent2: pd.DataFrame,
    ) -> pd.DataFrame:
        mask = np.random.randint(0, 2, size=parent1.shape).astype(bool)
        child1 = np.where(mask, parent1, parent2)
        return pd.DataFrame(child1)

    def generateOriginalPopulation(self, startingValue: pd.DataFrame) -> list:
        population = []
        population.append(pd.DataFrame(copy.deepcopy(startingValue)))
        while len(population) < self.populationSize:
            population.append(self.mutateGenes(startingValue))
        return population

    def generateNewPopulation(self, parents: list) -> list:
        population = []
        for i in range(self.numParents - 1):
            for j in range(i + 1, self.numParents):
                population.append(
                    self.mutateGenes(self.reproduce(parents[i], parents[j]))
                )
        population.extend(parents)
        return population

    def getParents(self, population: list) -> list:
        returnPopulation = []
        parentsFound = False
        while not parentsFound:
            for i in range(int(len(population)/2)):
                if self.errorFunction(population[i*2], self.functionInputs) < self.errorFunction(population[i*2+1], self.functionInputs):
                    returnPopulation.append(population[i*2])
                else:
                    returnPopulation.append(population[i*2+1])
                if len(returnPopulation) == self.numParents:
                    parentsFound = True
                    break
        return returnPopulation

    def setBestSolution(self, population: list):
        population = copy.deepcopy(population)
        errors = []
        for agent in population:
            errors.append(self.errorFunction(agent, self.functionInputs))
        rank1error = min(errors)
        if self.bestSolutionError > rank1error or self.bestSolutionError < 0:
            self.improved = True
            self.bestSolution = population[errors.index(rank1error)]
            self.bestSolutionError = rank1error
        else:
            self.improved = False

    def run(self):
        np.random.seed(1186244499)
        self.population = self.generateOriginalPopulation(self.startingValue)
        self.bestSolutionError = -1.0
        self.setBestSolution(self.population)
        foundSolution = False
        self.generationsSinceImprovement = 0
        generationNumber = 0
        while not foundSolution:
            self.parents = self.getParents(self.population)
            self.population = self.generateNewPopulation(self.parents)
            self.setBestSolution(self.population)
            if self.improved:
                self.generationsSinceImprovement = 0
            else:
                self.generationsSinceImprovement += 1
            if self.generationsSinceImprovement >= 25:
                foundSolution = True
            if generationNumber > 1500:
                foundSolution = True
            generationNumber += 1
            # print("generation", generationNumber)
            # print("error", self.bestSolutionError)
        return [self.bestSolution, self.bestSolutionError]
