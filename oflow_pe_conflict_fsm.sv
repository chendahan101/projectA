/*------------------------------------------------------------------------------
 * File          : oflow_pe_conflict_fsm.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 27, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

module oflow_pe_conflict_fsm #() (
	input logic clk,
	input logic reset_N,
	input logic start, //we will get start signal from core

	//output logic done,
	//control mem signal
	input logic done_read ,
	input logic done_write ,
	output logic start_read ,
	output logic start_write 
	

);

endmodule