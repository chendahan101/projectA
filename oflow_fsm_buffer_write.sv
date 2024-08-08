/*------------------------------------------------------------------------------
 * File          : oflow_fsm_read.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"

module oflow_fsm_buffer_write #() (


	input logic clk,
	input logic reset_N ,
	// global inputs
	input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num,//the serial number of the current frame 0-255
	input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames, // fallback number
	//from fsm mem in wrapper mem
	input logic [`ADDR_WIDTH-1:0] end_pointers [5],
	//from fsm in core
	input logic start_write,
	//from similarity metric will pass througth core
	input logic ready_from_core,//only after core fsm ready to fetch us the next 2 line of data

	
	output logic done_write, // send to fsm core
	output logic [`OFFSET_WIDTH-1:0] offset_0,
	output logic [`OFFSET_WIDTH-1:0] offset_1
	//output logic we

);





// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

logic [`OFFSET_WIDTH-1:0] counter_offset;
	
typedef enum {idle_st,offset_st,wait_st} sm_type;
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
		 if (!reset_N) counter_offset <= #1 0;
		 else if(current_state ==  idle_st )	counter_offset <= #1 0;
		 else if (next_state ==  offset_st && current_state !=  idle_st ) counter_offset <= #1 counter_offset + 2;
		 
	  end
	  
	 
	 
 // -----------------------------------------------------------       
 //						FSM – Async Logic
 // -----------------------------------------------------------	
 always_comb begin
	 next_state = current_state;
	 done_write = 0;// send to fsm core
	 case (current_state)
		 idle_st: begin
			 next_state = start_write ? offset_st: idle_st;	
			 
		 end
		 
		 offset_st: begin
			 
			 if((counter_offset < end_pointers[frame_num % num_of_history_frames]-1) && ready_from_core ) begin
				next_state = offset_st;
			 end 
			 else if((counter_offset < end_pointers[frame_num % num_of_history_frames]-1) && !ready_from_core ) begin
				next_state = wait_st;
			 end 
			 else  begin
					 next_state = idle_st; //end to write one frame
					 done_write = 1;
					end
			
		 end
		 

		 
		 wait_st: begin 
			 if (ready_from_core) begin 
				 next_state = offset_st;
			end
				 

		 end
		 
	 endcase
 end
	  
	assign offset_0 = counter_offset;
	assign offset_1 = counter_offset + 1;
	//assign we = 1;
	 
	 
endmodule
