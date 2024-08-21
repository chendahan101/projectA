/*------------------------------------------------------------------------------
 * File          : all_mem_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Aug 21, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`define NUM_ADDR 8
`define NUM_OUT 64
`define WORD_DEPTH 2**(`NUM_ADDR)

//`timescale 1ns/100fs

module all_mem_tb #() ();


// -----------------------------------------------------------       
//                  Registers & Wires
// -----------------------------------------------------------  

		   
	 logic clk;
	 //logic reset_N;
	 logic [`NUM_ADDR-1:0] A1,A2;
	 logic [`NUM_OUT-1:0] I1, I2, O1, O2;
	 logic  WEB1, WEB2, OEB1, OEB2,CSB1, CSB2;

// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------





// ----------------------------------------------------------------------
//                   Test Pattern
// ----------------------------------------------------------------------


initial 
begin
// initiate	
initiate_all ();   // Initiates all input signals to '0' and open necessary files
#50

//  Write: data_in_0, data_in_1, frame_num, offset_0, offset_1
write_data (8'd10,8'd20,64'd30,64'd40);
#50
#10
//  read: addr1,addr2
read_data (8'd10,8'd20);
#50 $finish;  
end




// ----------------------------------------------------------------------
//                   Clock generator  (Duty cycle 8ns)
// ----------------------------------------------------------------------


always begin
	#2.5 clk = ~clk;
end

//always begin
	//#2.5 CEB1= ~CEB1;
	//end
//always begin
//	#2.5 CEB2 = ~CEB2;
	//end




// ----------------------------------------------------------------------
//                   Tasks
// ----------------------------------------------------------------------


task initiate_all ();        // sets all oflow inputs to '0'.
  begin
	  
	  //OEB1 = 1'b0;
	  //OEB2 = 1'b0;
	  WEB1 =1'b1;
	  WEB2 = 1'b1;
	 //CEB1 = 1'b1;
	  //CEB2 = 1'b1;
	  //CSB1 = 1'b0;
	  //CSB2 = 1'b0;
		clk = 1'b1;
		A1 = 0;
		A2 = 0;
		I1 = 0;
		I2 = 0; 
		
		
  end
endtask




task write_data (input logic [`NUM_ADDR-1:0] a1, input logic [`NUM_ADDR-1:0] a2, input logic [`NUM_OUT-1:0] i1, input logic [`NUM_OUT-1:0] i2);
begin
	@(posedge clk);
	A1 = a1;
	A2 = a2;
	//OEB1 = 1'b0;
	//OEB2 = 1'b0;
	WEB1 =1'b0;
	WEB2 = 1'b0;
	I1 = i1;
	I2 = i2; 
	CSB1 = 1'b0;
	CSB2 = 1'b0;		
	$display("write: data_in_0: %d, data_in_1: %d ",O1,O2 );
end
endtask	

task read_data (input logic [`NUM_ADDR-1:0] a1,input logic [`NUM_ADDR-1:0] a2);
begin
	@(posedge clk);
	A1 = a1;
	A2 = a2;
	//OEB1 = 1'b0;
	//OEB2 = 1'b0;
	WEB1 =1'b1;
	WEB2 = 1'b1;
	
	CSB1 = 1'b0;
	CSB2 = 1'b0;
	
			
$display("read: data_out_0: %d, data_out_1: %d ",O1,O2 );
end
endtask	



endmodule