# HeartUp

All-in-one cardiac digital twin widget including personalized holographic 1) healthy and 2) abnormal heartbeat simulations and AI-ML driven risk prediction for long-term health outcomes to empower patient-provider interactions and provide additional considerations in holistic care. This streamlines the explanation of complex cardiological diagnoses such as atrial fibrillation. AI-ML models are constructed using genetic, environmental, lifestyle, and personalized health information, including data from patients' charts. Models provide predictive risk scores of future events or conditions occurring that existing tools cannot anticipate, such as iron-deficiency anemia in the case of atrial fibrillation. 

Current companies have been able to use Fitbit data to detect and notify patients of emergency arrhythmias but have lagged in areas of more complex pathology. Clotting emergencies such as pulmonary embolism and stroke place substantial stress on the healthcare system and involve many high-order interactions of different physical/biological stimuli.

By augmenting our ECG data inputs with laboratory blood tests and leveraging state-of-the-art AI models, we can more efficiently identify the complex nonlinear/synergistic effects of different clotting factors and how their interplay is affected by the changes in flow induced by arrhythmia. By flagging patients at risk of a clotting event, providers can intervene earlier with low-cost therapies (blood thinners?), saving both patient lives and vital resources for the healthcare system.

### Data Files
All additional data files are available on Google Drive due to Github's storage limitations. 

[Data/Output Google Drive](https://drive.google.com/drive/folders/1FI2YUl5tPj-B_HsUYBclEO3AYK01i9hj?usp=sharing)

This includes input datasets, model training history, evaluation results, and final model output files:
- **data/ECGModel**: Contains raw ECG datasets for training and testing (`mitbih_test.csv`, `mitbih_train.csv`, `ptbdb_abnormal.csv`, `ptbdb_normal.csv`).
- **data/heart**: Heart dataset (`heart.csv`) for model training and evaluation.
- **output/ecg**:
  - `confusion_matrix`: Stores the confusion matrices generated for ECG-based model evaluations.
  - `final_results`: Stores the final evaluation results.
  - `training_history.csv` and `training_history`: Record the training progression of the ECG models.
- **output/heart/models**: Trained models are saved here, with the best model stored as `best_model.pth`.
- **output/heart/plots**: Contains various visualizations, such as:
  - `confusion_matrix`: Shows prediction accuracy.
  - `correlation_matrix`: Displays feature correlations within the heart dataset.
  - `roc_curve`: Illustrates the ROC curves for trained models.
  - `training_history`: Records the training progress.
- **output/heart/results**:
  - `classification_report`: Detailed classification metrics.
  - `data_info`: Dataset structure and statistics.
  - `training_info`: Overview of the training process.
- **output/heart**:
  - `catboost_report`: CatBoost-specific classification results.
  - `data_info`: Saved descriptions of the dataset used.
  - `training_info`: Contains details about training set configurations.

## Installation
1. **Clone the repository**:
   
   git clone https://github.com/HannahNJIT/HeartUp.git

2. 
