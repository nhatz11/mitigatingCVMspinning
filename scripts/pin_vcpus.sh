#!/bin/bash

# Usage: sudo ./pin_vcpus.sh <vm-name>
# Purpose: Easy way to pin the vCPUs of my test VMs to the same cores to simulate lock contention.
VM_NAME="$1"

if [ -z "$VM_NAME" ]; then
    echo "Usage: $0 <vm-name>"
    exit 1
fi

# Pin vCPU i to physical core i for i = 0..15
for i in $(seq 0 35); do
    echo "Pinning vCPU $i of $VM_NAME to physical core $i"
    virsh vcpupin "$VM_NAME" "$i" "$i" 
done

echo "vCPU pinning complete."
