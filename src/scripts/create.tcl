set project_name "systolic_core"
set target_part "xc7a35tcpg236-1"
set root_dir [pwd]

create_project $project_name $root_dir/$project_name -part $target_part -force

add_files [glob $root_dir/src/rtl/*.sv]
set_property FILE_TYPE SystemVerilog [get_files $root_dir/src/rtl/*.sv]
add_files -fileset constrs_1 $root_dir/src/constraints/basys3.xdc
set_property top basys3_wrapper [current_fileset]
update_compile_order -fileset sources_1