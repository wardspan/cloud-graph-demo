// Test script to verify the overview panel update works
function testUpdate() {
    console.log('Testing overview panel update...');
    
    const overviewTitle = document.getElementById('overviewTitle');
    const overviewContent = document.getElementById('overviewContent');
    
    if (!overviewTitle) {
        console.error('overviewTitle element not found!');
        return;
    }
    
    if (!overviewContent) {
        console.error('overviewContent element not found!');
        return;
    }
    
    console.log('Elements found, updating...');
    
    overviewTitle.innerHTML = '🔓 AWS Privilege Escalation';
    overviewContent.innerHTML = `
        <div style="background: #e8f5e8; padding: 15px; border-radius: 8px; margin: 10px 0; border-left: 4px solid #28a745;">
            <h4 style="margin: 0 0 10px 0; color: #155724;">📊 Analysis</h4>
            <p style="margin: 0; color: #155724;">This query finds privilege escalation paths from developer users to sensitive AWS services.</p>
        </div>
        
        <div style="background: #e3f2fd; padding: 15px; border-radius: 8px; margin: 10px 0; border-left: 4px solid #2196f3;">
            <h4 style="margin: 0 0 10px 0; color: #1976d2;">🎯 Expected Results</h4>
            <p style="margin: 0; color: #1976d2;">Shows how 'Sarah Chen' can escalate from developer access to sensitive S3 buckets.</p>
        </div>
        
        <div style="background: #d1ecf1; padding: 15px; border-radius: 8px; margin: 10px 0; border-left: 4px solid #17a2b8;">
            <h4 style="margin: 0 0 10px 0; color: #0c5460;">💡 Analysis Tips</h4>
            <ul style="margin: 0; padding-left: 20px; color: #0c5460;">
                <li>Use the Graph view to visually trace attack paths</li>
                <li>Click on nodes to see their properties and relationships</li>
                <li>Look for patterns in MITRE technique mappings</li>
            </ul>
        </div>
    `;
    
    console.log('Update complete!');
}

// Run test after page loads
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        setTimeout(testUpdate, 1000);
    });
} else {
    setTimeout(testUpdate, 1000);
}