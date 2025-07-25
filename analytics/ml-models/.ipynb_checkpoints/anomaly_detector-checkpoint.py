"""
Educational Anomaly Detection Engine for Cloud Security

This module provides explainable machine learning models for detecting
security anomalies in cloud environments with step-by-step educational
explanations for students and security teams.
"""

import numpy as np
import pandas as pd
from sklearn.ensemble import IsolationForest
from sklearn.neighbors import LocalOutlierFactor
from sklearn.cluster import DBSCAN
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from neo4j import GraphDatabase
import logging
from typing import Dict, List, Tuple, Optional
import json

class EducationalAnomalyDetector:
    """
    Educational anomaly detection system with clear explanations
    
    This class demonstrates machine learning for cybersecurity with:
    - Step-by-step algorithm explanations
    - Clear interpretation of results
    - Real-world security applications
    - Educational visualizations
    """
    
    def __init__(self, neo4j_uri: str = "bolt://neo4j:7687", 
                 neo4j_user: str = "neo4j", 
                 neo4j_password: str = "cloudsecurity"):
        """
        Initialize the educational anomaly detection system
        
        Args:
            neo4j_uri: Neo4j database connection string
            neo4j_user: Database username
            neo4j_password: Database password
        """
        self.driver = GraphDatabase.driver(neo4j_uri, auth=(neo4j_user, neo4j_password))
        self.scaler = StandardScaler()
        self.models = {}
        self.explanations = {}
        self.feature_names = []
        
        # Configure logging for educational purposes
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger(__name__)
        
        print("🤖 Educational Anomaly Detection System Initialized")
        print("📚 Ready for explainable AI security analysis")
    
    def extract_security_features(self) -> pd.DataFrame:
        """
        Extract meaningful security features from the graph database
        
        EDUCATIONAL NOTE:
        Feature engineering is critical for ML success. We transform
        security concepts into numerical features that algorithms can process.
        
        Returns:
            DataFrame with security features for each user
        """
        
        print("\n🔬 EDUCATIONAL: Feature Engineering for Security")
        print("=" * 50)
        print("Converting security concepts into machine learning features...")
        
        query = """
        MATCH (user:User)
        OPTIONAL MATCH (user)-[access_rel]->(target)
        WITH user,
             count(access_rel) as total_access_count,
             count(DISTINCT target) as unique_targets_accessed,
             collect(DISTINCT labels(target)[0]) as target_types,
             collect(DISTINCT type(access_rel)) as access_methods
        
        OPTIONAL MATCH (user)-[*1..3]->(sensitive)
        WHERE sensitive.contains_pii = true OR sensitive.type = 'S3Bucket'
        WITH user, total_access_count, unique_targets_accessed, 
             target_types, access_methods,
             count(DISTINCT sensitive) as sensitive_data_reachable
        
        OPTIONAL MATCH (user)-[:ASSUMES_ROLE]->(role:Role)
        WITH user, total_access_count, unique_targets_accessed,
             target_types, access_methods, sensitive_data_reachable,
             count(role) as roles_assumed
        
        RETURN 
            user.name as user_name,
            user.access_level as access_level,
            total_access_count,
            unique_targets_accessed,
            size(target_types) as target_diversity,
            size(access_methods) as access_method_diversity,
            sensitive_data_reachable,
            roles_assumed,
            CASE user.access_level
                WHEN 'administrator' THEN 5
                WHEN 'developer' THEN 3
                ELSE 1
            END as privilege_level
        """
        
        with self.driver.session() as session:
            result = session.run(query)
            data = [dict(record) for record in result]
        
        df = pd.DataFrame(data)
        
        # Educational feature explanations
        feature_explanations = {
            'total_access_count': 'Total resources user can access (activity level)',
            'unique_targets_accessed': 'Number of different resources accessed (diversity)',
            'target_diversity': 'Types of resources accessed (breadth)',
            'access_method_diversity': 'Different ways user gains access (complexity)',
            'sensitive_data_reachable': 'Amount of sensitive data accessible (risk)',
            'roles_assumed': 'Privilege escalation paths available (elevation risk)',
            'privilege_level': 'Numerical privilege ranking (authority level)'
        }
        
        print(f"\n📊 Extracted {len(df)} user profiles with security features:")
        for feature, explanation in feature_explanations.items():
            if feature in df.columns:
                print(f"• {feature}: {explanation}")
        
        self.feature_names = [col for col in df.columns if col not in ['user_name', 'access_level']]
        
        return df
    
    def explain_algorithm(self, algorithm_name: str, purpose: str, how_it_works: str, 
                         security_applications: List[str]) -> None:
        """
        Provide educational explanations for ML algorithms
        
        Args:
            algorithm_name: Name of the algorithm
            purpose: What problem it solves
            how_it_works: Simple explanation of the mechanism
            security_applications: Real-world security use cases
        """
        print(f"\n🎓 ALGORITHM EXPLANATION: {algorithm_name}")
        print("=" * 60)
        print(f"PURPOSE: {purpose}")
        print(f"\nHOW IT WORKS: {how_it_works}")
        print(f"\nSECURITY APPLICATIONS:")
        for i, application in enumerate(security_applications, 1):
            print(f"{i}. {application}")
        print("=" * 60)
    
    def isolation_forest_detection(self, df: pd.DataFrame, 
                                 contamination: float = 0.1) -> Dict:
        """
        Isolation Forest anomaly detection with educational explanations
        
        Args:
            df: DataFrame with security features
            contamination: Expected percentage of anomalies
            
        Returns:
            Dictionary with results and explanations
        """
        
        self.explain_algorithm(
            "Isolation Forest",
            "Identifies users with unusual access patterns by isolating outliers",
            """
            Think of a party where most people cluster together, but a few stand alone.
            Isolation Forest randomly splits data until each point is isolated.
            Unusual points (anomalies) get isolated faster with fewer splits.
            
            Steps:
            1. Randomly select a feature (e.g., access_count)
            2. Randomly pick a split value between min and max
            3. Separate data points based on this split
            4. Repeat until each point is isolated
            5. Points requiring fewer splits = anomalies
            """,
            [
                "Detecting compromised accounts with unusual activity",
                "Finding insider threats with abnormal access patterns", 
                "Identifying privilege abuse by legitimate users",
                "Discovering misconfigured service accounts"
            ]
        )
        
        # Prepare features
        X = df[self.feature_names].fillna(0)
        X_scaled = self.scaler.fit_transform(X)
        
        # Train model
        model = IsolationForest(
            contamination=contamination,
            random_state=42,
            n_estimators=100
        )
        
        predictions = model.fit_predict(X_scaled)
        anomaly_scores = model.decision_function(X_scaled)
        
        # Add results to dataframe
        results_df = df.copy()
        results_df['is_anomaly'] = predictions == -1
        results_df['anomaly_score'] = anomaly_scores
        
        # Educational analysis
        anomalies = results_df[results_df['is_anomaly']]
        normal_users = results_df[~results_df['is_anomaly']]
        
        print(f"\n🎯 Isolation Forest Results:")
        print(f"• Anomalies detected: {len(anomalies)} ({len(anomalies)/len(results_df)*100:.1f}%)")
        print(f"• Normal users: {len(normal_users)}")
        
        # Detailed anomaly analysis
        if len(anomalies) > 0:
            print(f"\n🚨 Security Anomalies Detected:")
            for _, user in anomalies.sort_values('anomaly_score').iterrows():
                print(f"\n🔍 {user['user_name']} ({user['access_level']})")
                print(f"   • Anomaly Score: {user['anomaly_score']:.3f} (lower = more suspicious)")
                print(f"   • Access Activity: {user['total_access_count']} resources")
                print(f"   • Sensitive Access: {user['sensitive_data_reachable']} resources")
                
                # Generate educational explanation
                reasons = []
                if user['total_access_count'] > normal_users['total_access_count'].mean() + 2*normal_users['total_access_count'].std():
                    reasons.append("Extremely high access activity")
                if user['sensitive_data_reachable'] > normal_users['sensitive_data_reachable'].mean() + normal_users['sensitive_data_reachable'].std():
                    reasons.append("Above-average sensitive data access")
                if user['target_diversity'] > normal_users['target_diversity'].mean() + normal_users['target_diversity'].std():
                    reasons.append("Accessing unusually diverse resources")
                
                if reasons:
                    print(f"   • Likely reasons: {'; '.join(reasons)}")
                else:
                    print(f"   • Complex anomaly pattern - requires investigation")
        
        # Store model and results
        self.models['isolation_forest'] = model
        
        return {
            'model': model,
            'results': results_df,
            'anomalies': anomalies,
            'normal_users': normal_users,
            'method': 'Isolation Forest',
            'explanation': 'Global anomaly detection using random isolation'
        }
    
    def local_outlier_factor_detection(self, df: pd.DataFrame,
                                     n_neighbors: int = 5,
                                     contamination: float = 0.15) -> Dict:
        """
        Local Outlier Factor detection with educational explanations
        
        Args:
            df: DataFrame with security features
            n_neighbors: Number of neighbors to consider
            contamination: Expected percentage of outliers
            
        Returns:
            Dictionary with results and explanations
        """
        
        self.explain_algorithm(
            "Local Outlier Factor (LOF)",
            "Finds users unusual within their peer group or role context",
            """
            Imagine comparing each person to their immediate social circle:
            - A developer accessing 10 systems might be normal among developers
            - But a marketing person accessing 10 systems could be unusual
            
            LOF Process:
            1. For each user, find their k nearest neighbors
            2. Calculate local density (how close are neighbors?)
            3. Compare user's density to neighbors' densities
            4. If user is in sparse area while neighbors are dense → outlier
            
            This finds contextual anomalies missed by global methods.
            """,
            [
                "Detecting insider threats within role-based groups",
                "Finding users unusual compared to their department peers",
                "Identifying privilege abuse within specific access levels",
                "Discovering anomalous behavior in legitimate user contexts"
            ]
        )
        
        # Prepare features
        X = df[self.feature_names].fillna(0)
        X_scaled = self.scaler.fit_transform(X)
        
        # Adjust n_neighbors based on dataset size
        n_neighbors = min(n_neighbors, len(X) - 1)
        
        # Train model
        lof = LocalOutlierFactor(
            n_neighbors=n_neighbors,
            contamination=contamination
        )
        
        predictions = lof.fit_predict(X_scaled)
        outlier_scores = lof.negative_outlier_factor_
        
        # Add results to dataframe
        results_df = df.copy()
        results_df['is_local_outlier'] = predictions == -1
        results_df['lof_score'] = outlier_scores
        
        # Educational analysis
        local_outliers = results_df[results_df['is_local_outlier']]
        normal_users = results_df[~results_df['is_local_outlier']]
        
        print(f"\n🎯 Local Outlier Factor Results:")
        print(f"• Local outliers: {len(local_outliers)} ({len(local_outliers)/len(results_df)*100:.1f}%)")
        print(f"• Normal in context: {len(normal_users)}")
        
        if len(local_outliers) > 0:
            print(f"\n🔍 Contextual Security Anomalies:")
            for _, user in local_outliers.sort_values('lof_score').iterrows():
                print(f"\n🚨 {user['user_name']} ({user['access_level']})")
                print(f"   • LOF Score: {user['lof_score']:.3f} (more negative = more unusual)")
                
                # Context-specific analysis
                same_level_users = results_df[results_df['access_level'] == user['access_level']]
                if len(same_level_users) > 1:
                    level_avg_access = same_level_users['total_access_count'].mean()
                    print(f"   • Access vs {user['access_level']} peers: {user['total_access_count']} (avg: {level_avg_access:.1f})")
                    
                    # Context reasons
                    context_reasons = []
                    if user['total_access_count'] > level_avg_access * 1.5:
                        context_reasons.append(f"High access for {user['access_level']} role")
                    if user['sensitive_data_reachable'] > same_level_users['sensitive_data_reachable'].mean() * 1.5:
                        context_reasons.append(f"Above-average sensitive access for role")
                    
                    if context_reasons:
                        print(f"   • Context reasons: {'; '.join(context_reasons)}")
        
        # Store model and results
        self.models['local_outlier_factor'] = lof
        
        return {
            'model': lof,
            'results': results_df,
            'outliers': local_outliers,
            'normal_users': normal_users,
            'method': 'Local Outlier Factor',
            'explanation': 'Context-aware anomaly detection within peer groups'
        }
    
    def clustering_analysis(self, df: pd.DataFrame,
                          eps: float = 0.8,
                          min_samples: int = 2) -> Dict:
        """
        DBSCAN clustering analysis with educational explanations
        
        Args:
            df: DataFrame with security features
            eps: Distance threshold for clustering
            min_samples: Minimum samples per cluster
            
        Returns:
            Dictionary with clustering results and explanations
        """
        
        self.explain_algorithm(
            "DBSCAN Clustering",
            "Groups users by similar behavior patterns and identifies isolated outliers",
            """
            Imagine organizing users into behavioral groups at a security conference:
            - Group 1: Normal office workers (low access, standard patterns)
            - Group 2: System administrators (high access, varied patterns)
            - Group 3: Developers (moderate access, code-focused)
            - Outliers: Users who don't fit any group (potential threats!)
            
            DBSCAN Process:
            1. For each user, count nearby users within distance 'eps'
            2. If user has enough neighbors (min_samples), start a cluster
            3. Expand cluster by adding nearby users
            4. Users with too few neighbors become outliers
            
            Outliers often represent the most interesting security cases.
            """,
            [
                "Establishing behavioral baselines for different user types",
                "Identifying users who don't fit normal patterns",
                "Creating role-based security policies",
                "Detecting coordinated attacks (multiple users, similar unusual patterns)"
            ]
        )
        
        # Prepare features
        X = df[self.feature_names].fillna(0)
        X_scaled = self.scaler.fit_transform(X)
        
        # Train model
        dbscan = DBSCAN(eps=eps, min_samples=min_samples)
        cluster_labels = dbscan.fit_predict(X_scaled)
        
        # Add results to dataframe
        results_df = df.copy()
        results_df['cluster'] = cluster_labels
        results_df['is_outlier'] = cluster_labels == -1
        
        # Educational analysis
        unique_clusters = set(cluster_labels)
        outliers = results_df[results_df['is_outlier']]
        clustered_users = results_df[~results_df['is_outlier']]
        
        print(f"\n🎯 DBSCAN Clustering Results:")
        print(f"• Clusters found: {len(unique_clusters) - (1 if -1 in unique_clusters else 0)}")
        print(f"• Users in clusters: {len(clustered_users)}")
        print(f"• Outliers (security interest): {len(outliers)} ({len(outliers)/len(results_df)*100:.1f}%)")
        
        # Analyze each cluster
        print(f"\n📊 Cluster Behavior Analysis:")
        for cluster_id in sorted(unique_clusters):
            if cluster_id == -1:
                continue  # Handle outliers separately
            
            cluster_users = results_df[results_df['cluster'] == cluster_id]
            if len(cluster_users) == 0:
                continue
            
            avg_access = cluster_users['total_access_count'].mean()
            avg_sensitive = cluster_users['sensitive_data_reachable'].mean()
            common_level = cluster_users['access_level'].mode()[0] if not cluster_users['access_level'].mode().empty else 'Mixed'
            
            print(f"\n🔍 Cluster {cluster_id} ({len(cluster_users)} users):")
            print(f"   • Common role: {common_level}")
            print(f"   • Avg access: {avg_access:.1f} resources")
            print(f"   • Avg sensitive access: {avg_sensitive:.1f} resources")
            print(f"   • Members: {', '.join(cluster_users['user_name'].head(5).tolist())}")
            
            # Interpret cluster type
            if avg_access < 2 and avg_sensitive < 1:
                cluster_type = "🟢 Low-Activity Users"
            elif avg_access > 5 and avg_sensitive > 2:
                cluster_type = "🟡 High-Activity/Privileged Users"
            elif common_level == 'administrator':
                cluster_type = "🔵 Administrator Group"
            else:
                cluster_type = "🟠 Mixed Activity Group"
            
            print(f"   • Type: {cluster_type}")
        
        # Analyze outliers (most important for security)
        if len(outliers) > 0:
            print(f"\n🚨 Security Outliers (Immediate Investigation Required):")
            for _, user in outliers.iterrows():
                print(f"\n🔍 {user['user_name']} ({user['access_level']})")
                print(f"   • Doesn't fit any behavioral group")
                print(f"   • Access activity: {user['total_access_count']} resources")
                print(f"   • Sensitive access: {user['sensitive_data_reachable']} resources")
                
                # Risk assessment
                risk_factors = 0
                if user['total_access_count'] > results_df['total_access_count'].mean() * 2:
                    risk_factors += 1
                if user['sensitive_data_reachable'] > results_df['sensitive_data_reachable'].mean() * 2:
                    risk_factors += 1
                if user['target_diversity'] > results_df['target_diversity'].mean() * 1.5:
                    risk_factors += 1
                
                risk_level = "🔴 HIGH" if risk_factors >= 3 else "🟠 MEDIUM" if risk_factors >= 2 else "🟡 LOW"
                print(f"   • Risk level: {risk_level}")
        
        # Store model and results
        self.models['dbscan'] = dbscan
        
        return {
            'model': dbscan,
            'results': results_df,
            'outliers': outliers,
            'clustered_users': clustered_users,
            'n_clusters': len(unique_clusters) - (1 if -1 in unique_clusters else 0),
            'method': 'DBSCAN Clustering',
            'explanation': 'Behavioral grouping with automatic outlier detection'
        }
    
    def generate_comprehensive_report(self, analysis_results: List[Dict]) -> Dict:
        """
        Generate comprehensive security analysis report combining all methods
        
        Args:
            analysis_results: List of analysis results from different methods
            
        Returns:
            Comprehensive security report with recommendations
        """
        
        print("\n🎯 COMPREHENSIVE SECURITY ANALYSIS REPORT")
        print("=" * 60)
        
        # Combine results from all methods
        all_users = set()
        anomaly_detections = {}
        
        for result in analysis_results:
            method = result['method']
            
            if 'anomalies' in result:
                anomalous_users = set(result['anomalies']['user_name'].tolist())
            elif 'outliers' in result:
                anomalous_users = set(result['outliers']['user_name'].tolist())
            else:
                anomalous_users = set()
            
            anomaly_detections[method] = anomalous_users
            all_users.update(result['results']['user_name'].tolist())
        
        # Calculate composite risk scores
        user_risk_scores = {}
        for user in all_users:
            risk_score = 0
            detected_by = []
            
            for method, detected_users in anomaly_detections.items():
                if user in detected_users:
                    if method == 'Isolation Forest':
                        risk_score += 3  # Global anomalies are high priority
                    elif method == 'DBSCAN Clustering':
                        risk_score += 2  # Outliers are medium-high priority
                    elif method == 'Local Outlier Factor':
                        risk_score += 2  # Context anomalies are medium-high priority
                    detected_by.append(method)
            
            user_risk_scores[user] = {
                'risk_score': risk_score,
                'detected_by': detected_by,
                'risk_level': 'CRITICAL' if risk_score >= 6 else 
                             'HIGH' if risk_score >= 4 else 
                             'MEDIUM' if risk_score >= 2 else 'LOW'
            }
        
        # Generate recommendations
        high_risk_users = {user: info for user, info in user_risk_scores.items() 
                          if info['risk_level'] in ['CRITICAL', 'HIGH']}
        
        print(f"\n📊 EXECUTIVE SUMMARY:")
        print(f"• Total users analyzed: {len(all_users)}")
        print(f"• High-risk users identified: {len(high_risk_users)}")
        
        risk_distribution = {}
        for info in user_risk_scores.values():
            risk_level = info['risk_level']
            risk_distribution[risk_level] = risk_distribution.get(risk_level, 0) + 1
        
        for level in ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']:
            count = risk_distribution.get(level, 0)
            percentage = (count / len(all_users)) * 100
            icon = {'CRITICAL': '🔴', 'HIGH': '🟠', 'MEDIUM': '🟡', 'LOW': '🟢'}[level]
            print(f"• {icon} {level}: {count} users ({percentage:.1f}%)")
        
        # Detailed high-risk analysis
        if high_risk_users:
            print(f"\n🚨 HIGH-PRIORITY SECURITY ALERTS:")
            sorted_high_risk = sorted(high_risk_users.items(), 
                                    key=lambda x: x[1]['risk_score'], reverse=True)
            
            for user, info in sorted_high_risk[:5]:  # Top 5 highest risk
                risk_icon = '🔴' if info['risk_level'] == 'CRITICAL' else '🟠'
                print(f"\n{risk_icon} {info['risk_level']}: {user}")
                print(f"   • Risk Score: {info['risk_score']}/7")
                print(f"   • Detected by: {', '.join(info['detected_by'])}")
                
        # Security recommendations
        print(f"\n🛡️  SECURITY RECOMMENDATIONS:")
        print(f"\n🔧 Immediate Actions:")
        print(f"• Investigate {len(high_risk_users)} high-risk user accounts")
        print(f"• Review access patterns for users with risk score ≥ 4")
        print(f"• Implement enhanced monitoring for detected anomalies")
        
        print(f"\n📊 Strategic Improvements:")
        print(f"• Deploy automated ML-based anomaly detection")
        print(f"• Establish behavioral baselines for different user roles")
        print(f"• Create role-based access policies based on clustering")
        print(f"• Implement real-time risk scoring for user activities")
        
        return {
            'user_risk_scores': user_risk_scores,
            'high_risk_users': high_risk_users,
            'risk_distribution': risk_distribution,
            'total_users': len(all_users),
            'analysis_methods': list(anomaly_detections.keys()),
            'recommendations': [
                "Investigate high-risk user accounts immediately",
                "Implement enhanced monitoring for anomalies",
                "Deploy automated ML detection systems",
                "Create role-based security policies"
            ]
        }
    
    def close(self):
        """Close database connection"""
        if self.driver:
            self.driver.close()
            print("✅ Educational anomaly detection session closed")

# Example usage for educational purposes
if __name__ == "__main__":
    # Initialize the educational system
    detector = EducationalAnomalyDetector()
    
    try:
        # Extract security features
        security_features = detector.extract_security_features()
        
        # Run different anomaly detection methods
        isolation_results = detector.isolation_forest_detection(security_features)
        lof_results = detector.local_outlier_factor_detection(security_features)
        clustering_results = detector.clustering_analysis(security_features)
        
        # Generate comprehensive report
        all_results = [isolation_results, lof_results, clustering_results]
        comprehensive_report = detector.generate_comprehensive_report(all_results)
        
        print("\n🎓 Educational ML Security Analysis Complete!")
        print("Students can now understand how AI detects security threats!")
        
    finally:
        detector.close()