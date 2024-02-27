/*------------------------------------------------------------------------------
 * File          : oflow_conflict_resolve.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
 //------------------general define-----------------------------
'define MAX_PE 22 //number of pe-processor engine
 //------------------define for the fill_histogram------------------------------
'define score_threshould 0.5
'define width_num_of_bbox_for_frame 8 // max num =250 => represent by 8 bit
'define width_max_row_in_score_board 3 // max row =6 => represent by 3 bit
'define width_num_of_fall_back 3 // max row =5 => represent by 3 bit
'define width_th_conf_counter 3 // max num =6 => represent by 3 bit
'define width_address_to_read_from_score_board 3 // max row =6 => represent by 3 bit, in each score board we have max 6 row:250/22/2
'define width_pe 8 // max num of pe =22 => represent by 8 bit
'define width_pe_data 446 // with in bit 446  
'define width_id 12 // width id 12 
'define width_pointer 3 //0-4, 2^3=8>
'define width_idx_in_sb_line 9 //0-445, 2^9=512, index in data of score board line

'define start_upper_pointer_idx 443 //position pointer in score board data line
'define start_lower_pointer_idx 220 //position pointer in score board data line
'define offset_in_data 44 //id bit+score bit =12+32=44bit 

//communucation with score board
'define  width_data_in_from_score_board 446 //size of row in score board mem
'define  width_score 32 //float number




 
module oflow_conflict_resolve #() (
	input logic clk,
	input logic reset_N	,
		
	 input logic[width_num_of_bbox_for_frame-1:0] num_of_bbox_for_frame,
	 input logic[width_max_row_in_score_board-1:0] max_row_in_score_board,
	 input logic[width_num_of_fall_back-1:0] num_of_fall_back,
	 
	 //signal for communication with score board
	input  logic    reading_done_from_score_board  // Output Enable from the score_board we read from,if oe=1 the read is done! we need to raise it to 1 so the conflict resolve will be ready to read

	input logic [width_data_in_from_score_board-1:0] data_in_from_score_board,//one line we read from score board
	output logic [width_address_to_read_from_score_board-1:0] address_to_read_from_score_board,
	output logic we_for_score_board,
	output logic [width_pe-1:0] choose_pe_to_read,
	 

	 
	 output logic[width_th_conf_counter-1:0] th_conf_counter,
	 output logic[width_pe-1:0] pe,

	 output logic[20:0] id  ); 


//-----------------------------------------
// 			wire for LUT
//-----------------------------------------

 input logic address_LUT  ;// Address Input
 input logic data_LUT     ;// Data bi-directional
 input logic cs_LUT       ;// Chip Select
 input logic we_LUT       ;// Write Enable/Read Enable
 input logic oe_LUT		  ;// Output Enable
 
 //-----------------------------------------
// 			instantiation for LUT
//-----------------------------------------

 oflow_conflict_resolve_LUT #(
	.address(address_LUT)  , // Address Input
	.data(data_LUT)     , // Data bi-directional
	.cs(cs_LUT)       , // Chip Select
	.we(we_LUT)       , // Write Enable/Read Enable
	.oe(oe_LUT)         // Output Enable
 );
 
//-----------------------------------------
// 			wire for histogram
//-----------------------------------------

 input logic address_histogram  ;// Address Input
 input logic data_histogram     ;// Data bi-directional
 input logic cs_histogram       ;// Chip Select
 input logic we_histogram       ;// Write Enable/Read Enable
 input logic oe_histogram		  ;// Output Enable
 
//-----------------------------------------
// 			instantiation for histogram
//-----------------------------------------
 oflow_registration_score_board_ram_sp_sr_sw #(
  	.address(address_histogram)  , // Address Input
	.data(data_histogram)     , // Data bi-directional
	.cs(cs_histogram)       , // Chip Select
	.we(we_histogram)       , // Write Enable/Read Enable
	.oe(oe_histogram)         // Output Enable
 );









task fill_histogram (input bit [3:0] count, delay,data_in_from_score_board); 
	
	logic [width_data_in_from_score_board-1:0] data_out_from_score_board;
	logic [width_address_to_read_from_score_board-1:0] address_to_read_from_score_board;
for (int pe = 0; pe < 'MAX_PE; pe = pe + 1) begin
	for (int row_in_s_board = 0; row_in_s_board < max_row_in_score_board; ) begin
	
		read_from_score_board(reading_done_from_score_board,pe,row_in_s_board,data_out_from_score_board,address_to_read_from_score_board,choose_pe_to_read,we_for_score_board)
		if (reading_done_from_score_board) begin 
			row_in_s_board = row_in_s_board + 1
			//in one row in score board we have 2 BBox
			logic [width_id-1:0] upper_id;
			logic [width_id-1:0] lower_id;
			logic [width_score-1:0] upper_score;
			logic [width_score-1:0] lower_score;
			
			// remmber the fsm will make sure i have pe_data at the right time i want to read it
			extract_score_N_id (data_in_from_score_board,upper_id,lower_id,upper_score,lower_score);
			fill_lut
			
			fill_histogram_score_addr---->check_min_score
			
		end //if reading_done_from_score_board
		
		
	end//row in score board

end//pe for
  
  
endtask


task read_from_score_board(reading_done_from_score_board,pe,row_in_s_board,data_out_from_score_board,address_to_read_from_score_board,choose_pe_to_read,we_for_score_board);
	address_to_read_from_score_board = row_in_s_board;
	choose_pe_to_read =  pe;
	we_for_score_board = 0;
endtask


task extract_score_N_id (input data_in_from_score_board,output upper_id, output lower_id,output upper_score,output lower_score);
	logic width_data = width_data_in_from_score_board 
	
	logic [width_pointer-1:0] upper_pointer = data_in_from_score_board[start_upper_pointer_idx+width_pointer-1:start_upper_pointer_idx];
	logic [width_pointer-1:0] lower_pointer = data_in_from_score_board[start_lower_pointer_idx+width_pointer-1:start_lower_pointer_idx];
	//sb = score board
	logic [width_idx_in_sb_line-1:0] start_upper_id_idx = width_data-(width_pointer+offset_in_data*upper_pointer+width_id) ;
	logic [width_idx_in_sb_line-1:0] start_lower_id_idx = width_score+(offset_in_data*lower_pointer);

	logic [width_idx_in_sb_line-1:0] start_upper_score_idx = width_data-(width_pointer+offset_in_data*upper_pointer+width_id+width_score) ;
	logic [width_idx_in_sb_line-1:0] start_lower_score_idx = (offset_in_data*lower_pointer);


	upper_id = data_in_from_score_board[start_upper_id_idx+width_id-1:start_upper_id_idx];
	lower_id = data_in_from_score_board[start_lower_id_idx+width_id-1:start_lower_id_idx];
	upper_score = data_in_from_score_board[start_upper_score_idx+width_score-1:start_upper_score_idx];
	lower_score = data_in_from_score_board[start_lower_score_idx+width_score-1:start_lower_score_idx];

	

endtask


























typedef enum {idle_st,fill_histogram,resolve_conflict} sm_type;
sm_type current_state;
sm_type next_state;

	
// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

	logic [10:0] x_tl_intersection;
	logic [10:0] x_br_intersection;
	logic [10:0] y_tl_intersection;
	logic [10:0] y_tl_intersection;
	logic [21:0] Intersection;
	logic [21:0] size_length_k;
	logic [21:0] size_length_history;
	logic [4:0] counter;
	logic [4:0] break_flag;



// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
    always_ff @(posedge clk, posedge rst) begin
        if (reset_N == 1'b1|| !is_conflicr_resolve_state_EN) begin   //if is_conflicr_resolve_state_EN==0 mean we need to stop(e.g th_conf=10)->go idle and stop
            current_state <=#1 idle_st;
        end
        else begin
            current_state <=#1 next_state;
        end
    end
//--------------------counter---------------------------------	
	 always_ff @(posedge clk, posedge rst) begin
        if (reset_N == 1'b1|| next_state==idle_st|| !is_conflicr_resolve_state_EN) begin
            counter_of_fall_back <=#1 num_of_fall_back;
        end
        else begin
            counter_of_fall_back <=#1 counter+1;
        end
    end
	

	
	
	
	
// -----------------------------------------------------------       
//						FSM – Async Logic
// -----------------------------------------------------------	
always_comb begin
    next_state = current_state;
    case (current_state)
        idle_st: begin
				break_flag =1;
                next_state = fill_histogram;
				task clean_histogram (input bit [3:0] count, delay); 
                
            
        end
		fill_histogram: begin
			if (break_flag) next_state = idle_st;
			else next_state = resolve_conflict;

	         
        end
        resolve_conflict: begin 
		if (!counter_of_fall_back) next_state = idle_st;
		else next_state = fill_histogram;
        end
		
        
				
          
    endcase
end

	
	
	
endmodule
	
	