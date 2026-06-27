`timescale 1ns / 1ps

module mode_decoder
#(
    parameter STATE_WIDTH = 4,
    parameter TIMER_WIDTH = 6,

  
    parameter QUICK_WASH_TIME  = 6'd5,
    parameter NORMAL_WASH_TIME = 6'd10,
    parameter HEAVY_WASH_TIME  = 6'd20,


    parameter QUICK_RINSE_TIME  = 6'd2,
    parameter NORMAL_RINSE_TIME = 6'd4,
    parameter HEAVY_RINSE_TIME  = 6'd8,

 
    parameter QUICK_SPIN_TIME  = 6'd2,
    parameter NORMAL_SPIN_TIME = 6'd5,
    parameter HEAVY_SPIN_TIME  = 6'd8,

  
    parameter DRAIN_TIME = 6'd3
)
(
    input  [STATE_WIDTH-1:0] current_state,
    input  [1:0]             mode_latched,

    output reg [TIMER_WIDTH-1:0] timer_value
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
always @(*) begin

    timer_value = 0;

    case(current_state)

        WASH:
        begin
            case(mode_latched)
                2'b00: timer_value = QUICK_WASH_TIME;
                2'b01: timer_value = NORMAL_WASH_TIME;
                2'b10: timer_value = HEAVY_WASH_TIME;
                default: timer_value = NORMAL_WASH_TIME;
            endcase
        end

        RINSE:
        begin
            case(mode_latched)
                2'b00: timer_value = QUICK_RINSE_TIME;
                2'b01: timer_value = NORMAL_RINSE_TIME;
                2'b10: timer_value = HEAVY_RINSE_TIME;
                default: timer_value = NORMAL_RINSE_TIME;
            endcase
        end

        SPIN:
        begin
            case(mode_latched)
                2'b00: timer_value = QUICK_SPIN_TIME;
                2'b01: timer_value = NORMAL_SPIN_TIME;
                2'b10: timer_value = HEAVY_SPIN_TIME;
                default: timer_value = NORMAL_SPIN_TIME;
            endcase
        end

        DRAIN_AFTER_WASH,
        DRAIN_AFTER_RINSE,
        DRAIN_CANCEL:
            timer_value = DRAIN_TIME;

        default:
            timer_value = 0;

    endcase

end

endmodule