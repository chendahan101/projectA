/*------------------------------------------------------------------------------
 * File          : oflow_fsm_write.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

module oflow_fsm_write #() ();

input logic clk,
input logic reset_N ,
// global inputs
input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num,//the serial number of the current frame 0-255
input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames, // fallback number
//from fsm mem in wrapper mem
input logic [`ADDR_WIDTH-1:0] end_pointers [5],
//from fsm in core
input logic start_read,
//from similarity metric will pass througth core
input logic similarity_metric_flag_ready_to_read_new_line,//only after the similarity metric finish to process one line 


output logic done_write,
output logic [`OFFSET_WIDTH-1:0] offset_0,
output logic [`OFFSET_WIDTH-1:0] offset_1,
output logic we

);





// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] counter_of_history_frame;
logic [`OFFSET_WIDTH-1:0] counter_offset;
logic new_frame_to_read;

typedef enum {idle_st,frame_st,offset_st} sm_type;
sm_type current_state;
sm_type next_state;




// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
always_ff @(posedge clk or negedge reset_N) begin
	if (!reset_N) current_state <= #1 idle_st;
	else current_state <= #1 next_state;

end
//--------------------counter---------------------------------	
 always_ff @(posedge clk or negedge reset_N) begin
	if (!reset_N) counter_of_history_frames <= #1 4'd0;
	else if(current_state ==  idle_st )	counter_of_history_frames <= #1 4'd0;
	else if (new_frame_to_read) counter_of_history_frames <= #1 counter_of_history_frames + 1;
	
 end
 
 always_ff @(posedge clk or negedge reset_N) begin
	 if (!reset_N) counter_offset <= #1 0;
	 else if(current_state ==  idle_st || new_frame_to_read)	counter_offset <= #1 0;
	 else if (current_state ==  offset_st && similarity_metric_flag_ready_to_read_new_line ) counter_offset <= #1 counter_offset + 1;
	 
  end
  
 
 
// -----------------------------------------------------------       
//						FSM – Async Logic
// -----------------------------------------------------------	
always_comb begin
 next_state = current_state;
 new_frame_to_read = 0;
 frame_to_read = 0;
 done_read = 0;
 case (current_state)
	 idle_st: begin
		 next_state = start_read ? frame_st: idle_st;	
		 
	 end
	 
	 frame_st: begin
		 
		 if(counter_of_history_frames < num_of_history_frames) begin
			 frame_to_read = frame_num - counter_of_history_frames - 1;
			next_state = offset_st;
		 end 
		 else begin
				 next_state = idle_st;
				 done_read = 1;
				end
		
	 end
	 

	 
	 offset_st: begin 
		 if (counter_offset == end_pointers[frame_to_read % num_of_history_frames]) begin //end to read one frame
			 next_state = frame_st;
			 new_frame_to_read = 1;
		end
			 

	 end
	 
 endcase
end
  
assign offset_0 = counter_offset;
assign offset_1 = 0;
assign we = 0;
 

endmodule