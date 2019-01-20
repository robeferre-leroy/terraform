#!/bin/bash

# Symlink variables files
ln -sfn ../variables.tf variables.tf
ln -sfn ../initialize.tf initialize.tf


# Initialize backend
terraform init
