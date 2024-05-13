module fifo #(parameter WIDTH = 8, parameter LOGDEPTH = 3) (
    input clk,
    input reset,

    input enq_val,
    input [WIDTH-1:0] enq_data,
    output reg enq_rdy,

    output reg deq_val,
    output reg [WIDTH-1:0] deq_data,
    input deq_rdy
);

localparam DEPTH = (1 << LOGDEPTH);

// the buffer itself. Take note of the 2D syntax.
reg [WIDTH-1:0] buffer [DEPTH-1:0];
// read pointer, write pointer
reg [LOGDEPTH-1:0] rptr, wptr;
// is the buffer full? This is needed for when rptr == wptr
reg full;

// Define any additional regs or wires you need (if any) here

// use "fire" to indicate when a valid transaction has been made
wire enq_fire;
wire deq_fire;

assign enq_fire = enq_val & enq_rdy;
assign deq_fire = deq_val & deq_rdy;

// Your code here (don't forget the reset!)
always @(posedge clk or negedge reset) begin
    if (reset) begin
        wptr <= 0;
        rptr <= 0;
        full <= 0;
        enq_rdy <= 1; // Assume FIFO is ready to accept data after reset
        deq_val <= 0;
        deq_data <= 0;
    end else begin
        // Enqueue logic
        if (enq_fire && ~full) begin
            buffer[wptr] <= enq_data;
            wptr <= wptr + 1;
            if (wptr + 1'b1 == rptr) // Check if FIFO is full
                full <= 1;
        end
        
        // Dequeue logic
        if (deq_fire && ~full) begin
            deq_val <= 1;
            deq_data <= buffer[rptr];
            rptr <= rptr + 1;
            if (rptr == wptr) // Check if FIFO is empty
                full <= 0;
        end else begin
            deq_val <= 0;
            deq_data <= 0;
        end
    end
end

endmodule
