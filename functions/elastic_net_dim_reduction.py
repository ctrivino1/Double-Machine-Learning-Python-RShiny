import optuna
from sklearn.linear_model import  ElasticNetCV
import pandas as pd
from sklearn.model_selection import KFold
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
from sklearn.model_selection import cross_val_predict
from sklearn.preprocessing import StandardScaler
from sklearn.datasets import make_regression
from sklearn.model_selection import train_test_split
from sklearn.model_selection import cross_val_score
import numpy as np
import re
import sys

sys.setrecursionlimit(10**9)
  
def optimize_elastic_net(X_train, y_train, n_trials):
    print('x_train :', X_train)
    print()
    print('y_train :', y_train.head())
    print()
    print('trials: ', n_trials)
    def objective(trial):
        # Hyperparameter range
        n_alphas = trial.suggest_int('n_alphas', 100, 1000)
        l1_ratio = trial.suggest_float('l1_ratio', 0.1, 1.0)

        # Create ElasticNetCV with suggested hyperparameters
        model = ElasticNetCV(l1_ratio=l1_ratio,n_alphas=n_alphas, random_state=0, max_iter=100000, n_jobs=-1)

        # Perform cross-validation with R2 scoring and return the mean
        score = cross_val_score(model, X_train, y_train, scoring='r2', cv=3, n_jobs=-1).mean()

        return score

    # Create study to optimize the objective function with proper direction
    study = optuna.create_study(direction='maximize')  # You want to maximize R2

    # Perform the optimization with the given number of trials
    study.optimize(objective, n_trials=n_trials)

    # Return the best hyperparameters
    best_params = study.best_params

    return best_params


def ENet_reg_dim_reduction(target, df):
    # Scale the features with StandardScaler
    ss = StandardScaler()
    print("target: ",target)
    print('df cols', df.columns)
    df = df.loc[:, (df != 0).any(axis=0)]
    print('Strings Columns :',df.select_dtypes(include=['object']).columns)
    print('computing get_dummies')
    X = pd.get_dummies(df.drop([target],axis=1))
    print('X cols',len(X.columns))
    print('finished get dummies')
    y = df[target]
    X_scaled = ss.fit_transform(X)
    # Split the data into training and test sets
    X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.3, random_state=42)
    best_params = optimize_elastic_net(X_train, y_train, n_trials=30) #change to a higher num in prod

    print("fitting the model")
    print("best_params ", best_params)
    # Initialize and fit the Lasso model to the training data
    en = ElasticNetCV(l1_ratio=best_params['l1_ratio'],n_alphas=best_params['n_alphas'],random_state=0, max_iter=10000,cv = 3,n_jobs=-1)
    #lasso = ElasticNetCV(random_state=0, max_iter=100000,cv = 2,n_jobs=-1)

    en.fit(X_train, y_train)
    print('model fitted')

    # Get the names of the selected features with non-zero coefficients
    coefficients = en.coef_
    selected_indices = coefficients.nonzero()[0]
    selected_feature_names = X.columns[selected_indices]
    # sorted_feature_names = [x for _, x in sorted(zip(coefficients[selected_indices], selected_feature_names), key=lambda pair: abs(pair[0]), reverse=True)]
    # sorted_feature_coefficients = [sorted(coefficients, key=lambda x: abs(x),reverse = True)]
    
    
    ##Testing
    selected_feature_coefficients = coefficients[selected_indices]
    selected_features_df = pd.DataFrame({'Features': selected_feature_names,'Coefficients': selected_feature_coefficients})
    print("testing df created")
    # Sort DataFrame by the absolute value of the 'Coefficients' column in descending order
    selected_features_df = selected_features_df.reindex(selected_features_df['Coefficients'].abs().sort_values(ascending=False).index)
    print("testing df sorted")
    
    ###
    # Define the regex pattern for case-insensitive matching
    #pattern = re.compile(r'^(?:mds|acft|base|status)', flags=re.IGNORECASE)
    pattern = re.compile(r'^(?:mds)', flags=re.IGNORECASE)
    print("pattern created")
    # Define the conditions
    conditions = selected_features_df['Features'].str.contains(pattern)
    print("conditions created")
    # Filter the DataFrame based on the conditions
    selected_features_df = selected_features_df[~conditions].reset_index(drop=True)
    print("selcted_features_df")
    print(selected_features_df.head())
    
    
    

    # Make predictions on the test set
    y_pred_test = en.predict(X_test)

    # Calculate evaluation metrics for the test set
    mse_test = mean_squared_error(y_test, y_pred_test)
    rmse_test = mean_squared_error(y_test, y_pred_test, squared=False)
    mae_test = mean_absolute_error(y_test, y_pred_test)
    r2_test = r2_score(y_test, y_pred_test)
    print('generating evaluation metric df')

    # Create a DataFrame with the evaluation metrics
    metrics_dict = {
        "Metric": ["Mean Squared Error (MSE)", "Root Mean Squared Error (RMSE)", "Mean Absolute Error (MAE)", "R-squared (R2)"],
        "Value": [mse_test, rmse_test, mae_test, r2_test]
    }

    df_metrics = pd.DataFrame(metrics_dict)


    # Return the selected feature names and the evaluation metrics DataFrame
    return selected_features_df, df_metrics
