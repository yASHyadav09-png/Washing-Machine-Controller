`timescale 1ns / 1ps

module fsm_controller (
  input  wire  clk,
  input  wire  rst_n,

  input  wire start,
  input  wire pause,
  input  wire resume,
  input  wire cancel,
  input  wire [1:0]  mode_sel,

  input  wire door_locked,
  input  wire water_level_ok,

  input  wire timer_done,

  output reg fill_valve,
  output reg drain_valve,
  output reg wash_motor,
  output reg spin_motor,
  output reg door_lock_ctrl,

  output reg busy,
  output reg done,
  output reg error,

  output reg timer_enable,
  output reg timer_restart,

  output reg  [1:0] mode_latched,
  output wire [3:0] current_state_dbg
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
 
  // Internal Registers

  reg [3:0] current_state;
  reg [3:0] next_state;
  reg [3:0] previous_state;

  assign current_state_dbg = current_state;

  // State Register
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      current_state <= IDLE;
    else
      current_state <= next_state;
  end

  // Previous State Register (for Pause)
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      previous_state <= IDLE;
    else if (current_state != PAUSE && next_state == PAUSE)
      previous_state <= current_state;
  end

  // mode_latched 
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      mode_latched <= 2'b00;
    else if (current_state == IDLE && start && door_locked)
      mode_latched <= mode_sel;
  end
  
  //  Next State Logic

  always @(*) begin
    next_state = current_state;

    case (current_state)

      IDLE: begin
        if (start && door_locked)
          next_state = FILL_WASH;
      end

      FILL_WASH: begin
        if(!door_locked)
            next_state = ERROR;
        else if (cancel)
          next_state = IDLE;
        else if (pause)
          next_state = PAUSE;
        else if (water_level_ok)
          next_state = WASH;
      end

      WASH: begin
        if (!door_locked)
          next_state = ERROR;
        else if (cancel)
          next_state = DRAIN_CANCEL;
        else if (pause)
          next_state = PAUSE;
        else if (timer_done)
          next_state = DRAIN_AFTER_WASH;
      end

      DRAIN_AFTER_WASH: begin
         if(!door_locked)
            next_state = ERROR;
         else if(cancel)
            next_state = DRAIN_CANCEL;
         else if(timer_done)
            next_state = FILL_RINSE;
      end

      FILL_RINSE: begin
        if (!door_locked)
          next_state = ERROR;
        else if (cancel)
          next_state = DRAIN_CANCEL;
        else if (pause)
          next_state = PAUSE;
        else if (water_level_ok)
          next_state = RINSE;
      end

      RINSE: begin
        if (!door_locked)
          next_state = ERROR;
        else if (cancel)
          next_state = DRAIN_CANCEL;
        else if (pause)
          next_state = PAUSE;
        else if (timer_done)
          next_state = DRAIN_AFTER_RINSE;
      end

      DRAIN_AFTER_RINSE: begin
         if(!door_locked)
           next_state = ERROR;
        else if(cancel)
          next_state = DRAIN_CANCEL;
        else if(timer_done)
          next_state = SPIN;
      end

      SPIN: begin
        if (!door_locked)
          next_state = ERROR;
        else if (cancel)
          next_state = IDLE;
        else if (pause)
          next_state = PAUSE;
        else if (timer_done)
          next_state = DONE;
      end

      DONE: begin
        next_state = IDLE;
      end

      PAUSE: begin
        if (cancel) begin
          case (previous_state)
            FILL_WASH, WASH, DRAIN_AFTER_WASH,
            FILL_RINSE, RINSE, DRAIN_AFTER_RINSE:
              next_state = DRAIN_CANCEL;
            default:
              next_state = IDLE;        
          endcase
        end
        else if (resume && door_locked)
          next_state = previous_state;
      end

      DRAIN_CANCEL: begin
        if (timer_done)
          next_state = IDLE;
      end
      
      ERROR: begin
        if (door_locked)
          next_state = IDLE;
        else
          next_state = ERROR;
        end

      default: next_state = IDLE;

    endcase
  end

  //Output Logic 
  
  always @(*) begin
    fill_valve     = 1'b0;
    drain_valve    = 1'b0;
    wash_motor     = 1'b0;
    spin_motor     = 1'b0;
    busy           = 1'b0;
    done           = 1'b0;
    timer_enable   = 1'b0;
    error          = 1'b0;
    case (current_state)

      IDLE:              ;  

      FILL_WASH: begin
        fill_valve = 1'b1;
        busy       = 1'b1;
      end

      WASH: begin
        wash_motor   = 1'b1;
        busy         = 1'b1;
        timer_enable = 1'b1;
      end

      DRAIN_AFTER_WASH: begin
        drain_valve  = 1'b1;
        busy         = 1'b1;
        timer_enable = 1'b1;
      end

      FILL_RINSE: begin
        fill_valve = 1'b1;
        busy       = 1'b1;
      end

      RINSE: begin
        wash_motor   = 1'b1;
        busy         = 1'b1;
        timer_enable = 1'b1;
      end

      DRAIN_AFTER_RINSE: begin
        drain_valve  = 1'b1;
        busy         = 1'b1;
        timer_enable = 1'b1;
      end

      SPIN: begin
        spin_motor   = 1'b1;
        busy         = 1'b1;
        timer_enable = 1'b1;
      end

      DONE:
        done = 1'b1;

      PAUSE:
        busy = 1'b1;

      DRAIN_CANCEL: begin
        drain_valve  = 1'b1;
        busy         = 1'b1;
        timer_enable = 1'b1;
      end
      ERROR:
        begin
           error=1'b1;
        end

      default: ; 

    endcase

    door_lock_ctrl = busy;
  end

// timer restart Logic

  always @(*) begin
    timer_restart = 1'b0;

    if (current_state == FILL_WASH && next_state == WASH)
      timer_restart = 1'b1;

    else if (current_state == WASH && next_state == DRAIN_AFTER_WASH)
      timer_restart = 1'b1;

    else if (current_state == DRAIN_AFTER_WASH && next_state == FILL_RINSE)
      timer_restart = 1'b1;

    else if (current_state == FILL_RINSE && next_state == RINSE)
      timer_restart = 1'b1;

    else if (current_state == RINSE && next_state == DRAIN_AFTER_RINSE)
      timer_restart = 1'b1;

    else if (current_state == DRAIN_AFTER_RINSE && next_state == SPIN)
      timer_restart = 1'b1;

    else if (next_state == DRAIN_CANCEL)
      timer_restart = 1'b1;

  end

endmodule