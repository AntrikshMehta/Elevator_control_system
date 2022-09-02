`timescale 1ns / 1ps

module Lift_Ctrl_sys(clk, reset, flr_sel, up_sel, down_sel, door_obst, door);
input [1:0] flr_sel, up_sel, down_sel;
input door_obst, clk, reset;
output reg door;
reg [1:0] flr_rchd;

parameter[2:0] flr1_door_open = 3'b000;
parameter[2:0] flr1_door_close = 3'b001;
parameter[2:0] flr2_door_open = 3'b011;
parameter[2:0] flr2_door_close = 3'b010;
parameter[2:0] flr3_door_open = 3'b100;
parameter[2:0] flr3_door_close = 3'b101;
 
reg [2:0] current_state;
reg [2:0] next_state;
 
always @(posedge clk)
begin
if(reset == 1)
current_state <= flr1_door_open;
else 
current_state <= next_state;
end  

always @(current_state, flr_sel, up_sel, down_sel, door_obst)
begin
case(current_state) 
    flr1_door_open:
    if (reset == 1 || door_obst == 1 || flr_sel == 2'b01) begin
        next_state <= flr1_door_open;
        flr_rchd <= 01;
        end
    else begin
        next_state <= flr1_door_close;
        flr_rchd <= 01;
        end
 
    flr1_door_close:
    if (flr_sel == 2'b01 || up_sel == 2'b01) begin
        next_state <= flr1_door_open;
        flr_rchd <= 01;
        end
    else if (flr_sel == 2'b10 || flr_sel == 2'b11 || up_sel == 2'b10 || down_sel == 2'b10 || down_sel == 2'b11) begin
        next_state <= flr2_door_close;
        flr_rchd <= 10;
        door <= 0;
        end
    else begin
        next_state <= flr1_door_close;
        flr_rchd <= 01;
        end     
 
    flr2_door_close:
    if (flr_sel == 2'b10 || up_sel == 2'b10 || down_sel == 2'b10)begin
        next_state <= flr2_door_open;
        flr_rchd <= 10;
        end
    else if (flr_sel == 2'b11 || down_sel == 2'b11)begin
        next_state <= flr3_door_close;
        flr_rchd <= 11;
        end
    else if (flr_sel == 2'b01 || up_sel == 2'b01)begin
        next_state <= flr1_door_close;
        flr_rchd <= 01;
        end
    else begin
        next_state <= flr2_door_close;
        flr_rchd <= 10;
        end 
 
    flr2_door_open:
    if (door_obst == 1 || flr_sel == 2'b10) begin
        next_state <= flr2_door_open;
        flr_rchd <= 10;
        end
    else begin
        next_state <= flr2_door_close;
        flr_rchd <= 10;
        end
 
    flr3_door_close:
    if (flr_sel == 2'b11 || down_sel == 2'b11) begin
        next_state <= flr3_door_open;
        flr_rchd <= 11;
        end
    else if (flr_sel == 2'b10 || flr_sel == 2'b01 || up_sel == 2'b10 || down_sel == 2'b10 || up_sel == 2'b01) begin
        next_state <= flr2_door_close;
        flr_rchd <= 10;
        end
     else begin
        next_state <= flr3_door_close;
        flr_rchd <= 11;
        end 
 
    flr3_door_open:
    if (door_obst == 1 || flr_sel == 2'b11) begin
        next_state <= flr3_door_open;
        flr_rchd <=11;
        end
    else begin
        next_state <= flr3_door_close;
        flr_rchd <= 11;
        end
 
    default:
        begin
        next_state <= flr1_door_open; 
        flr_rchd <= 01;
        end
endcase
end

always @(current_state)
begin
case (current_state)
    flr1_door_open, flr2_door_open, flr3_door_open:
        door <= 1;
    flr1_door_close, flr2_door_close, flr3_door_close:
        door <= 0;
endcase
end
endmodule
