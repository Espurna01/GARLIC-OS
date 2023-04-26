#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------
ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

include $(DEVKITARM)/ds_rules

export TARGET		:=	$(shell basename $(CURDIR))
export TOPDIR		:=	$(CURDIR)

NITRODATA 			:=	nitrofiles 
export _ADDFILES	:=	-d $(CURDIR)/$(NITRODATA)


.PHONY: arm7/$(TARGET).elf arm9/$(TARGET).elf

#---------------------------------------------------------------------------------
# main targets
#---------------------------------------------------------------------------------

#---------------------------------------------------------------------------------
$(TARGET).nds	:	arm7/$(TARGET).elf arm9/$(TARGET).elf
	ndstool	-c $(TARGET).nds -7 arm7/$(TARGET).elf -9 arm9/$(TARGET).elf $(_ADDFILES)

#---------------------------------------------------------------------------------
arm7/$(TARGET).elf:
	$(MAKE) -C arm7
#---------------------------------------------------------------------------------
arm9/$(TARGET).elf:
	$(MAKE) -C arm9

#---------------------------------------------------------------------------------
clean:
	$(MAKE) -C arm9 clean
	$(MAKE) -C arm7 clean
	rm -f $(TARGET).nds $(TARGET).arm7 $(TARGET).arm9

#---------------------------------------------------------------------------------
run : $(TARGET).nds
	@echo "runing $(TARGET).nds with DesmuME"
	@$(DESMUME)/DeSmuME.exe $(TARGET).nds &

#---------------------------------------------------------------------------------
debug9 : $(TARGET).nds
	@echo "testing $(TARGET).nds/.elf with DeSmuME_dev/Insight (gdb) through TCP port=1000"
	$(DESMUME)/DeSmuME_dev.exe --arm9gdb=1000 $(TARGET).nds &
	$(DEVKITPRO)/insight/bin/arm-eabi-insight arm9/$(TARGET).elf &
	
#---------------------------------------------------------------------------------
debug7 : $(TARGET).nds
	@echo "testing $(TARGET).nds/.elf with DeSmuME_dev/Insight (gdb) through TCP port=1000"
	$(DESMUME)/DeSmuME_dev.exe --arm7gdb=1000 $(TARGET).nds &
	$(DEVKITPRO)/insight/bin/arm-eabi-insight arm7/$(TARGET).elf &
