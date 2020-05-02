TARGET	= mysh
CFLAGS	= -g -c -D_POSIX_C_SOURCE
CFLAGS += -std=c99 -Wimplicit-function-declaration -Werror
CFLAGS += # Add your own cflags here if necessary
LDFLAGS	=

all: mysh toy

mysh: pa1.o
	gcc $(LDFLAGS) $^ -o $@

toy: toy.o
	gcc $(LDFLAGS) $^ -o $@

%.o: %.c
	gcc $(CFLAGS) $< -o $@

.PHONY: clean
clean:
	rm -rf $(TARGET) toy *.o *.dSYM


.PHONY: test-run
test-run: $(TARGET) toy testcases/test-run
	./$< -q < testcases/test-run

.PHONY: test-cd
test-cd: $(TARGET) testcases/test-cd
	./$< -q < testcases/test-cd

.PHONY: test-for
test-for: $(TARGET) testcases/test-for
	./$< -q < testcases/test-for

.PHONY: test-prompt
test-prompt: $(TARGET) testcases/test-prompt
	./$< < testcases/test-prompt

.PHONY: test-parser
test-parser: $(TARGET) testcases/test-parser
	./$< < testcases/test-parser


test-all: test-prompt test-run test-cd test-prompt test-for
	echo
