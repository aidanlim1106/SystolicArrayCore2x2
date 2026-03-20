# Systolic Core

A fully deployable, silicon-proven **Tensor Processing Unit (TPU) Lite** accelerator. This project implements a 2x2 systolic array in SystemVerilog, verified with an industry-standard UVM testbench, and deployed physically onto a Xilinx Artix-7 FPGA (Basys3).

## Project Goals
1. **Understand AI Hardware:** Demystify the "heavy math" behind Neural Networks by building the fundamental compute block of Google's TPU: the Systolic Array.
2. **Master UVM:** Build a professional, phase-accurate Universal Verification Methodology (UVM) environment from scratch to achieve 99% functional coverage.
3. **Silicon Deployment:** Take abstract RTL through synthesis, placement, routing, and physical deployment on an FPGA using optimized DSP48 hardware slices.

---

## Architecture

The core operates on a **Wavefront Schedule**. Instead of reading/writing to memory for every calculation, data pulses through a grid of Processing Elements (PEs) like a heartbeat.

* **Memory (`memory.sv`):** A verification-friendly 8-entry register file storing the A and B operands. Includes hardware-level `transpose_b` multiplexing for immediate matrix transpositions.
* **MMU / Scheduler (`mmu.sv`):** The "Brain" of the operation. It injects operands into the edges of the array at staggered cycles and issues per-PE `clear` pulses aligned exactly to the arrival of valid data.
* **Systolic Array (`systolic_array.sv`):** A 2x2 grid of MAC (Multiply-Accumulate) Processing Elements. Data flows East and South every clock cycle.
* **Processing Element (`processing_element.sv`):** The atomic unit. Multiplies inputs, accumulates the partial sum, and forwards the data to its neighbors with a 1-cycle delay.

---

## UVM Verification Environment
This core was verified using a robust, object-oriented UVM testbench run on **Cadence Xcelium**.

* **Dynamic Sequence Items:** Fully randomized matrix operands and transpose commands.
* **Passive Monitor:** Uses a shadow memory to passively reconstruct DUT inputs purely by snooping the write bus, enforcing strict separation between the Driver and Monitor.
* **Golden Reference Scoreboard:** An exact mathematical predictor that computes expected 2x2 matrix dot-products and compares them against the DUT's latched output.
* **Coverage:** Driven via Constrained Random tests (`tpu_random_seq.sv`) to hit edge cases (zero matrices, negative limits, asymmetric transposes).

---

## FPGA Deployment (Xilinx Artix-7)

The design is synthesized and physically routed onto the **Digilent Basys3** board. 
* **DSP Inference:** Vivado correctly infers the `a * b` MAC operations into physical **DSP48 slices** (the cyan rectangles in the layout above), proving the design is highly optimized for AI workloads.
* **Physical Wrapper:** `basys3_wrapper.sv` translates raw human interaction (100ms button presses) into 100MHz 1-cycle logic pulses via an edge-detector. 
* **On-Board Math:** Users can load matrices via 16 physical switches and view the 16-bit MAC results dynamically on the board's LEDs.

---

## Challenges & Learnings
* **Wavefront Timing & Flushing:** A systolic array requires deepest nodes to finish cycles *after* the initial nodes. Adding "flush cycles" to the MMU state machine was critical to prevent the output capture from latching premature zero-values.
* **Clock Domain Physics:** Connecting physical FPGA buttons directly to a 100MHz state machine causes the state machine to loop millions of times per press. Designing a dual-flop synchronizer and rising-edge detector was required for stable hardware deployment.
* **EDA Tool Chains:** Navigated Vivado's strict file-locking mechanisms (conflicts with cloud syncing) and managed mixed-language UVM linking using Python automation.

---

## Quick Start / How to Run

### 1. Run UVM Simulation (Cadence Xcelium)
```bash
cd sim/
make -f MakefileUVM all
