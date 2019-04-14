import numpy as np
import pandas as pd

# TODO: Document functions in sequential model class
# TODO: Write a fit function for class so not doing manually

class SequentialModel:
	def __init__(self, base_model, HR_model, cutoff=0.10, prefit=True):
		self.base_model = base_model
		self.HR_model = HR_model
		self.cutoff = cutoff
		self.prefit = prefit

	def predict_proba(self, X):
		initial_risk = self.base_model.predict_proba(X)
		hr_risk = self.HR_model.predict_proba(X)

		risk = np.where(initial_risk[:, 1] >= self.cutoff, hr_risk[:, 1], initial_risk[:, 1])
		risk = np.array([1-risk, risk]).T
		return risk