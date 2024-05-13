//=========================================================================
// Template for GCD coprocessor
//-------------------------------------------------------------------------
//
module gcd_coprocessor #( parameter W = 32 ) (
  input clk,
  input reset,

  input [W-1:0] operands_bits_A,
  input [W-1:0] operands_bits_B,
  input operands_val, result_rdy,
  
  output operands_rdy, result_val,
  output [W-1:0] result_bits
  
);

  // You should be able to build this with mostly structural verilog!
  
  // TODO: Define wires
  wire enq_rdy_A, enq_rdy_B, deq_val_A, deq_val_B, deq_val_o; 
  wire B_mux_sel, A_en, B_en, B_zero, A_lt_B; 
  wire [1:0] A_mux_sel; 
  
  wire [W-1:0] result_bits_data_in; 

  wire [W-1:0] operands_bits_A_in;
  wire [W-1:0] operands_bits_B_in; 

  wire result_val_i; 
  wire operands_rdy_o;  
  wire operands_val_o;
  wire result_rdy_o;

  // TODO: Instantiate gcd_control
  gcd_control control_module(
    // external
    //input signal 
    .operands_val(operands_val_o), 
    .result_rdy(result_rdy_o), 
    //output signal
    .operands_rdy(operands_rdy_o),
    .result_val(result_val_i), 

    // system
    .clk(clk), 
    .reset(reset), 

    // internal (between ctrl and dpath)
    .B_zero(B_zero), 
    .A_lt_B(A_lt_B),
    .A_mux_sel(A_mux_sel[1:0]), 
    .A_en(A_en), 
    .B_en(B_en),
    .B_mux_sel(B_mux_sel)

  );
  assign operands_val_o = enq_rdy_A && enq_rdy_B; 
  assign result_rdy_o = result_rdy; 

// TODO: Instantiate gcd_datapath
  gcd_datapath #(W) datapath_module(
    // external
    .operands_bits_A(operands_bits_A_in), //output fifo A
    .operands_bits_B(operands_bits_B_in), //output fifo B 
    .result_bits_data(result_bits_data_in), //input fifo results

    // system
    .clk(clk), 
    .reset(reset),

    // internal (between ctrl and dpath)
    .A_mux_sel(A_mux_sel[1:0]), 
    .A_en(A_en), 
    .B_en(B_en),
    .B_mux_sel(B_mux_sel),
    .B_zero(B_zero),
    .A_lt_B(A_lt_B)
  );

 // Instantiate request FIFO
  fifo #(W, $clog2(W)) fifoA_module (
    .clk(clk), 
    .reset(reset),
    //input signal
    .enq_val(operands_val), // write enable signal  
    .deq_rdy(operands_rdy_o), // read enable signal 
    .enq_data(operands_bits_A), // input

    //output signal
    .enq_rdy(enq_rdy_A), // full signal
    .deq_val(deq_val_A), // empty signal 
    .deq_data(operands_bits_A_in) // output 
  );

  fifo #(W, $clog2(W)) fifoB_module (
    .clk(clk), 
    .reset(reset), 
    //input signal
    .enq_val(operands_val), // write enable signal
    .deq_rdy(operands_rdy_o), // read enable signal 
    .enq_data(operands_bits_B), // input
    
    //output signal
    .enq_rdy(enq_rdy_B), // full signal 
    .deq_val(deq_val_B), // empty signal 
    .deq_data(operands_bits_B_in) // output 
  );

 
  // Instantiate response FIFO
  fifo #(W, $clog2(W)) fifo_result (
    .clk(clk), 
    .reset(reset), 
    //input signal 
    .enq_val(result_val_i),  // write enable signal
    .deq_rdy(result_rdy_o), // read enable signal
    .enq_data(result_bits_data_in), //input
    //output signal 
    .enq_rdy(result_val),  // full signal
    .deq_val(deq_val_o), // empty signal 
    .deq_data(result_bits) // output 
  );

  assign operands_rdy  = deq_val_A && deq_val_B; 

endmodule
