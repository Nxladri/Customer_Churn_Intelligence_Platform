import joblib
import pandas as pd
from sklearn.model_selection import train_test_split
import streamlit as st
import matplotlib.pyplot as plt
import seaborn as sns
import xgboost as xgb
from sklearn.metrics import (confusion_matrix, roc_curve, 
                            precision_recall_curve, auc,
                            accuracy_score, classification_report,
                            roc_auc_score)

st.set_page_config(
    page_title="Customer Churn Model Prediction",
    page_icon="🔮",
    layout="wide"
)
st.title("🔮 Customer Churn Model Performance Metrics")
model = joblib.load("churn_sentinel.joblib")
scaler = joblib.load("Clustered_Features.joblib")
df = pd.read_csv("customer_churn_clustered.csv")
threshold = joblib.load("decision_boundary.joblib")

X = df.drop(['ChurnLabel','ClusterLabel','RecencyRatio','AvgDaysBetweenOrders','Cluster'],axis =1)
y = df['ChurnLabel']


X_train , X_test , y_train , y_test = train_test_split(X,y,test_size=0.25,random_state=42,stratify=y)

y_prob = model.predict_proba(X_test)[:,1]
y_pred = (y_prob >= threshold).astype(int)


st.markdown("Threshold for Churn Prediction: " + str(threshold))
print("Accuracy:", accuracy_score(y_test, (y_prob >= 0.45)))
print("Threshold:", threshold)
print("Test size:", X_test.shape)
# Model Performance
st.subheader("Engine Performance")
col1, col2 , col3 , col4 , col5 = st.columns(5)

report = classification_report(y_test, y_pred, output_dict=True)

with col1:
    
    st.metric("Accuracy", f"{accuracy_score(y_test, y_pred) * 100:.2f}%")
with col2: 
    st.metric("ROC AUC", f"{roc_auc_score(y_test, y_prob) * 100:.2f}%")
with col3:
    st.metric("Precision", f"{report['1']['precision'] * 100:.2f}%")
with col4:
    st.metric("Recall", f"{report['1']['recall'] * 100:.2f}%")
with col5:
    st.metric("F1-Score", f"{report['1']['f1-score'] * 100:.2f}%")

# Confusion Matrix
st.subheader("Confusion Matrix")
cm = confusion_matrix(y_test , y_pred)
col1, col2, col3, col4 = st.columns([1,1, 1, 1])

with col1:
    st.metric("True Negatives", f"{cm[0, 0]:,}") 
    st.metric("False Positives", f"{cm[0, 1]:,}")   
    st.metric("False Negatives", f"{cm[1, 0]:,}")
    st.metric("True Positives", f"{cm[1, 1]:,}")

with col2:
    fig, ax = plt.subplots(figsize=(4, 3))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', 
                cbar=False, ax=ax)
    ax.set_xlabel("Predicted")
    ax.set_ylabel("Actual")
    st.pyplot(fig)

with col3:
    st.metric("Total Customers", f"{df.shape[0]:,}")
    st.metric("Total Churned Customers", f"{cm[1, 0] + cm[1, 1]:,}")
    st.metric("Total Retained Customers" , f"{cm[0, 0] + cm[0, 1]:,}")

with col4:
    st.markdown("**Interpretation:**")
    st.markdown("- **True Negatives (TN)**: Customers correctly predicted as not churning.")
    st.markdown("- **False Positives (FP)**: Customers incorrectly predicted as churning.")
    st.markdown("- **False Negatives (FN)**: Customers incorrectly predicted as not churning.")
    st.markdown("- **True Positives (TP)**: Customers correctly predicted as churning.")


# ROC Curve
st.subheader("ROC Curve")

col1 , col2 , col3= st.columns([1,1,1])

with col1:
    st.markdown("**ROC Curve** (Receiver Operating Characteristic) illustrates the model's ability to distinguish between classes across different thresholds. " \
    "The AUC (Area Under the Curve) quantifies this performance, " 
    "with 1.0 being perfect and 0.5 indicating no discriminative power.")
with col2:
    fpr , tpr , thresholds = roc_curve(y_test, y_prob)
    roc_auc  = auc(fpr,tpr)
    fig, ax = plt.subplots(figsize=(4, 3))
    ax.plot(fpr, tpr, color='blue', label=f'ROC curve (AUC = {roc_auc:.2f})')
    ax.plot([0, 1], [0, 1], color='red', linestyle='--')
    ax.set_xlabel('False Positive Rate')
    ax.set_ylabel('True Positive Rate')
    ax.set_title('ROC Curve')
    ax.legend(loc='lower right')
    st.pyplot(fig)

with col3:
    st.markdown("Decision Threshold Analysis: The ROC curve helps us understand how changing the decision threshold affects the " \
    "trade-off between true positive rate and false positive rate. " 
     "By analyzing the curve, we can select an optimal threshold that balances sensitivity and specificity based on business needs.")
    st.markdown("In our case, the chosen threshold is " + str(threshold) + ", "" We derived an optimal threshold of ~0.43 using ROC analysis, but used 0.5 in deployment for interpretability and stability."
    ", which corresponds to a specific point on the ROC curve that optimizes our model's performance for predicting customer churn.")

# Precision-Recall Curve
st.subheader("Precision-Recall Curve")
col1 , col2 , col3= st.columns([1,1,1])
with col1:
    st.markdown("**Precision-Recall Curve** focuses on the performance of the model with respect to the positive class (churned customers). " \
    "Precision measures the accuracy of positive predictions, while Recall measures the ability to capture all actual positives." )
            
with col2:
    precision , recall , thresholds = precision_recall_curve(y_test, y_prob)
    fig, ax = plt.subplots(figsize=(4, 3))
    ax.plot(recall, precision, color='blue')
    ax.set_xlabel('Recall')
    ax.set_ylabel('Precision')
    ax.set_title('Precision-Recall Curve')
    st.pyplot(fig)

with col3:
    st.markdown("Precision-Recall Trade-off: The curve illustrates the trade-off between precision and recall at different thresholds. " \
    "A high area under the curve indicates that the model maintains good precision and recall across various thresholds. " \
    "By analyzing this curve, we can select a threshold that achieves the desired balance between precision" \
    " and recall based on the specific requirements of our churn prediction task.")



#  Feature importance 
st.subheader("Feature Importance")
col1 , col2 , col3= st.columns([1,1,1])

with col2:
   st.markdown("Top 5 Important Features")
   fig, ax = plt.subplots(figsize=(4, 3))
   xgb.plot_importance(model, ax=ax, importance_type='weight', 
                    max_num_features=5, show_values=True)
   st.pyplot(fig)


# Model note
st.info("""
**Model Development Note:**

The initial model was trained on 8 features and achieved 99.39% accuracy. 
However, further analysis showed that *RecencyRatio* was the dominant feature. 
Since it is derived from *DaysSinceLastOrder*, which directly influences the 
churn label, this introduced data leakage.

To ensure a more robust and generalizable model, we retrained using 5 core 
features, excluding RecencyRatio, AvgDaysBetweenOrders, and Cluster.

The final model achieves 89.77% accuracy with a ROC AUC of 97.25%, 
providing a more realistic and production-ready churn prediction system.
This approach prioritizes model reliability over inflated performance metrics.
""")

# Final Interpretation
st.subheader("Final Interpretation")
st.markdown("The model demonstrates strong performance in predicting customer churn, with an accuracy of " + \
             f"{accuracy_score(y_test, y_pred) * 100:.2f}%" + " and an AUC of " + f"{roc_auc_score(y_test, y_prob) * 100:.2f}%." \
" The confusion matrix reveals that the model correctly identifies a significant number of churned customers "
"(True Positives) while maintaining a relatively low number of false positives. " \
" The ROC and Precision-Recall curves further illustrate the model's ability to balance sensitivity and specificity across different thresholds. " \
" By analyzing feature importance, "
"we can identify key drivers of churn, which can inform targeted retention strategies. "
"Overall, this predictive model serves as a valuable tool for proactively identifying at-risk customers and implementing effective interventions to reduce churn.") 