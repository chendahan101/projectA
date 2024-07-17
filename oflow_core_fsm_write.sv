/*------------------------------------------------------------------------------
 * File          : oflow_fsm_read.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"


module oflow_core_fsm_write #() (


	input logic clk,
	input logic reset_N ,
	// global inputs
	input logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame, // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove
	
	//from genreal fsm in core (after conflict_resolve done)
	input logic start_write,
	//from buffer 
	//input logic done_write_buffer,//only after core fsm ready to fetch us the next 2 line of data ; we are going to add a wait state to cure this. the wait state has to be sure the buffer is done to writes 2 rows and now we can change the PE's

	
	output logic ready_from_core, // send from fsm core to fsm buffer
	output logic [`REMAINDER_LEN-1:0] remainder, //if the fsm is in the remainder states
	output logic [`ROW_LEN-1:0] row_sel,
	output logic [`PE_LEN-1:0] pe_sel
	

);





// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

logic [`ROW_LEN-1:0] counter_row;
logic [`PE_LEN-1:0] counter_pe;
	
typedef enum {idle_st,select_row_st,select_pe_st,select_pe0_st,select_pe1_st,select_pe2_st,select_pe3_st} sm_type; //select_pe0_st is that the remainder with 4 of the #bboxes%22 is 0, ...
sm_type current_state;
sm_type next_state;




// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) current_state <= #1 idle_st;
		else current_state <= #1 next_state;
	
	end
//--------------------counter_row---------------------------------	

	 
	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st ) counter_row <= #1 0;
		 else if (next_state ==  select_row && cur_state == select_pe_st) counter_row <= #1 counter_row + 1;
		 
	  end

//--------------------counter_pe---------------------------------	

	 
	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st ) pe <= #1 0;
		 else if (cur_state == select_pe_st && next_state == select_pe_st ) counter_pe <= #1 counter_pe + 1;
		 else if (cur_state == select_pe_st && next_state == select_row_st ) counter_pe <= #1 0;
		 else if (cur_state == select_pe0_st && next_state == select_pe0_st ) counter_pe <= #1 counter_pe + 1;
	  end	  
/*
//--------------------counter_for_ready_from_core---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st ) counter_for_ready_from_core <= #1 0;
		 else if ( (cur_state == select_pe_st || cur_state == select_pe0_st ||
			 cur_state == select_pe1_st || cur_state == select_pe2_st ||  cur_state == select_pe3_st ) && counter_for_ready_from_core < 3 ) counter_for_ready_from_core <= #1 counter_for_ready_from_core + 1;
		else if ( (cur_state == select_pe_st || cur_state == select_pe0_st ||
			cur_state == select_pe1_st || cur_state == select_pe2_st ||  cur_state == select_pe3_st ) && counter_for_ready_from_core == 3 ) counter_for_ready_from_core <= #1 0;
	  end	  
	
//--------------------ready_from_core---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st ) ready_from_core <= #1 0;
		 else if (cur_state == select_pe_st && cur_state == select_pe0_st &&
			 cur_state == select_pe1_st && cur_state == select_pe2_st && cur_state == select_pe3_st && ) counter_pe <= #1 counter_pe + 1;
		
	  end	  
*/	 
	 	 
 // -----------------------------------------------------------       
 //						FSM – Async Logic
 // -----------------------------------------------------------	
 always_comb begin
	 next_state = current_state;
	 ready_from_core = 0; // send to fsm buffer
	 remainder = 0;
	 case (current_state)
		 idle_st: begin
			 next_state = start_write ? select_row_st: idle_st;	
			 
		 end
		 
		 select_row_st: begin
			 
			 if( counter_row < (num_of_bbox_in_frame/PE_NUM) )	next_state = select_pe_st;

			 else if(counter_row == (num_of_bbox_in_frame/PE_NUM) && (num_of_bbox_in_frame%PE_NUM/4 > 0 || num_of_bbox_in_frame%PE_NUM%4 > 0)
				next_state = select_pe0_st;
			 
			 else next_state = idle_st;
			
		 end
		 
 
		select_pe_st: begin 
			 if (counter_pe == PE_NUM/4) begin 
				 next_state = select_row_st;
			end
			else if (counter_for_ready_from_core == 3)
				 next_state = select_row_st;

			
		
		
		select_pe0_st: begin 
			
			 if (counter_pe == num_of_bbox_in_frame%PE_NUM/4) begin 
				case(num_of_bbox_in_frame%PE_NUM%4) begin
					0: next_state = idle_st;
					1: next_state = select_pe1_st;
					2: next_state = select_pe2_st;
					3: next_state = select_pe3_st;
				endcase 
			end	

		select_pe1_st: begin
		
			remainder = 1;
			next_state = idle_st;
			
			end	

		select_pe2_st: begin 
		
			remainder = 2;
			next_state = idle_st;
			
			end	

		select_pe3_st: begin 
		
			remainder = 3;
			next_state = idle_st;
			
			end				

		 end
		 
	 endcase
 end
	  
	assign row_sel = counter_row;
	assign pe_sel = counter_pe;
	
	 
	 
endmodule
