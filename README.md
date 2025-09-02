# Mitigating Excessive vCPU Spinning in Confidential VMs Without Hypervisor Support

## Overview

This project benchmarks and analyzes the performance impacts of vCPU spinning in Confidential Virtual Machines (CVMs) and proposes guest-side solutions for mitigating these issues, focusing on environments where the hypervisor cannot assist (e.g., Intel TDX). Scripts, results, and documentation are here to enable full reproduction of my experiments and to illustrate the performance challenges and solutions for vCPU spinning in confidential VMs.
This repository is a work in progress, and will continue to be updated as new findings, analysis, and improvements are added. The current goal is to now build the spinning solution, estimated to be done December 2026.

---

## Background

**Confidential Virtual Machines (CVMs)** use hardware-backed memory encryption and attestation to protect guest data, even from privileged hypervisors. While this greatly improves security, it disables or limits traditional virtualization performance optimizations like Paravirtualization (PV) and Pause-Loop Exiting (PLE).

As a consequence, performance bottlenecks such as excessive vCPU spinning—where threads waste CPU cycles waiting for locks—are more pronounced in CVMs due to reduced host-guest coordination.

---

## Performance Bottlenecks

- **vCPU Spinning:** Occurs when threads repeatedly check the status of a lock.
    - Short waits: Efficient.
    - Long or excessive waits: Wastes CPU, degrades performance.
- **Lock Holder/Waiter Problems (LHP/LWP):** Preemption of lock holders or waiters causes other vCPUs to spin excessively, particularly problematic for CVMs.

Traditional solutions (PV/PLE) rely on host-guest collaboration, but are ineffective in CVMs due to their strict isolation.

---

## Benchmarking Results

Experiments compare Regular VMs (REGVM) and CVMs under four conditions:

- REGVM PV/PLE OFF
- REGVM PV/PLE ON
- CVM PV/PLE OFF
- CVM PV/PLE ON

**Benchmarks Used as of 9/1/2025:**
- `hackbench` (CPU scheduler and lock contention)
- `dbench` (Filesystem/I/O throughput)

### Hackbench Results (Time in seconds, lower is better):

| Configuration         | Time (s) |
|-----------------------|----------|
| REGVM PV/PLE OFF      | 31.421   |
| REGVM PV/PLE ON       | 27.099   |
| CVM PV/PLE OFF        | 38.579   |
| CVM PV/PLE ON         | 37.633   |

**Highlights:**
- PV/PLE ON gives REGVM a 13.78% speedup vs. OFF.
- For CVM, PV/PLE ON yields only a 2.45% speedup. The 2.45% speedup for CVM PV/PLE ON versus OFF is likely within the margin of run-to-run noise. Prior work shows these features have minimal impact in CVMs due to hardware-enforced isolation, and more accurate assessment would require averaging over multiple test runs.
- REGVM PV/PLE ON completes hackbench 27.97% faster than the best CVM.
- REGVM PV/PLE OFF is still 16.52% faster than the best CVM.

### Dbench Results (Throughput in MB/sec, higher is better):

| Configuration         | Throughput (MB/sec) |
|-----------------------|--------------------|
| REGVM PV/PLE OFF      | 3337.43            |
| REGVM PV/PLE ON       | 3590.81            |
| CVM PV/PLE OFF        | 2625.12            |
| CVM PV/PLE ON         | 2657.53            |

**Highlights:**
- PV/PLE ON gives REGVM a 7.60% throughput gain vs. OFF.
- For CVMs, PV/PLE ON offers only 1.23% improvement. The 1.23% speedup for CVM PV/PLE ON versus OFF is likely within the margin of run-to-run noise. Prior work shows these features have minimal impact in CVMs due to hardware-enforced isolation, and more accurate assessment would require averaging over multiple test runs.
- REGVM PV/PLE ON is 35.13% higher throughput than CVM.
- REGVM PV/PLE OFF is still 25.63% higher than CVM.

---

## Solution: Lockholder Awareness

To address excessive spinning when traditional PV/PLE are unavailable, this project explores **guest-side, scheduler-based techniques**:

- **Delayed Preemption:** Migrates lockholding vCPUs before preemption to enable other vCPUs to spin efficiently.
- **Adaptive Spinning:** Converts lockwaiters to sleep when a lockholder gets preempted, reducing resource waste.

Both are implemented via `vSched`, which infers real-time vCPU state within the guest for intelligent scheduling decisions.  
See:  
Guo, Edward, Weiwei Jia, Xiaoning Ding, and Jianchen Shan. "Optimizing Task Scheduling in Cloud VMs with Accurate vCPU Abstraction." In Proceedings of the Twentieth European Conference on Computer Systems, pp. 753-768. 2025.

---

## Directory Structure

- **/scripts** — Scripts to run benchmarks (`hackbench`, `dbench`, etc...) and configure VMs.
- **/results** — Collected raw data from benchmarks and tables to visualize said data.
- **/docs** — My methodology of going about this project and references.

---

## How To Reproduce

1. Clone the repo and review `/scripts/README.md` for setup instructions.
2. Use provided scripts to run tests under each VM configuration.
3. Compare with my results and if anything is askew, contact me through the email found in my profile.

---

## License

MIT

---

# Acknowledgments

Nickolaos Hatzigeorgiou  
Advisor: Dr. Jianchen Shan
