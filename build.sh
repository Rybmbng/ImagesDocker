#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

NAMESPACE="itbalitimbungan"
DOCKERFILE_ROOT="$(cd "$(dirname "$0")" && pwd)"
PHP_VERSIONS_DEFAULT=("8.0" "8.1" "8.2" "8.3" "8.4")
NODE_VERSIONS_DEFAULT=("18" "20" "22")

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Build & push Docker images to Docker Hub.

Options:
    --type TYPE         Build one type: php7-apache | php7-nginx | php8-apache |
                                 php8-nginx | php8-apache-node | php8-nginx-node |
                                 nodejs-only | all
    --php VERSION       PHP version (default: 8.4). Used for php8-* types.
    --node VERSION      NodeJS version (default: 22). Used for node types.
    --all-php           Build all PHP versions (8.0-8.4)
    --all-node          Build all NodeJS versions (18, 20, 22)
    --no-cache          Build without cache
    --push              Push to Docker Hub after build
    --login             Docker Hub login first
    --help              Show this help

Examples:
    $0 --type php8-nginx --php 8.4 --push
    $0 --type php8-apache-node --php 8.3 --node 20 --push
    $0 --type all --all-php --all-node --push
EOF
    exit 0
}

LOGIN=0
PUSH=0
TYPE=""
PHP_VERSION=""
NODE_VERSION=""
NO_CACHE=""
ALL_PHP=0
ALL_NODE=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --type) TYPE="$2"; shift 2 ;;
        --php) PHP_VERSION="$2"; shift 2 ;;
        --node) NODE_VERSION="$2"; shift 2 ;;
        --all-php) ALL_PHP=1; shift ;;
        --all-node) ALL_NODE=1; shift ;;
        --no-cache) NO_CACHE="--no-cache"; shift ;;
        --push) PUSH=1; shift ;;
        --login) LOGIN=1; shift ;;
        --help|-h) usage ;;
        *) echo -e "${RED}Unknown option: $1${NC}"; usage ;;
    esac
done

[[ -z "$TYPE" ]] && { echo -e "${RED}--type is required${NC}"; usage; }
[[ -z "$PHP_VERSION" ]] && PHP_VERSION="8.4"
[[ -z "$NODE_VERSION" ]] && NODE_VERSION="22"

log() { echo -e "${GREEN}[build]${NC} $1"; }
warn() { echo -e "${YELLOW}[warn]${NC} $1"; }
err() { echo -e "${RED}[err]${NC} $1"; exit 1; }

command -v docker >/dev/null || err "Docker not installed"

if [[ "$LOGIN" == "1" ]]; then
    docker login
fi

build_one() {
    local type=$1
    local php_v=$2
    local node_v=$3
    local dir="images/${type}"
    local tag=""

    case "$type" in
        1-php7-apache)
            tag="${NAMESPACE}/php74-apache"
            ;;
        2-php7-nginx)
            tag="${NAMESPACE}/php74-nginx"
            ;;
        3-php8-apache)
            tag="${NAMESPACE}/php${php_v}-apache"
            ;;
        4-php8-nginx)
            tag="${NAMESPACE}/php${php_v}-nginx"
            ;;
        5-php8-apache-node)
            tag="${NAMESPACE}/php${php_v}-apache-node${node_v}"
            ;;
        6-php8-nginx-node)
            tag="${NAMESPACE}/php${php_v}-nginx-node${node_v}"
            ;;
        7-nodejs-only)
            tag="${NAMESPACE}/nodejs${node_v}"
            ;;
        *) err "Unknown type: $type" ;;
    esac

    log "Building ${tag}:latest (php=${php_v}, node=${node_v})"
    docker build $NO_CACHE \
        --build-arg PHP_VERSION="${php_v}" \
        --build-arg NODE_VERSION="${node_v}" \
        -f "${dir}/Dockerfile" \
        -t "${tag}:latest" \
        "$DOCKERFILE_ROOT"

    if [[ "$PUSH" == "1" ]]; then
        log "Pushing ${tag}:latest"
        docker push "${tag}:latest"
    fi
}

expand_php() {
    if [[ "$ALL_PHP" == "1" ]]; then
        echo "${PHP_VERSIONS_DEFAULT[@]}"
    else
        echo "$PHP_VERSION"
    fi
}

expand_node() {
    if [[ "$ALL_NODE" == "1" ]]; then
        echo "${NODE_VERSIONS_DEFAULT[@]}"
    else
        echo "$NODE_VERSION"
    fi
}

case "$TYPE" in
    1-php7-apache|php7-apache)
        build_one "1-php7-apache" "7.4" ""
        ;;
    2-php7-nginx|php7-nginx)
        build_one "2-php7-nginx" "7.4" ""
        ;;
    3-php8-apache|php8-apache)
        for v in $(expand_php); do
            build_one "3-php8-apache" "$v" ""
        done
        ;;
    4-php8-nginx|php8-nginx)
        for v in $(expand_php); do
            build_one "4-php8-nginx" "$v" ""
        done
        ;;
    5-php8-apache-node|php8-apache-node)
        for pv in $(expand_php); do
            for nv in $(expand_node); do
                build_one "5-php8-apache-node" "$pv" "$nv"
            done
        done
        ;;
    6-php8-nginx-node|php8-nginx-node)
        for pv in $(expand_php); do
            for nv in $(expand_node); do
                build_one "6-php8-nginx-node" "$pv" "$nv"
            done
        done
        ;;
    7-nodejs-only|nodejs-only)
        for v in $(expand_node); do
            build_one "7-nodejs-only" "" "$v"
        done
        ;;
    all)
        for t in 1-php7-apache 2-php7-nginx; do
            build_one "$t" "7.4" ""
        done
        for t in 3-php8-apache 4-php8-nginx; do
            for v in $(expand_php); do
                build_one "$t" "$v" ""
            done
        done
        for t in 5-php8-apache-node 6-php8-nginx-node; do
            for pv in $(expand_php); do
                for nv in $(expand_node); do
                    build_one "$t" "$pv" "$nv"
                done
            done
        done
        for v in $(expand_node); do
            build_one "7-nodejs-only" "" "$v"
        done
        ;;
    *) err "Unknown --type: $TYPE" ;;
esac

log "Done."
