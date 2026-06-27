`timescale 1ns / 1ps

module Top_Module_tb(

    );
  localparam IDLE              = 4'd0;
  localparam FILL_WASH         = 4'd1;
  localparam WASH              = 4'd2;
  localparam DRAIN_AFTER_WASH  = 4'd3;
  localparam FILL_RINSE        = 4'd4;
  localparam RINSE             = 4'd5;
  localparam DRAIN_AFTER_RINSE = 4'd6;
  localparam SPIN              = 4'd7;
  localparam DONE              = 4'd8;
  localparam PAUSE             = 4'd9;
  localparam DRAIN_CANCEL      = 4'd10;
  localparam ERROR             = 4'd11;
  localparam QUICK  = 2'b00;
  localparam NORMAL = 2'b01;
  localparam HEAVY  = 2'b10;
reg clk;  
reg rst_n;
reg start;
reg pause;
reg resume;
reg cancel;

reg [1:0] mode_sel;

reg [5:0] pause_count;

reg door_locked;
reg water_level_ok;

wire fill_valve;
wire drain_valve;
wire wash_motor;
wire spin_motor;
wire door_lock_ctrl;

wire busy;
wire done;
wire error;

wire [3:0] current_state_dbg;

wire [1:0] mode_latched_dbg;

wire timer_enable_dbg;

wire timer_restart_dbg;

wire timer_done_dbg;

wire [5:0] timer_value_dbg;
wire [5:0] timer_count_dbg;

top_module dut(

    .clk(clk),
    .rst_n(rst_n),

    .start(start),
    .pause(pause),
    .resume(resume),
    .cancel(cancel),

    .mode_sel(mode_sel),

    .door_locked(door_locked),
    .water_level_ok(water_level_ok),

    .fill_valve(fill_valve),
    .drain_valve(drain_valve),
    .wash_motor(wash_motor),
    .spin_motor(spin_motor),

    .door_lock_ctrl(door_lock_ctrl),

    .busy(busy),
    .done(done),
    .error(error),
    
    .current_state_dbg(current_state_dbg),

    .mode_latched_dbg(mode_latched_dbg),

    .timer_enable_dbg(timer_enable_dbg),

    .timer_restart_dbg(timer_restart_dbg),

    .timer_done_dbg(timer_done_dbg),
    .timer_value_dbg(timer_value_dbg),
    .timer_count_dbg(timer_count_dbg)
);

// Clock Generation
    initial
      clk = 0;
    always
     #5 clk = ~clk;  
  
  // WAit clock task   
task wait_clocks;
 input integer n;
 integer i;
 begin
     for(i=0;i<n;i=i+1)
        @(posedge clk);
 end
endtask
     
// Reset Task
task reset_dut;
 begin

    rst_n = 0;

    start = 0;
    pause = 0;
    resume = 0;
    cancel = 0;

    mode_sel = 2'b00;

    door_locked = 0;
    water_level_ok = 0;

    wait_clocks(2);

    rst_n = 1;
    wait_clocks(1);

 end
endtask


// Start block task
task start_machine;
 begin
     start = 1'b1;
     @(posedge clk);
     start = 1'b0;
 end
endtask

// Pause Block task
task pause_machine;
 begin
     pause = 1'b1;
     @(posedge clk);
     pause = 1'b0;
 end
endtask 
     
// Resume Block Task
task resume_machine;
 begin
     resume = 1'b1;
     @(posedge clk);
     resume = 1'b0;
 end
endtask

// Cancel block Task
task cancel_machine;
 begin
     cancel = 1'b1;
     @(posedge clk);
     cancel = 1'b0;
 end
endtask

// Select mode task
task select_mode;
  input [1:0] mode;
  begin
      mode_sel = mode;
  end
endtask
 
// Door Locked Task
task lock_door;
 begin
     door_locked = 1'b1;
      @(posedge clk);
 end
endtask

// Door unlocked task
task unlock_door;
 begin
     door_locked = 1'b0;
      @(posedge clk);
 end
endtask
   
// WAter Level detector task
task water_detected;
 begin
     water_level_ok = 1'b1;
     @(posedge clk);
 end
endtask

  // Water level not detected task
task water_not_detected;
 begin
     water_level_ok = 1'b0;
      @(posedge clk);
 end
endtask

  // wait for state task
task wait_for_state;
 input [3:0] expected_state;
 begin
     wait(current_state_dbg == expected_state);
     #1;
 end
endtask

function [25*8:1] state_name;

   input [3:0] state;  
   begin

          case(state)

          IDLE:
            state_name="IDLE";

          FILL_WASH:
            state_name="FILL_WASH";

          WASH:
            state_name="WASH";

          DRAIN_AFTER_WASH:
            state_name="DRAIN_AFTER_WASH";

          FILL_RINSE:
            state_name="FILL_RINSE";

          RINSE:
            state_name="RINSE";

          DRAIN_AFTER_RINSE:
            state_name="DRAIN_AFTER_RINSE";

          SPIN:
            state_name="SPIN";

          DONE:
            state_name="DONE";

          PAUSE:
            state_name="PAUSE";

          DRAIN_CANCEL:
            state_name="DRAIN_CANCEL";

          ERROR:
            state_name="ERROR";

          default:
            state_name="UNKNOWN";

    endcase

end

endfunction

// Check task if it is in that state or not
task check;
    input condition;
    input [200*8:1] message;
    begin

     if(condition)
         $display("[%0t] PASS : %0s",$time,message);

     else begin

         $display("[%0t] FAIL : %0s",$time,message);
         $display("Current State = %0s", state_name(current_state_dbg));

         $stop;

    end

end
endtask

task check_outputs;

input exp_fill;
input exp_drain;
input exp_wash;
input exp_spin;
input exp_busy;
input exp_done;
input exp_error;
input exp_door_lock;

begin

    check(fill_valve  == exp_fill , "Fill Valve");
    check(drain_valve == exp_drain, "Drain Valve");
    check(wash_motor == exp_wash , "Wash Motor");
    check(spin_motor == exp_spin , "Spin Motor");
    check(busy == exp_busy , "Busy");
    check(done == exp_done , "Done");
    check(error == exp_error, "Error");
    check(door_lock_ctrl  == exp_door_lock,
          "Door Lock");
end
endtask

initial
begin
$display("========================================");
$display("Washing Machine Verification Started");
$display("========================================");

reset_dut();

$display("[%0t] Reset Completed", $time);


$monitor("T=%0t State=%0s Busy=%b Fill=%b Drain=%b Wash=%b Spin=%b Done=%b Error=%b",
         $time,
         state_name(current_state_dbg),
         busy,
         fill_valve,
         drain_valve,
         wash_motor,
         spin_motor,
         done,
         error);
$monitor("T=%0t State=%0s Count=%0d Timer=%0d Done=%b Restart=%b Enable=%b",
        $time,
        state_name(current_state_dbg),
        timer_count_dbg,
        timer_value_dbg,
        timer_done_dbg,
        timer_restart_dbg,
        timer_enable_dbg
        );
          
$display("\n========================================");
$display("TC1 : NORMAL WASH CYCLE");

select_mode(NORMAL);

lock_door();

start_machine();
check(mode_latched_dbg == NORMAL,
      "Normal Mode Latched");

// FILL WASH

wait_for_state(FILL_WASH);

check(current_state_dbg==FILL_WASH,
      "Entered FILL_WASH");

check_outputs(
              1'b1,   // Fill Valve
              1'b0,   // Drain Valve
              1'b0,   // Wash Motor
              1'b0,   // Spin Motor
              1'b1,   // Busy
              1'b0,   // Done
              1'b0,   // Error
              1'b1    // Door Lock
);

// WATER DETECTED
water_detected();
wait_for_state(WASH);

check(current_state_dbg==WASH,
      "Entered WASH");
check_outputs(           
            1'b0,
            1'b0,            
            1'b1,           
            1'b0,           
            1'b1,            
            1'b0,            
            1'b0,
            1'b1          
);

check(timer_enable_dbg,
      "Timer Enabled");
// WAIT FOR TIMER

wait_for_state(DRAIN_AFTER_WASH);
check(current_state_dbg == DRAIN_AFTER_WASH,
      "Entered DRAIN_AFTER_WASH");

check_outputs(           
            1'b0,
            1'b1,            
            1'b0,           
            1'b0,           
            1'b1,            
            1'b0,            
            1'b0,
            1'b1          
);
check(timer_enable_dbg,
      "Timer Enable");

// WAIT DRAIN COMPLETE
wait_for_state(FILL_RINSE);
check(current_state_dbg == FILL_RINSE,
      "Entered FILL_RINSE");

check_outputs(           
            1'b1,
            1'b0,            
            1'b0,           
            1'b0,           
            1'b1,            
            1'b0,            
            1'b0,
            1'b1          
);


water_detected();

// RINSE  
wait_for_state(RINSE);
check(current_state_dbg == RINSE,
      "Entered RINSE");

check_outputs(           
            1'b0,
            1'b0,            
            1'b1,           
            1'b0,           
            1'b1,            
            1'b0,            
            1'b0,
            1'b1          
);
check(timer_enable_dbg,
      "Timer Enable");

// DRAIN RINSE
wait_for_state(DRAIN_AFTER_RINSE);
check(current_state_dbg == DRAIN_AFTER_RINSE,
      "Entered DRAIN_AFTER_RINSE");

check_outputs(           
            1'b0,
            1'b1,            
            1'b0,           
            1'b0,           
            1'b1,            
            1'b0,            
            1'b0,
            1'b1          
);

check(timer_enable_dbg,
      "Timer Enable");

// SPIN
wait_for_state(SPIN);
check(current_state_dbg == SPIN,
      "Entered SPIN");

check_outputs(           
            1'b0,
            1'b0,            
            1'b0,           
            1'b1,           
            1'b1,            
            1'b0,            
            1'b0,
            1'b1          
);

check(timer_enable_dbg,
      "Timer Enable");

// DONE
wait_for_state(DONE);
check(current_state_dbg == DONE,
      "Entered DONE");

check_outputs(           
            1'b0,
            1'b0,            
            1'b0,           
            1'b0,           
            1'b0,            
            1'b1,            
            1'b0,
            1'b0          
);
// IDLE
wait_for_state(IDLE);
check(current_state_dbg == IDLE,
      "Returned to IDLE");

check_outputs(           
            1'b0,
            1'b0,            
            1'b0,           
            1'b0,           
            1'b0,            
            1'b0,            
            1'b0,
            1'b0          
);

$display("\n========================================");
$display("TC1 PASSED");


$display("\n========================================");
$display("TC2 : PAUSE / RESUME");

reset_dut();

select_mode(NORMAL);

lock_door();

start_machine();

// Reach WASH
wait_for_state(FILL_WASH);

water_detected();

wait_for_state(WASH);

check(current_state_dbg == WASH,
      "Entered WASH");

check_outputs(
    0, // Fill
    0, // Drain
    1, // Wash
    0, // Spin
    1, // Busy
    0, // Done
    0, // Error
    1  // Door Lock
);

check(timer_enable_dbg,
      "Timer Enabled");

// Pause During Wash

pause_machine();

wait_for_state(PAUSE);
check(current_state_dbg == PAUSE,
      "Entered PAUSE");
pause_count = timer_count_dbg;

wait_clocks(4);

check(timer_count_dbg == pause_count,
      "Timer Frozen During Pause");



check_outputs(
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    1
);

check(!timer_enable_dbg,
      "Timer Disabled");

// Resume
resume_machine();

wait_for_state(WASH);

wait(timer_count_dbg != pause_count);

check(timer_count_dbg > pause_count,
      "Timer Continued After Resume");

check(current_state_dbg == WASH,
      "Returned To WASH");


check_outputs(
    0,
    0,
    1,
    0,
    1,
    0,
    0,
    1
);

check(timer_enable_dbg,
      "Timer Enabled");

// Continue To Fill Rinse
wait_for_state(DRAIN_AFTER_WASH);

wait_for_state(FILL_RINSE);

water_detected();

wait_for_state(RINSE);

check(current_state_dbg == RINSE,
      "Entered RINSE");

check_outputs(
    0,
    0,
    1,
    0,
    1,
    0,
    0,
    1
);

// Pause During Rinse
pause_machine();

wait_for_state(PAUSE);

check(current_state_dbg == PAUSE,
      "Entered PAUSE Again");

check_outputs(
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    1
);

check(!timer_enable_dbg,
      "Timer Disabled");

// Resume Again
resume_machine();

wait_for_state(RINSE);

check(current_state_dbg == RINSE,
      "Returned To RINSE");

check_outputs(
    0,
    0,
    1,
    0,
    1,
    0,
    0,
    1
);

check(timer_enable_dbg,
      "Timer Enabled");

// Finish Cycle
wait_for_state(DRAIN_AFTER_RINSE);

wait_for_state(SPIN);

wait_for_state(DONE);

wait_for_state(IDLE);

check(current_state_dbg == IDLE,
      "Returned To IDLE");

check_outputs(
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
);

$display("\n========================================");
$display("TC2 PASSED");



$display("\n========================================");
$display("TC3 : DOOR OPEN FAULT");


reset_dut();

select_mode(NORMAL);

lock_door();

start_machine();

// Reach WASH
wait_for_state(FILL_WASH);

water_detected();

wait_for_state(WASH);

check(current_state_dbg==WASH,
      "Entered WASH");

// Open Door
unlock_door();

wait_for_state(ERROR);

check(current_state_dbg==ERROR,
      "Entered ERROR");

check_outputs(
    0,   // Fill
    0,   // Drain
    0,   // Wash
    0,   // Spin
    0,   // Busy
    0,   // Done
    1,   // Error
    0    // Door Lock
);

wait_clocks(5);

check(current_state_dbg==ERROR,
      "Still In ERROR");

reset_dut();

check(current_state_dbg==IDLE,
      "Returned To IDLE");

check_outputs(
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
);

$display("\n========================================");
$display("TC3 PASSED");


$display("\n========================================");
$display("TC4 : RESET DURING OPERATION");

// Reach WASH
reset_dut();

select_mode(NORMAL);

lock_door();

start_machine();

wait_for_state(FILL_WASH);

water_detected();

wait_for_state(WASH);

check(current_state_dbg == WASH,
      "Entered WASH");

check_outputs(
    0,
    0,
    1,
    0,
    1,
    0,
    0,
    1
);

check(timer_enable_dbg,
      "Timer Enabled");

// Apply Reset
rst_n = 0;

#2;

check(current_state_dbg == IDLE,
      "Returned To IDLE After Reset");

check_outputs(
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
);

check(mode_latched_dbg == 2'b00,
      "Mode Cleared");

check(!timer_enable_dbg,
      "Timer Disabled");

check(!timer_done_dbg,
      "Timer Done Cleared");

// Release Reset
rst_n = 1;

wait_clocks(2);

check(current_state_dbg == IDLE,
      "Stayed In IDLE");

$display("\n========================================");
$display("TC4 PASSED");
$finish;

end
endmodule
