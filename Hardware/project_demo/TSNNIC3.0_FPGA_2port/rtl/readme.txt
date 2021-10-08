本目录下的rtl文件是TSNNic3.0的网络接口数目相关文件和器件相关文件，此示例工程是实例化2个接口（一个主机接口和一个网络接口）的TSN网卡工程。本目录中各个文件说明如下：
1.网络接口数目相关文件
network_input_process_top.v：网络接口输入处理逻辑实例化数目相关代码
network_output_process.v：    网络接口输出处理逻辑实例化数目相关代码
time_sensitive_end.v:               调用network_input_process_top.v和network_output_process.v，并根据网络接口数目实例化对应数量的gmii_adapter
tsnnic_top.v:                            调用time_sensitive_end.v
2.器件相关文件
除network_input_process_top.v，network_output_process.v，time_sensitive_end.v，tsnnic_top.v外，其他文件均为器件相关文件。