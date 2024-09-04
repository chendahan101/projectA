/*------------------------------------------------------------------------------
 * File          : oflow_calc_iou_define.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 9, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

// defines for inputs
`define BBOX_POSITION_FRAME 44
`define POSITION_INTERSECTION 11  // len of x_TL,BR
`define INTERSECTION 22  // len of (X_BR-X_TL)*(Y_BR-Y_TL)
`define SIZE_LENGTH 16  // len of WITDH*HEIGHT
`define COUNTER_LEN 4  // len of COUNTER


// defines for wires AND OUTPUTS


`define IOU_LEN 22  // len of iou output number between 0 to 1 : q0.22


// defines for comb_logic

`define X_TL_MSB_IN_BBOX (`BBOX_POSITION_FRAME) //
`define Y_TL_MSB_IN_BBOX (`X_TL_MSB_IN_BBOX-`POSITION_INTERSECTION) //
`define X_BR_MSB_IN_BBOX (`Y_TL_MSB_IN_BBOX-`POSITION_INTERSECTION) //
`define Y_BR_MSB_IN_BBOX (`X_BR_MSB_IN_BBOX-`POSITION_INTERSECTION) //









