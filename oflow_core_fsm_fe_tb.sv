/*------------------------------------------------------------------------------
 * File          : oflow_core_fsm_fe_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Sep 20, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"

module oflow_core_fsm_fe_tb #() ();


 logic clk;
 logic reset_N;

 //fsm_core_top
  logic [`SET_LEN-1:0] num_of_sets; 
  logic start_pe;
  logic [`REMAIN_BBOX_LEN-1:0] counter_of_remain_bboxes; // will help us to choose how many pe to activate because sometimes current #bboxes_in_set < 24
  logic new_set; // will help to know if new_set in the frame is waiting
 //output logic [`SET_LEN] counter_set_fe - need to check if need this because we draw it in module but we forgot
  logic [`SET_LEN-1:0] counter_set_fe; // for counter_of_remain_bboxes in core_fsm_top
 
 //oflow_core_fsm_registration
  logic done_registration;
  logic done_fe; // done_fe of all fe's in use
 
 
 // pe's
  logic [`PE_NUM] done_fe_i;
  logic [`PE_NUM] start_fe_i; 




 // ----------------------------------------------------------------------
 //                   Instantiation
 // ----------------------------------------------------------------------

 oflow_core_fsm_fe oflow_core_fsm_fe (.*);



 // ----------------------------------------------------------------------
 //                   Test Pattern
 // ----------------------------------------------------------------------


 initial 
 begin
	 // initiate	
	 initiate_all ();   // Initiates all input signals to '0' and open necessary files
	 #50
	 three_sets_not_full ();

	 
	 #50 $finish;  
 end




 // ----------------------------------------------------------------------
 //                   Clock generator  (Duty cycle 8ns)
 // ----------------------------------------------------------------------


 always begin
	 #2.5 clk = ~clk;
 end

 // ----------------------------------------------------------------------
 //                   Tasks
 // ----------------------------------------------------------------------



 task initiate_all ();        // sets all oflow inputs to '0'.
  begin   
	 clk = 1'b0;
	 reset_N = 1'b0;
	 
	 done_registration = 0;
	 counter_of_remain_bboxes = 0;
	 num_of_sets = 0; // for stop_counter
	 start_pe = 1'b0;
	 new_set = 1'b0;
	 done_fe_i = 0;
	 #10
	 reset_N = 1'b1;
	
	
   end  
 endtask


 task three_sets_not_full ();
 begin
	 
	 // first set
	 num_of_sets = `SET_LEN'd3;
	 counter_of_remain_bboxes = `REMAIN_BBOX_LEN'd70;
	 start_pe=1'b1;
	 @(posedge clk);
	 start_pe=1'b0;
	 new_set = 1'b1;
	 @(posedge clk);
	 new_set = 1'b0;
	 @(posedge clk);
	 done_fe_i = {`PE_NUM{1'b1}};
	 
	 // second set
	 counter_of_remain_bboxes = `REMAIN_BBOX_LEN'd46;
	 @(posedge clk);
	 new_set = 1'b1;
	 @(posedge clk);
	 new_set = 1'b0;
	 done_fe_i = {`PE_NUM{1'b0}};
	 @(posedge clk);
	 done_fe_i = {`PE_NUM{1'b1}};
	 @(posedge clk);
	
	
	
	repeat (39) @(posedge clk);
	done_registration = 1'b1;
	@(posedge clk);
	done_registration = 1'b0;
	
	
	
	// third set
	 
	counter_of_remain_bboxes = `REMAIN_BBOX_LEN'd22;
	
	new_set = 1'b1;
	@(posedge clk);
	new_set = 1'b0;
	@(posedge clk);
	done_fe_i = {`PE_NUM{1'b0}};
	@(posedge clk);
	done_fe_i = {(`PE_NUM-2){1'b1}};
   
   
   repeat (39) @(posedge clk);
   done_registration = 1'b1;
   @(posedge clk);
   done_registration = 1'b0;
	 
	
	 
	 
 end  
 endtask



endmodule