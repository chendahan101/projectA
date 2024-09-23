/*------------------------------------------------------------------------------
 * File          : oflow_conflict_resolve_fsm.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :	
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"


`define DATA_WIDTH_LUT 16
`define HALF_DATA_WIDTH_LUT (`DATA_WIDTH_LUT)/2
`define ADDR_WIDTH_LUT 11
`define HIST_REG_WIDTH 45

`define INSTANCES_LEN 4


module oflow_conflict_resolve_fsm #(parameter MAX_CONFLICTS_TH = 10 ) (
	
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
	
	//flag reg
	input logic [`FLAG_REG_WIDTH-1:0] data_out_flag, 
	output logic [`ADDR_WIDTH_LUT-1:0] address_flag, 
	output logic [`FLAG_REG_WIDTH-1:0] data_in_flag, 
	
	
	
	//interface_betwe_luten_conflict_resolve_and_pes
	input logic [`SCORE_LEN-1:0] score_to_cr, //arrives from score_board
	input logic [`ID_LEN-1:0] id_to_cr, //arrives from score_board
	output logic [`ROW_LEN-1:0] row_sel, //for read from score_board
	output logic [`PE_LEN-1:0] pe_sel, //for read from score_board
	output logic [`ROW_LEN-1:0] row_to_change, //for write to score_board
	output logic [`PE_LEN-1:0] pe_to_change, //for write to score_board
	output logic  data_to_score_board, // for write to score_board. *****if we_lut will want to change the fallbacks we_lut need to change the size of this signal*******
	output logic  write_to_pointer, //for write to score_board
	
	output logic csb,

	output logic conflict_counter_th
);	


// -----------------------------------------------------------       
//              Parameter
// -----------------------------------------------------------  
localparam  DEPTH_LUT = 1<<`ADDR_WIDTH_LUT;
localparam  COUNTER_STATE = 2;

// -----------------------------------------------------------       
//              Logics
// -----------------------------------------------------------  

	 logic [`ROW_LEN-1:0] counter_row_sel;
	 logic [`PE_LEN-1:0] counter_pe_sel;
	 logic [COUNTER_STATE-1:0] counter_state;
	 logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] counter_hist; //count how many different ids in lut/hist
	
	logic column_lut;
	logic [`DATA_WIDTH_LUT-1:0] row_lut;
	logic [`DATA_WIDTH_LUT-1:0] mask_lut;
	logic [`FLAG_REG_WIDTH-1:0] mask_flag;
	logic [`DATA_WIDTH_LUT-1:0] the_mask_side;

	
	
	logic [`INSTANCES_LEN-1:0] hist_reg_instances [`MAX_BBOXES_PER_FRAME];
	logic [`SCORE_LEN-1:0] hist_reg_min_score [`MAX_BBOXES_PER_FRAME];
	logic [`ROW_LEN-1:0] hist_reg_row [`MAX_BBOXES_PER_FRAME];
	logic [`PE_LEN-1:0] hist_reg_pe [`MAX_BBOXES_PER_FRAME];
	
	
	logic [`PE_LEN-1:0] cur_pe_reg;
	logic [`SCORE_LEN-1:0] cur_score_reg;
	logic [`HALF_DATA_WIDTH_LUT-1:0] old_data_lut;
	logic [`HALF_DATA_WIDTH_LUT-1:0] cur_data_lut_reg;
	
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
	assign address_flag = address_lut;
	
	assign conflict_counter_th = th_conflict_flg;
	
	always_comb begin
		column_lut = (id_to_cr / DEPTH_LUT); // suppose to be one bit. Eg. while (id_to_cr/2048)!=0 
		row_lut = (id_to_cr % DEPTH_LUT);
	
		address_lut = row_lut;
		mask_lut = (column_lut) ? {{`HALF_DATA_WIDTH_LUT{1'b0}}, {`HALF_DATA_WIDTH_LUT{1'b1}}} : {{`HALF_DATA_WIDTH_LUT{1'b1}}, {`HALF_DATA_WIDTH_LUT{1'b0}}};
		mask_flag = (column_lut) ? {1'b0, 1'b1} : {1'b1, 1'b0};

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
	
//--------------------counter_state---------------------------------	

always_ff @(posedge clk or negedge reset_N) begin
	if (!reset_N || current_state ==  idle_st || (current_state!= pe_sel_N_fill_lut_st  && next_state== pe_sel_N_fill_lut_st ) ) counter_state <= #1 0;
	else  if( current_state == pe_sel_N_fill_lut_st ) counter_state <= #1 counter_state + 1 ;
	
 end	
	
	
//--------------------counter_row_sel---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st ) counter_row_sel <= #1 0;
		 else  if( current_state == pe_sel_N_fill_lut_st && next_state == row_sel_st) counter_row_sel <= #1 counter_row_sel + 1 ;
		 
	  end	

//--------------------counter_pe_sel---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st || current_state ==  row_sel_st) counter_pe_sel <= #1 0;
		 else  if( current_state ==  pe_sel_N_fill_lut_st && next_state == fill_hist_st) counter_pe_sel <= #1 counter_pe_sel + 1 ;
		 
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
	assign old_data_lut = (column_lut)? data_out_lut_for_fsm[7:0] : data_out_lut_for_fsm[15:8]  ;
	
	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N ) cur_data_lut_reg <= #1 0;
		 else  if( current_state ==  pe_sel_N_fill_lut_st) begin
			 //old_data_lut = (mask_flag)? data_out_lut_for_fsm[7:0] : data_out_lut_for_fsm[15:8]  ;
			 cur_data_lut_reg <= #1 (data_out_flag & mask_flag) ? old_data_lut : counter_hist + 1 ;
		 end
		 
	  end	
	  
	  
//--------------------counter_hist---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st) counter_hist <= #1 0;
		 else  if( current_state ==  pe_sel_N_fill_lut_st && !(data_out_flag & mask_flag) && (counter_state == 1) ) counter_hist <= #1 counter_hist + 1 ;
		 
	  end	
//--------------------hist_reg_instances---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st) begin
			 hist_reg_instances <= #1 '{default: 0}; 	
		end
		else  if( current_state ==  fill_hist_st) hist_reg_instances[cur_data_lut_reg -1] <= #1 hist_reg_instances[cur_data_lut_reg -1] + 1 ;
			
	  end	

//--------------------hist_reg_pe---------------------------------	

	  always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st) begin
			hist_reg_pe <= #1 '{default: 0};
		end
		else  if( current_state ==  fill_hist_st && update_hist) hist_reg_pe[cur_data_lut_reg -1] <= #1 cur_pe_reg ;
			
	  end	

//--------------------hist_reg_row---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st) begin
			 hist_reg_row <= #1 '{default: 0};
		end
		else  if( current_state ==  fill_hist_st && update_hist) hist_reg_row[cur_data_lut_reg -1] <= #1 counter_row_sel ;
			
	  end

//--------------------hist_reg_min_score---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st) begin
			 hist_reg_min_score <= #1 '{default: {`SCORE_LEN{1'b1}}} ; 
		end
		else  if( current_state ==  fill_hist_st && update_hist) hist_reg_min_score[cur_data_lut_reg -1] <= #1 cur_score_reg ;
			
	  end	  
 // -----------------------------------------------------------       
 //						FSM – Async Logic
 // -----------------------------------------------------------	
 always_comb begin
	next_state = current_state;
	done_cr = 1'b0;
	we_lut = 1'b0;
	update_hist = 1'b0;
	data_to_score_board = 1'b0; //*****if we_lut will want to change the fallbacks we_lut need to change the size of this signal*******
	write_to_pointer = 1'b0;
	row_to_change = counter_row_sel;
	pe_to_change = cur_pe_reg;
	//data_in_lut = data_out_lut_for_fsm;
	data_in_lut = 1'b0;
	th_conflict_flg = 1'b0;
	csb = 1'b1;
	
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
			
			csb = 1'b0;
			if (!id_to_cr) begin 
				done_cr = 1'b1;
				next_state = idle_st;
			end
			else begin
					/*if (counter_pe_sel == `PE_NUM) begin
						next_state = row_sel_st; 
					end
					else  begin
						
					
						if(!(data_out_flag & mask_flag)) begin
							
							data_in_flag =  (data_out_flag & ~mask_flag) | (( 2'b11) & mask_flag); // we_lut add 1 to hist_counter because it doesnt update yet. and we_lut dont want start from 0 because it indicate that this is the first time this id
							
							
							the_mask_side = (!data_out_flag) ? 0: (data_out_lut_for_fsm & ~mask_lut);
							
							data_in_lut =  (the_mask_side) | ((counter_hist+1)<<( (column_lut) ? 0 : 8 ) & mask_lut); // we_lut add 1 to hist_counter because it doesnt update yet. and we_lut dont want start from 0 because it indicate that this is the first time this id
						end	
						//next_state = fill_hist_st; 
						//we_lut = 1'b1;
					end
					if (counter_state==1) begin 
						we_lut = 1'b1;
						next_state = fill_hist_st; 
					end
					*/

		
			
				if(!(data_out_flag & mask_flag)) begin
					
					if (counter_state==1) begin 
						we_lut = 1'b1;
						next_state = fill_hist_st; 
					end
						
						data_in_flag =  (data_out_flag & ~mask_flag) | (( 2'b11) & mask_flag); // we_lut add 1 to hist_counter because it doesnt update yet. and we_lut dont want start from 0 because it indicate that this is the first time this id
						
						
						
						the_mask_side = (!data_out_flag) ? 0: (data_out_lut_for_fsm & ~mask_lut);
						
						data_in_lut =  (the_mask_side) | ((counter_hist+1)<<( (column_lut) ? 0 : 8 ) & mask_lut); // we_lut add 1 to hist_counter because it doesnt update yet. and we_lut dont want start from 0 because it indicate that this is the first time this id
				end	
					//next_state = fill_hist_st; 
					//we_lut = 1'b1;
				else next_state = fill_hist_st;
				
			end
			
		end
		
		fill_hist_st: begin 
			
			
			
			if( hist_reg_instances[cur_data_lut_reg-1] != 0 ) begin
					
				// first we_lut read the LUT 
				if(cur_score_reg < hist_reg_min_score[cur_data_lut_reg-1]) begin
					update_hist = 1'b1;
					row_to_change = hist_reg_row[cur_data_lut_reg -1];
					pe_to_change = hist_reg_pe[cur_data_lut_reg -1];
					write_to_pointer = 1'b1;
					data_to_score_board = 1'b1;
				end
				else begin
					write_to_pointer = 1'b1;
					data_to_score_board = 1'b1;
				end
			
				
			end	
			if( hist_reg_instances[cur_data_lut_reg -1] >= MAX_CONFLICTS_TH ) begin
				done_cr = 1'b1;
				th_conflict_flg = 1'b1;
				next_state = idle_st;
			end
			else begin
				we_lut = 1'b0;
				if(counter_pe_sel == `PE_NUM) next_state = row_sel_st; 
				else next_state = pe_sel_N_fill_lut_st;
			end	
		
		end
		
				
		 
	 endcase
 end
		 
	 
endmodule