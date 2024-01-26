/*------------------------------------------------------------------------------
* File          : oflow_core.sv
* Project       : RTL
* Author        : epchof
* Creation date : Jan 13, 2024
* Description   :	
*------------------------------------------------------------------------------*/
//number of proccessing engin is 22 thus we need 5 bit 
`define K 22
`define BIT_NUMBER_OF_PE 22
module  oflow_core( 
		   input logic clk,
		   input logic reset_N	,
		   input logic [`BIT_NUMBER_OF_PE-1:0][111:0] data_in,//[5-1:0]->22 PEs
		   input logic [`BIT_NUMBER_OF_PE-1:0] wr,
		   input logic [`BIT_NUMBER_OF_PE-1:0][7:0] addr,
		   input logic  EN,


		   output logic [`BIT_NUMBER_OF_PE-1:0][111:0] data_out
		   );
		   
// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  



// -----------------------------------------------------------       
//				Instanciation
// -----------------------------------------------------------
 
//------------------PEs------------	 
genvar i;
generate for  ( i=0;i<`K; i++) 
begin 
   oflow_PE oflow_PE_inst( 
		   .clk(clk),
		   .reset_N(reset_N)	,
		   .data_in(data_in[i]),
		   .wr(wr[i]),
		   .addr(addr[i]),
		   .EN(EN),
		   
		   
		   .data_out(data_out[i])
	   );
end
endgenerate
/*
//------------------conflict resolve------------
oflow_conflict_resolve #() (
   input logic clk,
   input logic reset_N	,
	   
	input logic[43:0] num_of_row_to_read_from_mem,
	input logic[43:0] is_conflicr_resolve_state_EN,
	input logic[10:0] num_of_fall_back,
	input logic[10:0] max_bbox,
	input logic[10:0] 
	
	output logic[20:0] th_conf_counter
	output logic[20:0] id  ); */
//------------------mem manager------------	 
/*oflow_mem_manager*/
	
	
	

endmodule