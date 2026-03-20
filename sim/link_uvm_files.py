import os
# UVM File Linker Script
# generates 'compile.f' by scanning RTL and Interfaces


def generate_filelist():
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    sim_dir  = os.path.join(base_dir, "sim")
    src_dir  = os.path.join(base_dir, "src")
    
    output_file = os.path.join(sim_dir, "compile.f")
    
    print(f"[*] Generating {output_file}...")
    
    with open(output_file, 'w') as f:
        f.write("// Auto-generated UVM Compile File List\n")
        f.write("+incdir+./Include\n")
        f.write("+incdir+./Testbench/agent\n")
        f.write("+incdir+./Testbench/env\n")
        f.write("+incdir+./Testbench/sequences\n\n")
        f.write(f"{os.path.join(src_dir, 'interfaces', 'tpu_if.sv')}\n\n")
        rtl_files = [
            "processing_element.sv",
            "systolic_array.sv",
            "memory.sv",
            "mmu.sv",
            "top_lvl.sv"
        ]
        for rtl in rtl_files:
            f.write(f"{os.path.join(src_dir, 'rtl', rtl)}\n")
            
        f.write("\n")
        f.write(f"{os.path.join(sim_dir, 'Testbench', 'tb', 'tb_top.sv')}\n")
        
    print("[+] Successfully generated compile.f!")

if __name__ == "__main__":
    generate_filelist()