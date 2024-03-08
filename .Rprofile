
env_name <- "my_python_env"

# Create the virtual environment
reticulate::virtualenv_create(envname = env_name)

reticulate::virtualenv_install(env_name, 
                               packages = c("numpy","pandas","doubleml","xgboost","scikit-learn","optuna"))  # <- Add other packages here, if needed

# Install the required Python packages within the virtual environment
reticulate::use_virtualenv(env_name, required = TRUE)
