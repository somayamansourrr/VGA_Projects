create_pblock pblock_host_client
add_cells_to_pblock [get_pblocks pblock_host_client] [get_cells -quiet [list host_client]]
resize_pblock [get_pblocks pblock_host_client] -add {SLICE_X30Y50:SLICE_X33Y99}
set_property IS_SOFT FALSE [get_pblocks pblock_host_client]
