/*------------------------------------------------------------------------------
 * File          : oflow_mem_buffer_wrapper.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"

module oflow_mem_buffer_wrapper #() (

input logic clk,
input logic reset_N,
// control signal from core fsm
input logic start_read,
input logic start_write,
// data in from pe
input logic data_in_0,
input logic data_in_1,
//global variable
input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num,//the serial number of the current frame 0-255
input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames, // fallback number
input logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame, // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove

//control signal for core fsm
output logic done_read,
output logic done_write,
//data out for pe
output logic data_out_0,
output logic data_out_1 

);


// -----------------------------------------------------------       
//              Logics
// -----------------------------------------------------------  
//mem logic

	 logic frame_to_read;
	 logic offset_0;
	 logic offset_1;
	 logic we;
	 logic done_read_mem;
	 logic done_write_mem;
	 

 // fsm mem logic
	 logic start_new_frame;
	
// -----------------------------------------------------------       
//                Instantiations
// -----------------------------------------------------------  

//mem instantiation
	 oflow_MEM_buffer oflow_MEM_buffer (
	.clk (clk),
	.reset_N (reset_N),

	.frame_num(frame_to_read),
	.num_of_history_frames(num_of_history_frames), 
	
	.data_in_0(data_in_0),
	.data_in_1(data_in_1),
	
	.offset_0(offset_0),
	.offset_1(offset_1),
	
	.we(we),

	.data_out_0(data_out_0),
	.data_out_1(data_out_1) 
	);
	 
	 
//fsm of mem  in wrapper instantiation
	 oflow_fsm_mem_buffer_in_mem_wrapper oflow_fsm_mem_buffer_in_mem_wrapper (
	.clk(clk),
	.reset_N (reset_N),
	.frame_num(frame_num),
	.num_of_history_frames(num_of_history_frames),
	.num_of_bbox_in_frame(num_of_bbox_in_frame),
	.start_read(start_read),
	.start_write(start_write),
	.done_read(done_read),
	.done_write(done_write)

);




endmodule