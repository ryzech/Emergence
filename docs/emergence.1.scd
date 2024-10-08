EMERGENCE(1)

# NAME

Emergence - NixOS-Like generations for gentoo, but in zig!

# SYNOPSIS

*emergence* [_options_] _command_ [_command specific arguments_]

# DESCRIPTION

*emergence* is a command-line utility used to create generations and rollback
changes made, like NixOS.

# OPTIONS

*-h*, *--help*
	Print a help message and exit.

*-v*, *--version*
	Print the version number and exit.

# COMMANDS

## gen

Configure and modify generations.

*list*
	List all generations in output.

*create*
	Create a new generation.

	*-m*, *--message*
		Message to be displayed in the list command, should be changes between the
		last generation and this. If applicable.

## init

Create new configuration, will not overwrite existing.

