# scripts/run_vivado.tcl

# --- Configuration ---
set project_name "hdmi_fir_proj"
set device_part "xc7k70tfbg676-1" 

# 1. Create the Project
puts "Creating Vivado Project..."
create_project -force $project_name ./vivado_project -part $device_part

# 2. Add RTL and Netlist Sources
# Vivado automatically pairs .v wrappers with .edn netlists
puts "Adding RTL and Netlist Sources..."
add_files -norecurse {
    ./rtl/hdmi_top.v
    ./rtl/hdmi_rx.v
    ./rtl/hdmi_rx.edn
    ./rtl/hdmi_tx.v
    ./rtl/hdmi_tx.edn
    ./rtl/component_buffer.v
    ./rtl/dsp16x8.v
    ./rtl/fir2d.v
    ./rtl/sp_bram.v
	./rtl/mac.v
}

# 3. Add Constraints
puts "Adding Constraints..."
add_files -fileset constrs_1 -norecurse {
    ./constr/hdmi_top.xdc
    ./constr/chipscope.xdc
}

# 4. Add Test Fixtures
# Fixed: Added .v extensions and -nocomplain is usually for globbing
puts "Adding Test Fixtures..."
add_files -fileset sim_1 {
    ./sim/tf_fir2d.v
    ./sim/tf_dsp16x8.v
    ./sim/tf_component_buffer.v
	./sim/lena.raw
}

# 5. Set Design Top Module
puts "Setting Design Top Module..."
set_property top hdmi_top [current_fileset]

# 6. Set Simulation Top Module
# Specifically targeting tf_fir2d as requested
puts "Setting Simulation Top Module to tf_fir2d..."
set_property top tf_fir2d [get_filesets sim_1]

# 7. Finalize and Update
puts "Updating Compile Order..."
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "---------------------------------------------"
puts " Project Created Successfully!"
puts " To open the GUI, run: start_gui"
puts " Or open manually: vivado_project/$project_name.xpr"
puts "---------------------------------------------"
