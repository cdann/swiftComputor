# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: cdannapp <cdannapp@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2017/04/16 21:34:00 by cdannapp          #+#    #+#              #
#    Updated: 2017/04/12 14:15:29 by cdannapp         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = pana

SRC = PanagramTuto/Panagram.swift
SRC += PanagramTuto/ConsoleIO.swift
SRC += PanagramTuto/OptionType.swift
SRC += PanagramTuto/extension.swift
SRC += PanagramTuto/main.swift
#SRC += FileParser.cpp
#SRC += Exceptions/OperandException.cpp

#MAIN += PanagramTuto/main.swift
# CFLAGS = -Wall -Werror -Wextra

OBJ = $(SRC:.swift=.o)
# OBJMAIN = $(MAIN:.swift=.o)

# MACOSX = $(xcrun --show-sdk-path)

SDK = -sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk


all : $(NAME)

%.o:%.swift
	swift -frontend  -c $(SDK) -emit-object -primary-file $< $(SRC) -o $@

#swift -frontend -c -sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk -emit-object -primary-file PanagramTuto/ConsoleIO.swift PanagramTuto/main.swift
$(NAME): $(OBJ) $(OBJMAIN)
	swiftc  $(OBJ) -o $(NAME)

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

test: $(OBJ) test.o
	clang++ -o test $(OBJ) test.o $(INCLUDE)

re: fclean all
