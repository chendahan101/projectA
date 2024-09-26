/*------------------------------------------------------------------------------
 * File          : oflow_MEM_buffer_fsm.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 27, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"

module oflow_MEM_buffer_fsm #() (
	input logic clk,
	input logic reset_N,
	input logic start,
	input logic start_read ,
	input logic start_write ,
	input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num,//the serial number of the current frame 0-255
	input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames, // fallback number
	input logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame, // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove
	
	//control pe_conflict signal
	output logic done_read ,
	output logic done_write 
);







// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  
	
	logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] counter_history_frame_read;
	logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] counter_offset_read;
	logic [`ADDR_WIDTH-1:0] end_pointers [5];

	typedef enum {idle_st,read_st,write_st} sm_type;
	sm_type current_state;
	sm_type next_state;
	
// -----------------------------------------------------------       
//				Assignments
// ----------------------------------------------------------- 	

	


// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) current_state <= #1 idle_st;
		else current_state <= #1 next_state;
	
	end
//--------------------counter---------------------------------	
	 always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) counter <= #1 4'd0;
		else if(current_state ==  avg_st && next_state!=current_state)	counter <= #1 4'd0;
		else counter <= #1 counter + 1;
		
	 end
	
	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N) counter_history_frame_read <= #1 4'd0;
		 else if(current_state ==  idle_st )	counter_history_frame_read <= #1 4'd0;
		 else if (current_state ==  read_st && new_frame_to_read == 1) counter_history_frame_read <= #1 counter_history_frame_read + 1;
		 
	 end
	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N) counter_offset_read <= #1 4'd0;
		 else if(current_state ==  idle_st || new_frame_to_read == 1)	counter_offset_read <= #1 4'd0;
		 else if (current_state ==  read_st) counter_offset_read <= #1 counter_offset_read + 1;
		 
	 end
	
	
	
	
// -----------------------------------------------------------       
//						FSM – Async Logic
// -----------------------------------------------------------	
always_comb begin
	next_state = current_state;
	valid = 0;//of similarity
	start_iou = 0;
	score = 0;
	case (current_state)
		idle_st: begin
			next_state = start_read ? read_st:(start_write? write_st : idle_st);	
		end
		
		read_st: begin
			if (frame_num>=num_of_history_frames) begin
				if (counter_history_frame_read < num_of_history_frames) begin
					new_frame_to_read = 0;
					if (counter_offset_read < end_pointers[counter_history_frame_read])
						frame_to_read = frame_num - counter_history_frame_read +1;
						offset = counter_offset_read;
					else begin
						new_frame_to_read = 1
					end
						
					
					
					
					
					
					
				end
				
				
				
				
				
			end
			else begin
				
			end
			
		end
		
		
		
		
		
		
		write_st: begin 
				 
			end_pointers[frame_num%num_of_history_frames] = num_of_bbox_in_frame;
				
				
		end
		
		
	endcase
end



endmodule