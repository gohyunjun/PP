## Project #1: My Simple Shell

### *** Due on 11:59:59pm, May 3 (Sunday)***

### Goal
With the system calls learned in the class and a few additional ones, you are ready to manipulate processes in the system.
Let's build a simple shell program by leveraging the system calls.


### Background
- *Shell* is a program that interpretes user inputs, and processes them accordingly. The example includes the Command Prompt in Windows, Bourne Shell in Linux terminal, zsh in Mac terminal, so forth.

- An user can input a command by writing a sentence on the shell prompt. Upon receiving the input, the shell parses the requests into tokens, just as you did in PA0, and performs designated actions according to the first token.

- If the first token is one of *built-in* commands, the shell processes the command internally. In other words, the built-in command are processed without any other executable, but handled directly by the shell program.

- If the first token is not the built-in command, the shell assumes the first token as the name of the executable file to run.

- Each process has *environment variables* that defines the settings for the process. `PATH` is one of the environment variables that lists the directories to look up for the executable file. When the shell finds the executable from the directories in `PATH`, it launches the executable with the remaining tokens as the arguments for the executable.


### Problem Specification
- The shell program `mysh` waits for your command line input after printing out a prompt `$`. When you enter a line of command, it will be parsed into tokens in `parse_command()` as you did for project assignment 0, and the framework will call `run_command()` function with the tokens. You need to implement following features in these functions.
- Currently, the shell keep getting input commands from users, and exit the execution when the user enters `exit`. Technically speaking, the shell terminates itself upon the `exit` built-in command.


#### Change prompt (20 pts)
- `mysh` prints out the prompt using the contents in `char __prompt[]`. Implement `prompt` built-in command that changes the prompt as follow;

- ```
  $ prompt #
  # prompt ict332>
  ict332> prompt $
  $
  ```

- You may change `__prompt` value to implement this feature.


#### Execute external programs (100 pts)
- When the shell gets the command that is not the built-in commands (`prompt`, `cd`, `for`, and `exit`), it should run the executable as explained above. Each command can be comprised of one exeutable followed by zero or more arguments. For example;
- ```bash
  $ /bin/ls
  Makefile  pa1.c  parser.c  parser.o   toy    toy.o
  mysh   	  pa1.o  parser.h  README.md  toy.c  types.h
  $ ls
  Makefile  pa1.c  parser.c  parser.o   toy    toy.o
  mysh  	  pa1.o  parser.h  README.md  toy.c  types.h
  $ pwd
  /home/sanghoon/pa/os/pa1
  $ cp mysh mysh.copied
  $ ls
  Makefile  mysh.copied  pa1.o	   parser.h  README.md  toy.c  types.h
  mysh 	    pa1.c        parser.c  parser.o  toy	      toy.o
  $ exit
  ```
- `ls`, `pwd`, and `cp` are **NOT** built-in commands (These are external programs that lists the files in the directory, shows the current working directory, and copies files, respectively). Thus, the shell should execute the corresponding executable on the `PATH` environment variable. The p-variants of `exec()` command family will help you doing this. When the specified command cannot be executed, print out the following message to `stderr`.
- ```C
	if (unable to execute the specified command) {
		fprintf(stderr, "No such file or directory\n");
	}
  ```
- You should handle `stdin` and `stdout` of the child process properly in case `exec()` fails. Otherwise, supposed-to-be the input of the child is flushed into the parent process' `stdin`, making *ghost* input to the parent process. On mac, this will not be happened since BSD libc does not flush the buffered input on child's exit. Nevertheless, you will need to handle this issue to pass the test on PASubmit server.
- Use `toy` application which is included in the repository for your development and testing. It prints out the arguments so that you can check whether your implementation handles input commands properly.
- ```bash
  $ ./toy arg1 arg2 arg3 arg4
  pid  = xxxxxx
  argc = 5
  argv[0] = ./toy
  argv[1] = arg1
  argv[2] = arg2
  argv[3] = arg3
  argv[4] = arg4
  done!
	```


- Hint: `fork(), exec(), wait(), waitpid(), close()`, and `fflush()`

#### Change working directory (30 pts)
- Each process has so-called *working directory* on which the process is working. This value can be checked by executing `/bin/pwd` or calling `getcwd()` system call. Implement `cd` command which changes the current working directory.

- Each user has one's *home directory* which is denoted by `~`. The actual path is defined in `HOME` environment variable. Make `cd` command to understand it

- ```bash
  $ pwd
  /home/directory/of/your/account  # Assume this is the home directory of the user
  $ cd /somewhere/i/dont/know
  $ pwd
  /somewhere/i/dont/know
  $ cd ~
  $ pwd
  /home/directory/of/your/account
  ```

- Hints: `chdir(), getcwd(), getenv("HOME")`



#### Improve the parser (50 pts)
- The current `parse_command()` separates tokens at every whitespace. Improve this parser to handle the quoted tokens that are surrounded by quotation marks("") and may contain whitespaces.
- Suppose the input string is *"  We will get over with the "COVID 19" virus   "*, then the tokens are We, will, get, over, with, the, **COVID 19**, and virus. The token may contain whitespaces if it is quoted. Note that the tokens do not contain the quotation marks themselves though.
- The required functionality must be implemented in `parse_command()` function by editing/adding/replacing the current implementation. As of PA0, the user input is passed through `command`. After parsing `command` into tokens, the tokens should be assigned to `tokens[]` in order, which is passed as the argument of the `parse_command()` function. Also, the number of tokens should be assigined to `*nr_tokens` which will be used by the framework.
- The functionality of this work can be checked with the `toy` program explained above.



#### Repeat the command n times (50 pts)
- Implement `for <N> <command ...>` built-in command to run the commands N-times. `for` can be nested.

- ```
  $ for 5 pwd
  /home/pasubmit/some/directory/in/depth
  /home/pasubmit/some/directory/in/depth
  /home/pasubmit/some/directory/in/depth
  /home/pasubmit/some/directory/in/depth
  /home/pasubmit/some/directory/in/depth
  $ for 4 cd ..
  $ pwd
  /home/pasubmit
  $ for 2 for 3 echo hello world
  hello world
  hello world
  hello world
  hello world
  hello world
  hello world
  $ for 20 for 10 for 2 echo nested for
  nested for
  (... 398 more "nested for" ...)
  nested for
  $
  ```



### Restriction

- DO NOT USE `system()` system call. You will get 0 pts if it is used.
- Implement only `prompt`, `for`, `cd`, and `exit` as *built-in commands* (i.e., handle the features in the shell process), whereas other commands should be processed by *external processes* created with `fork()` and `exec()`. ***Implementing external program's features (e.g., printing out a message for handling `echo` command, handling arguments to emulate the `toy` etc) will be penalized with -250 pts***
- DO NOT TRY to figure out whether the code is under testing on the server by parsing the number of tokens and/or token contents. Such a forged execution will be screened offline and punished with -250 pts as well.
- It is advised to test your code on your computer first. You may submit your work to PASubmit as much as possible. However, it would be best to test your implementation on your local machine using `make test-run`,  `make test-cd`, `make test-for`, `make test-parser`, and `make test-prompt`. `make test-all` runs all the tests one after the other. Have a look at `Makefile` to learn making test automatic.
- You may put any initialization code and finialization code in `initialize()` and `finalize()`, respectively, in `pa1.c`. These functions are called by the framework automatically when the shell starts and finishes. For sure, you can leave them blank if you don't need any.
- For your coding practice, the compiler is set to halt on some (important) warnings. Write your code to comply the C99 standard.



### Submission / Grading

- Use [PAsubmit](https://sslab.ajou.ac.kr/pasubmit) for submission
	- 300 pts in total
- Source: pa1.c (250 pts in total)
  - Points will be prorated by testcase results.
- Document: *One PDF* document (50 pts) that must include followings;
  - How programs are launched and how arguments are passed
  - How the quoted tokens are handled
  - How the `for` built-in command is implemented
  - Lessons learned (if you have any)
  - You don't need to explain the code itself. Instead, focus on explaining your idea.
  - NO MORE THAN ***THREE*** PAGES 
  - DO NOT INCLUDE COVER PAGE. No need to specify your name nor student ID on the document.
  - YOU WILL NOT GET any pts for the document if you do not comply the statements.
- You don't need to register GIT repository.
- Free to make a question through AjouBb. However, YOU MIGHT NOT GET AN ANSWER IF THE QUESTIONS ARE ABOUT THOSE ALREADY SPECIFIED ON THIS HANDOUT.
- QUESTIONS OVER EMAIL WILL BE IGNORED unless it concerns your privacy.
