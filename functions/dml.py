import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning) 
# import warnings filter
from warnings import simplefilter
# ignore all future warnings
simplefilter(action='ignore', category=FutureWarning)
import numpy as np
import pandas as pd
from sklearn.datasets import fetch_california_housing
from sklearn.model_selection import train_test_split
from xgboost import XGBRegressor
import matplotlib.pyplot as plt
import sklearn
from sklearn.metrics import mean_squared_error, mean_absolute_error
from sklearn.metrics import r2_score
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score
from sklearn.inspection import permutation_importance
import doubleml as dml


from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LassoCV, LogisticRegressionCV
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.tree import DecisionTreeClassifier, DecisionTreeRegressor
from sklearn.pipeline import make_pipeline

from xgboost import XGBClassifier, XGBRegressor

import matplotlib.pyplot as plt
import seaborn as sns
import optuna
pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)


def xgb_classifcation(X_train, X_test, y_train, y_test):
  def objective(trial):
    # XGBoost Classifier
    np.random.seed(123)
    xgb_model = XGBClassifier(n_jobs=-1,random_state=42,learning_rate=trial.suggest_float('xgb_learning_rate', 0.01, 0.1),
                              n_estimators=trial.suggest_int('xgb_n_estimators', 50, 200),
                              max_depth=trial.suggest_int('xgb_max_depth', 3, 10),
                              min_child_weight=trial.suggest_int('xgb_min_child_weight', 1, 5),)
     
    xgb_model.fit(X_train, y_train)
    xgb_predictions = xgb_model.predict(X_test)
    xgb_accuracy = accuracy_score(y_test, xgb_predictions)
    return 1 - xgb_accuracy  # Optuna minimizes the objective function, so we use 1 - accuracy
  np.random.seed(123)
  study = optuna.create_study(direction='minimize')
  study.optimize(objective, n_trials=10,n_jobs=-1)  # You can adjust the number of trials as needed
 

    # Get the best hyperparameters
  best_params = study.best_params

    # Train the models with the best hyperparameters
  xgb_class_model = XGBClassifier(n_jobs=-1,random_state=42,
        learning_rate=best_params['xgb_learning_rate'],
        n_estimators=best_params['xgb_n_estimators'],
        max_depth=best_params['xgb_max_depth'],
        min_child_weight=best_params['xgb_min_child_weight'],
    )
<<<<<<< HEAD
  #print("best_params")
  #print(best_params)
=======
  print("best_params")
  print(best_params)
>>>>>>> 7cb5fa1f79ac18c316ece23f808f7906504c4897
   
  return xgb_class_model
 
def xgb_regressor(X_train, X_test, y_train, y_test):
    def objective(trial):
        np.random.seed(123)
        # XGBoost Classifier
        xgb_model = XGBRegressor(n_jobs=-1,random_state=42,
                                learning_rate=trial.suggest_float('xgb_learning_rate', 0.01, 0.1),
                                n_estimators=trial.suggest_int('xgb_n_estimators', 50, 200),
                                max_depth=trial.suggest_int('xgb_max_depth', 3, 10),
                                min_child_weight=trial.suggest_int('xgb_min_child_weight', 1, 5),
                                )
        xgb_rmse = run_and_evaluate_model(xgb_model, X_train, X_test, y_train, y_test)



        return xgb_rmse  # Optuna minimizes the objective function, so we use 1 - accuracy
    np.random.seed(123)
    study = optuna.create_study(direction='minimize')
    study.optimize(objective, n_trials=10,n_jobs=-1)  # You can adjust the number of trials as needed
 

    # Get the best hyperparameters
    best_params = study.best_params

    # Train the models with the best hyperparameters
    xgb_model = XGBRegressor(n_jobs=-1,random_state=42,
                             learning_rate=best_params['xgb_learning_rate'],
                             n_estimators=best_params['xgb_n_estimators'],
                             max_depth=best_params['xgb_max_depth'],
                             min_child_weight=best_params['xgb_min_child_weight']
                             )
<<<<<<< HEAD
    #print("best_params")
    #print(best_params)
=======
    print("best_params")
    print(best_params)
>>>>>>> 7cb5fa1f79ac18c316ece23f808f7906504c4897
   

    return xgb_model

def run_and_evaluate_model(model, X_train, X_test, y_train, y_test):
    np.random.seed(123)
    model.fit(X_train, y_train)
    predictions = model.predict(X_test)
    rmse = mean_squared_error(y_test, predictions,squared=False)
    return rmse
 
def accuracy_score_model(model, X_train, X_test, y_train, y_test):
    np.random.seed(123)
    model.fit(X_train, y_train)
    predictions = model.predict(X_test)
    rmse = mean_squared_error(y_test, predictions,squared=False)
    return rmse



def optimize_and_update_models_classifier(X_train, X_test, y_train, y_test):
    np.random.seed(123)
    def objective(trial):
        np.random.seed(123)
        # Logistic RegressionCV
        log_reg_model = LogisticRegressionCV(n_jobs=-1,random_state=42,
            Cs=[trial.suggest_float('log_reg_C', 1e-5, 10, log=True)],
            cv=5  # Number of folds for cross-validation
        )
        log_reg_model.fit(X_train, y_train)
        log_reg_predictions = log_reg_model.predict(X_test)
        log_reg_accuracy = accuracy_score(y_test, log_reg_predictions)

        # XGBoost Classifier
        xgb_model = XGBClassifier(n_jobs = -1,random_state=42,
            learning_rate=trial.suggest_float('xgb_learning_rate', 0.01, 0.1),
            n_estimators=trial.suggest_int('xgb_n_estimators', 50, 200),
            max_depth=trial.suggest_int('xgb_max_depth', 3, 10),
            min_child_weight=trial.suggest_int('xgb_min_child_weight', 1, 5),
        )
        xgb_model.fit(X_train, y_train)
        xgb_predictions = xgb_model.predict(X_test)
        xgb_accuracy = accuracy_score(y_test, xgb_predictions)

        # Random Forest Classifier
        rf_model = RandomForestClassifier(n_jobs=-1,random_state=42,
            n_estimators=trial.suggest_int('rf_n_estimators', 50, 200),
            max_depth=trial.suggest_int('rf_max_depth', 2, 8),
            min_samples_split=trial.suggest_int('rf_min_samples_split', 2, 10),
        )
        rf_model.fit(X_train, y_train)
        rf_predictions = rf_model.predict(X_test)
        rf_accuracy = accuracy_score(y_test, rf_predictions)


        overall_accuracy = log_reg_accuracy + xgb_accuracy + rf_accuracy

        return 3 - overall_accuracy  # Optuna minimizes the objective function, so we use 1 - accuracy
    study = optuna.create_study(direction='minimize')
    study.optimize(objective, n_trials=10,n_jobs=-1)  # You can adjust the number of trials as needed
 

    # Get the best hyperparameters
    best_params = study.best_params

    # Train the models with the best hyperparameters
    log_reg_class_model = LogisticRegressionCV(n_jobs=-1,random_state=42,
        Cs=[best_params['log_reg_C']],
        cv=5  # Number of folds for cross-validation
    )
    xgb_class_model = XGBClassifier(n_jobs = -1,random_state=42,
        learning_rate=best_params['xgb_learning_rate'],
        n_estimators=best_params['xgb_n_estimators'],
        max_depth=best_params['xgb_max_depth'],
        min_child_weight=best_params['xgb_min_child_weight'],
    )
    rf_class_model = RandomForestClassifier(n_jobs = -1,random_state=42,
        n_estimators=best_params['rf_n_estimators'],
        max_depth=best_params['rf_max_depth'],
        min_samples_split=best_params['rf_min_samples_split'],
    )

    return log_reg_class_model, xgb_class_model, rf_class_model

 
def optimize_and_update_models_parallel_continuous(X_train, X_test, y_train, y_test):
    np.random.seed(123)
    def objective(trial):
        np.random.seed(123)
        lasso_model = LassoCV(alphas=[trial.suggest_float('lasso_alpha', 1e-5, 10)], cv=5, n_jobs=-1,random_state=42)
        lasso_model.fit(X_train, y_train)
        lasso_predictions = lasso_model.predict(X_test)
        lasso_rmse = mean_squared_error(y_test, lasso_predictions,squared=False)
       

        xgb_model = XGBRegressor(n_jobs=-1,random_state=42,
                                learning_rate=trial.suggest_float('xgb_learning_rate', 0.01, 0.1),
                                n_estimators=trial.suggest_int('xgb_n_estimators', 50, 200),
                                max_depth=trial.suggest_int('xgb_max_depth', 3, 10),
                                min_child_weight=trial.suggest_int('xgb_min_child_weight', 1, 5),
                                )
        xgb_rmse = run_and_evaluate_model(xgb_model, X_train, X_test, y_train, y_test)
       

        rf_model = RandomForestRegressor(n_jobs=-1,random_state=42,
                                         n_estimators=trial.suggest_int('rf_n_estimators', 50, 200),
                                         max_depth=trial.suggest_int('rf_max_depth', 2, 8),
                                         min_samples_split=trial.suggest_int('rf_min_samples_split', 2, 10),
                                         )
        rf_rmse = run_and_evaluate_model(rf_model, X_train, X_test, y_train, y_test)

        overall_mse = lasso_rmse + xgb_rmse + rf_rmse

        return overall_mse

    # Create the Optuna study with parallel processing
    study = optuna.create_study(direction='minimize')

    # Optimize the objective function
    study.optimize(objective, n_trials=10, show_progress_bar=False,n_jobs=-1)

    # Get the final best parameters
    best_params = study.best_params


    # Train the final models with the best parameters
<<<<<<< HEAD
    lasso_model = LassoCV(alphas=[best_params['lasso_alpha']],max_iter=1000000,tol = 1e-2, cv=5, n_jobs=-1,verbose=False,random_state=42)
=======
    lasso_model = LassoCV(alphas=[best_params['lasso_alpha']],max_iter=100000, cv=5, n_jobs=-1,verbose=False,random_state=42)
>>>>>>> 7cb5fa1f79ac18c316ece23f808f7906504c4897

    xgb_model = XGBRegressor(n_jobs=-1,random_state=42,
                             learning_rate=best_params['xgb_learning_rate'],
                             n_estimators=best_params['xgb_n_estimators'],
                             max_depth=best_params['xgb_max_depth'],
                             min_child_weight=best_params['xgb_min_child_weight']
                             )

    rf_model = RandomForestRegressor(n_jobs=-1,random_state=42,
                                     n_estimators=best_params['rf_n_estimators'],
                                     max_depth=best_params['rf_max_depth'],
                                     min_samples_split=best_params['rf_min_samples_split']
                                     )

    return lasso_model, xgb_model, rf_model

def dml_func(data,outcome,treatments=None,cov=None,n_treatments=None):
  optuna.logging.set_verbosity(optuna.logging.WARNING)
  print("treatments: ", treatments)
  print("n_treatments: ",n_treatments)
<<<<<<< HEAD
  date_columns = data.select_dtypes(include='datetime64').columns 
  print("date columns :",date_columns)
  timestamp_columns = data.select_dtypes(include='datetime64[ns, UTC]').columns 
  print("timestamp_columns", timestamp_columns)
  # Combine date and timestamp columns
  columns_to_drop = date_columns.union(timestamp_columns) 
  # Drop identified columns
  data = data.drop(columns=columns_to_drop)
  og_cols = data.columns
  # (get rid of this in production: #########################
  ###drop time columns (specific for this example) #######
  data = data.drop(['dt_mo_cd','dt_time'],axis=1)
  ############################################################
  string_treatments = [col for col in data.columns if data[col].dtype == 'O' and col in treatments]
  string_treatments_dummies = []
  for col in string_treatments:
    treatment_dummies = pd.get_dummies(data[col], prefix=col, sparse=True)
    string_treatments_dummies.extend(treatment_dummies.columns.tolist())
    data = pd.concat([data.drop(columns=[col]), treatment_dummies], axis=1)
  
  #data = pd.get_dummies(data,sparse=True)
=======
  data = pd.get_dummies(data,sparse=True)
>>>>>>> 7cb5fa1f79ac18c316ece23f808f7906504c4897
  data = data.apply(lambda col: pd.to_numeric(col, errors='coerce')).astype(float)
  np.random.seed(123)
  X = pd.DataFrame(data.drop([outcome],axis=1), columns=data.drop([outcome],axis=1).columns)
  y = data[outcome]
  # check if outcome is binary
  unique_values = data[outcome].unique()
  outcome_is_binary = len(unique_values) == 2 and all(val in [0.0, 1.0] for val in unique_values)
  scaler = StandardScaler()
  X_scaled = scaler.fit_transform(X) # Step 2: Transform the training and test data
  X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2, random_state=42)
 
  if treatments is None:
    print("No treatments given")
    if outcome_is_binary:
      print("Outcome is binary")
      np.random.seed(123)
      xgb_model = xgb_classifcation(X_train, X_test, y_train, y_test)
      xgb_model.fit(X_train, y_train)

      # Perform permutation feature importance
      perm_importance = permutation_importance(xgb_model, X_test, y_test, n_repeats=100, random_state=42,n_jobs=-1)


      # Create a DataFrame for permutation importances
      importances_df = pd.DataFrame({'Feature': X.columns, 'Importance': perm_importance.importances_mean})
      importances_df = importances_df.sort_values(by='Importance', ascending=False).reset_index(drop=True)


      n = int(n_treatments)
      treatments = importances_df.Feature.head(n).tolist()
      print("Outcome: ", outcome)
      print("Treatments :", treatments)
     
    else:
      print("Outcome is continuous")
      np.random.seed(123)
      xgb_model = xgb_regressor(X_train, X_test, y_train, y_test)
      xgb_model.fit(X_train, y_train)

      # Perform permutation feature importance
      print("perm feature importance")
      perm_importance = permutation_importance(xgb_model, X_test, y_test, n_repeats=100, random_state=42,n_jobs=-1)


      # Create a DataFrame for permutation importances
      importances_df = pd.DataFrame({'Feature': X.columns, 'Importance': perm_importance.importances_mean})
      importances_df = importances_df.sort_values(by='Importance', ascending=False).reset_index(drop=True)


      n = int(n_treatments)
      treatments = importances_df.Feature.head(n).tolist()
      print("Outcome: ", outcome)
      print("Treatments :", treatments)
  else:
    n = len(treatments)
    treatments = treatments
   
<<<<<<< HEAD
  binary_columns = [col for col in X.columns if set(data[col].unique()) == {0.0, 1.0}] 
  binary_treatments = [value for value in binary_columns if value in treatments] + string_treatments_dummies
=======
  binary_columns = [col for col in X.columns if set(data[col].unique()) == {0.0, 1.0}]
  binary_treatments = [value for value in binary_columns if value in treatments]
>>>>>>> 7cb5fa1f79ac18c316ece23f808f7906504c4897
  print("binarytreatments: ",binary_treatments)
  continuous_treatments = [col for col in X.columns if len(X[col].unique()) > 2 and col in treatments]
  print("continuous_treatments: ",continuous_treatments)
 
  if binary_treatments:
    if outcome_is_binary:
      np.random.seed(123)
      print("Binary treatments with binary outcome")
      ml_g = xgb_classifcation(X_train, X_test, y_train, y_test)
    else:
      np.random.seed(123)
      print("Binary treatments with continuous outcome")
      ml_g = xgb_regressor(X_train, X_test, y_train, y_test)
    test_list = []
    for col in binary_treatments:
<<<<<<< HEAD
=======
      print('col :',col)
>>>>>>> 7cb5fa1f79ac18c316ece23f808f7906504c4897
      obj_dml_data = dml.DoubleMLData(data, outcome, col) 
      np.random.seed(123)
      dml_irm_obj = dml.DoubleMLIRM(obj_dml_data, ml_g, XGBClassifier(n_jobs=-1,random_state=42))  
      dat = dml_irm_obj.fit().summary
      dat['treatment'] = col
      dat['type'] = 'binary'
      test_list.append(dat)
   
    classifier_plr_summary =  pd.concat(test_list, ignore_index=True)
    classifier_plr_summary['method'] = 'xgb_classifier'
<<<<<<< HEAD
    
=======
>>>>>>> 7cb5fa1f79ac18c316ece23f808f7906504c4897
   
  if continuous_treatments:
    if outcome_is_binary:
      print("Continuous treatments and binary outcome")
      np.random.seed(123)
      log_reg_class_model, xgb_class_model, rf_class_model = optimize_and_update_models_classifier(X_train, X_test, y_train, y_test)
      ml_m =XGBRegressor(n_jobs=-1,random_state=42)
      # Initialize DoubleMLData (data-backend of DoubleML)
      data_dml_base = dml.DoubleMLData(data,
                                       y_col=outcome,
                                       d_cols=continuous_treatments,
                                       use_other_treat_as_covariate=True,
                                       x_cols=None)
      np.random.seed(123)
      dml_plr_forest = dml.DoubleMLPLR(data_dml_base,
                                 ml_l = rf_class_model,
                                 ml_m = RandomForestRegressor(n_jobs=-1,random_state=42),
                                 n_folds = 3)
      dml_plr_forest.fit(store_predictions=True)
      forest_summary = dml_plr_forest.summary


      np.random.seed(123)
      dml_plr_boost = dml.DoubleMLPLR(data_dml_base,
                                  ml_l = xgb_class_model,
                                  ml_m = XGBRegressor(n_jobs=-1,random_state=42),
                                  n_folds = 3)
      dml_plr_boost.fit(store_predictions=True)
      boost_summary = dml_plr_boost.summary
 
 
      # Lasso
      Cs = 0.0001*np.logspace(0, 4, 10)
      
      # Initialize DoubleMLPLR model
      np.random.seed(123)
      dml_plr_lasso = dml.DoubleMLPLR(data_dml_base,
                                ml_l = log_reg_class_model,
                                ml_m = LassoCV(n_jobs=-1,random_state=42),
                                n_folds = 3)

      dml_plr_lasso.fit(store_predictions=True)
      lasso_summary = dml_plr_lasso.summary
      plr_summary = pd.concat((lasso_summary, forest_summary, boost_summary))
      index_values = ['lasso', 'forest', 'xgboost']

      m = [item for item in index_values for _ in range(len(continuous_treatments))]
      plr_summary['method'] = m
      plr_smmary['type'] = 'continuous'
      plr_summary = plr_summary.reset_index().rename(columns={"index": "treatment"})
      # Calculate the mean coefficient across methods for each treatment
      plr_summary['ATE']= None
      #plr_summary['ATE'] = plr_summary.groupby('treatment').apply(lambda group: group['coef'].mean() if (group['P>|t|'] <= .05).all() else None).reset_index(drop=True)
      #plr_summary['ATE'] = plr_summary.groupby('treatment')['coef'].transform('mean')
      #plr_summary['ATE'] =  np.where((plr_summary['P>|t|'] <= 0.05).groupby(plr_summary['treatment']).transform('all'),
                             # plr_summary.groupby('treatment')['coef'].transform('mean'),
                              # None)
       
   
    else:
      np.random.seed(123)
      print("continuous treatments with continuous outcome")
      lasso_model, xgb_model, rf_model = optimize_and_update_models_parallel_continuous(X_train, X_test, y_train, y_test)
      rf_reg = rf_model
      xgb_reg = xgb_model
      lasso_reg = lasso_model

      # Initialize DoubleMLData (data-backend of DoubleML)
      data_dml_base = dml.DoubleMLData(data,
                                       y_col=outcome,
                                       d_cols=continuous_treatments,
                                       use_other_treat_as_covariate=True,
                                       x_cols=None)
     
      
      np.random.seed(123)
      dml_plr_forest = dml.DoubleMLPLR(data_dml_base,
                                 ml_l = rf_reg,
                                 ml_m = RandomForestRegressor(n_jobs=-1,random_state=42),
                                 n_folds = 3)
      dml_plr_forest.fit(store_predictions=True)
      forest_summary = dml_plr_forest.summary
      
 
      # xgb
      np.random.seed(123)
      dml_plr_boost = dml.DoubleMLPLR(data_dml_base,
                                  ml_l = xgb_reg,
                                  ml_m = XGBRegressor(n_jobs=-1,random_state=42),
                                  n_folds = 3)
      dml_plr_boost.fit(store_predictions=True)
      boost_summary = dml_plr_boost.summary

 
      # Lasso
      Cs = 0.0001*np.logspace(0, 4, 10)
      np.random.seed(123)
      # Initialize DoubleMLPLR model
      np.random.seed(123)
      dml_plr_lasso = dml.DoubleMLPLR(data_dml_base,
                                ml_l = lasso_reg,
<<<<<<< HEAD
                                ml_m = LassoCV(n_jobs=-1,cv=5, max_iter=1000000,tol = 1e-2,verbose=False,random_state=42),
=======
                                ml_m = LassoCV(n_jobs=-1,cv=5, max_iter=100000,verbose=False,random_state=42),
>>>>>>> 7cb5fa1f79ac18c316ece23f808f7906504c4897
                                n_folds = 3)
                                
      dml_plr_lasso.fit(store_predictions=True)
      lasso_summary = dml_plr_lasso.summary
      plr_summary = pd.concat((lasso_summary, forest_summary, boost_summary))
      index_values = ['lasso', 'forest', 'xgboost']

      m = [item for item in index_values for _ in range(len(continuous_treatments))]
      plr_summary['method'] = m
      plr_summary['type'] = 'continuous'
      plr_summary = plr_summary.reset_index().rename(columns={"index": "treatment"})
<<<<<<< HEAD
=======
      print("plr_summary")
      print(plr_summary)
>>>>>>> 7cb5fa1f79ac18c316ece23f808f7906504c4897
      # Calculate the mean coefficient across methods for each treatment
      plr_summary['ATE']= None
      #plr_summary['ATE'] = plr_summary.groupby('treatment').apply(lambda group: group['coef'].mean() if (group['P>|t|'] <= .05).all() else None).reset_index(drop=True)
      #plr_summary['ATE']=  np.where((plr_summary['P>|t|'] <= 0.05).groupby(plr_summary['treatment']).transform('all'),
                             # plr_summary.groupby('treatment')['coef'].transform('mean'),
                              #None)

     
  
  if binary_treatments and continuous_treatments:
    print("binary/continuous treatments")
    final_plr_summary=  pd.concat([plr_summary,classifier_plr_summary], ignore_index=True)
    final_plr_summary['Significant'] = final_plr_summary['P>|t|'] <= .05
    window_agg = final_plr_summary.query("Significant == True")
    winow_agg = window_agg.groupby('treatment')['coef'].mean()
    final_plr_summary['ATE'] = final_plr_summary['treatment'].map(winow_agg)
    final_plr_summary['ATE'] = np.where(final_plr_summary['Significant'],final_plr_summary['ATE'],np.nan)
<<<<<<< HEAD
=======
    
    
>>>>>>> 7cb5fa1f79ac18c316ece23f808f7906504c4897
    significant_treatments = final_plr_summary[['treatment','Significant', 'ATE']].drop_duplicates()
    empty = False
  elif binary_treatments and not continuous_treatments:
    print("binary treatments and not continuous")
    final_plr_summary = classifier_plr_summary
    final_plr_summary['Significant'] = final_plr_summary['P>|t|'] <= .05
    window_agg = final_plr_summary.query("Significant == True")
    window_agg = window_agg.groupby('treatment')['coef'].mean()
    final_plr_summary['ATE'] = final_plr_summary['treatment'].map(window_agg)
    final_plr_summary['ATE'] = np.where(final_plr_summary['Significant'],final_plr_summary['ATE'],np.nan)
    significant_treatments = final_plr_summary[['treatment','Significant', 'ATE']].drop_duplicates()
    empty = False
  elif continuous_treatments:
    print("continuous and not binary")
    final_plr_summary = plr_summary
    final_plr_summary['Significant'] = final_plr_summary['P>|t|'] <= .05
    window_agg = final_plr_summary.query("Significant == True")
    window_agg = window_agg.groupby('treatment')['coef'].mean()
    final_plr_summary['ATE'] = final_plr_summary['treatment'].map(window_agg)
    final_plr_summary['ATE'] = np.where(final_plr_summary['Significant'],final_plr_summary['ATE'],np.nan)
    significant_treatments = final_plr_summary[['treatment','Significant', 'ATE']].drop_duplicates()
    empty = False
    
  if (significant_treatments['Significant'] == False).all():
    empty = True
  else:
    pass
    
  
  final_plr_summary = final_plr_summary[['treatment','ATE','Significant','method','coef', 'std err', 't', 'P>|t|', '2.5 %', '97.5 %','type']]
  print("done with dml functions")
  return significant_treatments,final_plr_summary,empty
