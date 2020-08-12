all: deps install

deps:
	yum install -y lua luarocks 

install:
	luarocks make

upgrade:
	luarocks make

deinstall:
	luarocks remove luaacd
