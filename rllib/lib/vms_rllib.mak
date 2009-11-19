######### makefile for the module #############################################
# history: rainer lehrig                                             25.09.1996
#
# for general settings see MAKE_DEFAULTS (logical name)
#
######### make.ini begin can be generated by IMAKE do not edit ################
includes = \
           rlevent.h          \
           rleventlogserver.h \
           rldataprovider.h   \
           rlcutil.h          \
           rldefine.h         \
           rlfifo.h           \
           rlinifile.h        \
           rlinterpreter.h    \
           rlmailbox.h        \
           rlpcontrol.h       \
           rlsharedmemory.h   \
           rlsocket.h         \
           rlspreadsheet.h    \
           rlthread.h         \
           rltime.h           \
           rlwthread.h

######### make.ini end ########################################################
#
######### specify here ########################################################

cflags  = $(cflags)
main    = rllib
objects = \
          $(lib)$(main).olb(rlevent)          \
          $(lib)$(main).olb(rleventlogserver) \
          $(lib)$(main).olb(rldataprovider)   \
          $(lib)$(main).olb(rlcutil)          \
          $(lib)$(main).olb(rlfifo)           \
          $(lib)$(main).olb(rlinifile)        \
          $(lib)$(main).olb(rlinterpreter)    \
          $(lib)$(main).olb(rlmailbox)        \
          $(lib)$(main).olb(rlpcontrol)       \
          $(lib)$(main).olb(rlsharedmemory)   \
          $(lib)$(main).olb(rlsocket)         \
          $(lib)$(main).olb(rlspreadsheet)    \
          $(lib)$(main).olb(rlthread)         \
          $(lib)$(main).olb(rltime)           \
          $(lib)$(main).olb(rlwthread) 

###### the following must not be changed ######################################

librarys       =  $(lib)$(main).olb     $(librarys)
library_string = ,$(lib)$(main).olb/lib $(library_string)
define         = ("makefile=$(makefile)"

%ifdef debug
debug  = _debug
lflags = $(lflags)/debug
define = $(define),"debug")
%else
debug  =
lflags = $(lflags)/nodebug
define = $(define))
%endif

%ifdef force
force  = yes
%else
force  = no
%endif

all:   $(exe)$(main)$(debug).exe $(uidfile)

$(resource).uid : $(resource).uil
       write sys$output "  Compiling file : $(resource).uil"
       uil/motif $(resource).uil
       ! ********* delete obj on error and severe error ****************
       if $severity .ne. 1
       then
         delete $(resource).uid;0
       endif

$(lib)$(main).olb : $(includes)
       write sys$output "  Creating: $(lib)$(main).olb"
       library/create/object $(lib)$(main).olb
       purge/keep=2          $(lib)$(main).olb
       if("$(force)" .eqs. "no")
       then ! some headers have changed -> level 2 make
         write sys$output "  start a level 2 make for $(lib)$(main).olb"
         make /input=$(makefile) /define=$(define)
         goto The_Exit
       endif

*_proc.cpp : *.pc
       write sys$output "proc $*.pc"
       proc $*.pc $*_proc.cpp

*_s.cpp : *.idl
       write sys$output "omniidl -bcxx -k -K -Wba -Wbs=_s.cpp -Wbd=_dynSK -Wbh=_s.hh $*.idl"
       omniidl -bcxx -k -K -Wba -Wbs=_s.cpp -Wbd=_dynSK -Wbh=_s.hh $*.idl

*_dynSK.cpp : *.idl
       write sys$output "omniidl dummy"

moc_*.cpp : *.h
       write sys$output "  moc $*.h -o moc_$*.cpp"
       moc $*.h -o moc_$*.cpp

$(lib)$(main).olb(*) : *.$(sf)
       write sys$output "  Compiling file : $*.$(sf)"
       $(compiler) $(cflags) $*.$(sf) /object=$(obj)$*.obj
       ! ********* delete obj on error and severe error ****************
       if $severity .ne. 1
       then
         delete $(obj)$*.obj;0
       else
         write sys$output "  Insert in lib  : $(lib)$(main).olb($*.obj)"
         library /replace $(lib)$(main).olb $(obj)$*.obj
         delete $(obj)$*.obj;*
       endif

$(obj)$(main).obj : $(main).$(sf) $(includes)
       write sys$output "  Compiling file : $(main).$(sf)"
       $(compiler) $(cflags) $(main).$(sf) /object=$(obj)$(main).obj
       ! ********* delete obj on error and severe error ****************
       if $severity .ne. 1
       then
         delete $(obj)$(main).obj;0
       endif

$(exe)$(main)$(debug).exe : $(librarys) $(objects) $(obj)$(main).obj
       write sys$output "  Linking module : $(exe)$(main)$(debug).exe"
       $(link)  $(lflags)           -
                $(obj)$(main).obj   -  
                $(library_string)   -
                $(option_string)    -
                /executable=$(exe)$(main)$(debug).exe
       ! ******* delete exe if no success ****************************
       if $severity .ne. 1
       then
         delete $(exe)$(main).exe;0
       endif 

clean:
       purge/log $(makefile)
       purge/log $(exe)$(main)$(debug).exe
       purge/log $(obj)$(main).obj
       purge/log $(lib)$(main).olb
       purge/log *.$(sf)

depend:
      $(imake_command) out=$(makefile)

print_help:
      write sys$output "-------------------------------------------------------"
      write sys$output "---- Commands in the makefile $(makefile)"
      write sys$output "-------------------------------------------------------"
      write sys$output "make <all>  ; makes program/library target"
      write sys$output "make clean  ; purges no longer needed files"
      write sys$output "make depend ; runs imake to create the make.ini section"
      write sys$output "            ; the symbol includes is defined"
      write sys$output "            ; includes depends on all included headers"
      write sys$output "-------------------------------------------------------"