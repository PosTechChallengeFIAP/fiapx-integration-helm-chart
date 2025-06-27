#!/bin/bash
set -euo pipefail
cd ../../terraform/cluster
terraform output -json > ../integration/cluster_outputs.json