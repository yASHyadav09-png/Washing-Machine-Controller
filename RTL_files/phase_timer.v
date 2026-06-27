`timescale 1ns / 1ps

 module phase_timer
#(
    parameter Timer_Width=6
)(
    input rst_n,
    input clk,
    input timer_enable,
    input timer_restart,
    input [Timer_Width-1:0] timer_value,

    output timer_done,
    output [Timer_Width-1:0] timer_count_dbg
);
    reg [Timer_Width-1:0]count ;
    always@(posedge clk or negedge rst_n)
     begin
      if(!rst_n) 
       begin
        count<=0;
       end
      else if(timer_restart)
       begin
        count<=0;
       end
      else
       begin
        if(timer_enable) 
         begin
          if(!timer_done)
            count <= count + 1'b1;
         end
        else 
         begin
          count<=count;
         end
       end
       
      
     end
     assign timer_done =
       (timer_value != 0) &&
       (count == (timer_value - 1'b1));
     assign timer_count_dbg = count;

endmodule
