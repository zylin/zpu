UNISIM_DIR="'location of GHDL objects for unisim library'/unisim_v93"
IMPORT_OPTIONS="--std=93 --ieee=synopsys --workdir=work -P${UNISIM_DIR}"
MAKE_OPTIONS="${IMPORT_OPTIONS} -Wl,-s -fexplicit --syn-binding"
