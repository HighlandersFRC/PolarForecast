import copy
from datetime import datetime
import random
import numpy as np
import pandas as pd


class geneticAlg:
    def __init__(
        self,
        errorFunction,
        functionInputs,
        mins,
        maxs,
        startingValue: pd.DataFrame,
        mutationPercent: float,
    ) -> None:
        self.errorFunction = errorFunction
        self.startingValue = startingValue
        self.mutationPercent = mutationPercent
        self.generationNumber = 0
        self.numParents = 3
        self.populationSize = 0
        self.mins = mins
        self.maxs = maxs
        for i in range(self.numParents+1):
            self.populationSize += i
        self.functionInputs = functionInputs

    def clamp(self, min, max, value):
        return np.max([min, np.min([max, value])])

    def mutate_gene(self, current_value, max, min):
        sigma = 1  # (max - min)/(1.0+float(self.generationNumber)*0.05)
        mutated_value = np.random.normal(current_value, sigma)
        return mutated_value

    def mutateGenes(self, mutant: pd.DataFrame) -> pd.DataFrame:
        mutant = pd.DataFrame(copy.deepcopy(mutant))
        for column in mutant.columns:
            if column != "team_number" and column in self.mins:
                for index, value in mutant[column].items():
                    rand = np.random.random()
                    max = self.maxs[column]
                    min = self.mins[column]
                    mutant.at[index, column] = self.clamp(min, max, value)
                    if rand < self.mutationPercent:
                        mutant.at[index, column] = self.mutate_gene(
                            current_value=value,
                            max=max,
                            min=min,
                        )
        return mutant

    def reproduce(
        self,
        parent1: pd.DataFrame,
        parent2: pd.DataFrame,
    ) -> pd.DataFrame:
        mask = np.random.randint(0, 2, size=parent1.shape).astype(bool)
        child1 = np.where(mask, parent1, parent2)
        return pd.DataFrame(child1, columns=parent1.columns)

    def generateOriginalPopulation(self, startingValue: pd.DataFrame) -> list:
        population = []
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
        returnPopulation = copy.deepcopy(population)
        population.sort(key=lambda x: self.errorFunction(
            x, self.functionInputs))
        return returnPopulation[:self.numParents]

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
        np.random.seed(datetime.now().microsecond)
        self.population = self.generateOriginalPopulation(self.startingValue)
        self.bestSolutionError = -1.0
        self.setBestSolution(self.population)
        foundSolution = False
        self.generationsSinceImprovement = 0
        self.generationNumber = 0
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
            if self.generationNumber > 1500:
                foundSolution = True
            self.generationNumber += 1
        return [self.bestSolution, self.bestSolutionError]
