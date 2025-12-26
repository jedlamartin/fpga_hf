# fpga_hf

A hardware-accelerated image processing project that implements a 2D Finite Impulse Response (FIR) filter on an FPGA. 

The core logic processes video data in the pixel domain, utilizing line buffers and convolution kernels to apply spatial filtering (e.g., Sobel, Laplacian) directly to the video pipeline.

## Repository Structure

* `src/`: Contains the Verilog source code for the HDMI interface, line buffers, and FIR filter logic.
* `constr/`: Physical constraints files (pinout and timing definitions) for the target FPGA board.
* `sim/`: Simulation files and testbenches for verifying the logic before synthesis.
* `docs/`: Design documentation and diagrams explaining the filter architecture.
