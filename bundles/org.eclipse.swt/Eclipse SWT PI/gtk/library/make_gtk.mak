#*******************************************************************************
# Copyright (c) 2000, 2003 IBM Corporation and others.
# All rights reserved. This program and the accompanying materials 
# are made available under the terms of the Common Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/cpl-v10.html
# 
# Contributors:
#     IBM Corporation - initial API and implementation
#*******************************************************************************

# Makefile for creating SWT libraries for Linux GTK

include make_common.mak

CC=gcc
LD=gcc

SWT_VERSION=$(maj_ver)$(min_ver)

# Define the installation directories for various products.
# Your system may have these in a different place.
#    JAVA_HOME   - IBM's version of Java

ifeq ($(SWT_PTR_CFLAGS),-DSWT_PTR_SIZE_64)
# 64 bit path
JAVA_HOME		= /bluebird/teamswt/swt-builddir/jdk1.5.0
AWT_LIB_PATH	= $(JAVA_HOME)/jre/lib/amd64
XTEST_LIB_PATH  = /usr/X11R6/lib64
else
# 32 bit path
JAVA_HOME		= /bluebird/teamswt/swt-builddir/IBMJava2-141
AWT_LIB_PATH	= $(JAVA_HOME)/jre/bin
XTEST_LIB_PATH  = /usr/X11R6/lib
endif

#  mozilla source distribution folder
MOZILLA_HOME = /mozilla/mozilla/1.6/linux_gtk2/mozilla/dist

# Define the various shared libraries to be build.
WS_PREFIX    		= gtk
SWT_PREFIX   		= swt
AWT_PREFIX		= swt-awt
SWTPI_PREFIX   	= swt-pi
ATK_PREFIX   		= swt-atk
GNOME_PREFIX	= swt-gnome
MOZILLA_PREFIX = swt-mozilla
SWT_LIB			= lib$(SWT_PREFIX)-$(WS_PREFIX)-$(SWT_VERSION).so
AWT_LIB			= lib$(AWT_PREFIX)-$(WS_PREFIX)-$(SWT_VERSION).so
SWTPI_LIB		= lib$(SWTPI_PREFIX)-$(WS_PREFIX)-$(SWT_VERSION).so
ATK_LIB				= lib$(ATK_PREFIX)-$(WS_PREFIX)-$(SWT_VERSION).so
GNOME_LIB		= lib$(GNOME_PREFIX)-$(WS_PREFIX)-$(SWT_VERSION).so
MOZILLA_LIB 	= lib$(MOZILLA_PREFIX)-$(WS_PREFIX)-$(SWT_VERSION).so

GTKCFLAGS = `pkg-config --cflags gtk+-2.0`
GTKLIBS = `pkg-config --libs gtk+-2.0 gthread-2.0` -L$(XTEST_LIB_PATH) -lXtst

AWT_LIBS      = -L$(AWT_LIB_PATH) -ljawt -shared

ATKCFLAGS = `pkg-config --cflags atk gtk+-2.0`
ATKLIBS = `pkg-config --libs atk gtk+-2.0`

GNOMECFLAGS = `pkg-config --cflags gnome-vfs-module-2.0 libgnome-2.0 libgnomeui-2.0`
GNOMELIBS = `pkg-config --libs gnome-vfs-module-2.0 libgnome-2.0 libgnomeui-2.0`

MOZILLACFLAGS = -O \
	-fno-rtti	\
	-Wall	\
	-I./ \
	-I$(JAVA_HOME)	\
	-include $(MOZILLA_HOME)/include/mozilla-config.h \
	-I$(MOZILLA_HOME)/include \
	-I$(MOZILLA_HOME)/include/xpcom \
	-I$(MOZILLA_HOME)/include/string \
	-I$(MOZILLA_HOME)/include/nspr \
	-I$(MOZILLA_HOME)/include/embed_base \
	-I$(MOZILLA_HOME)/include/gfx
MOZILLALIBS = -L$(MOZILLA_HOME)/lib -lembed_base_s -lxpcom
# Specify the default location of supported Mozilla versions
# for RedHat and Suse
MOZILLALDFLAGS = -s -Xlinker -rpath -Xlinker /usr/lib/mozilla-1.6 \
					-Xlinker -rpath -Xlinker /usr/lib/mozilla-1.5 \
					-Xlinker -rpath -Xlinker /usr/lib/mozilla-1.4.2 \
					-Xlinker -rpath -Xlinker /usr/lib/mozilla-1.4 \
					-Xlinker -rpath -Xlinker /opt/mozilla/lib

SWT_OBJECTS		= callback.o
AWT_OBJECTS		= swt_awt.o
SWTPI_OBJECTS	= os.o os_structs.o os_custom.o os_stats.o
ATK_OBJECTS		= atk.o atk_structs.o atk_custom.o atk_stats.o
GNOME_OBJECTS	= gnome.o gnome_structs.o gnome_stats.o
MOZILLA_OBJECTS = xpcom.o
 
CFLAGS = -O -Wall \
		-DSWT_VERSION=$(SWT_VERSION) \
		-DLINUX -DGTK \
		-I$(JAVA_HOME)/include \
		-fpic \
		${SWT_PTR_CFLAGS}

LIBS = -shared -fpic

#
#  Target Rules
#

all: make_swt make_atk make_gnome make_awt make_mozilla

all64: make_swt make_atk make_gnome make_awt

#
# SWT libs
#
make_swt: $(SWT_LIB) $(SWTPI_LIB)

$(SWT_LIB): $(SWT_OBJECTS)
	$(LD) $(LIBS) -o $(SWT_LIB) $(SWT_OBJECTS)

callback.o: callback.c callback.h
	$(CC) $(CFLAGS) -c callback.c

$(SWTPI_LIB): $(SWTPI_OBJECTS)
	$(LD) $(LIBS) $(GTKLIBS) -o $(SWTPI_LIB) $(SWTPI_OBJECTS)

os.o: os.c os.h swt.h os_custom.h
	$(CC) $(CFLAGS) $(GTKCFLAGS) -c os.c
os_structs.o: os_structs.c os_structs.h os.h swt.h
	$(CC) $(CFLAGS) $(GTKCFLAGS) -c os_structs.c 
os_custom.o: os_custom.c os_structs.h os.h swt.h
	$(CC) $(CFLAGS) $(GTKCFLAGS) -c os_custom.c
os_stats.o: os_stats.c os_structs.h os.h os_stats.h swt.h
	$(CC) $(CFLAGS) $(GTKCFLAGS) -c os_stats.c

#
# AWT lib
#
make_awt:$(AWT_LIB)

$(AWT_LIB): $(AWT_OBJECTS)
	$(LD) $(AWT_LIBS) -o $(AWT_LIB) $(AWT_OBJECTS)

#
# Atk lib
#
make_atk: $(ATK_LIB)

$(ATK_LIB): $(ATK_OBJECTS)
	$(LD) $(LIBS) $(ATKLIBS) -o $(ATK_LIB) $(ATK_OBJECTS)

atk.o: atk.c atk.h
	$(CC) $(CFLAGS) $(ATKCFLAGS) -c atk.c
atk_structs.o: atk_structs.c atk_structs.h atk.h
	$(CC) $(CFLAGS) $(ATKCFLAGS) -c atk_structs.c
atk_custom.o: atk_custom.c atk_structs.h atk.h
	$(CC) $(CFLAGS) $(ATKCFLAGS) -c atk_custom.c
atk_stats.o: atk_stats.c atk_structs.h atk_stats.h atk.h
	$(CC) $(CFLAGS) $(ATKCFLAGS) -c atk_stats.c

#
# Gnome lib
#
make_gnome: $(GNOME_LIB)

$(GNOME_LIB): $(GNOME_OBJECTS)
	$(LD) $(LIBS) $(GNOMELIBS) -o $(GNOME_LIB) $(GNOME_OBJECTS)

gnome.o: gnome.c 
	$(CC) $(CFLAGS) $(GNOMECFLAGS) -c gnome.c

gnome_structs.o: gnome_structs.c 
	$(CC) $(CFLAGS) $(GNOMECFLAGS) -c gnome_structs.c
	
gnome_stats.o: gnome_stats.c gnome_stats.h
	$(CC) $(CFLAGS) $(GNOMECFLAGS) -c gnome_stats.c
	
#
# Mozilla lib
#
make_mozilla:$(MOZILLA_LIB)

$(MOZILLA_LIB): $(MOZILLA_OBJECTS)
	$(CXX) $(LIBS) $(MOZILLALDFLAGS) -o $(MOZILLA_LIB) $(MOZILLA_OBJECTS) $(MOZILLALIBS)

xpcom.o: xpcom.cpp
	$(CXX) $(MOZILLACFLAGS) -c xpcom.cpp	

#
# Clean
#
clean:
	rm -f *.o *.so
