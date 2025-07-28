/**
 * Cloud Threat Graph Lab - Jupyter Instruction Overlay System
 * Interactive educational guidance for cybersecurity learning
 */

define([
    'base/js/namespace',
    'base/js/events',
    'services/kernels/kernel',
    'notebook/js/codecell',
    'notebook/js/textcell'
], function(Jupyter, events, kernel, codecell, textcell) {
    "use strict";

    var InstructionOverlay = function() {
        this.currentStep = 0;
        this.instructions = [];
        this.isVisible = false;
        this.progressTracking = {};
        this.highlightedCells = [];
        
        this.init();
    };

    InstructionOverlay.prototype.init = function() {
        var that = this;
        
        // Add toolbar button
        this.addToolbarButton();
        
        // Bind keyboard shortcuts
        this.bindKeyboardShortcuts();
        
        // Load instructions from notebook metadata
        this.loadInstructions();
        
        // Listen for notebook events
        events.on('notebook_loaded.Notebook', function() {
            that.loadInstructions();
        });
        
        console.log("Cloud Threat Graph Lab Instruction Overlay initialized");
    };

    InstructionOverlay.prototype.addToolbarButton = function() {
        var that = this;
        
        if (!Jupyter.toolbar) {
            setTimeout(function() { that.addToolbarButton(); }, 100);
            return;
        }

        var action = {
            icon: 'fa-graduation-cap',
            help: 'Show/Hide Learning Instructions',
            help_index: 'zz',
            handler: function() {
                that.toggleOverlay();
            }
        };

        var prefix = 'instruction_overlay';
        var action_name = 'show-instructions';
        var full_action_name = Jupyter.actions.register(action, action_name, prefix);
        
        Jupyter.toolbar.add_buttons_group([{
            'label': '🎓 Instructions',
            'icon': 'fa-graduation-cap',
            'callback': function() {
                that.toggleOverlay();
            },
            'id': 'instruction-overlay-btn'
        }]);
    };

    InstructionOverlay.prototype.bindKeyboardShortcuts = function() {
        var that = this;
        
        // ESC to close overlay
        Jupyter.keyboard_manager.command_shortcuts.add_shortcut('esc', {
            help: 'Close instruction overlay',
            help_index: 'zz',
            handler: function() {
                if (that.isVisible) {
                    that.hideOverlay();
                    return false;
                }
                return true;
            }
        });
        
        // Ctrl+Shift+I to toggle overlay
        Jupyter.keyboard_manager.command_shortcuts.add_shortcut('ctrl-shift-i', {
            help: 'Toggle instruction overlay',
            help_index: 'zz',
            handler: function() {
                that.toggleOverlay();
                return false;
            }
        });
    };

    InstructionOverlay.prototype.loadInstructions = function() {
        var that = this;
        
        // Try to load from notebook metadata
        if (Jupyter.notebook && Jupyter.notebook.metadata) {
            var metadata = Jupyter.notebook.metadata;
            
            if (metadata.learning_instructions) {
                this.instructions = metadata.learning_instructions;
                console.log("Loaded instructions from notebook metadata:", this.instructions.length, "steps");
                return;
            }
        }
        
        // Fallback: detect notebook type and load appropriate instructions
        this.detectAndLoadInstructions();
    };

    InstructionOverlay.prototype.detectAndLoadInstructions = function() {
        var notebookName = this.getNotebookName();
        var instructionUrl = '/files/jupyter/templates/' + this.getInstructionFile(notebookName);
        
        var that = this;
        $.getJSON(instructionUrl)
            .done(function(data) {
                that.instructions = data.instructions || [];
                console.log("Loaded instructions for", notebookName, ":", that.instructions.length, "steps");
            })
            .fail(function() {
                console.log("No specific instructions found for", notebookName, "using default");
                that.loadDefaultInstructions();
            });
    };

    InstructionOverlay.prototype.getNotebookName = function() {
        if (Jupyter.notebook && Jupyter.notebook.notebook_name) {
            return Jupyter.notebook.notebook_name;
        }
        return 'default';
    };

    InstructionOverlay.prototype.getInstructionFile = function(notebookName) {
        var mapping = {
            '00-Getting-Started-TUTORIAL.ipynb': 'jupyter-basics-instructions.json',
            '01-Graph-Fundamentals.ipynb': 'graph-fundamentals-instructions.json',
            '02-Attack-Path-Discovery.ipynb': 'attack-path-instructions.json',
            '05-Anomaly-Detection-ML.ipynb': 'ml-security-instructions.json'
        };
        
        return mapping[notebookName] || 'default-instructions.json';
    };

    InstructionOverlay.prototype.loadDefaultInstructions = function() {
        this.instructions = [
            {
                "title": "Welcome to Cloud Threat Graph Lab",
                "content": "This interactive guide will help you learn cybersecurity concepts through hands-on practice.",
                "type": "overview",
                "target_cell": null
            },
            {
                "title": "Running Code Cells",
                "content": "Click on a code cell and press <kbd>Shift + Enter</kbd> to execute it. Try it with the cell below!",
                "type": "execute",
                "target_cell": 0
            }
        ];
    };

    InstructionOverlay.prototype.toggleOverlay = function() {
        if (this.isVisible) {
            this.hideOverlay();
        } else {
            this.showOverlay();
        }
    };

    InstructionOverlay.prototype.showOverlay = function() {
        if (this.instructions.length === 0) {
            alert("No instructions available for this notebook. Check that instruction files are properly loaded.");
            return;
        }
        
        this.createOverlayHTML();
        this.isVisible = true;
        this.currentStep = 0;
        this.updateOverlayContent();
        this.updateProgress();
        
        // Show with animation
        $('#instruction-overlay').fadeIn(300);
    };

    InstructionOverlay.prototype.hideOverlay = function() {
        $('#instruction-overlay').fadeOut(300);
        this.clearHighlights();
        this.isVisible = false;
    };

    InstructionOverlay.prototype.createOverlayHTML = function() {
        // Remove existing overlay
        $('#instruction-overlay').remove();
        
        var overlayHTML = `
            <div id="instruction-overlay" class="instruction-overlay">
                <div class="overlay-content">
                    <div class="overlay-header">
                        <h3 id="overlay-title">🎓 Learning Instructions</h3>
                        <div class="overlay-controls">
                            <button id="overlay-minimize" class="control-btn" title="Minimize">─</button>
                            <button id="overlay-close" class="control-btn" title="Close (ESC)">×</button>
                        </div>
                    </div>
                    
                    <div class="progress-container">
                        <div class="progress-bar">
                            <div id="progress-fill" class="progress-fill"></div>
                        </div>
                        <div id="progress-text" class="progress-text">Step 1 of ${this.instructions.length}</div>
                    </div>
                    
                    <div class="instruction-content">
                        <h4 id="instruction-title">Loading...</h4>
                        <div id="instruction-body">Loading instructions...</div>
                    </div>
                    
                    <div class="overlay-actions">
                        <button id="prev-step" class="action-btn secondary">◀ Previous</button>
                        <div class="center-actions">
                            <button id="try-it-btn" class="action-btn primary">✨ Try It Now</button>
                            <button id="show-solution" class="action-btn secondary" style="display: none;">💡 Show Solution</button>
                        </div>
                        <button id="next-step" class="action-btn primary">Next ▶</button>
                    </div>
                </div>
            </div>
        `;
        
        $('body').append(overlayHTML);
        this.bindOverlayEvents();
    };

    InstructionOverlay.prototype.bindOverlayEvents = function() {
        var that = this;
        
        // Close button
        $('#overlay-close').click(function() {
            that.hideOverlay();
        });
        
        // Minimize button
        $('#overlay-minimize').click(function() {
            $('.overlay-content').toggleClass('minimized');
        });
        
        // Navigation buttons
        $('#prev-step').click(function() {
            that.previousStep();
        });
        
        $('#next-step').click(function() {
            that.nextStep();
        });
        
        // Try It Now button
        $('#try-it-btn').click(function() {
            that.tryItNow();
        });
        
        // Show Solution button
        $('#show-solution').click(function() {
            that.showSolution();
        });
        
        // Make overlay draggable
        this.makeOverlayDraggable();
    };

    InstructionOverlay.prototype.makeOverlayDraggable = function() {
        var isDragging = false;
        var currentX, currentY, initialX, initialY;
        
        $('.overlay-header').on('mousedown', function(e) {
            isDragging = true;
            initialX = e.clientX - $('.overlay-content').offset().left;
            initialY = e.clientY - $('.overlay-content').offset().top;
        });
        
        $(document).on('mousemove', function(e) {
            if (isDragging) {
                currentX = e.clientX - initialX;
                currentY = e.clientY - initialY;
                $('.overlay-content').css({
                    'left': currentX + 'px',
                    'top': currentY + 'px',
                    'position': 'fixed'
                });
            }
        });
        
        $(document).on('mouseup', function() {
            isDragging = false;
        });
    };

    InstructionOverlay.prototype.updateOverlayContent = function() {
        if (this.currentStep >= this.instructions.length) {
            this.showCompletionMessage();
            return;
        }
        
        var instruction = this.instructions[this.currentStep];
        
        $('#instruction-title').text(instruction.title);
        $('#instruction-body').html(instruction.content);
        
        // Update button states
        $('#prev-step').prop('disabled', this.currentStep === 0);
        $('#next-step').prop('disabled', this.currentStep === this.instructions.length - 1);
        
        // Show/hide action buttons based on instruction type
        this.updateActionButtons(instruction);
        
        // Highlight target cell if specified
        this.highlightTargetCell(instruction);
    };

    InstructionOverlay.prototype.updateActionButtons = function(instruction) {
        var $tryItBtn = $('#try-it-btn');
        var $solutionBtn = $('#show-solution');
        
        // Show Try It Now for executable instructions
        if (instruction.type === 'execute' || instruction.type === 'challenge') {
            $tryItBtn.show();
            $tryItBtn.text(instruction.type === 'challenge' ? '🧪 Try Challenge' : '✨ Try It Now');
        } else {
            $tryItBtn.hide();
        }
        
        // Show solution button for challenges
        if (instruction.type === 'challenge' && instruction.solution) {
            $solutionBtn.show();
        } else {
            $solutionBtn.hide();
        }
    };

    InstructionOverlay.prototype.highlightTargetCell = function(instruction) {
        this.clearHighlights();
        
        if (instruction.target_cell !== null && instruction.target_cell !== undefined) {
            var cellIndex = instruction.target_cell;
            var cells = Jupyter.notebook.get_cells();
            
            if (cellIndex >= 0 && cellIndex < cells.length) {
                var cell = cells[cellIndex];
                var cellElement = $(cell.element);
                
                cellElement.addClass('instruction-highlighted');
                this.highlightedCells.push(cellElement);
                
                // Scroll to cell
                cellElement[0].scrollIntoView({
                    behavior: 'smooth',
                    block: 'center'
                });
            }
        }
    };

    InstructionOverlay.prototype.clearHighlights = function() {
        this.highlightedCells.forEach(function(cell) {
            cell.removeClass('instruction-highlighted');
        });
        this.highlightedCells = [];
    };

    InstructionOverlay.prototype.tryItNow = function() {
        var instruction = this.instructions[this.currentStep];
        
        if (instruction.target_cell !== null && instruction.target_cell !== undefined) {
            var cellIndex = instruction.target_cell;
            var cells = Jupyter.notebook.get_cells();
            
            if (cellIndex >= 0 && cellIndex < cells.length) {
                var cell = cells[cellIndex];
                
                // Focus on the cell
                Jupyter.notebook.select(cellIndex);
                
                // If it's a code cell and instruction says to execute
                if (cell instanceof codecell.CodeCell && instruction.type === 'execute') {
                    // Optionally auto-execute
                    if (instruction.auto_execute) {
                        cell.execute();
                    }
                }
                
                // Flash effect
                $(cell.element).addClass('instruction-flash');
                setTimeout(function() {
                    $(cell.element).removeClass('instruction-flash');
                }, 1000);
            }
        }
        
        // Mark step as attempted
        this.trackProgress('attempted');
    };

    InstructionOverlay.prototype.showSolution = function() {
        var instruction = this.instructions[this.currentStep];
        
        if (instruction.solution) {
            var solutionHTML = `
                <div class="solution-panel">
                    <h5>💡 Solution:</h5>
                    <div class="solution-content">${instruction.solution}</div>
                </div>
            `;
            
            $('#instruction-body').append(solutionHTML);
            $('#show-solution').hide();
            
            this.trackProgress('solution_viewed');
        }
    };

    InstructionOverlay.prototype.nextStep = function() {
        if (this.currentStep < this.instructions.length - 1) {
            this.trackProgress('completed');
            this.currentStep++;
            this.updateOverlayContent();
            this.updateProgress();
        }
    };

    InstructionOverlay.prototype.previousStep = function() {
        if (this.currentStep > 0) {
            this.currentStep--;
            this.updateOverlayContent();
            this.updateProgress();
        }
    };

    InstructionOverlay.prototype.updateProgress = function() {
        var progress = ((this.currentStep + 1) / this.instructions.length) * 100;
        $('#progress-fill').css('width', progress + '%');
        $('#progress-text').text(`Step ${this.currentStep + 1} of ${this.instructions.length}`);
    };

    InstructionOverlay.prototype.trackProgress = function(action) {
        var stepId = this.currentStep;
        
        if (!this.progressTracking[stepId]) {
            this.progressTracking[stepId] = {
                started: new Date(),
                actions: []
            };
        }
        
        this.progressTracking[stepId].actions.push({
            action: action,
            timestamp: new Date()
        });
        
        // Save to notebook metadata
        if (Jupyter.notebook && Jupyter.notebook.metadata) {
            Jupyter.notebook.metadata.learning_progress = this.progressTracking;
        }
        
        console.log("Progress tracked:", stepId, action);
    };

    InstructionOverlay.prototype.showCompletionMessage = function() {
        $('#instruction-title').text('🎉 Congratulations!');
        $('#instruction-body').html(`
            <div class="completion-message">
                <p>You've completed all learning instructions for this notebook!</p>
                <p>🎯 <strong>What you've learned:</strong></p>
                <ul>
                    <li>Security graph concepts and analysis</li>
                    <li>Neo4j database querying techniques</li>
                    <li>Attack path discovery methods</li>
                    <li>Hands-on cybersecurity skills</li>
                </ul>
                <p>💡 <strong>Next steps:</strong></p>
                <ul>
                    <li>Practice with the dashboard scenarios</li>
                    <li>Try advanced notebooks</li>
                    <li>Explore Neo4j Browser queries</li>
                </ul>
            </div>
        `);
        
        $('#try-it-btn').hide();
        $('#show-solution').hide();
        $('#next-step').text('🔄 Restart').prop('disabled', false);
        
        // Override next button to restart
        $('#next-step').off('click').on('click', function() {
            this.currentStep = 0;
            this.updateOverlayContent();
            this.updateProgress();
        }.bind(this));
    };

    // Initialize the extension when notebook is ready
    function load_ipython_extension() {
        return Jupyter.notebook.config.loaded.then(function() {
            new InstructionOverlay();
        });
    }

    return {
        load_ipython_extension: load_ipython_extension
    };
});