FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Cartography with compatible versions
RUN pip install --upgrade pip && \
    pip install cartography boto3 neo4j

# Create application directory
WORKDIR /opt/cartography

# Copy configuration and scripts
COPY config/ /etc/cartography/
COPY mock-data/ /opt/cartography/mock-data/
COPY run-discovery.sh /opt/cartography/
COPY simulate-discovery.py /opt/cartography/

# Make scripts executable
RUN chmod +x /opt/cartography/run-discovery.sh

# Set environment
ENV PYTHONPATH=/opt/cartography
ENV CARTOGRAPHY_CONFIG=/etc/cartography/config.yaml

CMD ["/opt/cartography/run-discovery.sh"]