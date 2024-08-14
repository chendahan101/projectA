//`timescale 1ns/1ps
`include "/users/epchof/Project/design/work/include_files/oflow_feature_extraction_define.sv"

module oflow_feature_extraction_tb #() ();

  // Testbench signals
  logic clk;
  logic reset_N;
  logic [`BBOX_VECTOR_SIZE-1:0] bbox;
  logic start_fe;
  logic done_fe;
  logic done_pe;
  
  // Outputs
  logic [`CM_CONCATE_LEN-1:0] cm_concate;
  logic [`POSITION_CONCATE_LEN-1:0] position_concate;
  logic [`WIDTH_LEN-1:0] width;
  logic [`HEIGHT_LEN-1:0] height;
  logic [`COLOR_LEN-1:0] color1;
  logic [`COLOR_LEN-1:0] color2;

  // Instantiate the module under test (MUT)
  oflow_feature_extraction mut (
	.clk(clk),
	.reset_N(reset_N),
	.bbox(bbox),
	.start_fe(start_fe),
	.cm_concate(cm_concate),
	.position_concate(position_concate),
	.width(width),
	.height(height),
	.color1(color1),
	.color2(color2),
	.done_fe(done_fe),
	.done_pe(done_pe)
  );

  // Clock generation
  initial begin
	clk = 0;
	forever #2.5 clk = ~clk; // Generate a clock with a period of 10ns
  end

  // Test sequence
  initial begin
	// Initialize inputs
	initial_task;


	// Drive some test values
	#10;
	fe_task (  50,150,20,80, {`COLOR_LEN{1'b1}},`COLOR_LEN'b0,1,0);//set 1,frame 1

	// Wait for a 2 clock cycles
	#100;
	fe_task (  50,100,20,80, {`COLOR_LEN{1'b1}},`COLOR_LEN'b0,1,0);//set 2, frame 1

	#100;
	fe_task (  50,100,20,80, {`COLOR_LEN{1'b1}},`COLOR_LEN'b0,1,1);// set3, frame 1
	//registration done

	// Wait for a few clock cycles
	#100;

	// Finish the simulation
	$finish;
  end
  
  

  
  
  
  
  
  
task fe_task (input logic [`CM_CONCATE_LEN/2-1:0 ] x,input logic  [`CM_CONCATE_LEN/2-1:0 ] y,input logic [`WIDTH_LEN-1:0] width,input logic [`HEIGHT_LEN-1:0] height,input logic [`COLOR_LEN-1:0] color1,input logic [`COLOR_LEN-1:0] color2,a,b);
begin
  
	bbox = {x,y,width,height,color1,color2};
	start_fe = a;
	done_pe = b; 
	#5
	start_fe = 1'b0;

	$monitor("Time: %0t, cm_concate: %0h, position_concate: %0h, width: %0d, height: %0d, color1: %0h, color2: %0h",
			$time, cm_concate, position_concate, width, height, color1, color2);
end
endtask	

task initial_task  ;
	reset_N = 0;
	bbox = '0;
	start_fe = 0;
	done_pe = 0; 
	
	
	// Reset the module
	#10;
	reset_N = 1;
	$monitor("Time: %0t, cm_concate: %0h, position_concate: %0h, width: %0d, height: %0d, color1: %0h, color2: %0h",
			$time, cm_concate, position_concate, width, height, color1, color2);

endtask	



endmodule