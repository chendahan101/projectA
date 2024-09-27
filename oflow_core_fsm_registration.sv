/*------------------------------------------------------------------------------
 * File          : oflow_core_fsm_registration.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"



module oflow_core_fsm_registration #() (


	input logic clk,
	input logic reset_N ,
	
	//fsm_core_top
	input logic [`SET_LEN-1:0] num_of_sets, 
	input logic [`REMAIN_BBOX_LEN-1:0] counter_of_remain_bboxes, // will help us to choose how many pe to activate because sometimes current #bboxes_in_set < 24
	output logic done_pe,
	
	
	
	//oflow_core_fsm_fe
	input logic done_fe,
	output logic done_registration, // done_registration of all registration's in use
	
	
	// pe's
	input logic [`PE_NUM] done_registration_i,
	output logic [`PE_NUM] start_registration_i,
	
	// oflow_core_fsm_read
	output logic [`SET_LEN-1:0] counter_set_registration

);





// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  


logic [`PE_NUM-1:0] num_of_bbox_to_compare;

logic generate_done_registration;
	
typedef enum {idle_st,registration_st,wait_st} sm_type; 
sm_type current_state;
sm_type next_state;

// -----------------------------------------------------------       
//                  Assignments
// -----------------------------------------------------------  

assign done_registration = generate_done_registration;
assign done_pe = (counter_set_registration == num_of_sets);

// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) current_state <= #1 idle_st;
		else current_state <= #1 next_state;
	
	end
//--------------------counter_set_registration---------------------------------	

	 
	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st ) counter_set_registration <= #1 0;
		 else if (current_state ==  wait_st && (next_state == registration_st || next_state == idle_st)) counter_set_registration <= #1 counter_set_registration + 1;
		 
	  end

		 
 // -----------------------------------------------------------       
 //						FSM – Async Logic
 // -----------------------------------------------------------	
 always_comb begin
	 next_state = current_state;
	 generate_done_registration = 1'b0; 
	 start_registration_i = 1'b0;
	 case (current_state)
		 idle_st: begin
			 next_state = done_fe ? registration_st: idle_st;	
			 
		 end
		 
		 registration_st: begin
			 
			 if((counter_set_registration < num_of_sets)&& (counter_set_registration==0||done_fe)) begin
				if( counter_set_registration == num_of_sets - 1 )
					start_registration_i = {`PE_NUM{1'b1}} >> (`PE_NUM-counter_of_remain_bboxes);
				else start_registration_i = {`PE_NUM{1'b1}};
				next_state = wait_st;
				//if( counter_of_remain_bboxes < `PE_NUM )
				
			end
		
			else if(counter_set_registration == num_of_sets) next_state = idle_st;
			
		 end
		 
 
		wait_st: begin 
			
				if( counter_set_registration == num_of_sets - 1 ) begin
					num_of_bbox_to_compare = {`PE_NUM{1'b1}} >> (`PE_NUM-counter_of_remain_bboxes);
					generate_done_registration = (num_of_bbox_to_compare == done_registration_i);
					if (generate_done_registration) begin 
						next_state = idle_st;

					end
				end
					//generate_done_registration = (start_registration_i[counter_of_remain_bboxes-1:0] == done_registration_i[counter_of_remain_bboxes-1:0]);
				else begin
					generate_done_registration = ( done_registration_i == {`PE_NUM{1'b1}} );
					if ( generate_done_registration || counter_set_registration == 0)  begin
						next_state = registration_st;
					 end
				end
				
			
		end
		
		 
	 endcase
 end
		 
	 
endmodule