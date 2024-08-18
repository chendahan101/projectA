/*------------------------------------------------------------------------------
 * File          : oflow_conflict_resolve.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_similarity_metric_define.sv"



module oflow_conflict_resolve #() (


	input logic clk,
	input logic reset_N,
	
	//CR
	input logic start_cr,
	output logic done_cr,
	
	
	
	//interface_betwe_luten_conflict_resolve_and_pes
	input logic [`SCORE_LEN-1:0] score_to_cr, //arrives from score_board
	input logic [`ID_LEN-1:0] id_to_cr, //arrives from score_board
	output logic [`ROW_LEN-1:0] row_sel_from_cr, //for read from score_board
	output logic [`PE_LEN-1:0] pe_sel_from_cr, //for read from score_board
	output logic [`ROW_LEN-1:0] row_to_change, //for write to score_board
	output logic [`PE_LEN-1:0] pe_to_change, //for write to score_board
	output logic  data_to_score_board, // for write to score_board. *****if we_lut will want to change the fallbacks we_lut need to change the size of this signal*******
	output logic  write_to_pointer //for write to score_board
);
 


// -----------------------------------------------------------       
//              Logics
// -----------------------------------------------------------  

	//LUT 
	logic [`DATA_WIDTH_LUT-1:0] data_out_lut_for_fsm; 
	logic [`ADDR_WIDTH_LUT-1:0] address_lut; 
	logic [`DATA_WIDTH_LUT-1:0] data_in_lut;
	logic we_lut;



// -----------------------------------------------------------       
//						 Instantiation
// -----------------------------------------------------------	
 
// Instantiate the oflow_conflict_resolve_fsm module
    oflow_conflict_resolve_fsm #(
        .MAX_CONFLICTS_TH() // Set the parameter value here
    ) oflow_conflict_resolve_fsm (
        .clk(clk),
        .reset_N(reset_N),
        
        // Conflict Resolution
        .start_cr(start_cr),
        .done_cr(done_cr),
        
        // LUT
        .data_out_lut_for_fsm(data_out_lut_for_fsm),
        .address_lut(address_lut),
        .data_in_lut(data_in_lut),
        .we_lut(we_lut),
        
        // Interface
        .score_to_cr(score_to_cr),
        .id_to_cr(id_to_cr),
        .row_sel(row_sel_from_cr),
        .pe_sel(pe_sel_from_cr),
        .row_to_change(row_to_change),
        .pe_to_change(pe_to_change),
        .data_to_score_board(data_to_score_board),
        .write_to_pointer(write_to_pointer)
    );
	
 
// Instantiate of the LUT











endmodule