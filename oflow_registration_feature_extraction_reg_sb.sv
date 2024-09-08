/*------------------------------------------------------------------------------
 * File          : oflow_registration_feature_extraction_reg_sb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Sep 8, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"

module oflow_registration_feature_extraction_reg_sb #() (

	input logic clk,
	input logic reset_N	,
	// Feature_Extraction
	input logic [`FEATURE_EXTRACTION_ONLY-1:0] data_in,
	
	// interface MEM_PEs
	output logic [`FEATURE_EXTRACTION_ONLY-1:0] data_out,
	
	// registration 
	input logic [`ROW_LEN-1:0] addr,
	input logic we,
	
	// core
	input logic ready_new_frame
	

);

// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

	
	logic [`FEATURE_EXTRACTION_ONLY-1:0] feature_extraction_reg[`MAX_ROWS_IN_SCORE_BOARD];// we insert feture_extraction only of 1 bbox

	

	
// -----------------------------------------------------------       
//                 synchronous procedural block.	
// -----------------------------------------------------------


// -----------------------------------------------------------       
//						write to internal regs
// -----------------------------------------------------------

	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N || ready_new_frame) begin 
			
			feature_extraction_reg <= #1 '{default: 0};

		end	
		else if  (we)  feature_extraction_reg[addr] <= #1 data_in;
	end	
			
	

// -----------------------------------------------------------       
//						read from reg
// -----------------------------------------------------------	
	//interface mem-pe
	assign data_out = feature_extraction_reg [addr];





endmodule