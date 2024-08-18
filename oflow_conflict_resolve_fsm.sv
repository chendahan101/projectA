/*------------------------------------------------------------------------------
* File          : oflow_conflict_resolve_fsm.sv
* Project       : RTL
* Author        : epchof
* Creation date : Jan 13, 2024
* Description   :	
*------------------------------------------------------------------------------*/

	
`include "/users/epchof/Project/design/work/include_files/oflow_similarity_metric_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_feature_extraction_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"

`define DATA_WIDTH_LUT 16
`define HALF_DATA_WIDTH_LUT (`DATA_WIDTH_LUT)/2
`define ADDR_WIDTH_LUT 11
`define HIST_REG_WIDTH 45

`define INSTANCES_LEN 4




module oflow_conflict_resolve_fsm #(parameter MAX_CONFLICTS_TH = 10 ) (
	//inputs
	input logic clk,
	input logic reset_N,
	
	//CR
	input logic start_cr,
	output logic done_cr,
	
	//LUT 
	input logic [`DATA_WIDTH_LUT-1:0] data_out_lut_for_fsm, 
	output logic [`ADDR_WIDTH_LUT-1:0] address_lut, 
	output logic [`DATA_WIDTH_LUT-1:0] data_in_lut, 
	output logic we_lut,
	
	
	//interface_betwe_luten_conflict_resolve_and_pes
	input logic [`SCORE_LEN-1:0] score_to_cr, //arrives from score_board
	input logic [`ID_LEN-1:0] id_to_cr, //arrives from score_board
	output logic [`ROW_LEN-1:0] row_sel, //for read from score_board
	output logic [`PE_LEN-1:0] pe_sel, //for read from score_board
	output logic [`ROW_LEN-1:0] row_to_change, //for write to score_board
	output logic [`PE_LEN-1:0] pe_to_change, //for write to score_board
	output logic  data_to_score_board, // for write to score_board. *****if we_lut will want to change the fallbacks we_lut need to change the size of this signal*******
	output logic  write_to_pointer //for write to score_board
	

);	


// -----------------------------------------------------------       
//              Logics
// -----------------------------------------------------------  

	 logic [`ROW_LEN-1:0] counter_row_sel;
	 logic [`PE_LEN-1:0] counter_pe_sel;
	 logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] counter_hist; //count how many different ids in lut/hist
	
	logic column_lut;
	logic [`DATA_WIDTH_LUT-1:0] row_lut;
	logic [`DATA_WIDTH_LUT-1:0] mask_lut;
	
	logic [`INSTANCES_LEN-1:0] hist_reg_instances [`MAX_BBOXES_PER_FRAME];
	logic [`SCORE_LEN-1:0] hist_reg_min_score [`MAX_BBOXES_PER_FRAME];
	logic [`ROW_LEN-1:0] hist_reg_row [`MAX_BBOXES_PER_FRAME];
	logic [`PE_LEN-1:0] hist_reg_pe [`MAX_BBOXES_PER_FRAME];
	
	
	logic [`PE_LEN-1:0] cur_pe_reg;
	logic [`SCORE_LEN-1:0] cur_score_reg;
	logic [`DATA_WIDTH_LUT-1:0] cur_data_lut_reg;
	
	logic update_hist;
	logic th_conflict_flg;
	
	typedef enum {idle_st, row_sel_st, pe_sel_N_fill_lut_st, fill_hist_st } sm_type; 
	sm_type current_state;
	sm_type next_state;


// -----------------------------------------------------------       
//                Assignments
// -----------------------------------------------------------  
	assign  row_sel = counter_row_sel;
	assign  pe_sel  = counter_pe_sel; 
	

	
	always_comb begin
		column_lut = (id_to_cr/2048); // suppose to be one bit. Eg. while (id_to_cr/2048)!=0 
		row_lut = (id_to_cr%2048);
	
		address_lut = row_lut;
		mask_lut = (column_lut) ? {`HALF_DATA_WIDTH_LUT{1'b0},`HALF_DATA_WIDTH_LUT{1'b1}} : {`HALF_DATA_WIDTH_LUT{1'b1},`HALF_DATA_WIDTH_LUT{1'b0}};
	end	
// -----------------------------------------------------------       
//                Instantiations
// -----------------------------------------------------------  

	


// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) current_state <= #1 idle_st;
		else current_state <= #1 next_state;
	
	end
	
//--------------------counter_row_sel---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st ) counter_row_sel <= #1 0;
		 else  if( cur_state == pe_sel_N_fill_lut_st && next_state == row_sel_st) counter_row_sel <= #1 counter_row_sel + 1 ;
		 
	  end	

//--------------------counter_pe_sel---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st || current_state ==  row_sel_st) counter_pe_sel <= #1 0;
		 else  if( cur_state ==  pe_sel_N_fill_lut_st && next_state == fill_hist_st) counter_pe_sel <= #1 counter_pe_sel + 1 ;
		 
	  end	
//--------------------cur_pe_reg---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N) cur_pe_reg <= #1 0;
		 else if (current_state ==  pe_sel_N_fill_lut_st) cur_pe_reg <= #1 counter_pe_sel;
		 
	  end
//--------------------cur_score_reg---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N) cur_score_reg <= #1 0;
		 else if (current_state ==  pe_sel_N_fill_lut_st) cur_score_reg <= #1 score_to_cr;
		 
	  end		  
//--------------------cur_data_lut_reg---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N ) cur_data_lut_reg <= #1 0;
		 else  if( current_state ==  pe_sel_N_fill_lut_st) cur_data_lut_reg <= #1 (data_out_lut_for_fsm & write_mask) ? data_out_lut_for_fsm : counter_hist + 1 ;
		 
	  end	
	  
	  
//--------------------counter_hist---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st) counter_pe_sel <= #1 0;
		 else  if( cur_state ==  pe_sel_N_fill_lut_st && !(data_out_lut_for_fsm & write_mask)) counter_hist <= #1 counter_hist + 1 ;
		 
	  end	
//--------------------hist_reg_instances---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st) begin
			for (int i=0; i<`MAX_BBOXES_PER_FRAME; i+=1) begin hist_reg_instances[i] <= #1 0; 	end
		end
		else  if( cur_state ==  fill_hist_st) hist_reg_instances[cur_data_lut_reg -1] <= #1 hist_reg_instances[cur_data_lut_reg -1] + 1 ;
			
	  end	

//--------------------hist_reg_pe---------------------------------	

	  always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st) begin
			for (int i=0; i<`MAX_BBOXES_PER_FRAME; i+=1) begin hist_reg_pe[i] <= #1 0; 	end
		end
		else  if( cur_state ==  fill_hist_st && update_hist) hist_reg_pe[cur_data_lut_reg -1] <= #1 cur_pe_reg ;
			
	  end	

//--------------------hist_reg_row---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st) begin
			for (int i=0; i<`MAX_BBOXES_PER_FRAME; i+=1) begin hist_reg_row[i] <= #1 0; 	end
		end
		else  if( cur_state ==  fill_hist_st && update_hist) hist_reg_row[cur_data_lut_reg -1] <= #1 counter_row_sel ;
			
	  end

//--------------------hist_reg_min_score---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st) begin
			for (int i=0; i<`MAX_BBOXES_PER_FRAME; i+=1) begin hist_reg_min_score[i] <= #1 {`SCORE_LEN{1'b1}}; 	end
		end
		else  if( cur_state ==  fill_hist_st && update_hist) hist_reg_min_score[cur_data_lut_reg -1] <= #1 cur_score_reg ;
			
	  end	  
 // -----------------------------------------------------------       
 //						FSM – Async Logic
 // -----------------------------------------------------------	
 always_comb begin
	next_state = current_state;
	done_cr = 1'b0;
	we_lut = 1'b0;
	update_hist = 1'b0;
	write_to_pointer = 1'b0;
	row_to_change = counter_row_sel;
	pe_to_change = cur_pe_reg;
	data_in_lut = data_out_lut_for_fsm;
	th_conflict_flg = 1'b0;
	data_to_score_board = 1'b0; //*****if we_lut will want to change the fallbacks we_lut need to change the size of this signal*******
	
	 case (current_state)
		 idle_st: begin
		 
				next_state = (start_cr) ? row_sel_st : idle_st; 
			 
		 end
		 
		 row_sel_st: begin
		
			if (counter_row_sel == `MAX_ROWS_IN_SCORE_BOARD) begin
				done_cr = 1'b1;
				next_state = idle_st;
			end	
			else begin
				we_lut = 1'b0;
				next_state = pe_sel_N_fill_lut_st;
			end
			
		 end
		 
 
		pe_sel_N_fill_lut_st: begin 
			
			
			
			
			if (counter_pe_sel == `PE_NUM) begin
				next_state = row_sel_st; 
			end
			else  begin
				
				if(!(data_out_lut_for_fsm & write_mask)) begin
					we_lut = 1'b1;
					data_in_lut =  (data_out_lut_for_fsm & ~write_mask) | ((hist_counter+1) & write_mask); // we_lut add 1 to hist_counter because it doesnt update yet. and we_lut dont want start from 0 because it indicate that this is the first time this id
				end	
				
				next_state = fill_hist; 
			end
			
		fill_hist_st: begin 
			
			// first we_lut read the LUT 
			if(cur_score_reg < hist_reg_min_score[cur_data_lut_reg-1]) begin
				update_hist = 1'b1;
				// row_to_change = counter_row_sel;
				// pe_to_change = cur_pe_reg;
				write_to_pointer = 1'b1;
				data_to_score_board = 1'b1;
			end
			
			if( hist_reg_instances[cur_data_lut_reg -1] >= MAX_CONFLICTS_TH ) begin
				done_cr = 1'b1;
				th_conflict_flg = 1'b1;
				next_state = idle_st;
			end
			else begin
				we_lut = 1'b0;
				next_state = pe_sel_N_fill_lut_st;
			end	
		end
		
		
			
		 
	 endcase
 end
		 
	 
endmodule