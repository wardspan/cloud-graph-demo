/**
 * Cartography Service - Interface with the Cartography container
 * Handles asset discovery simulation and progress tracking
 */

class CartographyService {
    constructor() {
        this.cartographyApiUrl = 'http://localhost:8080';
        this.discoveryInProgress = false;
        this.discoveryPhases = [
            { 
                name: 'Foundation Discovery', 
                duration: 2000, 
                message: 'Discovering AWS accounts and regions...',
                detail: 'Cartography scans AWS API endpoints to enumerate accounts, regions, and availability zones. Uses boto3 SDK with read-only permissions.'
            },
            { 
                name: 'Identity Discovery', 
                duration: 3000, 
                message: 'Mapping IAM users, roles, and policies...',
                detail: 'Enumerating IAM entities using list_users(), list_roles(), and get_role_policy() calls. Analyzing trust relationships and permissions.'
            },
            { 
                name: 'Compute Discovery', 
                duration: 2000, 
                message: 'Discovering EC2 instances and networking...',
                detail: 'Scanning EC2 instances, VPCs, security groups, and networking configurations. Identifying instance profiles and metadata access.'
            },
            { 
                name: 'Storage Discovery', 
                duration: 2000, 
                message: 'Mapping S3 buckets and databases...',
                detail: 'Enumerating S3 buckets, analyzing bucket policies, and discovering RDS instances. Checking for public access and encryption settings.'
            },
            { 
                name: 'Serverless Discovery', 
                duration: 2000, 
                message: 'Discovering Lambda functions and APIs...',
                detail: 'Mapping Lambda functions, API Gateway endpoints, and serverless execution roles. Analyzing environment variables and trigger configurations.'
            },
            { 
                name: 'Relationship Discovery', 
                duration: 2000, 
                message: 'Analyzing resource relationships...',
                detail: 'Building graph relationships between discovered resources. Mapping IAM role assumptions, resource access patterns, and trust relationships.'
            },
            { 
                name: 'Security Analysis', 
                duration: 1000, 
                message: 'Performing security posture analysis...',
                detail: 'Analyzing discovered assets for security risks, overprivileged roles, public access, and potential attack paths. Generating risk scores.'
            }
        ];
    }

    /**
     * Start the asset discovery simulation
     */
    async startAssetDiscovery() {
        if (this.discoveryInProgress) {
            console.log('Discovery already in progress');
            return;
        }

        this.discoveryInProgress = true;
        this.updateDiscoveryUI('starting');

        try {
            // Simulate progressive discovery phases
            for (let i = 0; i < this.discoveryPhases.length; i++) {
                const phase = this.discoveryPhases[i];
                const progress = ((i + 1) / this.discoveryPhases.length) * 100;
                
                this.updateDiscoveryPhase(phase.name, phase.message, progress);
                
                // Simulate phase duration
                await this.sleep(phase.duration);
                
                // Update asset counts as discovery progresses
                this.updateAssetCounts(i + 1);
            }

            // Trigger the actual Cartography simulation
            await this.triggerCartographySimulation();
            
            this.updateDiscoveryUI('completed');
            this.discoveryInProgress = false;
            
        } catch (error) {
            console.error('Discovery simulation failed:', error);
            this.updateDiscoveryUI('error', error.message);
            this.discoveryInProgress = false;
        }
    }

    /**
     * Trigger the actual Cartography container simulation
     */
    async triggerCartographySimulation() {
        try {
            const response = await fetch(`${this.cartographyApiUrl}/discover`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    simulation: true,
                    phases: this.discoveryPhases.map(p => p.name.toLowerCase().replace(' ', '_'))
                })
            });

            if (!response.ok) {
                console.warn('Cartography API not available, using simulation mode');
                return;
            }

            const result = await response.json();
            console.log('Cartography discovery result:', result);
            
        } catch (error) {
            // Cartography container might not be running, continue with UI simulation
            console.warn('Could not connect to Cartography API, using simulation mode:', error);
        }
    }

    /**
     * Update the discovery UI with current phase information
     */
    updateDiscoveryPhase(phaseName, message, progress) {
        const phaseElement = document.getElementById('discoveryPhase');
        const progressBar = document.getElementById('discoveryBar');
        
        // Find the current phase details
        const currentPhase = this.discoveryPhases.find(phase => phase.name === phaseName);
        const detail = currentPhase ? currentPhase.detail : '';
        
        if (phaseElement) {
            phaseElement.innerHTML = `
                <div style="margin-bottom: 6px;">
                    <strong>${phaseName}:</strong> ${message}
                </div>
                <div style="font-size: 0.75em; color: #666; font-style: italic; line-height: 1.3;">
                    💡 ${detail}
                </div>
            `;
        }
        
        if (progressBar) {
            progressBar.style.width = `${progress}%`;
        }
    }

    /**
     * Update asset counts as discovery progresses
     */
    updateAssetCounts(phaseIndex) {
        // Simulate increasing asset counts
        const baseAssets = [5, 12, 18, 25, 32, 38, 42];
        const baseRelationships = [3, 8, 14, 20, 26, 30, 35];
        
        const assetCount = baseAssets[Math.min(phaseIndex - 1, baseAssets.length - 1)] || 0;
        const relationshipCount = baseRelationships[Math.min(phaseIndex - 1, baseRelationships.length - 1)] || 0;
        
        const discoveredCountElement = document.getElementById('discoveredCount');
        const relationshipCountElement = document.getElementById('relationshipCount');
        
        if (discoveredCountElement) {
            this.animateCount(discoveredCountElement, assetCount);
        }
        
        if (relationshipCountElement) {
            this.animateCount(relationshipCountElement, relationshipCount);
        }
    }

    /**
     * Animate counter updates
     */
    animateCount(element, targetValue) {
        const currentValue = parseInt(element.textContent) || 0;
        const increment = Math.ceil((targetValue - currentValue) / 10);
        
        const updateCount = () => {
            const current = parseInt(element.textContent) || 0;
            if (current < targetValue) {
                element.textContent = Math.min(current + increment, targetValue);
                setTimeout(updateCount, 100);
            }
        };
        
        updateCount();
    }

    /**
     * Update the overall discovery UI state
     */
    updateDiscoveryUI(state, message = '') {
        const statusElement = document.getElementById('discoveryStatus');
        const progressElement = document.getElementById('discoveryProgress');
        const buttonElement = document.getElementById('discoverBtn');
        
        switch (state) {
            case 'starting':
                if (progressElement) {
                    progressElement.style.display = 'block';
                }
                if (buttonElement) {
                    buttonElement.disabled = true;
                    buttonElement.innerHTML = '🔄 Discovery Running...';
                }
                break;
                
            case 'completed':
                if (statusElement) {
                    const discoveredCount = document.getElementById('discoveredCount')?.textContent || '47';
                    const relationshipCountEl = document.getElementById('relationshipCount')?.textContent || '23';
                    statusElement.innerHTML = `
                        <div style="background: #d4edda; padding: 12px; border-radius: 6px; text-align: center; border: 1px solid #c3e6cb;">
                            <p style="margin: 0; color: #155724; font-weight: bold;">
                                ✅ Asset Discovery Complete
                            </p>
                            <div style="margin-top: 10px;">
                                <span style="font-size: 0.8em; color: #155724;">
                                    📊 Discovered Assets: <strong>${discoveredCount}</strong> | 
                                    🔗 New Relationships: <strong>${relationshipCountEl}</strong>
                                </span>
                            </div>
                            <div style="margin-top: 8px; font-size: 0.7em; color: #6c757d;">
                                Try scenarios 9 & 10 to explore discovery-based attack paths
                            </div>
                        </div>
                    `;
                }
                if (progressElement) {
                    progressElement.style.display = 'none';
                }
                if (buttonElement) {
                    buttonElement.disabled = false;
                    buttonElement.innerHTML = '🔄 Rediscover Infrastructure';
                }
                
                // Show discovery-dependent scenarios
                this.enableDiscoveryScenarios();
                break;
                
            case 'error':
                if (statusElement) {
                    statusElement.innerHTML = `
                        <div style="background: #f8d7da; padding: 12px; border-radius: 6px; text-align: center;">
                            <p style="margin: 0; color: #721c24; font-weight: bold;">
                                ❌ Discovery Failed
                            </p>
                            <div style="margin-top: 5px;">
                                <span style="font-size: 0.8em; color: #721c24;">
                                    ${message || 'Unknown error occurred'}
                                </span>
                            </div>
                        </div>
                    `;
                }
                if (progressElement) {
                    progressElement.style.display = 'none';
                }
                if (buttonElement) {
                    buttonElement.disabled = false;
                    buttonElement.innerHTML = '🔍 Retry Discovery';
                }
                break;
        }
    }

    /**
     * Enable scenarios that require asset discovery
     */
    enableDiscoveryScenarios() {
        const discoveryScenarios = document.querySelectorAll('.requires-discovery');
        discoveryScenarios.forEach(scenario => {
            scenario.style.opacity = '1';
            scenario.style.pointerEvents = 'auto';
            scenario.classList.add('discovery-enabled');
        });
    }

    /**
     * Check if asset discovery has been completed
     */
    isDiscoveryComplete() {
        return !this.discoveryInProgress && 
               document.getElementById('discoveredCount') && 
               parseInt(document.getElementById('discoveredCount').textContent) > 0;
    }

    /**
     * Get discovery statistics
     */
    async getDiscoveryStats() {
        try {
            const response = await fetch(`${this.cartographyApiUrl}/stats`);
            if (response.ok) {
                return await response.json();
            }
        } catch (error) {
            console.warn('Could not fetch discovery stats:', error);
        }
        
        // Return simulated stats if Cartography API is not available
        return {
            totalAssets: parseInt(document.getElementById('discoveredCount')?.textContent) || 0,
            totalRelationships: parseInt(document.getElementById('relationshipCount')?.textContent) || 0,
            securityFindings: Math.floor(Math.random() * 15) + 5,
            lastDiscovery: new Date().toISOString()
        };
    }

    /**
     * Utility function for async sleep
     */
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    /**
     * Reset discovery state
     */
    resetDiscovery() {
        this.discoveryInProgress = false;
        
        // Reset UI elements
        const discoveredCountElement = document.getElementById('discoveredCount');
        const relationshipCountElement = document.getElementById('relationshipCount');
        
        if (discoveredCountElement) discoveredCountElement.textContent = '0';
        if (relationshipCountElement) relationshipCountElement.textContent = '0';
        
        // Disable discovery-dependent scenarios
        const discoveryScenarios = document.querySelectorAll('.requires-discovery');
        discoveryScenarios.forEach(scenario => {
            scenario.style.opacity = '0.6';
            scenario.style.pointerEvents = 'none';
            scenario.classList.remove('discovery-enabled');
        });
        
        this.updateDiscoveryUI('reset');
    }
}

// Export for use in main dashboard
window.CartographyService = CartographyService;