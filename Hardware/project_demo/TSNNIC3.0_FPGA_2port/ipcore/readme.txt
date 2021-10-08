TSN网卡示例工程使用的quartus版本为Quartus Prime Standard Edition 19.1,使用的FPGA型号为Intel Arria10:10AX048H2F34E2SG，硬件逻辑源码（包括核心代码、器件相关代码和接口相关代码）中总共使用到14个ip核文件，用户在搭建TSN网卡示例工程时，可根据下面的IP核配置参数说明信息来生成对应IP核，并将所有IP核的QSYS文件放置在当前路径下。
IP核配置参数说明信息如下：
（1）IP核：altera_iopll 
    ipcore_name:clk125M_50M125M
    Device Family:Arria 10
    Component:10AX048H2F34E2SG
    Speed Grade:2
    Reference Clock Frequency : 125.0 MHz
    Enable locked output port : selected
    Compensation Mode : direct
    Number Of Clocks : 2
    Clock Name of outclk0 : clk_50M
    Desired Frequency of outclk0 : 50.0 MHz
    Phase Shift Units of outclk0 : ps
    Desired Phase Shift of outclk0 : 0.0  
    Desired  Duty Cycle of outclk0 : 50.0%
    Clock Name of outclk1 : clk_125M
    Desired Frequency of outclk0 : 125.0 MHz
    Phase Shift Units of outclk0 : ps
    Desired Phase Shift of outclk0 : 0.0  
    Desired  Duty Cycle of outclk0 : 50.0%
    PLL Bandwidth Preset : Low
    Others:default

（2）IP核: altera_eth_tse （生成三速以太网IP核后，需替换两个文件，详见./sgmii_pcs_revise_note）
    ipcore_name:sgmii_pcs_share
    Core variation : 10/100/1000Mb Ethernet MAC with 1000BASE-X/sgmii pcs
    Component:10AX048H2F34E2SG
    Use internal fifo：deseclect（不勾选Use internal fifo）
    Number of ports : 4
    Transceiver type : LVDS I/O
    PHY ID : 0x00000000
    Others:default


（3）IP核:2-port RAM
    ipcore_name:asdprf16x8_rq
    Operation Mode:With one read port and one write port
    Ram_width:8
    Ram_depth:16
    Clocking method:dual clock:use separate 'read' and 'write' clocks
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（4）IP核:2-port RAM
    ipcore_name:asdprf16x9_rq
    Operation Mode:With one read port and one write port
    Ram_width:9
    Ram_depth:16
    Clocking method:dual clock:use separate 'read' and 'write' clocks
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（5）IP核: FIFO
    ipcore_name:DCFIFO_10bit_64
    Fifo_width:10
    Fifo_depth:64
    Clock for reading and writing the FIFO : synchronize reading and writing to 'rdclk' and 'wrclk', respectively.
    Asynchronous clear: selected
    Read access:Normal synchronous FIFO mode
    Others:default

（6）IP核: FIFO
    ipcore_name:dcm_fifo9x256
    Fifo_width:9
    Fifo_depth:256
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
    Read access:show_ahead synchronous FIFO mode
    Reset:Asynchronous clear
    Others:default

（7）IP核:FIFO
    ipcore_name:fifo_35x4
    Fifo_width:35
    Fifo_depth:4
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
    Read access:show_ahead synchronous FIFO mode
    Reset:Asynchronous clear
    Others:default

（8）IP核:2-port RAM
    ipcore_name:ram_32_131
    Operation Mode:With two read/write ports
    Ram_width:131
    Ram_depth:32
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Others:default

（9）IP核:2-port RAM
    ipcore_name:ram_62_256
    Operation Mode:With two read/write ports
    Ram_width:62
    Ram_depth:256
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Others:default

（10）IP核:2-port RAM
    ipcore_name:sdprf16x23_s
    Operation Mode:With one read port and one write port
    Ram_width:23
    Ram_depth:16
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（11）IP核:2-port RAM
    ipcore_name:sdprf16x57_s
    Operation Mode:With one read port and one write port
    Ram_width:57
    Ram_depth:16
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（12）IP核:2-port RAM
    ipcore_name:sdprf512x9_s
    Operation Mode:With one read port and one write port
    Ram_width:9
    Ram_depth:512
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（13）IP核:2-port RAM
    ipcore_name:suhddpsram65536x134_s
    Operation Mode:With two read/write ports
    Ram_width:134
    Ram_depth:65536
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Output aclrs:"q_a port" and "q_b port" are both selected
    Others:default

（14）IP核:2-port RAM
    ipcore_name:suhddpsram512x4_rq
    Operation Mode:With two read/write ports
    Ram_width:4
    Ram_depth:512
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Output aclrs:"q_a port" and "q_b port" are both selected
    Others:default

