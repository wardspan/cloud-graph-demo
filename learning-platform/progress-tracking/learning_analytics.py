"""
Educational Progress Tracking and Learning Analytics

This module provides comprehensive progress tracking, assessment analytics,
and adaptive learning recommendations for the Cloud Threat Graph Lab
educational platform.
"""

import json
import sqlite3
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple
import pandas as pd
import numpy as np
from dataclasses import dataclass, asdict
import uuid

@dataclass
class LearningEvent:
    """Individual learning event tracking"""
    event_id: str
    user_id: str
    session_id: str
    timestamp: datetime
    event_type: str  # 'module_start', 'module_complete', 'assessment_attempt', 'query_execution'
    module_id: str
    content_path: str
    duration_seconds: Optional[int] = None
    score: Optional[float] = None
    max_score: Optional[float] = None
    metadata: Optional[Dict] = None

@dataclass
class UserProgress:
    """User's overall learning progress"""
    user_id: str
    current_path: str
    modules_completed: List[str]
    modules_in_progress: List[str]
    total_time_spent: int  # seconds
    overall_score: float
    last_activity: datetime
    skill_levels: Dict[str, str]  # skill -> level mapping
    achievements: List[str]
    next_recommended_modules: List[str]

class EducationalProgressTracker:
    """
    Comprehensive learning analytics and progress tracking system
    
    Features:
    - Individual progress tracking
    - Learning path analytics
    - Adaptive recommendations
    - Instructor dashboards
    - Achievement systems
    """
    
    def __init__(self, db_path: str = "learning_analytics.db"):
        """
        Initialize the progress tracking system
        
        Args:
            db_path: Path to SQLite database for storing analytics
        """
        self.db_path = db_path
        self.setup_database()
        
        # Skill progression mappings
        self.skill_levels = {
            'graph_fundamentals': ['novice', 'beginner', 'intermediate', 'advanced', 'expert'],
            'attack_path_analysis': ['novice', 'beginner', 'intermediate', 'advanced', 'expert'],
            'machine_learning': ['novice', 'beginner', 'intermediate', 'advanced', 'expert'],
            'threat_hunting': ['novice', 'beginner', 'intermediate', 'advanced', 'expert'],
            'risk_assessment': ['novice', 'beginner', 'intermediate', 'advanced', 'expert']
        }
        
        # Achievement definitions
        self.achievements = {
            'first_query': {
                'title': 'First Steps',
                'description': 'Executed your first security graph query',
                'icon': '🎯',
                'points': 10
            },
            'attack_path_finder': {
                'title': 'Attack Path Detective',
                'description': 'Successfully identified 5 different attack paths',
                'icon': '🔍',
                'points': 25
            },
            'ml_practitioner': {
                'title': 'ML Security Analyst',
                'description': 'Completed machine learning anomaly detection training',
                'icon': '🤖',
                'points': 50
            },
            'assessment_ace': {
                'title': 'Assessment Ace',
                'description': 'Scored 90%+ on all module assessments',
                'icon': '🏆',
                'points': 75
            },
            'speed_learner': {
                'title': 'Speed Learner',
                'description': 'Completed beginner path in under 3 hours',
                'icon': '⚡',
                'points': 30
            },
            'persistent_learner': {
                'title': 'Persistent Learner',
                'description': 'Studied for 5+ days consecutively',
                'icon': '🔥',
                'points': 40
            }
        }
        
        print("📊 Educational Progress Tracking System Initialized")
        print("🎓 Ready for comprehensive learning analytics")
    
    def setup_database(self):
        """Initialize SQLite database for learning analytics"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Learning events table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS learning_events (
                event_id TEXT PRIMARY KEY,
                user_id TEXT NOT NULL,
                session_id TEXT NOT NULL,
                timestamp TEXT NOT NULL,
                event_type TEXT NOT NULL,
                module_id TEXT NOT NULL,
                content_path TEXT,
                duration_seconds INTEGER,
                score REAL,
                max_score REAL,
                metadata TEXT
            )
        ''')
        
        # User progress table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS user_progress (
                user_id TEXT PRIMARY KEY,
                current_path TEXT,
                modules_completed TEXT,
                modules_in_progress TEXT,
                total_time_spent INTEGER,
                overall_score REAL,
                last_activity TEXT,
                skill_levels TEXT,
                achievements TEXT,
                next_recommended_modules TEXT
            )
        ''')
        
        # Learning paths table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS learning_paths (
                path_id TEXT PRIMARY KEY,
                title TEXT,
                description TEXT,
                difficulty TEXT,
                estimated_duration INTEGER,
                modules TEXT,
                prerequisites TEXT
            )
        ''')
        
        conn.commit()
        conn.close()
    
    def track_event(self, event: LearningEvent):
        """
        Track a learning event
        
        Args:
            event: LearningEvent instance to track
        """
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT OR REPLACE INTO learning_events
            (event_id, user_id, session_id, timestamp, event_type, module_id, 
             content_path, duration_seconds, score, max_score, metadata)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            event.event_id,
            event.user_id, 
            event.session_id,
            event.timestamp.isoformat(),
            event.event_type,
            event.module_id,
            event.content_path,
            event.duration_seconds,
            event.score,
            event.max_score,
            json.dumps(event.metadata) if event.metadata else None
        ))
        
        conn.commit()
        conn.close()
        
        # Update user progress
        self.update_user_progress(event.user_id)
        
        # Check for achievements
        self.check_achievements(event.user_id)
    
    def update_user_progress(self, user_id: str):
        """
        Update user's overall progress based on their learning events
        
        Args:
            user_id: User identifier
        """
        conn = sqlite3.connect(self.db_path)
        
        # Get user's learning events
        events_df = pd.read_sql_query('''
            SELECT * FROM learning_events 
            WHERE user_id = ? 
            ORDER BY timestamp
        ''', conn, params=(user_id,))
        
        if events_df.empty:
            conn.close()
            return
        
        # Calculate progress metrics
        modules_completed = events_df[
            events_df['event_type'] == 'module_complete'
        ]['module_id'].unique().tolist()
        
        modules_in_progress = events_df[
            (events_df['event_type'] == 'module_start') & 
            (~events_df['module_id'].isin(modules_completed))
        ]['module_id'].unique().tolist()
        
        total_time = events_df['duration_seconds'].fillna(0).sum()
        
        # Calculate overall score from assessments
        assessment_scores = events_df[
            (events_df['event_type'] == 'assessment_attempt') & 
            (events_df['score'].notna())
        ]
        
        if not assessment_scores.empty:
            # Weight by max_score to handle different assessment scales
            weighted_scores = assessment_scores['score'] / assessment_scores['max_score']
            overall_score = weighted_scores.mean() * 100
        else:
            overall_score = 0.0
        
        last_activity = pd.to_datetime(events_df['timestamp']).max()
        
        # Determine current learning path (most recent)
        current_path = self.infer_current_path(modules_completed, modules_in_progress)
        
        # Calculate skill levels
        skill_levels = self.calculate_skill_levels(user_id, events_df)
        
        # Get achievements
        achievements = self.get_user_achievements(user_id)
        
        # Generate recommendations
        next_recommended = self.generate_recommendations(
            user_id, modules_completed, skill_levels
        )
        
        # Store updated progress
        cursor = conn.cursor()
        cursor.execute('''
            INSERT OR REPLACE INTO user_progress
            (user_id, current_path, modules_completed, modules_in_progress,
             total_time_spent, overall_score, last_activity, skill_levels,
             achievements, next_recommended_modules)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            user_id,
            current_path,
            json.dumps(modules_completed),
            json.dumps(modules_in_progress),
            int(total_time),
            overall_score,
            last_activity.isoformat(),
            json.dumps(skill_levels),
            json.dumps(achievements),
            json.dumps(next_recommended)
        ))
        
        conn.commit()
        conn.close()
    
    def calculate_skill_levels(self, user_id: str, events_df: pd.DataFrame) -> Dict[str, str]:
        """
        Calculate user's skill levels across different domains
        
        Args:
            user_id: User identifier
            events_df: DataFrame of user's learning events
            
        Returns:
            Dictionary mapping skills to current levels
        """
        skill_levels = {}
        
        # Define module to skill mappings
        skill_mappings = {
            'graph_fundamentals': ['intro-to-graphs', 'basic-queries', 'graph-visualization'],
            'attack_path_analysis': ['attack-paths', 'privilege-escalation', 'multi-hop-analysis'],
            'machine_learning': ['anomaly-detection-ml', 'clustering-analysis', 'risk-modeling'],
            'threat_hunting': ['threat-hunting-automation', 'custom-detection', 'investigation-workflows'],
            'risk_assessment': ['risk-scoring-models', 'quantitative-analysis', 'business-impact']
        }
        
        for skill, related_modules in skill_mappings.items():
            # Count completed modules in this skill area
            completed_in_skill = len([
                module for module in events_df[
                    events_df['event_type'] == 'module_complete'
                ]['module_id'].unique() 
                if any(related_module in module for related_module in related_modules)
            ])
            
            # Get assessment scores for this skill
            skill_assessments = events_df[
                (events_df['event_type'] == 'assessment_attempt') &
                (events_df['module_id'].str.contains('|'.join(related_modules), na=False)) &
                (events_df['score'].notna())
            ]
            
            avg_score = 0
            if not skill_assessments.empty:
                avg_score = (skill_assessments['score'] / skill_assessments['max_score']).mean() * 100
            
            # Determine skill level based on completion and performance
            if completed_in_skill == 0:
                level = 'novice'
            elif completed_in_skill >= 5 and avg_score >= 90:
                level = 'expert'
            elif completed_in_skill >= 3 and avg_score >= 80:
                level = 'advanced'
            elif completed_in_skill >= 2 and avg_score >= 70:
                level = 'intermediate'
            elif completed_in_skill >= 1 or avg_score >= 60:
                level = 'beginner'
            else:
                level = 'novice'
            
            skill_levels[skill] = level
        
        return skill_levels
    
    def check_achievements(self, user_id: str):
        """
        Check and award achievements for user
        
        Args:
            user_id: User identifier
        """
        conn = sqlite3.connect(self.db_path)
        
        events_df = pd.read_sql_query('''
            SELECT * FROM learning_events 
            WHERE user_id = ? 
            ORDER BY timestamp
        ''', conn, params=(user_id,))
        
        current_achievements = self.get_user_achievements(user_id)
        new_achievements = []
        
        # Check each achievement condition
        if 'first_query' not in current_achievements:
            if len(events_df[events_df['event_type'] == 'query_execution']) > 0:
                new_achievements.append('first_query')
        
        if 'attack_path_finder' not in current_achievements:
            attack_path_queries = len(events_df[
                (events_df['event_type'] == 'query_execution') &
                (events_df['metadata'].str.contains('attack_path', na=False))
            ])
            if attack_path_queries >= 5:
                new_achievements.append('attack_path_finder')
        
        if 'ml_practitioner' not in current_achievements:
            ml_modules = len(events_df[
                (events_df['event_type'] == 'module_complete') &
                (events_df['module_id'].str.contains('ml|machine|anomaly', na=False))
            ])
            if ml_modules >= 1:
                new_achievements.append('ml_practitioner')
        
        if 'assessment_ace' not in current_achievements:
            assessments = events_df[
                (events_df['event_type'] == 'assessment_attempt') &
                (events_df['score'].notna()) &
                (events_df['max_score'].notna())
            ]
            if not assessments.empty:
                success_rate = (assessments['score'] / assessments['max_score']).mean()
                if success_rate >= 0.9 and len(assessments) >= 3:
                    new_achievements.append('assessment_ace')
        
        if 'speed_learner' not in current_achievements:
            beginner_modules = events_df[
                (events_df['event_type'] == 'module_complete') &
                (events_df['module_id'].str.contains('beginner|intro|basic', na=False))
            ]
            if not beginner_modules.empty:
                total_time = events_df['duration_seconds'].fillna(0).sum()
                if total_time <= 10800:  # 3 hours
                    new_achievements.append('speed_learner')
        
        if 'persistent_learner' not in current_achievements:
            # Check for 5+ consecutive days of activity
            unique_days = pd.to_datetime(events_df['timestamp']).dt.date.unique()
            if len(unique_days) >= 5:
                # Check if consecutive
                sorted_days = sorted(unique_days)
                consecutive_days = 1
                max_consecutive = 1
                
                for i in range(1, len(sorted_days)):
                    if (sorted_days[i] - sorted_days[i-1]).days == 1:
                        consecutive_days += 1
                        max_consecutive = max(max_consecutive, consecutive_days)
                    else:
                        consecutive_days = 1
                
                if max_consecutive >= 5:
                    new_achievements.append('persistent_learner')
        
        # Award new achievements
        for achievement in new_achievements:
            self.award_achievement(user_id, achievement)
            print(f"🏆 Achievement Unlocked: {self.achievements[achievement]['title']}")
        
        conn.close()
    
    def award_achievement(self, user_id: str, achievement_id: str):
        """
        Award an achievement to a user
        
        Args:
            user_id: User identifier
            achievement_id: Achievement identifier
        """
        # Track achievement event
        event = LearningEvent(
            event_id=str(uuid.uuid4()),
            user_id=user_id,
            session_id="system",
            timestamp=datetime.now(),
            event_type="achievement_awarded",
            module_id="achievements",
            content_path=f"achievements/{achievement_id}",
            metadata={'achievement_id': achievement_id}
        )
        
        self.track_event(event)
    
    def get_user_achievements(self, user_id: str) -> List[str]:
        """
        Get list of user's achievements
        
        Args:
            user_id: User identifier
            
        Returns:
            List of achievement IDs
        """
        conn = sqlite3.connect(self.db_path)
        
        achievements_df = pd.read_sql_query('''
            SELECT metadata FROM learning_events 
            WHERE user_id = ? AND event_type = 'achievement_awarded'
        ''', conn, params=(user_id,))
        
        conn.close()
        
        achievements = []
        for _, row in achievements_df.iterrows():
            if row['metadata']:
                metadata = json.loads(row['metadata'])
                if 'achievement_id' in metadata:
                    achievements.append(metadata['achievement_id'])
        
        return achievements
    
    def generate_recommendations(self, user_id: str, completed_modules: List[str], 
                               skill_levels: Dict[str, str]) -> List[str]:
        """
        Generate personalized learning recommendations
        
        Args:
            user_id: User identifier
            completed_modules: List of completed module IDs
            skill_levels: Current skill levels
            
        Returns:
            List of recommended module IDs
        """
        recommendations = []
        
        # Skill-based recommendations
        for skill, level in skill_levels.items():
            if level == 'novice':
                if skill == 'graph_fundamentals':
                    recommendations.extend(['intro-to-graphs', 'basic-queries'])
                elif skill == 'attack_path_analysis':
                    recommendations.extend(['attack-paths', 'privilege-escalation'])
                elif skill == 'machine_learning':
                    recommendations.extend(['anomaly-detection-ml'])
        
        # Prerequisites-based recommendations
        if 'intro-to-graphs' in completed_modules and 'basic-queries' not in completed_modules:
            recommendations.append('basic-queries')
        
        if 'basic-queries' in completed_modules and 'attack-paths' not in completed_modules:
            recommendations.append('attack-paths')
        
        # Advanced recommendations for experienced users
        advanced_skills = [skill for skill, level in skill_levels.items() 
                          if level in ['advanced', 'expert']]
        
        if len(advanced_skills) >= 2:
            recommendations.extend(['custom-scenario-building', 'advanced-graph-mining'])
        
        # Remove already completed modules
        recommendations = [rec for rec in recommendations if rec not in completed_modules]
        
        # Return top 3 recommendations
        return recommendations[:3]
    
    def get_user_progress(self, user_id: str) -> Optional[UserProgress]:
        """
        Get comprehensive user progress
        
        Args:
            user_id: User identifier
            
        Returns:
            UserProgress object or None if user not found
        """
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('SELECT * FROM user_progress WHERE user_id = ?', (user_id,))
        row = cursor.fetchone()
        
        if not row:
            conn.close()
            return None
        
        # Unpack row data
        (user_id, current_path, modules_completed, modules_in_progress,
         total_time_spent, overall_score, last_activity, skill_levels,
         achievements, next_recommended_modules) = row
        
        progress = UserProgress(
            user_id=user_id,
            current_path=current_path,
            modules_completed=json.loads(modules_completed) if modules_completed else [],
            modules_in_progress=json.loads(modules_in_progress) if modules_in_progress else [],
            total_time_spent=total_time_spent,
            overall_score=overall_score,
            last_activity=datetime.fromisoformat(last_activity),
            skill_levels=json.loads(skill_levels) if skill_levels else {},
            achievements=json.loads(achievements) if achievements else [],
            next_recommended_modules=json.loads(next_recommended_modules) if next_recommended_modules else []
        )
        
        conn.close()
        return progress
    
    def generate_instructor_dashboard(self) -> Dict:
        """
        Generate comprehensive instructor dashboard data
        
        Returns:
            Dictionary with instructor analytics
        """
        conn = sqlite3.connect(self.db_path)
        
        # Get all user progress
        progress_df = pd.read_sql_query('SELECT * FROM user_progress', conn)
        events_df = pd.read_sql_query('SELECT * FROM learning_events', conn)
        
        # Calculate summary statistics
        total_users = len(progress_df)
        active_users = len(progress_df[
            pd.to_datetime(progress_df['last_activity']) >= 
            datetime.now() - timedelta(days=7)
        ])
        
        # Module completion rates
        all_modules = set()
        for modules_str in progress_df['modules_completed']:
            if modules_str:
                all_modules.update(json.loads(modules_str))
        
        module_completion_rates = {}
        for module in all_modules:
            completion_count = sum(1 for modules_str in progress_df['modules_completed']
                                 if modules_str and module in json.loads(modules_str))
            module_completion_rates[module] = (completion_count / total_users) * 100
        
        # Average time per module
        module_times = events_df[
            (events_df['event_type'] == 'module_complete') &
            (events_df['duration_seconds'].notna())
        ].groupby('module_id')['duration_seconds'].mean().to_dict()
        
        # Skill level distribution
        skill_distribution = {}
        for skill in self.skill_levels.keys():
            skill_distribution[skill] = {}
            for level in self.skill_levels[skill]:
                count = sum(1 for skill_levels_str in progress_df['skill_levels']
                           if skill_levels_str and 
                           json.loads(skill_levels_str).get(skill) == level)
                skill_distribution[skill][level] = count
        
        # Learning path analytics
        path_distribution = progress_df['current_path'].value_counts().to_dict()
        
        # Recent activity
        recent_events = events_df[
            pd.to_datetime(events_df['timestamp']) >= 
            datetime.now() - timedelta(days=7)
        ]
        daily_activity = recent_events.groupby(
            pd.to_datetime(recent_events['timestamp']).dt.date
        ).size().to_dict()
        
        conn.close()
        
        return {
            'summary': {
                'total_users': total_users,
                'active_users': active_users,
                'average_score': progress_df['overall_score'].mean(),
                'total_learning_time': progress_df['total_time_spent'].sum() / 3600  # hours
            },
            'module_analytics': {
                'completion_rates': module_completion_rates,
                'average_times': module_times
            },
            'skill_analytics': {
                'skill_distribution': skill_distribution
            },
            'path_analytics': {
                'path_distribution': path_distribution
            },
            'activity_analytics': {
                'daily_activity': {str(k): v for k, v in daily_activity.items()},
                'event_types': events_df['event_type'].value_counts().to_dict()
            }
        }
    
    def infer_current_path(self, completed_modules: List[str], 
                          in_progress_modules: List[str]) -> str:
        """
        Infer user's current learning path based on their activity
        
        Args:
            completed_modules: List of completed module IDs
            in_progress_modules: List of in-progress module IDs
            
        Returns:
            Inferred learning path ID
        """
        all_modules = completed_modules + in_progress_modules
        
        # Simple heuristic based on module patterns
        if any('beginner' in module or 'intro' in module or 'basic' in module 
               for module in all_modules):
            return 'beginner-security-graphs'
        elif any('intermediate' in module or 'advanced' in module or 'ml' in module
                 for module in all_modules):
            return 'intermediate-attack-analysis'
        elif any('expert' in module or 'custom' in module or 'research' in module
                 for module in all_modules):
            return 'expert-security-research'
        else:
            return 'beginner-security-graphs'  # default

# Example usage for demonstration
if __name__ == "__main__":
    # Initialize progress tracker
    tracker = EducationalProgressTracker()
    
    # Simulate some learning events
    user_id = "student_001"
    session_id = str(uuid.uuid4())
    
    # Module start event
    start_event = LearningEvent(
        event_id=str(uuid.uuid4()),
        user_id=user_id,
        session_id=session_id,
        timestamp=datetime.now(),
        event_type="module_start",
        module_id="intro-to-graphs",
        content_path="tutorials/beginner/01-security-graphs-intro.md"
    )
    tracker.track_event(start_event)
    
    # Query execution event
    query_event = LearningEvent(
        event_id=str(uuid.uuid4()),
        user_id=user_id,
        session_id=session_id,
        timestamp=datetime.now(),
        event_type="query_execution",
        module_id="intro-to-graphs",
        content_path="tutorials/beginner/01-security-graphs-intro.md",
        duration_seconds=300,
        metadata={'query_type': 'basic_access_pattern'}
    )
    tracker.track_event(query_event)
    
    # Module completion event
    complete_event = LearningEvent(
        event_id=str(uuid.uuid4()),
        user_id=user_id,
        session_id=session_id,
        timestamp=datetime.now(),
        event_type="module_complete",
        module_id="intro-to-graphs", 
        content_path="tutorials/beginner/01-security-graphs-intro.md",
        duration_seconds=1800
    )
    tracker.track_event(complete_event)
    
    # Assessment attempt
    assessment_event = LearningEvent(
        event_id=str(uuid.uuid4()),
        user_id=user_id,
        session_id=session_id,
        timestamp=datetime.now(),
        event_type="assessment_attempt",
        module_id="intro-to-graphs-assessment",
        content_path="assessments/beginner-assessment.json",
        duration_seconds=600,
        score=85.0,
        max_score=100.0
    )
    tracker.track_event(assessment_event)
    
    # Get user progress
    progress = tracker.get_user_progress(user_id)
    if progress:
        print(f"\n📊 Progress Report for {user_id}:")
        print(f"• Modules completed: {len(progress.modules_completed)}")
        print(f"• Overall score: {progress.overall_score:.1f}%")
        print(f"• Time spent: {progress.total_time_spent/3600:.1f} hours")
        print(f"• Achievements: {len(progress.achievements)}")
        print(f"• Next recommended: {progress.next_recommended_modules}")
    
    # Generate instructor dashboard
    dashboard = tracker.generate_instructor_dashboard()
    print(f"\n👨‍🏫 Instructor Dashboard Summary:")
    print(f"• Total users: {dashboard['summary']['total_users']}")
    print(f"• Active users: {dashboard['summary']['active_users']}")
    print(f"• Average score: {dashboard['summary']['average_score']:.1f}%")
    
    print("\n🎓 Educational Progress Tracking Demonstration Complete!")