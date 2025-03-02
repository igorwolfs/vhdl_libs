MODULES_DIR := ../../modules/verilog
TOP_NAME := uart_tb
SRC_DIR := ${MODULES_DIR}/uart/rtl
LIBS_DIR := $(MODULES_DIR)/encoding/bin2gray $(MODULES_DIR)/synchronization/double_ff_sync
SRC_DIRS = ${SRC_DIR} ${LIBS_DIR}
SRC_FILE := $(shell find $(SRC_DIRS) -name '*.vh') $(shell find $(SRC_DIRS) -name '*.svh') \
			$(shell find $(SRC_DIRS) -name '*.v') $(shell find $(SRC_DIRS) -name '*.sv') \

ifeq (${TOP_NAME}, uart_tx_tb)
    CPP_FILE = sim_main_uart_tx.cpp
else ifeq (${TOP_NAME}, uart_rx_tb)
    CPP_FILE = sim_main_uart_rx.cpp
else ifeq (${TOP_NAME}, uart_tb)
    CPP_FILE = sim_main_uart.cpp
endif

# Verilator options
VERILATOR_OPTS = -cc \
    -Wno-NULLPORT \
    -Wno-COMBDLY \
    -Wno-PINMISSING \
    -Wno-MODDUP \
    -Wno-UNOPTFLAT \
    -Wno-WIDTHEXPAND \
    --exe \
    --trace \
    --trace-structs \
    --build \
    --timing

 # Make sure to unset this warning when first compiling + check warnings (
 # -Wno-UNOPTFLAT

.PHONY: run clean

# target (binary name) : dependencies
obj_dir/V$(TOP_NAME): ${SRC_DIR}/* $(SRC_FILE)
	verilator $(VERILATOR_OPTS) ${CPP_FILE} $(SRC_FILE) -I$(SRC_DIR) --top $(TOP_NAME) -j `nproc`
#verilator	-cc	-Wno-NULLPORT	-Wno-COMBDLY	-Wno-PINMISSING	-Wno-MODDUP	--exe	--trace	--trace-structs	--build	--timing	src/sim_main.cpp	$(SRC_FILE)	-I$(SRC_DIR)	--top	$(TOP_NAME)	-j	`nproc`

run: obj_dir/V$(TOP_NAME)
	./obj_dir/V$(TOP_NAME)

print_sources:
	echo ${SRC_FILE}

clean:
	rm -rf obj_dir
