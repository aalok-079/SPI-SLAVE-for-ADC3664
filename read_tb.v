module spi_tb();
reg sclk; // clock line given by master
wire sdio; // bidirectional transaction line
reg sdio_reg_m; // register used to transfer data from MASTER to SLAVE
reg sen; // transaction enable line
reg reset; // reset pin
reg decide=1'b0; // this variable is used to decide whether sdio will work as input or output line
reg [7:0]data_store=8'b0; // this register stores data coming from SLAVE in MASTER
integer i,j; // variables for running loop
reg [15:0] in = 16'b1000101000001101; //input register which contains all the bits that are to be sent
spi S1(.sclk(sclk),.sdio(sdio),.sen(sen),.reset(reset)); // declaration of spi module

assign sdio = (decide)? 1'hz : sdio_reg_m ; //line to control whether the sdio will act as input or output

initial begin
S1.memory[2573] = 8'b10110011; //storing of data at memory location so we can fetch in read operation from SLAVE
 sen=1'b1;
 sclk=1'b1;

 forever #50 sclk = ~sclk; //clock period of 100
 end
 
 
initial begin
 reset=1'b0;
 #50
 reset=1'b1;
 #40
 reset=1'b0;
 #110
 sen=1'b0;
 for(i=0;i<16;i=i+1) begin // for loop to send 16 bits sequentially containing read or write bit + 3 bits and other 12 bits of address
 if(i<15) begin //for srnding first 15 bits as it is
 sdio_reg_m=in[15-i];

 #100;
 end
 else begin  // at 16 bit sdio will change from input to SLAVE to output from SLAVE
 sdio_reg_m=in[15-i];
 #1 //this delay is give so as to store last bit address and then change mode of sdio line
 decide=1'b1;
 #50;
 end
 
end
 
 #50; // wait for posedge to capture sent by SLAVE on previous negedge
 
for(j=0;j<8;j=j+1) begin //for loop to recieve data from SLAVE
    data_store[7-j] = sdio;
    #100;
end

 sen=1'b1; // making sen high to disable transaction after successful transfer
 #100
 $finish;
end

// printing signals for monitoring
initial begin
    $monitor("Time=%0t | sclk=%b sdio=%b sen=%b  reset=%b state=%b address=%b bit_counter=%b  data_count=%b sdio_reg =%b, data=%b bits=%b",
              $time, sclk, sdio, sen, reset, S1.state, S1.address, S1.bit_counter,S1.data_count_r,S1.sdio_reg_s,data_store,S1.bit_24_reg);
              $display("mem =%b",S1.memory[2573]);
end

// dumping of data in file
initial begin
 $dumpfile("read.vcd"); // specifies the VCD file
 $dumpvars(0, spi_tb); //dump all the variables
end


endmodule

