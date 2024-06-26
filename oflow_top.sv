/*------------------------------------------------------------------------------
 * File          : oflow_top.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 6, 2024
 * Description   :
 *----------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"

//`timescale 1ns/100ps
module oflow_top ( 
	  // inputs
	  input logic clk,
	  input logic reset_N,
	  
	  input logic start,
	  // input logic frame_num
	
	   input logic [`BBOX_VECTOR_SIZE-1:0] bboxes_array_per_frame [`MAX_BBOXES_PER_FRAME-1:0],			//size 
	   
	   // APB Interface
	   input logic apb_pclk, 
	   input logic apb_pwrite,
	   input logic apb_psel, 
	   input logic apb_penable,
	   input logic[`REGISTER_ADD_LEN-1:0] apb_addr,
	   input logic[`REGISTER_DATA_LEN-1:0] apb_pwdata,
	   
	   
	   // outputs 
	   
	   // APB Interface
	   output logic apb_pready,  
	   output logic[`REGISTER_DATA_LEN-1:0] apb_prdata,
	   
	   
	   output logic done_frame,
	   output logic [`ID_LEN-1:0] ids [`MAX_BBOXES_PER_FRAME-1:0]  );  
// -----------------------------------------------------------       
//                 Registers & Wires
// -----------------------------------------------------------  

logic  [4:0]	 th_conflict_counter;


// -----------------------------------------------------------       
//                Instantiations
// -----------------------------------------------------------  


oflow_reg_file  oflow_reg_file_1(   .clk		(clk),
	.reset_N		(reset_N),
	
	.apb_pclk		(apb_pclk), 
	.apb_pwrite		(apb_pwrite),
	.apb_psel 	    (apb_psel), 
	.apb_penable 	(apb_penable),
	.apb_addr		(apb_addr),
	.apb_pwdata		(apb_pwdata),
	.th_conflict_counter (th_conflict_counter),
	.th_conflict_counter_wr (th_conflict_counter_wr),
	.apb_pready      (apb_pready),  
	.apb_prdata		(apb_prdata) );
   

oflow_core  oflow_core_1(   .clk		(clk),
	.reset_N		(reset_N),
	
	.bbox (bbox),
	
	.apb_prdata		(apb_prdata), 
	.th_conflict_counter(th_conflict_counter),
	.th_conflict_counter_wr (th_conflict_counter_wr),

	.ids (ids)          );


  


endmodule