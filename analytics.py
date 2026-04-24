import streamlit as st
import joblib
import pandas as pd
import matplotlib.pyplot as plt
import insights
import os




st.set_page_config(
    page_title="Customer Churn Analytics",
    page_icon="📊",
    layout="wide"
)
st.title("📈 Customer Churn Analytics Dashboard")
df = pd.read_csv("customer_churn_clustered.csv")


col1, col2, col3, col4 = st.columns(4)

with col1:
    st.metric("Total Customers", f"{df.shape[0]:,}")

with col2:
    st.metric("Total Churned Customers", f"{df[df['ChurnLabel'] == 1].shape[0]:,}")

with col3:
    st.metric("Retained Customers" , f"{df[df['ChurnLabel'] == 0].shape[0]:,}")

with col4:
    st.metric("Overall Churn Rate", f"{df['ChurnLabel'].mean() * 100:.2f}%")


# Overall
total_customers = df.shape[0]
total_churn = df['ChurnLabel'].sum()

overall_churn_customers = df[df["ChurnLabel"] == 1].shape[0]


# Segment filter
segment = st.selectbox("Select Segment", df['ClusterLabel'].unique())
filtered_df = df[df['ClusterLabel'] == segment]


# Segment-specific
seg_total = filtered_df.shape[0]
seg_churn = filtered_df['ChurnLabel'].sum()
seg_churn_rate = filtered_df['ChurnLabel'].mean() * 100

col1, col2, col3, col4 = st.columns(4)

with col1:
    st.metric(f"{segment}", f"{seg_total:,}")

with col2:
    st.metric("Churned", f"{int(seg_churn):,}")

with col3:
    st.metric("Churn Rate", f"{seg_churn_rate:.2f}%")

with col4:
    st.metric(
        "Contribution to Total",
        f"{(seg_total / total_customers)*100:.2f}%"
    )

overall_churn_rate = df['ChurnLabel'].mean() * 100

if seg_churn_rate > overall_churn_rate:
    st.warning(f"{segment} has higher churn than average!")
else:
    st.success(f"{segment} is performing better than average.")


# # LLM generated buisness strategies to segemnt specific customers
# Experimental module: LLM-based retention message generator
# Not included in production pipeline due to performance constraints


chart_df = pd.DataFrame({
    "Customers": [seg_churn, seg_total - seg_churn]
}, index=["Churned", "Retained"])



churn_pred = (seg_churn/seg_total) * 100 if seg_total > 0 else 0
retain_pred = 100 - churn_pred

st.caption(f"Predicted Churn Rate: {churn_pred:.2f}%")
st.caption(f"Predicted Retention Rate: {retain_pred:.2f}%")

st.bar_chart(chart_df)


# Easily navigate to other pages
st.markdown("---")
st.subheader("🔗 Explore More")
if st.button("📈 View Model Insights"):
     st.switch_page("pages/prediction.py")
