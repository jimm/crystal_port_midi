.PHONY: all examples test docs

all:	examples

examples:
	crystal build examples/list_devices.cr
	crystal build examples/note_send.cr
	crystal build examples/sysex_send_and_receive.cr

test:
	crystal spec

docs:
	crystal docs
