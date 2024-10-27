import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import confusion_matrix, classification_report, roc_curve, auc
from catboost import CatBoostClassifier
from xgboost import XGBClassifier
from lightgbm import LGBMClassifier
import os
import json
from datetime import datetime
import warnings
warnings.filterwarnings("ignore")

class ResultSaver:
    def __init__(self, base_path):
        self.base_path = base_path
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # 创建输出目录结构
        self.dirs = {
            'root': os.path.join(base_path, f'experiment_{self.timestamp}'),
            'models': None,
            'plots': None,
            'results': None
        }
        
        self._create_directories()
        
    def _create_directories(self):
        for subdir in ['models', 'plots', 'results']:
            path = os.path.join(self.dirs['root'], subdir)
            os.makedirs(path, exist_ok=True)
            self.dirs[subdir] = path
            
    def save_plot(self, fig, name):
        plt.savefig(os.path.join(self.dirs['plots'], f'{name}.png'), 
                   bbox_inches='tight', dpi=300)
        plt.close(fig)
    
    def save_results(self, results, name):
        path = os.path.join(self.dirs['results'], f'{name}.json')
        with open(path, 'w') as f:
            json.dump(results, f, indent=4)
            
    def save_dataframe(self, df, name):
        path = os.path.join(self.dirs['results'], f'{name}.csv')
        df.to_csv(path, index=True)

class AdvancedHeartPredictor:
    def __init__(self, save_path):
        self.saver = ResultSaver(save_path)
        
    def prepare_data(self, data):
        # 首先打印数据信息以了解结构
        print("\nDataset Information:")
        print(data.info())
        print("\nColumn Names:")
        print(data.columns.tolist())
        
        # 保存数据描述
        data_info = {
            'columns': data.columns.tolist(),
            'shape': data.shape,
            'dtypes': data.dtypes.astype(str).to_dict()
        }
        self.saver.save_results(data_info, 'data_info')
        
        # 分析并保存数据分布
        plt.figure(figsize=(15, 8))
        data.hist(bins=30)
        plt.tight_layout()
        self.saver.save_plot(plt.gcf(), 'feature_distributions')
        
        # 相关性矩阵
        plt.figure(figsize=(12, 10))
        sns.heatmap(data.corr(), annot=True, cmap='coolwarm')
        plt.title('Feature Correlations')
        self.saver.save_plot(plt.gcf(), 'correlation_matrix')
        
        return data
    
    def train_models(self, X_train, X_test, y_train, y_test):
        # 保存训练集信息
        train_info = {
            'train_size': X_train.shape,
            'test_size': X_test.shape,
            'feature_names': X_train.columns.tolist() if isinstance(X_train, pd.DataFrame) else None
        }
        self.saver.save_results(train_info, 'training_info')
        
        models = {}
        predictions = {}
        
        # CatBoost
        print("Training CatBoost...")
        catboost = CatBoostClassifier(
            iterations=1000,
            learning_rate=0.02,
            depth=6,
            l2_leaf_reg=3,
            verbose=False,
            random_seed=42
        )
        catboost.fit(X_train, y_train)
        models['catboost'] = catboost
        predictions['catboost'] = catboost.predict_proba(X_test)[:, 1]
        
        # XGBoost
        print("Training XGBoost...")
        xgboost = XGBClassifier(
            n_estimators=1000,
            learning_rate=0.02,
            max_depth=6,
            random_state=42
        )
        xgboost.fit(X_train, y_train)
        models['xgboost'] = xgboost
        predictions['xgboost'] = xgboost.predict_proba(X_test)[:, 1]
        
        # LightGBM
        print("Training LightGBM...")
        lightgbm = LGBMClassifier(
            n_estimators=1000,
            learning_rate=0.02,
            num_leaves=32,
            random_state=42
        )
        lightgbm.fit(X_train, y_train)
        models['lightgbm'] = lightgbm
        predictions['lightgbm'] = lightgbm.predict_proba(X_test)[:, 1]
        
        # 评估各个模型
        model_results = {}
        for name, pred_probs in predictions.items():
            y_pred = (pred_probs > 0.5).astype(int)
            results = {
                'classification_report': classification_report(y_test, y_pred, output_dict=True),
                'confusion_matrix': confusion_matrix(y_test, y_pred).tolist()
            }
            model_results[name] = results
            
            # 绘制混淆矩阵
            self._plot_confusion_matrix(y_test, y_pred, name)
        
        # 保存模型结果
        self.saver.save_results(model_results, 'model_performance')
        
        # 绘制ROC曲线
        self._plot_roc_curves(y_test, predictions)
        
        return models, predictions
    
    def _plot_confusion_matrix(self, y_true, y_pred, model_name):
        cm = confusion_matrix(y_true, y_pred)
        plt.figure(figsize=(8, 6))
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues')
        plt.title(f'Confusion Matrix - {model_name}')
        plt.ylabel('True Label')
        plt.xlabel('Predicted Label')
        self.saver.save_plot(plt.gcf(), f'confusion_matrix_{model_name}')
    
    def _plot_roc_curves(self, y_true, predictions):
        plt.figure(figsize=(10, 8))
        
        for name, y_pred in predictions.items():
            fpr, tpr, _ = roc_curve(y_true, y_pred)
            roc_auc = auc(fpr, tpr)
            plt.plot(fpr, tpr, label=f'{name} (AUC = {roc_auc:.3f})')
        
        plt.plot([0, 1], [0, 1], 'k--')
        plt.xlim([0.0, 1.0])
        plt.ylim([0.0, 1.05])
        plt.xlabel('False Positive Rate')
        plt.ylabel('True Positive Rate')
        plt.title('ROC Curves Comparison')
        plt.legend(loc="lower right")
        
        self.saver.save_plot(plt.gcf(), 'roc_curves_comparison')

def main():
    # 设置保存路径
    save_path = '/project/zhiwei/hf78/ecg/output/heart'
    
    # 初始化预测器
    predictor = AdvancedHeartPredictor(save_path)
    
    # 加载数据
    print("Loading data...")
    data = pd.read_csv('/project/zhiwei/hf78/ecg/data/heart/heart.csv')
    
    # 数据准备和探索
    data = predictor.prepare_data(data)
    
    # 分离特征和目标变量
    X = data.drop('target', axis=1)  # 假设目标变量列名为'target'
    y = data['target']
    
    # 分割数据
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    # 特征缩放
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # 转换回DataFrame以保留列名
    X_train_scaled = pd.DataFrame(X_train_scaled, columns=X_train.columns)
    X_test_scaled = pd.DataFrame(X_test_scaled, columns=X_test.columns)
    
    # 训练和评估模型
    models, predictions = predictor.train_models(X_train_scaled, X_test_scaled, y_train, y_test)
    
    print(f"All results have been saved to {save_path}")

if __name__ == "__main__":
    main()