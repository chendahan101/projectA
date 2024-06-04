`timescale 1ns/1ps

module tb_oflow_features_extraction;

  // Testbench signals
  logic clk;
  logic reset_N;
  logic [`BBOX_VECTOR_SIZE-1:0] bbox;
  logic fe_enable;
  
  // Outputs
  logic [`CM_CONCATE_LEN-1:0] cm_concate;
  logic [`POSITION_CONCATE_LEN-1:0] position_concate;
  logic [`WIDTH_LEN-1:0] width;
  logic [`HEIGHT_LEN-1:0] height;
  logic [`COLOR_LEN-1:0] color1;
  logic [`COLOR_LEN-1:0] color2;
  logic [`D_HISTORY_LEN-1:0] d_history;

  // Instantiate the module under test (MUT)
  oflow_features_extraction mut (
    .clk(clk),
    .reset_N(reset_N),
    .bbox(bbox),
    .fe_enable(fe_enable),
    .cm_concate(cm_concate),
    .position_concate(position_concate),
    .width(width),
    .height(height),
    .color1(color1),
    .color2(color2),
    .d_history(d_history)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // Generate a clock with a period of 10ns
  end

  // Test sequence
  initial begin
    // Initialize inputs
    reset_N = 0;
    bbox = 0;
    fe_enable = 0;

    // Reset the module
    #10;
    reset_N = 1;

    // Drive some test values
    #10;
    fe_enable = 1;
    bbox = {`BBOX_VECTOR_SIZE{1'b1}}; // Example value, set all bits to 1

    // Wait for a few clock cycles
    #100;

    // Change the input values
    bbox = {`BBOX_VECTOR_SIZE{1'b0}}; // Example value, set all bits to 0

    // Wait for a few clock cycles
    #100;

    // Finish the simulation
    $finish;
  end

  // Optional: Monitor changes on the outputs
  initial begin
    $monitor("Time: %0t, cm_concate: %0h, position_concate: %0h, width: %0d, height: %0d, color1: %0h, color2: %0h, d_history: %0b",
             $time, cm_concate, position_concate, width, height, color1, color2, d_history);
  end

endmodule