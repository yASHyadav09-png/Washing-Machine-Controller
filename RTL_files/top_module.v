`timescale 1ns / 1ps

module top_module(

    input  wire clk,
    input  wire rst_n,

    input  wire start,
    input  wire pause,
    input  wire resume,
    input  wire cancel,
    input  wire [1:0] mode_sel,

    input  wire door_locked,
    input  wire water_level_ok,

    output wire fill_valve,
    output wire drain_valve,
    output wire wash_motor,
    output wire spin_motor,
    output wire door_lock_ctrl,

    output wire busy,
    output wire done,
    output wire error,

    output wire [3:0] current_state_dbg,
    output wire [1:0] mode_latched_dbg,

    output wire timer_enable_dbg,
    output wire timer_restart_dbg,
    output wire timer_done_dbg,

    output wire [5:0] timer_value_dbg,
    output wire [5:0] timer_count_dbg

);
    wire        timer_done;
    wire        timer_enable;
    wire        timer_restart;

    wire [1:0]  mode_latched;
    wire [5:0]  timer_value;

    // FSM Controller
    
    fsm_controller fsm_inst (

        .clk               (clk),
        .rst_n             (rst_n),

        .start             (start),
        .pause             (pause),
        .resume            (resume),
        .cancel            (cancel),
        .mode_sel          (mode_sel),

        .door_locked       (door_locked),
        .water_level_ok    (water_level_ok),

        .timer_done        (timer_done),

        .fill_valve        (fill_valve),
        .drain_valve       (drain_valve),
        .wash_motor        (wash_motor),
        .spin_motor        (spin_motor),
        .door_lock_ctrl    (door_lock_ctrl),

        .busy              (busy),
        .done              (done),
        .error             (error),

        .timer_enable      (timer_enable),
        .timer_restart     (timer_restart),

        .mode_latched      (mode_latched),

        .current_state_dbg (current_state_dbg)

    );

    // Mode Decoder
  
    mode_decoder mode_decoder_inst (

        .mode_latched (mode_latched),
        .current_state(current_state_dbg),
        .timer_value  (timer_value)

    );

    
    // Phase Timer

    phase_timer timer_inst (

        .clk            (clk),
        .rst_n          (rst_n),
        .timer_enable   (timer_enable),
        .timer_restart  (timer_restart),
        .timer_value    (timer_value),
        .timer_done     (timer_done),
        .timer_count_dbg(timer_count_dbg)

    );
    
    // Debug Connections

    assign mode_latched_dbg  = mode_latched;
    assign timer_enable_dbg  = timer_enable;
    assign timer_restart_dbg = timer_restart;
    assign timer_done_dbg    = timer_done;

    assign timer_value_dbg   = timer_value;

endmodule
