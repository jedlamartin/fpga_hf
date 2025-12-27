# fpga_hf

A hardware-accelerated image processing project that implements a 2D Finite Impulse Response (FIR) filter on an FPGA. 

The core logic processes video data in the pixel domain, utilizing line buffers and convolution kernels to apply spatial filtering (e.g., Sobel, Laplacian) directly to the video pipeline.

## Repository Structure

* `src/`: Contains the Verilog source code for the HDMI interface, line buffers, and FIR filter logic.
* `constr/`: Physical constraints files (pinout and timing definitions) for the target FPGA board.
* `sim/`: Simulation files and testbenches for verifying the logic before synthesis.
* `docs/`: Design documentation and diagrams explaining the filter architecture.

## Building the Project (Scripted Flow)

This repository uses Tcl scripts to automate the project recreation and build process. This ensures reproducibility without relying on absolute paths or large project files.

**1. Run Vivado Integration**
This step creates the Vivado project, links the RTL/Netlists, and applies constraints.
```bash
vivado -mode batch -source scripts/run_vivado.tcl
```
*Output:* A fully configured Vivado project will be created in `vivado_project`.

**3. Open the Project (Optional)**
To view the design or generate the bitstream manually:
```bash
vivado vivado_project/hdmi_fir_proj.xpr
```
