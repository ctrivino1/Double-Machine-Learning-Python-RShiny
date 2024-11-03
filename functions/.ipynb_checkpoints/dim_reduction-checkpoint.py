
from sklearn.linear_model import  ElasticNetCV
import pandas as pd
from sklearn.model_selection import KFold
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
from sklearn.model_selection import cross_val_predict
from sklearn.preprocessing import StandardScaler
from sklearn.datasets import make_regression
from sklearn.model_selection import train_test_split
import numpy as np
  



def evaluate_lasso_regression(target, df):
    # Scale the features with StandardScaler
    ss = StandardScaler()
    
    if target == 'MC Rt.':
      mc_drop_cols = ['Month of Aggregation Selection','AA Rt.','TF Rt.','FMC Rt.', 'PMC Rt.','Field Rt.', 'NMCMsubNA Rt.', 'NMCSsubNA Rt.',
       'NMCBsubNA Rt.', 'NMCM Rt.', 'NMCMU Rt.', 'NMCSA Rt.', 'NMCB Rt.','NMCA Rt.',
       'NMC Rt.', 'PMCS Rt.', 'NMCMA Rt.', 'NMCMS Rt.', 'NMCMUA Rt.','NMCS Rt.', 'NMCBS Rt.', 'NMCBSA Rt.','TPMCM Rt.', 'TPMCS Rt.',
        'TAIAA Rt.', 'TAINoAA Rt.','PMCM Rt.', 'PMCB Rt.', 'NMCBA Rt.',
       'NMCBU Rt.', 'TNMCM Rt.', 'TNMCMS Rt.', 'TNMCS Rt.','NMCBUA Rt.','Cannot Duplicate',
       'Status Assigned Available Hr. Am.',
       'Status Assigned Depot Hr. Am',
       'Status Assigned Depot Possessed Mod. Hr. Am.',
       'Status Assigned Hr. Am.',
       'Status Assigned NMCB Hr. Am.',
       'Status Assigned NMCM Hr. Am.',
       'Status Assigned NMCMS Hr. Am.',
       'Status Assigned NMCMU Hr. Am.',
       'Status Assigned NMCS Hr. Am.',
       'Status Assigned Not Reported Hr. Am.',
       'Status Assigned PDM Hr. Am.',
       'Status Assigned Possessed Hr. Am.',
       'Status Assigned UDLM Hr. Am.',
       'Status Possessed FMC Hr. Am.',
       'Status Possessed Hr. Am.',
       'Status Depot Hr. Am.',
       'Status Possessed NMCBS Hr. Am.',
       'Status Possessed NMCBSA Hr. Am.',
       'Status Possessed NMCBU Hr. Am.',
       'Status Possessed NMCBUA Hr. Am.',
       'Status Possessed NMCMS Hr. Am.',
       'Status Possessed NMCMSA Hr. Am.',
       'Status Possessed NMCMU Hr. Am.',
       'Status Possessed NMCMUA Hr. Am.',
       'Status Possessed NMCS Hr. Am.',
       'Status Possessed NMCSA Hr. Am.',
       'Status Possessed PMCB Hr. Am.',
       'Status Possessed PMCM Hr. Am.',
       'Status Possessed PMCS Hr. Am.',
       'Status Possessed AA Rate Hr. Am.',
       'Status Possessed FMC Rate Hr. Am.',
       'Status Possessed MC Rate Hr. Am.',
       'Status Possessed NMC Rate Hr. Am.',
       'Status Possessed NMCA Rate Hr. Am.',
       'Status Possessed NMCB Rate Hr. Am.',
       'Status Possessed NMCBA Rate Hr. Am.',
       'Status Possessed NMCBS Rate Hr. Am.',
       'Status Possessed NMCBSA Rate Hr. Am.',
       'Status Possessed NMCBU Rate Hr. Am.',
       'Status Possessed NMCBUA Rate Hr. Am.',
       'Status Possessed NMCM Rate Hr. Am.',
       'Status Possessed NMCMA Rate Hr. Am.',
       'Status Possessed NMCMS Rate Hr. Am.',
       'Status Possessed NMCMSA Rate Hr. Am.',
       'Status Possessed NMCMU Rate Hr. Am.',
       'Status Possessed NMCMUA Rate Hr. Am.',
       'Status Possessed NMCS Rate Hr. Am.',
       'Status Possessed NMCSA Rate Hr. Am.',
       'Status Possessed PMC Rate Hr. Am.',
       'Status Possessed PMCB Rate Hr. Am.',
       'Status Possessed PMCM Rate Hr. Am.',
       'Status Possessed PMCS Rate Hr. Am.',
       'Status Possessed TF Rate Hr. Am.',
       'Status Possessed TNMCM Rate Hr. Am.',
       'Status Possessed TNMCMS Rate Hr. Am.',
       'Status Possessed TNMCMU Rate Hr. Am.',
       'Status Possessed TNMCS Rate Hr. Am.',
       'Status Possessed TPMCM Rate Hr. Am.',
       'Status Possessed TPMCS Rate Hr. Am.',
       'Status Possessed NMCM Na Rate Hr. Am.',
       'Status Possessed NMCB Na Rate Hr. Am.',
       'Status Possessed NMCS Na Rate Hr. Am.',
       'Status Possessed TNMCM Na Rate Hr. Am.',
       'Status Possessed TNMCS Na Rate Hr. Am.',
       'Status TAI AA Hr. Am.',
       'Status TAI Hr. Am.',
       'Status TAI No AA Hr. Am.',
       'Status UPNR Hr. Am.','dt_time','dt_time_year','row_id']
    
    if len(np.unique(df.MDS) == 1 ):
      mc_drop_cols = mc_drop_cols + ['MDS']
    print('drop_cols :',len(mc_drop_cols))
    df = df.drop(mc_drop_cols,axis = 1)
    print('computing get_dummies')
    X = pd.get_dummies(df.drop([target],axis=1))
    print('finished get dummies')
    y = df[target]
    X_scaled = ss.fit_transform(X)
    # Split the data into training and test sets
    X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.3, random_state=42)

    print("fitting the model")
    # Initialize and fit the Lasso model to the training data
    lasso = ElasticNetCV(cv=10, n_jobs=-1, random_state=0, max_iter=100000)
    lasso.fit(X_train, y_train)
    print('model fitted')

    # Get the names of the selected features with non-zero coefficients
    coefficients = lasso.coef_
    selected_indices = coefficients.nonzero()[0]
    selected_feature_names = X.columns[selected_indices]

    # Make predictions on the test set
    y_pred_test = lasso.predict(X_test)

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

    features = list(selected_feature_names)
    print(features)
    extracted_base = [obj.split('_')[-1] for obj in features if obj.startswith('base')]
    extracted_sn_id = [obj.split('_')[-1] for obj in features if obj.startswith('acft')]
    extracted_MDS = [obj.split('_')[-1] for obj in features if obj.startswith('MDS')]
    rate_list = [obj for obj in features if not (obj.startswith('MDS') or obj.startswith('acft')  or obj.startswith('base') or obj.startswith('Status'))]

    v = {
    "rates_list": rate_list,
    "mds_list": extracted_MDS,
    "base_list": extracted_base,
    "sn_id_list": extracted_sn_id
    }

    # Return the selected feature names and the evaluation metrics DataFrame
    return v, df_metrics
