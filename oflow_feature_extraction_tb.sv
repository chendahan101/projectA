/*------------------------------------------------------------------------------
 * File          : oflow_feature_extraction_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 19, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

module oflow_feature_extraction_tb #() ();

// -----------------------------------------------------------       
//                  registers & wires
// -----------------------------------------------------------  
	
	
	logic clk;
	logic reset_N;
	logic [99:0] bbox;
	logic fe_enable;
	
	logic [21:0] cm_concate;
	logic [43:0] position_concate;
	logic [10:0] width;
	logic [10:0] height;
	logic [23:0] color1;
	logic [23:0] color2;
	logic [7:0] d_history; 

   
  
   

// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------

	oflow_features_extraction  oflow_features_extraction(   .clk	(clk),
		   .reset_N		(reset_N),
		   
		   .bbox (bbox),
		   .fe_enable (fe_enable),
		   
	  .cm_concate (cm_concate),
	  .position_concate  (position_concate),
	  .width (width),
	  .height (height),
	  .color1 (color1),
	  .color2(color2),
	  .d_history (d_history)
		 
		   
	  );


// ----------------------------------------------------------------------
//                   Test Pattern
// ----------------------------------------------------------------------


initial 
begin
   initiate_all;                                 // Initiates all input signals to '0' and open necessary files
	 
   #50
  
 	bbox = 100'b00111110100_00011111010_00000010100_00000011110_000000000000000100000000_000000000000000100000000_00001000;
  	#20
	fe_enable = 1'b1;
   #100 $finish; 
//   #100000  $finish;
   
end
   



// ----------------------------------------------------------------------
//                   Clock generator  (Duty cycle 5ns)
// ----------------------------------------------------------------------

   
 always begin
	#2.5 clk = ~clk;
	
  end
 /*always begin
	 #2.5 apb_oflow_pclk =~ apb_oflow_pclk;
 end */
// ----------------------------------------------------------------------
//                   Tasks
// ----------------------------------------------------------------------

 
 task initiate_all;        // sets all oflow inputs to '0'.
	  begin
		clk = 1'b0;  
		bbox = 100'd0;		
	  
		 #10 reset_N = 1'b1;     // Disable Reset signal.	 
	  end
 endtask



/*
 task apb_write(input logic [11:0]  addr,input logic [31:0] data);
	begin
		
		// ---------------T1------------
		@(posedge oflow_clk); 
		#1
		apb_oflow_penable = 1'b0;	
		apb_oflow_pwrite = 1'b1;
		apb_oflow_psel = 1'b1;	
		apb_oflow_address = addr;		
		apb_oflow_pwdata = data;
		// ---------------T2------------
		@(posedge oflow_clk);  
		#1
		apb_oflow_penable = 1'b1;	
		// ---------------T3------------
		 @(posedge oflow_clk);
		 #1
		  //apb_oflow_pwrite    = 1'b0;
		 apb_oflow_psel 		  = 1'b1;
		 //apb_oflow_address  = 13'h0;
		// apb_oflow_pwdata  = 31'h0;
		 apb_oflow_penable = 1'b0;	
		 $display("Writing Data \n");
	end
 endtask	
 
 task apb_read(input logic [11:0]  addr);
	 begin
		 
		 // ---------------T1------------
		 @(posedge oflow_clk); 
		 #1
		 apb_oflow_penable = 1'b0;			 
		 apb_oflow_pwrite = 1'b0;			
		 apb_oflow_psel = 1'b1;
		 apb_oflow_address = addr;	
		 // ---------------T2------------
		 @(posedge oflow_clk);
		 #1
		 apb_oflow_penable = 1'b1;		 
		 // ---------------T3------------
		 @(posedge oflow_clk);
		 #1 
		 //apb_oflow_pwrite    = 1'b0;
		 apb_oflow_psel 		  = 1'b0;
		 //apb_oflow_address  = 13'h0;
		 apb_oflow_penable = 1'b0;	
		$display("Reading Data \n");
	 end
  endtask	
 */
 
endmodule
