current_design top_interface
create_clock [get_ports {clk}] -name clk -period 100 -waveform {0 50}
