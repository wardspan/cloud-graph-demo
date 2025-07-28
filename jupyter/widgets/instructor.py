"""
Cloud Threat Graph Lab - Interactive Instruction Widget
Python-based fallback solution using ipywidgets for educational guidance
"""

import ipywidgets as widgets
from IPython.display import display, HTML, clear_output
import json
import os
from typing import List, Dict, Any, Optional

class InstructionWidget:
    """
    Interactive instruction widget for Jupyter notebooks
    Provides step-by-step learning guidance for cybersecurity concepts
    """
    
    def __init__(self, instructions: Optional[List[Dict]] = None, notebook_name: str = ""):
        self.instructions = instructions or []
        self.notebook_name = notebook_name
        self.current_step = 0
        self.progress_tracking = {}
        
        # Widget components
        self.container = None
        self.header = None
        self.progress_bar = None
        self.content_area = None
        self.controls = None
        
        # Initialize
        self.load_instructions()
        self.create_widgets()
        
    def load_instructions(self):
        """Load instructions from file or use defaults"""
        if not self.instructions:
            instruction_file = self.get_instruction_file()
            try:
                with open(instruction_file, 'r') as f:
                    data = json.load(f)
                    self.instructions = data.get('instructions', [])
            except FileNotFoundError:
                self.instructions = self.get_default_instructions()
    
    def get_instruction_file(self) -> str:
        """Get instruction file path based on notebook name"""
        base_path = "/home/jovyan/work/jupyter/templates/"
        
        mapping = {
            '00-Getting-Started-TUTORIAL.ipynb': 'jupyter-basics-instructions.json',
            '01-Graph-Fundamentals.ipynb': 'graph-fundamentals-instructions.json',
            '02-Attack-Path-Discovery.ipynb': 'attack-path-instructions.json',
            '05-Anomaly-Detection-ML.ipynb': 'ml-security-instructions.json'
        }
        
        filename = mapping.get(self.notebook_name, 'default-instructions.json')
        return os.path.join(base_path, filename)
    
    def get_default_instructions(self) -> List[Dict]:
        """Default instructions for fallback"""
        return [
            {
                "title": "Welcome to Cloud Threat Graph Lab",
                "content": """
                <p>🎓 <strong>Welcome to interactive cybersecurity learning!</strong></p>
                <p>This widget will guide you through security concepts step-by-step.</p>
                <ul>
                    <li>📊 Learn graph-based security analysis</li>
                    <li>🔍 Discover attack paths in cloud infrastructure</li>
                    <li>🛡️ Understand MITRE ATT&CK techniques</li>
                    <li>💻 Practice with real security data</li>
                </ul>
                """,
                "type": "overview",
                "target_cell": None
            },
            {
                "title": "Understanding Jupyter Notebooks",
                "content": """
                <p>📚 <strong>How to use this notebook:</strong></p>
                <ol>
                    <li><strong>Read</strong> the text cells (like this one)</li>
                    <li><strong>Run</strong> code cells using <code>Shift + Enter</code></li>
                    <li><strong>Follow</strong> the instructions in order</li>
                    <li><strong>Experiment</strong> with the code examples</li>
                </ol>
                <div style="background: #e8f5e8; padding: 10px; border-radius: 5px; margin: 10px 0;">
                    <strong>💡 Pro Tip:</strong> Always run cells from top to bottom!
                </div>
                """,
                "type": "tutorial",
                "target_cell": 0
            }
        ]
    
    def create_widgets(self):
        """Create the main widget interface"""
        # Header with title and controls
        self.header = widgets.HBox([
            widgets.HTML(
                value="<h3 style='margin: 0; color: #2c3e50;'>🎓 Learning Instructions</h3>",
                layout=widgets.Layout(flex='1')
            ),
            widgets.Button(
                description="",
                icon="times",
                button_style="danger",
                layout=widgets.Layout(width='30px')
            )
        ])
        
        # Progress indicator
        self.progress_bar = widgets.IntProgress(
            value=1,
            min=1,
            max=len(self.instructions) if self.instructions else 1,
            description="Progress:",
            bar_style='info',
            layout=widgets.Layout(width='100%')
        )
        
        # Progress text
        self.progress_text = widgets.HTML(
            value=f"Step 1 of {len(self.instructions)}",
            layout=widgets.Layout(margin='5px 0')
        )
        
        # Content area
        self.content_area = widgets.HTML(
            value="Loading instructions...",
            layout=widgets.Layout(
                border='1px solid #e1e5e9',
                padding='20px',
                margin='10px 0',
                min_height='200px'
            )
        )
        
        # Action buttons
        self.prev_btn = widgets.Button(
            description="◀ Previous",
            button_style="",
            disabled=True,
            layout=widgets.Layout(width='100px')
        )
        
        self.try_it_btn = widgets.Button(
            description="✨ Try It Now",
            button_style="info",
            layout=widgets.Layout(width='120px')
        )
        
        self.solution_btn = widgets.Button(
            description="💡 Solution",
            button_style="warning",
            layout=widgets.Layout(width='100px', display='none')
        )
        
        self.next_btn = widgets.Button(
            description="Next ▶",
            button_style="primary",
            layout=widgets.Layout(width='100px')
        )
        
        # Control panel
        self.controls = widgets.HBox([
            self.prev_btn,
            widgets.HTML(layout=widgets.Layout(flex='1')),  # Spacer
            self.try_it_btn,
            self.solution_btn,
            widgets.HTML(layout=widgets.Layout(flex='1')),  # Spacer
            self.next_btn
        ])
        
        # Main container
        self.container = widgets.VBox([
            widgets.HTML(
                value="""
                <style>
                .instruction-widget {
                    background: white;
                    border: 1px solid #e1e5e9;
                    border-radius: 8px;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                    margin: 10px 0;
                }
                .instruction-header {
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    padding: 15px;
                    border-radius: 8px 8px 0 0;
                }
                .instruction-content {
                    padding: 0;
                }
                .instruction-content ul, .instruction-content ol {
                    margin: 10px 0;
                    padding-left: 20px;
                }
                .instruction-content li {
                    margin: 5px 0;
                }
                .instruction-content code {
                    background: #f1f3f4;
                    padding: 2px 6px;
                    border-radius: 4px;
                    font-family: monospace;
                }
                </style>
                """,
                layout=widgets.Layout(height='0px')
            ),
            widgets.VBox([
                self.header,
                self.progress_bar,
                self.progress_text,
                self.content_area,
                self.controls
            ], layout=widgets.Layout(
                border='1px solid #e1e5e9',
                border_radius='8px',
                padding='15px',
                background_color='white'
            ))
        ])
        
        # Bind events
        self.bind_events()
        
        # Initialize content
        self.update_content()
    
    def bind_events(self):
        """Bind widget events"""
        self.prev_btn.on_click(self.previous_step)
        self.next_btn.on_click(self.next_step)
        self.try_it_btn.on_click(self.try_it_now)
        self.solution_btn.on_click(self.show_solution)
    
    def update_content(self):
        """Update the content area with current instruction"""
        if not self.instructions or self.current_step >= len(self.instructions):
            self.show_completion()
            return
        
        instruction = self.instructions[self.current_step]
        
        # Update content
        content_html = f"""
        <div style="padding: 0;">
            <h4 style="color: #2c3e50; margin-bottom: 15px;">{instruction['title']}</h4>
            <div>{instruction['content']}</div>
        </div>
        """
        
        self.content_area.value = content_html
        
        # Update progress
        self.progress_bar.value = self.current_step + 1
        self.progress_text.value = f"Step {self.current_step + 1} of {len(self.instructions)}"
        
        # Update button states
        self.prev_btn.disabled = (self.current_step == 0)
        self.next_btn.disabled = (self.current_step >= len(self.instructions) - 1)
        
        # Show/hide action buttons based on instruction type
        instruction_type = instruction.get('type', 'overview')
        if instruction_type in ['execute', 'challenge']:
            self.try_it_btn.layout.display = 'block'
        else:
            self.try_it_btn.layout.display = 'none'
            
        if instruction_type == 'challenge' and 'solution' in instruction:
            self.solution_btn.layout.display = 'block'
        else:
            self.solution_btn.layout.display = 'none'
    
    def previous_step(self, button):
        """Go to previous step"""
        if self.current_step > 0:
            self.current_step -= 1
            self.update_content()
    
    def next_step(self, button):
        """Go to next step"""
        if self.current_step < len(self.instructions) - 1:
            self.track_progress('completed')
            self.current_step += 1
            self.update_content()
        elif self.current_step >= len(self.instructions) - 1:
            # Restart from beginning
            self.current_step = 0
            self.update_content()
    
    def try_it_now(self, button):
        """Handle Try It Now button"""
        instruction = self.instructions[self.current_step]
        
        # Create guidance output
        guidance_html = """
        <div style="background: #e8f5e8; border: 1px solid #28a745; border-radius: 5px; padding: 15px; margin: 10px 0;">
            <h5 style="color: #155724; margin-top: 0;">✨ Ready to try!</h5>
            <p style="color: #155724; margin-bottom: 0;">
        """
        
        if instruction.get('target_cell') is not None:
            cell_num = instruction['target_cell'] + 1
            guidance_html += f"Look for <strong>code cell #{cell_num}</strong> and run it with <code>Shift + Enter</code>."
        else:
            guidance_html += "Practice the concepts described above in the next code cell."
        
        guidance_html += """
            </p>
        </div>
        """
        
        display(HTML(guidance_html))
        self.track_progress('attempted')
    
    def show_solution(self, button):
        """Show solution for current step"""
        instruction = self.instructions[self.current_step]
        
        if 'solution' in instruction:
            solution_html = f"""
            <div style="background: #fff3cd; border: 1px solid #ffc107; border-radius: 5px; padding: 15px; margin: 10px 0;">
                <h5 style="color: #856404; margin-top: 0;">💡 Solution</h5>
                <div style="color: #856404;">{instruction['solution']}</div>
            </div>
            """
            display(HTML(solution_html))
            self.solution_btn.layout.display = 'none'
            self.track_progress('solution_viewed')
    
    def show_completion(self):
        """Show completion message"""
        completion_html = """
        <div style="text-align: center; padding: 20px;">
            <h4 style="color: #28a745;">🎉 Congratulations!</h4>
            <p>You've completed all learning instructions for this notebook!</p>
            
            <div style="background: #d4edda; border-radius: 5px; padding: 15px; margin: 15px 0;">
                <h5 style="color: #155724;">🎯 What you've learned:</h5>
                <ul style="text-align: left; color: #155724;">
                    <li>Security graph concepts and analysis</li>
                    <li>Neo4j database querying techniques</li>
                    <li>Attack path discovery methods</li>
                    <li>Hands-on cybersecurity skills</li>
                </ul>
            </div>
            
            <div style="background: #d1ecf1; border-radius: 5px; padding: 15px; margin: 15px 0;">
                <h5 style="color: #0c5460;">💡 Next steps:</h5>
                <ul style="text-align: left; color: #0c5460;">
                    <li>Practice with dashboard scenarios at <a href="http://localhost:3000" target="_blank">localhost:3000</a></li>
                    <li>Try advanced notebooks</li>
                    <li>Explore Neo4j Browser queries at <a href="http://localhost:7474" target="_blank">localhost:7474</a></li>
                </ul>
            </div>
        </div>
        """
        
        self.content_area.value = completion_html
        self.next_btn.description = "🔄 Restart"
        self.next_btn.disabled = False
        self.try_it_btn.layout.display = 'none'
        self.solution_btn.layout.display = 'none'
    
    def track_progress(self, action: str):
        """Track learning progress"""
        step_id = self.current_step
        
        if step_id not in self.progress_tracking:
            self.progress_tracking[step_id] = {
                'started': str(widgets.DateTime.now()),
                'actions': []
            }
        
        self.progress_tracking[step_id]['actions'].append({
            'action': action,
            'timestamp': str(widgets.DateTime.now())
        })
        
        print(f"Progress tracked: Step {step_id + 1} - {action}")
    
    def display(self):
        """Display the widget"""
        display(self.container)
    
    def get_progress_summary(self) -> Dict[str, Any]:
        """Get learning progress summary"""
        total_steps = len(self.instructions)
        completed_steps = len([s for s in self.progress_tracking.values() 
                             if any(a['action'] == 'completed' for a in s['actions'])])
        
        return {
            'total_steps': total_steps,
            'completed_steps': completed_steps,
            'completion_rate': (completed_steps / total_steps) * 100 if total_steps > 0 else 0,
            'detailed_progress': self.progress_tracking
        }


# Convenience functions for easy use in notebooks
def show_instructions(notebook_name: str = "", instructions: Optional[List[Dict]] = None):
    """
    Show interactive instructions for the current notebook
    
    Args:
        notebook_name: Name of the notebook (auto-detected if not provided)
        instructions: Custom instructions (loaded from file if not provided)
    
    Returns:
        InstructionWidget instance
    """
    try:
        # Try to get notebook name from IPython if not provided
        if not notebook_name:
            from IPython.core.display import Javascript
            # This is a simplified approach - in practice you'd need more robust detection
            notebook_name = "current_notebook.ipynb"
        
        widget = InstructionWidget(instructions=instructions, notebook_name=notebook_name)
        widget.display()
        return widget
        
    except Exception as e:
        print(f"Error creating instruction widget: {e}")
        print("Falling back to basic instructions...")
        
        # Fallback basic widget
        basic_widget = InstructionWidget()
        basic_widget.display()
        return basic_widget


def create_custom_instructions(title: str, steps: List[Dict[str, Any]]) -> InstructionWidget:
    """
    Create custom instruction widget with provided steps
    
    Args:
        title: Widget title
        steps: List of instruction steps
    
    Returns:
        InstructionWidget instance
    """
    instructions = []
    for i, step in enumerate(steps):
        instruction = {
            'title': step.get('title', f'Step {i+1}'),
            'content': step.get('content', ''),
            'type': step.get('type', 'overview'),
            'target_cell': step.get('target_cell'),
            'solution': step.get('solution')
        }
        instructions.append(instruction)
    
    widget = InstructionWidget(instructions=instructions)
    widget.display()
    return widget


# Example usage for notebook authors
def demo_instructions():
    """Demonstrate the instruction widget with sample content"""
    sample_instructions = [
        {
            'title': 'Welcome to Security Learning',
            'content': '''
            <p>🎓 <strong>Welcome to the Cloud Threat Graph Lab!</strong></p>
            <p>This interactive guide will teach you:</p>
            <ul>
                <li>Graph-based security analysis</li>
                <li>Attack path discovery</li>
                <li>Neo4j database queries</li>
                <li>MITRE ATT&CK techniques</li>
            </ul>
            ''',
            'type': 'overview'
        },
        {
            'title': 'Your First Security Query',
            'content': '''
            <p>Let's start with a basic query to explore our security graph.</p>
            <p>The code cell below connects to the Neo4j database and runs a simple query.</p>
            <div style="background: #e3f2fd; padding: 10px; border-radius: 5px; margin: 10px 0;">
                <strong>🎯 Goal:</strong> Understand how to connect to the security database
            </div>
            ''',
            'type': 'execute',
            'target_cell': 1
        },
        {
            'title': 'Challenge: Find Attack Paths',
            'content': '''
            <p>🧪 <strong>Your Challenge:</strong></p>
            <p>Write a Cypher query to find attack paths from developer users to sensitive services.</p>
            <p><strong>Hint:</strong> Look for users with <code>access_level = "developer"</code></p>
            ''',
            'type': 'challenge',
            'target_cell': 2,
            'solution': '''
            <pre><code>MATCH path = (user:User)-[*1..3]->(service:Service)
WHERE user.access_level = 'developer' 
  AND service.contains_pii = true
RETURN path LIMIT 5</code></pre>
            '''
        }
    ]
    
    return create_custom_instructions("Demo Instructions", sample_instructions)


if __name__ == "__main__":
    # For testing
    demo_instructions()