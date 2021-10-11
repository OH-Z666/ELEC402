onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/clk
add wave -noupdate /top_tb/reset
add wave -noupdate /top_tb/start
add wave -noupdate /top_tb/pass_key
add wave -noupdate /top_tb/mess_traffic_flag
add wave -noupdate /top_tb/daytime_flag
add wave -noupdate /top_tb/white2Tminus_flag
add wave -noupdate /top_tb/green2yellow_flag
add wave -noupdate /top_tb/red_flag
add wave -noupdate /top_tb/need_white2Tminus_flag
add wave -noupdate /top_tb/need_green2yellow_flag
add wave -noupdate /top_tb/need_red_flag
add wave -noupdate /top_tb/reds_on_flag
add wave -noupdate /top_tb/EW_straight_lights_flag
add wave -noupdate /top_tb/SN_straight_lights_flag
add wave -noupdate /top_tb/ES_turning_lights_flag
add wave -noupdate /top_tb/WN_turning_lights_flag
add wave -noupdate /top_tb/SW_turning_lights_flag
add wave -noupdate /top_tb/NE_turning_lights_flag
add wave -noupdate /top_tb/EWS_passenger_flag
add wave -noupdate /top_tb/EWN_passenger_flag
add wave -noupdate /top_tb/SNE_passenger_flag
add wave -noupdate /top_tb/SNW_passenger_flag
add wave -noupdate /top_tb/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {21980 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {7870 ps} {36750 ps}
