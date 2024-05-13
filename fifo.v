//=========================================================================
// FIFO Template
//-------------------------------------------------------------------------
//
//`include "EECS151.v"

module fifo #(parameter WIDTH = 8, parameter LOGDEPTH = 3) (
    input clk,
    input reset,

    input enq_val, deq_rdy, 
    input [WIDTH-1:0] enq_data,
    
    output enq_rdy, deq_val,
    output reg [WIDTH-1:0] deq_data
);

localparam DEPTH = (1 << LOGDEPTH);

// the buffer itself. Take note of the 2D syntax.
reg [WIDTH-1:0] buffer [DEPTH-1:0];
// read pointer, write pointer
reg [LOGDEPTH-1:0] rptr, wptr;
// is the buffer full? This is needed for when rptr == wptr

// Define any additional regs or wires you need (if any) here

// use "fire" to indicate when a valid transaction has been made
wire enq_fire;
wire deq_fire;


// Your code here (don't forget the reset!)
// set default values on reset 
always@(posedge clk) begin 
    if (reset) begin
        wptr        <= 0; 
        rptr        <= 0;
        deq_data    <= 0; 
    end
end  

//write data to FIFO
always@(posedge clk) begin 
    if(enq_fire) begin 
        buffer[wptr] <= enq_data; 
        wptr <= wptr + 1;
    end 
end 

//read data from FIFO 
always@(posedge clk) begin 
    if (deq_fire) begin 
        deq_data <= buffer[rptr];
        rptr <= rptr + 1; 
    end 
end 


assign enq_rdy = ((wptr + 1'b1) == rptr);
assign deq_val = (wptr == rptr);

//assign enq_rdy = ((wptr + 1'b1) == DEPTH);
//assign deq_val = (rptr == wptr); 

assign enq_fire = enq_val & !enq_rdy;
assign deq_fire = !deq_val & deq_rdy;

endmodule
