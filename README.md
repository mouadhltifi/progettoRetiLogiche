## ProgettoRetiLogiche Overview

### Key Features

1. **VHDL Implementations**:
   - The project includes several VHDL files that describe different versions and components of a digital circuit.
   - Key files include `behavioral_square.vhd`, `datapath_square.vhd`, `final_version.vhd`, `prima_versione.vhd`, `seconda_versione.vhd`, and `progetto.vhd`.

2. **Testbenches**:
   - The `tb testati` directory contains testbench files used for verifying the functionality of the VHDL modules.
   - These testbenches simulate the circuit and ensure it behaves as expected under various conditions.

3. **Clock Constraints**:
   - The `clock.xdc` file specifies clock constraints for the digital circuit, essential for proper timing and synchronization.

4. **Development and Simulation Logs**:
   - The `xvhdl.log` file contains logs of the VHDL simulation, useful for debugging and validating the design.

### Project Structure

- **Source Files**: Contains the main VHDL files for the digital logic design.
- **Testbenches**: Includes testbench files for simulating and testing the VHDL modules.
- **Constraints**: Holds clock constraint files necessary for timing analysis.
- **Logs**: Contains simulation logs that provide insights into the design's behavior during testing.

### Setup and Usage

1. **Clone the Repository**:
   ```sh
   git clone https://github.com/mouadhltifi/progettoRetiLogiche.git
   cd progettoRetiLogiche
   ```

2. **Simulation and Testing**:
   - Use a VHDL simulator like ModelSim or GHDL to compile and run the testbenches.
   - Verify the design's behavior using the provided testbenches and logs.

3. **Synthesis and Implementation**:
   - Synthesize the VHDL design using a synthesis tool compatible with your FPGA or ASIC development flow.
   - Apply the clock constraints specified in `clock.xdc` during the synthesis process.

For more detailed information, refer to the Relazione_Progetto_Reti_Logiche.pdf file.
