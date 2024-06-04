/*------------------------------------------------------------------------------
 * File          : oflow_feature_extraction_define.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 4, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

// defines for inputs
`define BBOX_VECTOR_SIZE 89


// defines for wires AND OUTPUTS

`define CM_LEN 11  // len of x,y
`define CM_CONCATE_LEN 22  // concate
`define POSITION_CONCATE_LEN 44  // concate
`define COLOR_LEN 24
`define D_HISTORY_LEN 3

// defines for intern calculations

`define POSTION_TL_LEN 22 // len of x&y tl-top left
`define POSTION_BR_LEN 22   // len of x&y br-top left

`define WIDTH_LEN 8  // we want the maximum size to be 200 by 8 bits: q8.0
`define HEIGHT_LEN 8  // we want the maximum size to be 200 by 8 bits:	q8.0





// defines for comb_logic

`define WIDTH_MSB_IN_BBOX (`BBOX_VECTOR_SIZE-`CM_CONCATE_LEN) //
`define HEIGHT_MSB_IN_BBOX (`WIDTH_MSB_IN_BBOX-`WIDTH_LEN) //
`define COLOR1_MSB_IN_BBOX (`HEIGHT_MSB_IN_BBOX-`HEIGHT_LEN) //
`define COLOR2_MSB_IN_BBOX (`COLOR1_MSB_IN_BBOX-`COLOR_LEN) //





