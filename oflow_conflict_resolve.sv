/*------------------------------------------------------------------------------
 * File          : oflow_conflict_resolve.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"

`define DATA_WIDTH_LUT 16
`define ADDR_WIDTH_LUT 11


module oflow_conflict_resolve #() (

	input logic clk,
	input logic reset_N,
	
	//CR
	input logic start_cr,
	output logic done_cr,
	
	// for new bbox 
	input logic [`SCORE_LEN-1:0] score_th_for_new_bbox, // from reg_file
	input logic initial_counter_for_new_bbox,
	input logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] total_bboxes_first_frame,
	
	//for conflict_counter_th
	input logic [`MAX_THRESHOLD_FOR_CONFLICTS_LEN-1:0] max_threshold_for_conflicts,
	
	//interface_betwe_luten_conflict_resolve_and_pes
	input logic [`SCORE_LEN-1:0] score_to_cr, //arrives from score_board
	input logic [`ID_LEN-1:0] id_to_cr, //arrives from score_board
	output logic [`ROW_LEN-1:0] row_sel_from_cr, //for read from score_board
	output logic [`PE_LEN-1:0] pe_sel_from_cr, //for read from score_board
	output logic [`ROW_LEN-1:0] row_to_change, //for write to score_board
	output logic [`PE_LEN-1:0] pe_to_change, //for write to score_board
	output logic  data_to_score_board_from_cr_pointer, // for write to score_board. *****if we_lut will want to change the fallbacks, we_lut need to change the size of this signal*******
	output logic  write_to_pointer, //for write to score_board
	output logic [`ID_LEN-1:0] data_to_score_board_from_cr_id,
	output logic  write_to_id, //for write to score_board the id
	
	output logic conflict_counter_th
	
);
 

// -----------------------------------------------------------       
//              Logics
// -----------------------------------------------------------  

	//LUT 
	logic [`DATA_WIDTH_LUT-1:0] data_out_lut_for_fsm; 
	logic [`DATA_WIDTH_LUT-1:0] data_out_dont_care_lut_for_fsm; 
	logic [`ADDR_WIDTH_LUT-1:0] address_lut; 
	logic [`DATA_WIDTH_LUT-1:0] data_in_lut;
	logic we_lut;
	logic csb;
	logic [`FLAG_REG_WIDTH-1:0] flag [2<<`ADDR_WIDTH_LUT];


	//flag reg
	 logic [`FLAG_REG_WIDTH-1:0] data_out_flag;
	 logic [`ADDR_WIDTH_LUT-1:0] address_flag;
	 logic [`FLAG_REG_WIDTH-1:0] data_in_flag;

 // -----------------------------------------------------------       
 //              assign
 // -----------------------------------------------------------  
 
 
 assign data_out_flag = flag[address_flag];
// -----------------------------------------------------------       
//						reg
// -----------------------------------------------------------

		 always_ff @(posedge clk or negedge reset_N) begin
			 if (!reset_N ) begin 
				 //for (int i=0; i<`MAX_ROWS_IN_SCORE_BOARD; i+=1) begin scores_reg[i] <= #1 '0; end
				 flag <= #1 '{default: 0};
			 end
			 else begin 
				 if (start_cr) begin 
					 //for (int i=0; i<`MAX_ROWS_IN_SCORE_BOARD; i+=1) begin scores_reg[i] <= #1 '0; end
					 flag <= #1 '{default: 0};
				 end
				 else if  (we_lut)  flag[address_flag] <= #1 data_in_flag;
			 end 
		 end	

// -----------------------------------------------------------       
//						 Instantiation
// -----------------------------------------------------------	
 
// Instantiate the oflow_conflict_resolve_fsm module
oflow_conflict_resolve_fsm #(
	) oflow_conflict_resolve_fsm (
		.clk(clk),
		.reset_N(reset_N),
		
		// Conflict Resolve
		.start_cr(start_cr),
		.done_cr(done_cr),
		
		// for new bbox 
		.score_th_for_new_bbox(score_th_for_new_bbox), //  from reg_file
		.initial_counter_for_new_bbox(initial_counter_for_new_bbox),
		.total_bboxes_first_frame(total_bboxes_first_frame),
		
		//for conflict_counter_th
		.max_threshold_for_conflicts(max_threshold_for_conflicts),
		
		// LUT
		.data_out_lut_for_fsm(data_out_lut_for_fsm),
		.address_lut(address_lut),
		.data_in_lut(data_in_lut),
		.we_lut(we_lut),
		
		//flag
		.data_out_flag(data_out_flag), 
		.address_flag(address_flag), 
		.data_in_flag(data_in_flag), 
		
		// Interface
		.score_to_cr(score_to_cr),
		.id_to_cr(id_to_cr),
		.row_sel(row_sel_from_cr),
		.pe_sel(pe_sel_from_cr),
		.row_to_change(row_to_change),
		.pe_to_change(pe_to_change),
		.data_to_score_board_from_cr_pointer(data_to_score_board_from_cr_pointer),
		.data_to_score_board_from_cr_id(data_to_score_board_from_cr_id),
		.write_to_pointer(write_to_pointer),
		.write_to_id(write_to_id),
		
		.csb(csb),
		
		.conflict_counter_th(conflict_counter_th)
	);
	
 
// Instantiate of the LUT

dpram2048x16_CB dpram2048x16_CB(
	.A1(address_lut), .A2(address_lut), .CEB1(clk), .CEB2(clk), .WEB1(~we_lut), .WEB2(1'b1),
	.OEB1(1'b1), .OEB2(1'b0), .CSB1(csb && ~we_lut), .CSB2(csb && we_lut),
	.I1(data_in_lut), .I2(16'b0), .O1(data_out_dont_care_lut_for_fsm), .O2(data_out_lut_for_fsm)
/*
		.clk(clk)
		.reset_N(reset_N),
		.data_in_0(data_in_lut),
		.data_out_0(data_out_dont_care_lut_for_fsm),
		.addr_0(address_lut),
		.web_0(~we_lut),//port 0 is only fo write(active low)
		.ceb_0(1'b0),//active low
		.csb_0(1'b0),
		.oeb_0(1'b1),//active low,but write mode only we dont need to enable read output
		.data_in_1(0),//dont care, port1 is for reading only
		.data_out_1(data_out_lut_for_fsm),
		.addr_1(address_lut),
		.web_1(1'b1),//port 1 is only fo read(active high)
		.ceb_1(1'b0//active low
			.csb_1(1'b0),
			.oeb_1(1'b0)
			*/
	);









endmodule