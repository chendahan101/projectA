/*------------------------------------------------------------------------------
 * File          : oflow_top.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 6, 2024
 * Description   :
 *----------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/oflow_define.sv"

//`timescale 1ns/100ps
module oflow_top ( 
	  // inputs
	  input logic clk,
	  input logic reset_N	,
	
	   input logic [99:0] bbox,			//size 
	   
	   // APB Interface
	   input logic apb_pclk, 
	   input logic apb_pwrite,
	   input logic apb_psel, 
	   input logic apb_penable,
	   input logic[11:0] apb_addr,
	   input logic[31:0] apb_pwdata,
	   // outputs
	   output logic apb_pready,  
	   output logic[31:0] apb_prdata,
	   
	   output logic[255:0][20:0] ids   );  
	
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