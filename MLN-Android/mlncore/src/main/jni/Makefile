
WHAT = A

all: $(WHAT)

A:
	cd lua && $(MAKE)
	@mv -f ./lua/liblua.a ./sys/
	cd luasocket && $(MAKE)
	@mv -f ./luasocket/libmlsocket.a ./sys/
	cd japi && $(MAKE)
	@mv -f ./japi/libluajapi.so ./sys/
	@rm -f ./japi/*.o