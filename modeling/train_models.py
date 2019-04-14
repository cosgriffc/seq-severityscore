import numpy as np
import pandas as pd

from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import BayesianRidge
from sklearn.impute import IterativeImputer
from sklearn.linear_model import LogisticRegressionCV, LogisticRegression
from sklearn.model_selection import StratifiedKFold, RandomizedSearchCV

from xgboost import XGBClassifier

import pickle

# TODO: Document functions
# TODO: Clean up sequential training

def train_logit(X, y):
	brm = BayesianRidge(n_iter=1000)
	iter_imp = IterativeImputer(estimator=brm, sample_posterior=True, 
		max_iter=25)
	logit_classifier = Pipeline([
		('impute', IterativeImputer(estimator=brm, sample_posterior=True, max_iter=25)),
		('center_scale', StandardScaler()),
		('logit', LogisticRegression(C=10**10, solver='lbfgs', max_iter=1000))])
	logit_classifier.fit(X, y)
	return logit_classifier

def train_xgb_rgridCV(X, y, params=None, K=10, n_iter=100, n_cpu=1, GPU=True):
	if params == None:
		params = {'objective': ['binary:logistic'], 
		'learning_rate': [0.01, 0.05, 0.10],
		'max_depth': [3, 6, 9, 12],
		'min_child_weight': [6, 8, 10, 12],
		'silent': [True],
		'subsample': [0.6, 0.8, 1],
		'colsample_bytree': [0.5, 0.75, 1],
		'n_estimators': [500, 1000]}

	if GPU:
		xgb_classifier = XGBClassifier(tree_method='gpu_hist', predictor='gpu_predictor')
	else:
		xgb_classifier = XGBClassifier()

	skf = StratifiedKFold(n_splits=K, shuffle=True, random_state=42)
	cv_grid_search = RandomizedSearchCV(xgb_classifier, param_distributions=params,
		n_iter=n_iter, scoring='neg_log_loss', n_jobs=n_cpu, cv=skf.split(X, y), 
		verbose=2, random_state=42)
	cv_grid_search.fit(X, y)
	xgb_classifier = cv_grid_search.best_estimator_
	xgb_classifier.fit(X, y)
	return xgb_classifier

def save_model(model, file_name):
	pickle.dump(model, open('./{0}'.format(file_name), 'wb'))

# Load training data
train_X = pd.read_csv('../extraction/data/train_X.csv').set_index('patientunitstayid').values
train_y = pd.read_csv('../extraction/data/train_y.csv').values.ravel()

#First train full cohort models
print('Training logistic regression model.')
logit_full = train_logit(X=train_X, y=train_y)
save_model(logit_full, 'logit_full')
print('Done, model saved.')

print('Training XGB model.')
xgb_full = train_xgb_rgridCV(X=train_X, y=train_y, K=10, n_cpu=4, GPU=True)
save_model(xgb_full, 'xgb_full')
print('Done, model saved.')

# Then train HR logit model at 0.10 cutoff
print('Using base logit model to identify HR (0.10) patients.')
logit_full = pickle.load(open('./logit_full', 'rb'))
initial_risk = logit_full.predict_proba(train_X)
train_X_HR = train_X[initial_risk[:, 1] >= 0.10, :]
train_y_HR = train_y[initial_risk[:, 1] >= 0.10]
print('Training HR logistic regression model.')
logit_HR = train_logit(X=train_X_HR, y=train_y_HR)
save_model(logit_HR, 'logit_HR')
print('Done, model saved.')

# Then train hHR logit model at 0.50 cutoff
print('Using base logit model to identify hHR patients.')
train_X_hHR = train_X[initial_risk[:, 1] >= 0.50, :]
train_y_hHR = train_y[initial_risk[:, 1] >= 0.50]
print('Training hHR logistic regression model.')
logit_hHR = train_logit(X=train_X_hHR, y=train_y_hHR)
save_model(logit_hHR, 'logit_hHR')
print('Done, model saved.')