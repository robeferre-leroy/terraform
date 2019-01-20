#!/bin/bash
ln -sfn ../variables.tf variables.tf
ln -sfn ../initialize.tf initialize.tf

terraform init
