#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' 
PROJECT_NAME=$(node -p "require('./package.json').name" 2>/dev/null || basename "$(pwd)")
IMAGE_NAME="itbalitimbungan/nginxphp84-node22"
VERSION=${1:-latest}

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Docker Build and Push Script${NC}"
echo -e "${GREEN}Image: ${IMAGE_NAME}:${VERSION}${NC}"
echo -e "${GREEN}========================================${NC}\n"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
fi

if ! docker info | grep -q "Username"; then
    echo -e "${YELLOW}Warning: Not logged in to Docker Hub${NC}"
    echo -e "${YELLOW}Please login first: docker login${NC}"
    read -p "Do you want to login now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker login
    else
        exit 1
    fi
fi

echo -e "${YELLOW}Building Docker image...${NC}"
docker build -t ${IMAGE_NAME}:${VERSION} .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Docker image built successfully${NC}\n"
else
    echo -e "${RED}✗ Failed to build Docker image${NC}"
    exit 1
fi

if [ "$VERSION" != "latest" ]; then
    echo -e "${YELLOW}Tagging image as latest...${NC}"
    docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest
fi

echo -e "${YELLOW}Pushing image to Docker Hub...${NC}"
docker push ${IMAGE_NAME}:${VERSION}

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Image pushed successfully: ${IMAGE_NAME}:${VERSION}${NC}"
else
    echo -e "${RED}✗ Failed to push image${NC}"
    exit 1
fi

if [ "$VERSION" != "latest" ]; then
    echo -e "${YELLOW}Pushing latest tag...${NC}"
    docker push ${IMAGE_NAME}:latest
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Latest tag pushed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to push latest tag${NC}"
    fi
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Build and Push Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\nYou can now pull the image with:"
echo -e "${YELLOW}docker pull ${IMAGE_NAME}:${VERSION}${NC}\n"
echo -e "Or run it with:"
echo -e "${YELLOW}docker run -d -p 80:80 -p 2222:22 \\"
echo -e "  ${IMAGE_NAME}:${VERSION}${NC}\n"
