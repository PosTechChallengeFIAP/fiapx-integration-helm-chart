#!/bin/bash
set -euo pipefail
terraform output -json > ../integration/cluster_outputs.json