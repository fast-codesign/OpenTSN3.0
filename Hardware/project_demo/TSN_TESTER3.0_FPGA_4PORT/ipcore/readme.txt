TSN网卡示例工程使用的quartus版本为Quartus Prime Standard Edition 19.1,使用的FPGA型号为Intel Arria10:10AX048H2F34E2SG，硬件逻辑源码中总共使用到10个ip核文件，IP核详细配置参数如下：
（1）IP核名称: clk125M_50M125M
    Reference Clock Frequency : 125.0 MHz
    Number Of Clocks : 2
    Clock Name of outclk0 : clk_50M
    Clock Name of outclk1 : clk_125M 
    PLL Bandwidth Preset : Low
    Others:default

（2）IP核名称: sgmii_pcs_share（生成三速以太网IP核后，需替换两个文件，详见./sgmii_pcs_revise_note）
    Core variation : 10/100/1000Mb Ethernet MAC with 1000BASE-X/sgmii pcs
    Component:10AX048H2F34I2SG
    Number of ports : 4
    Transceiver type : LVDS I/O
    PHY ID : 0x00000000
    Others:default

（3）IP核:2-port RAM
    IP核名称: ram_sdport_w128d32
    Operation Mode:With one read port and one write port
    Ram_width:128
    Ram_depth:32
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Others:default

（4）IP核:2-port RAM
    IP核名称: ram_sdport_w128d64
    Operation Mode:With one read port and one write port
    Ram_width:128
    Ram_depth:64
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Others:default

（5）IP核:2-port RAM
    IP核名称:  ram_sdport_separaterwclock_rdaclr_w8d16
    Operation Mode:With one read port and one write port
    Ram_width:8
    Ram_depth:16
    Clocking method : Single
    Clocking method:dual clock:use separate 'read' and 'write' clocks
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（6）IP核: FIFO
    IP核名称: fifo_w134d128_commonclock_sclr_showahead
    Operation Mode:With two read/write ports
    Ram_width:134
    Ram_depth:128
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
     Read access:show_ahead synchronous FIFO mode
    Reset:Synchronous clear
    Others:default


（7）IP核: FIFO
    IP核名称: fifo_w31d4_commonclock_sclr_showahead
    Operation Mode:With two read/write ports
    Ram_width:31
    Ram_depth:4
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
     Read access:show_ahead synchronous FIFO mode
    Reset:Synchronous clear
    Others:default

（8）IP核: FIFO
    IP核名称: fifo_w12d4_commonclock_sclr_showahead
    Operation Mode:With two read/write ports
    Ram_width:12
    Ram_depth:4
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
     Read access:show_ahead synchronous FIFO mode
    Reset:Synchronous clear
    Others:default

（9）IP核: FIFO
    IP核名称: fifo_w9d16_respectclock_aclr_showahead
    Operation Mode:With two read/write ports
    Ram_width:9
    Ram_depth:16
    Clock for reading and writing the FIFO : synchronize reading and writing to 'rdclk' and 'wrclk', respectively.
    Asynchronous clear: selected
    Read access:Normal synchronous FIFO mode
    Others:default

（10）IP核: FIFO
    IP核名称: DCFIFO_10bit_64
    Fifo_width:10
    Fifo_depth:64
    Clock for reading and writing the FIFO : synchronize reading and writing to 'rdclk' and 'wrclk', respectively.
    Asynchronous clear: selected
    Read access:Normal synchronous FIFO mode
    Others:default
