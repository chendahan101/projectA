/*------------------------------------------------------------------------------
 * File          : oflow_core_fsm_read_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Sep 15, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"

module oflow_core_fsm_read_tb #() ();

 logic clk;
 logic reset_N;

// global inputs


//fsm_core_top
 logic [`SET_LEN-1:0] num_of_sets; // for stop_counter
 logic [`REMAIN_BBOX_LEN-1:0] counter_of_remain_bboxes; // will help us to choose how many pe to activate because sometimes current #bboxes_in_set < 24


//control signals
 logic done_read; // from fsm buffer read
 logic done_registration; // from registration (after set done)
 logic start_read_mem_for_first_set; //its not enough to know that this is the first set of the frame, we also need to know that the similarity_metric is starting
 logic  [`PE_NUM-1:0] control_for_read_new_line;//from all similarity_metrics (to read new line)


 logic start_read; // send from fsm core to fsm buffer read
 logic read_new_line;//send from fsm core to fsm buffer read

// core_fsm_registration
 logic [`SET_LEN-1:0] counter_set_registration;








 // ----------------------------------------------------------------------
 //                   Instantiation
 // ----------------------------------------------------------------------

 oflow_core_fsm_read oflow_core_fsm_read (.*);



 // ----------------------------------------------------------------------
 //                   Test Pattern
 // ----------------------------------------------------------------------


 initial 
 begin
	 // initiate	
	 initiate_all ();   // Initiates all input signals to '0' and open necessary files
	 #50
	 read ();

	 
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
	 control_for_read_new_line = 0;
	 start_read_mem_for_first_set = 0;
	 done_read = 1'b0;
	 done_registration = 0;
	 counter_set_registration = 0;
	 counter_of_remain_bboxes = 0;
	 num_of_sets = 0; // for stop_counter
	 #10
	 reset_N	= 1'b1;
	
	
   end  
 endtask


 task read ();
 begin
	 
	 num_of_sets = `SET_LEN'd3;
	 counter_of_remain_bboxes = `REMAIN_BBOX_LEN'd68;
	 counter_set_registration = 0;

	 @(posedge clk);
	 start_read_mem_for_first_set = 1'b1;
	 @(posedge clk);
	 start_read_mem_for_first_set = 1'b0;
	 @(posedge clk);
	 //========================set 0===================
	 @(posedge clk);//wait to read from mem the old bbox
	 
	 for (int i=0; i<4;i++) begin
		 repeat(11) @(posedge clk);
		 //after 11 cycle we want control read new line
		 control_for_read_new_line = {`PE_NUM{1'b1}};
		 @(posedge clk);
		 control_for_read_new_line = 0;
		 @(posedge clk);
	end

	 done_read =1'b1;
	 @(posedge clk);// at this point the similirairty ends
	 done_read =1'b0;

	 repeat(2) @(posedge clk);// wait for calc min to end
	 @(posedge clk);// wait for score board to end
	 done_registration =1'b1;
	 @(posedge clk);

	 done_registration =1'b0;
	 
	 
	 
	 //========================set 1===================
	 counter_of_remain_bboxes = `REMAIN_BBOX_LEN'd44;
	 counter_set_registration = `SET_LEN'd1;
	 @(posedge clk);//wait to read from mem the old bbox
	 
	 for (int i=0; i<4;i++) begin
		 repeat(11) @(posedge clk);
		 //after 11 cycle we want control read new line
		 control_for_read_new_line = {`PE_NUM{1'b1}};
		 @(posedge clk);
		 control_for_read_new_line = 0;
		 @(posedge clk);
	end

	 done_read =1'b1;
	 @(posedge clk);// at this point the similirairty ends
	 done_read =1'b0;

	 repeat(2) @(posedge clk);// wait for calc min to end
	 @(posedge clk);// wait for score board to end
	 done_registration =1'b1;
	 @(posedge clk);

	 done_registration =1'b0;
	 
	 
	 //========================set 2===================
	 counter_of_remain_bboxes = `REMAIN_BBOX_LEN'd20;
	 counter_set_registration = `SET_LEN'd2;
	 @(posedge clk);//wait to read from mem the old bbox
	 
	 for (int i=0; i<4;i++) begin
		 repeat(11) @(posedge clk);
		 //after 11 cycle we want control read new line
		 control_for_read_new_line = {      {4{1'b0}}    ,   {20{1'b1}}   };
		 @(posedge clk);
		 control_for_read_new_line = 0;
		 @(posedge clk);
	end
	 done_read =1'b1;
	 @(posedge clk);// at this point the similirairty ends
	 done_read =1'b0;

	 repeat(2) @(posedge clk);// wait for calc min to end
	 @(posedge clk);// wait for score board to end
	 done_registration =1'b1;
	 @(posedge clk);

	 done_registration =1'b0;
	 
	 
 end  
 endtask



endmodule