vlib work

vlog SystemVerilogCSP.sv
vlog pe.sv
vlog pe_tb.sv

vsim -novopt work.testbench

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate {/testbench/intf_0/status}
add wave -noupdate {/testbench/intf_0/req}
add wave -noupdate {/testbench/intf_0/ack}
add wave -noupdate {/testbench/intf_0/data}
add wave -noupdate {/testbench/intf_1/status}
add wave -noupdate {/testbench/intf_1/req}
add wave -noupdate {/testbench/intf_1/ack}
add wave -noupdate {/testbench/intf_1/data}
add wave -noupdate {/testbench/intf_2/status}
add wave -noupdate {/testbench/intf_2/req}
add wave -noupdate {/testbench/intf_2/ack}
add wave -noupdate {/testbench/intf_2/data}



run -all