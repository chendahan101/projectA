/*------------------------------------------------------------------------------
 * File          : oflow_fsm_read.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`define ROW_LEN 3 //The maximum rows of each pe mem is 6
`define PE_LEN 5 // There are 24 PEs
`define SET_LEN 4 //The maximum sets: 256/PE_NUM=11, need 4 bits: 2^4 = 16 > 11
`define PE_NUM 24 // There are 24 PEs
`define DATA_OUT_NUM 4 // Num of the dataouts from the mux
`define REMAINDER_LEN 2 // remainder=1 or2 or 3
