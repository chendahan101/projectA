/*------------------------------------------------------------------------------
 * File          : oflow_fsm_mem_buffer_in_mem_wrapper.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"

module oflow_fsm_mem_buffer_in_mem_wrapper #() (


input logic clk,
input logic reset_N ,
input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num,//the serial number of the current frame 0-255
input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames, // fallback number
input logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame, // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove

//for fsm to fsm_write
input logic start_write,
//signal from fsm_write to mem
output logic done_write,

//for fsm to fsm_read
input logic similarity_metric_flag_ready_to_read_new_line,//only after the similarity metric finish to process one line 
input logic start_read,
//signal from fsm_read to mem
output logic done_read,
output logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_to_read,

output logic [`OFFSET_WIDTH-1:0] offset_0,
output logic [`OFFSET_WIDTH-1:0] offset_1,
output logic we


);




// -----------------------------------------------------------       
//              Logics
// -----------------------------------------------------------  
logic [`ADDR_WIDTH-1:0] end_pointers [5];
// -----------------------------------------------------------       
//                Instantiations
// -----------------------------------------------------------  

//fsm read instantiation
	 oflow_fsm_read oflow_fsm_read (
	.clk (clk),
	.reset_N (reset_N),
	
	.frame_num(frame_num),//the serial number of the current frame 0-255
	.num_of_history_frames(num_of_history_frames), // fallback number
	.end_pointers (end_pointers),
	.start_read(start_read),
	.similarity_metric_flag_ready_to_read_new_line(similarity_metric_flag_ready_to_read_new_line),//only after the similarity metric finish to process one line 

	
	.done_read(done_read),
	.frame_to_read(frame_to_read),
	.offset_0(offset_0),
	.offset_1(offset_1),
	.we(we)
	);
//fsm write instantiation
oflow_fsm_write oflow_fsm_write (
	.clk(clk),
	.reset_N (reset_N),
	.start (start),
	.start_read(start_read_mem),
	.start_write(start_write_mem),
	.done_read(done_read_mem),
	.done_write(done_write_mem)

);



// -----------------------------------------------------------       
//              Assignments
// ----------------------------------------------------------- 
// to set the end pointer

always_comb begin
	end_pointers[frame_num%num_of_history_frames] = (start_write) ? num_of_bbox_in_frame : 0;
end
 




endmodule