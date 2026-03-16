create_project tpu_lite C:/FPGA_Projects/Tensor_Processing_Unit/tpu_lite -part xc7a35tcpg236-1 -force
add_files [glob C:/FPGA_Projects/Tensor_Processing_Unit/src/rtl/*.sv]
set_property FILE_TYPE SystemVerilog [get_files *.sv]
report_compile_order -sources
