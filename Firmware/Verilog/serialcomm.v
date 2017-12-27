`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:13:07 12/04/2017 
// Design Name: 
// Module Name:    serialcomm 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module serialcomm(
    input clk,
    input rst_n,
    input rxd,
    input [7:0] outd,
    output txd,
    output [7:0] data
    );
	 //�м��������
	
	//�ӿڲ�������
	wire clk_baud;//������ʱ��
	wire sent_trig;
	wire sent_switch;
	
	//״̬��������
	
	//��ģ��ʵ��������
	//9600������ʱ�Ӳ���ģ��
	clk_baud_gen U1(
		.clk(clk),
		.clr(rst_n),
		.clk_baud(clk_baud)
	);
	clk_sent U2(
		.clk(clk),
		.clr(rst_n),
		.sent_switch(sent_switch),
		.senttrig(sent_trig)
	);
	//����ģ��
	serial_rxd U3(
		.clk(clk_baud),//������ʱ��
		.clr(rst_n),//ȫ�ָ�λ��
		.rxd(rxd),	//FPGA�������ݶ�
		.sent_switch(sent_switch),
		.data(data)	//8λ���ݼĴ������
    );
	 //����ģ��
	 serial_txd U4(
		.clk(clk_baud),//������ʱ��
		.clr(rst_n),//ȫ�ָ�λ��
		.enable(sent_trig),//����ʹ�ܶ�
		.data(outd),//FPGA���ݷ���ʱ�������͵�����
		.txd(txd)//FPGA���ݷ��Ͷ�
	 );
	
	//��ʼ���Ĵ���
	
	//��ʾ����ģ��
endmodule


module clk_baud_gen(
    input clk,
    input clr,
    output reg clk_baud
    );
	//clkΪ50MHz����clk_baud��ҪΪ9600Hz����һ��clk_baud���ڰ���5208.3333��clk����
	reg [11:0]divclk;
	
	initial
	begin
		divclk<=0;
		clk_baud<=0;
	end
	
	always @(posedge clk or posedge clr)
	begin
		//��λ
		if(clr)
		begin
			divclk<=0;
			clk_baud<=0;
		end
		//�����ڷ�ת
		else if(divclk>=2603)
		begin
			divclk<=0;
			clk_baud<=~clk_baud;
		end
		//����
		else
			divclk<=divclk+1;
	end

endmodule

module clk_sent(
	 input clk,
    input clr,
	 input sent_switch,
    output reg senttrig
    );
	 //clkΪ50MHz����clk_senttrig��ҪΪ100Hz����һ��clk_baud���ڰ���500000��clk����
	reg [19:0]divclk;
	
	initial
	begin
		divclk<=0;
		senttrig<=0;
	end
	
	always @(posedge clk or posedge clr)
	begin
		//��λ
		if(clr)
		begin
			divclk<=0;
			senttrig<=0;
		end
		//�����ڷ�ת
		else if(divclk>=250000)
		begin
			divclk<=0;
			if(sent_switch)
			senttrig<=~senttrig;
			else senttrig<=0;
		end
		//����
		else
			divclk<=divclk+1;
	end
endmodule


module serial_rxd(
    input clk,			//������ʱ��
    input clr,			//ȫ�ָ�λ��
    input rxd,			//FPGA�������ݶ�
	 output reg sent_switch,
    output reg [7:0]data	//8λ��λ�Ĵ���
    );

	//�м��������
	reg [3:0]count;//�����������ڼ�¼���յ�����λ��
	reg [1:0]rec_state;//��ʼλ���Ĵ�����ͬʱ��ΪFPGA��ǰ����״ָ̬ʾ��
	
	
	//��ʼ���Ĵ���
	initial
	begin
		count<=0;
		rec_state<=2'b11;//���ڿ���״̬��������״̬��
		data<=8'bzzzzzzzz;//ָʾ�Ƹ��費��
		sent_switch<=0;
	end
	
	
	//��������ģ��
	always @(posedge clk or posedge clr)
	begin
		//��λ���㶯��
		if(clr)
		begin
			rec_state<=2'b11;//���ڿ���״̬��������״̬��
			count<=0;//��ǰ����λ��
			sent_switch<=0;
			data<=8'bzzzzzzzz;//ָʾ�Ƹ��費��
		end
		//����Ϊ������ʱ�ӷ����Ķ���
		//��ǰ���ڿ���״̬���������λ��������rec_state�Ĵ�����
		else if(rec_state==2'b11)
			rec_state[0]<=rxd;
		//��ǰ���ڽ�������״̬���ҽ���λ��С��8���������λ��������data��λ�Ĵ�����
		else if(rec_state==2'b10 && count<8)
		begin
			data[7]<=data[6];
			data[6]<=data[5];
			data[5]<=data[4];
			data[4]<=data[3];
			data[3]<=data[2];
			data[2]<=data[1];
			data[1]<=data[0];
			data[0]<=rxd;//FPGA���յ������ݽ����λ
			count<=count+1;//����λ����¼
		end
		//��ǰ���ڽ�������״̬���ҽ���λ�����ڵ���8�����乤���ڿ���״̬����ս���λ����¼��
		else
		begin
			count<=0;
			rec_state<=2'b11;
			if(data[6]==0 && data[7]==0) sent_switch<=1;
			else sent_switch<=0;
		end
	end
	
endmodule


module serial_txd(
    input clk,			//������ʱ��
    input clr,			//ȫ�ָ�λ��
    input enable,		//����ʹ�ܶ�
    input [7:0]data,	//FPGA���ݷ���ʱ�������͵�����
    output reg txd	//FPGA���ݷ��Ͷ�
    );
	//�м��������
	//reg [7:0]reg_data;	//ԭʼ���ݵ���λ�Ĵ���
	reg [3:0] cnt;       //��������λ��������

	


always @(posedge clk or posedge clr)
      if(clr)
        cnt<=4'd0;                        //���ڷ��ͼ�������λ
      else if(enable==0)                    
        cnt<=4'd0;                        //��û�м�⵽���ڷ��ͱ�־λ����������ȴ�
      else if(enable==1)
        cnt<=(cnt>=10)?11:cnt+1; //��⵽���ڷ��ͱ�־λ������������
always @(posedge clk or posedge clr)
      if(clr)
        txd<=1'bz;              //���Ͷ˸�λ������̬        
  else 
        case (cnt)
    4'd0:txd<=1'bz;         
    4'd1:txd<=1'b0;         //������ʼλ
    4'd2:txd<=data[0];      //���͵�һλ
    4'd3:txd<=data[1];      //���͵ڶ�λ
    4'd4:txd<=data[2];      //���͵���λ
    4'd5:txd<=data[3];      //���͵���λ
    4'd6:txd<=data[4];      //���͵���λ
    4'd7:txd<=data[5];      //���͵���λ
    4'd8:txd<=data[6];      //���͵���λ
    4'd9:txd<=data[7];      //���͵ڰ�λ
    4'd10:txd<=1'b1;        //����ֹͣλ
    default:txd<=1'bz;
  endcase


endmodule