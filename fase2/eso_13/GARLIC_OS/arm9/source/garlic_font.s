
@;{{BLOCK(garlic_font)

@;=======================================================================
@;
@;	garlic_font, 1024x8@8, 
@;	+ palette 256 entries, not compressed
@;	+ 128 tiles lz77 compressed
@;	Total size: 512 + 1080 = 1592
@;
@;	Time-stamp: 2015-09-03, 16:56:28
@;	Exported by Cearn's GBA Image Transmogrifier, v0.8.6
@;	( http://www.coranac.com/projects/#grit )
@;
@;=======================================================================

	.section .rodata
	.align	2
	.global garlic_fontTiles		@; 1080 bytes
garlic_fontTiles:
	.hword 0x0010,0x0020,0x003D,0xF000,0xF001,0xF001,0x9001,0xFF05
	.hword 0x07F0,0xF0FF,0xF007,0x702F,0x303E,0x5030,0xF007,0xF001
	.hword 0xF001,0x9F3F,0x4750,0xFFFF,0x0120,0x0FF0,0x67F0,0xBFC0
	.hword 0x26C0,0x10FF,0x9049,0x4060,0xF055,0x50BF,0x00ED,0x30F6
	.hword 0x6070,0xFF50,0x9F60,0x8E30,0x0730,0x38F0,0x96C0,0x75A0
	.hword 0x5250,0xCB30,0x50FF,0xB196,0xF151,0xF067,0xF001,0xF001
	.hword 0xC040,0xE0DE,0xFF56,0x08F0,0x16F0,0x39F0,0x5FF0,0x7EF0
	.hword 0x1E41,0x0540,0xF950,0x31FF,0x407F,0x600F,0xF01F,0xF040

	.hword 0xA16E,0xF0F7,0xF11F,0xFF01,0x01F0,0xA0F1,0xBE71,0xC8F0
	.hword 0x01F0,0x7F80,0x01F0,0x01F0,0xF0FF,0xF001,0xE001,0xF187
	.hword 0xF0C1,0xF006,0xF006,0x7256,0xFF68,0x07A0,0x4043,0x03C0
	.hword 0x1773,0x3FE3,0x67F1,0x07F0,0x3FF0,0xC0FF,0xF07F,0xC3AB
	.hword 0xD14E,0xF056,0x533F,0xA2E8,0xF099,0xFFBF,0x80F3,0x8872
	.hword 0x67A0,0xC0F0,0xE8D1,0x24F0,0x2F84,0x7FF0,0xF0FF,0xC0FF
	.hword 0x8423,0xF16F,0xE07F,0xF2FE,0xF098,0xF006,0xFF07,0x7FF0
	.hword 0x67F0,0x17F0,0xBFF0,0x27F0,0x8173,0xFFF0,0x3FF0,0xF2FF

	.hword 0xF1DF,0xF09F,0xF017,0xF001,0xF027,0xF117,0xF018,0xFF0F
	.hword 0x1DF0,0x08F0,0x7DF0,0xF7F3,0x0FF0,0x01F0,0x55F0,0x08F0
	.hword 0xF0FF,0xF106,0xF2BF,0xF0FF,0xF006,0xF071,0x463F,0xB3AE
	.hword 0xFFFF,0xDFB2,0xFFF1,0xFFF1,0x7867,0x17F0,0xA7A0,0xE7F2
	.hword 0x3FB0,0xF0FF,0xB317,0xF057,0xF27F,0xD2E6,0xF383,0xF03F
	.hword 0xF03F,0xFF03,0x7FF0,0xFFF3,0xFFF3,0x87F0,0xBFF4,0x3FF0
	.hword 0x17F0,0x47F0,0xF0FF,0xF0FF,0xF1FF,0xF07F,0xF0FF,0xF11F
	.hword 0xF0BF,0xF503,0xFF7F,0xA1F0,0x07F0,0x3EF5,0x40F0,0x07F0

	.hword 0xF587,0xD6D5,0xBFF0,0xB5FF,0x50BF,0xF14C,0xF3DF,0xF00E
	.hword 0xF007,0xF507,0x60D8,0xFF93,0xE349,0xBC38,0xB298,0x73BA
	.hword 0x837A,0xBFF0,0xE469,0x7763,0x60FF,0xF0CF,0xF1E3,0xF03E
	.hword 0xF023,0xF103,0xF1FF,0xF128,0xFF40,0x07F1,0x3FF0,0x67F0
	.hword 0x03F0,0x7FE0,0x3341,0x3FF0,0x17B0,0xF1FF,0xF0C7,0xF1FF
	.hword 0x921B,0xF067,0xF37F,0xF07F,0xF0E0,0xFF07,0x00F1,0xB7F0
	.hword 0x03F0,0x7FF0,0x3FF0,0x03F0,0xAFFC,0x7FF0,0x92FF,0xD27F
	.hword 0xD25F,0xF047,0xF04F,0xA17F,0xFC70,0xF188,0xFF63,0x17F0

	.hword 0x3FF0,0x07F0,0x30F7,0xB7F6,0x06F0,0x2FF0,0xBFE2,0xF0FF
	.hword 0xF007,0xD907,0xF0BE,0xF008,0xF008,0xF008,0xF07F,0xFF69
	.hword 0x07F0,0x7FF0,0x67F1,0xDFE2,0x01F0,0x01F0,0x01F0,0x01F0
	.hword 0xF8FF,0xD7A7,0xF0D8,0xF025,0xF001,0xF101,0xA907,0xF2FF
	.hword 0xFF1F,0xC0CE,0x9FF1,0x8FF4,0x988B,0x4E4F,0x01F0,0x0FF4
	.hword 0x5EF0,0xF1FF,0xF07F,0x8423,0xF050,0x4F07,0xF0E9,0xF081
	.hword 0xF77F,0xFF47,0x7FF0,0x7FBC,0xDEAE,0x15F7,0xA6F1,0x01F0
	.hword 0x5F71,0x77F1,0xC3FF,0xF167,0x9627,0x86CA,0xF08F,0xF003

	.hword 0xF082,0xF098,0xFF59,0xC0F0,0x2FF0,0x0FF0,0x07F0,0xDDBD
	.hword 0x1DF0,0xEEC4,0x5EB3,0x71FF,0xDCC6,0xF01E,0xF049,0xF007
	.hword 0xE0A7,0x12B3,0x57DD,0xFFFC,0x07F8,0xFFF7,0x41F0,0x0FF2
	.hword 0x07F0,0x38F0,0x7FF2,0x03F0,0xF6FF,0xF07F,0xF001,0xF87F
	.hword 0xF00F,0xB1C3,0xA94F,0xF487,0xFFF7,0x41F0,0x7FF0,0xDFF1
	.hword 0x34F0,0x01F0,0xD7F2,0x0E9E,0xFEF0,0xF2FF,0xF36F,0xF078
	.hword 0xF007,0xB03B,0xF145,0xF4AE,0xF03E,0xFF01,0x4FF7,0x57F7
	.hword 0x7FF0,0x3EF0,0xEBE7,0x0C68,0x17A4,0x01F0,0xDDFF,0xF827

	.hword 0xF607,0xF09F,0xF001,0xF2F8,0xF100,0xFD88,0xFF8F,0x00F8
	.hword 0x7EFB,0x3FD5,0x2EF0,0x17F0,0x40EC,0xDFF1,0x07F0,0xF0FF
	.hword 0xF407,0xF03E,0xF21F,0xF047,0xF07D,0x96FF,0xF00D,0xFF32
	.hword 0x2DF1,0x01F0,0x01F0,0x01F0,0x0A50,0xBBF0,0x07F0,0x07F0
	.hword 0xF2FF,0xF001,0xF001,0xF001,0xF0B7,0xF056,0xF007,0xCA07
	.hword 0xFF0C,0x11F2,0x01F0,0x01F0,0x50F0,0x07F0,0x07F0,0x78D0
	.hword 0x1EF0,0xF0FF,0xF007,0xF107,0xF0B6,0xF027,0xF007,0x8007
	.hword 0xF047,0xFF20,0x07F0,0x07F0,0x13F0,0x07F0,0x07F0,0x43F0

	.hword 0x01F0,0x27F1,0xF0FF,0xF001,0xF001,0xCE01,0xF021,0xF007
	.hword 0xF107,0xF024,0xFF7F,0x03F2,0x07F0,0xBD99,0x01F0,0x01F0
	.hword 0x01F0,0xDDFC,0x07F0,0xF0FF,0xE007,0xF07F,0xF1FF,0xF07F
	.hword 0xE101,0xF07F,0xF03F,0xFF07,0x07F0,0x7FF1,0x07F0,0x07F0
	.hword 0xBFF0,0x01F0,0x7FF1,0x07F0,0xF1FF,0xF03F,0xF007,0xC0AF
	.hword 0xF0AF,0xF1BF,0xF13F,0xF02F,0xFF0F,0x01F0,0xAFF0,0x6FC1
	.hword 0x7FF1,0x07F0,0xEFF0,0x0FF0,0x2FF0,0xEEFF,0xF084,0xF0A7
	.hword 0xF001,0xF527,0xF048,0xF463,0xF070,0xFF3F,0x40C0,0x07F0

	.hword 0x3FF0,0x3FF0,0x8170,0x07F0,0x9B6D,0x3FF0,0xC5FF,0xA150
	.hword 0xF0F3,0xF007,0xD53F,0x9D90,0xF0B5,0xF007,0xFF3F,0xD0E5
	.hword 0x5E5F,0x07F0,0x3FF0,0x3FF0,0x202F,0x07F0,0x0790,0xF0F0
	.hword 0xF73F,0xF0D9,0xF601,0x006F
	.size	garlic_fontTiles, .-garlic_fontTiles

	.section .rodata
	.align	2
	.global garlic_fontPal		@; 512 bytes
garlic_fontPal:
	.hword 0x0000,0x0000,0x0000,0x0001,0x0001,0x0002,0x0002,0x0003
	.hword 0x0003,0x0004,0x0004,0x0005,0x0005,0x0006,0x0006,0x0007
	.hword 0x0007,0x0008,0x0008,0x0009,0x0009,0x000A,0x000A,0x000B
	.hword 0x000B,0x000C,0x000C,0x000D,0x000D,0x000E,0x000E,0x000F
	.hword 0x000F,0x0010,0x0010,0x0011,0x0011,0x0012,0x0012,0x0013
	.hword 0x0013,0x0014,0x0014,0x0015,0x0015,0x0016,0x0016,0x0017
	.hword 0x0017,0x0018,0x0018,0x0019,0x0019,0x001A,0x001A,0x001B
	.hword 0x001B,0x001C,0x001C,0x001D,0x001D,0x001E,0x001E,0x001F

	.hword 0x001F,0x001E,0x003D,0x005C,0x007B,0x009A,0x00B9,0x00D8
	.hword 0x00F7,0x0116,0x0135,0x0154,0x0173,0x0192,0x01B1,0x01D0
	.hword 0x01EF,0x020E,0x022D,0x024C,0x026B,0x028A,0x02A9,0x02C8
	.hword 0x02E7,0x0306,0x0325,0x0344,0x0363,0x0382,0x03A1,0x03C0
	.hword 0x03E0,0x03C0,0x07A0,0x0B80,0x0F60,0x1340,0x1720,0x1B00
	.hword 0x1EE0,0x22C0,0x26A0,0x2A80,0x2E60,0x3240,0x3620,0x3A00
	.hword 0x3DE0,0x41C0,0x45A0,0x4980,0x4D60,0x5140,0x5520,0x5900
	.hword 0x5CE0,0x60C0,0x64A0,0x6880,0x6C60,0x7040,0x7420,0x7800

	.hword 0x7C00,0x7C00,0x7C20,0x7C40,0x7C60,0x7C80,0x7CA0,0x7CC0
	.hword 0x7CE0,0x7D00,0x7D20,0x7D40,0x7D60,0x7D80,0x7DA0,0x7DC0
	.hword 0x7DE0,0x7E00,0x7E20,0x7E40,0x7E60,0x7E80,0x7EA0,0x7EC0
	.hword 0x7EE0,0x7F00,0x7F20,0x7F40,0x7F60,0x7F80,0x7FA0,0x7FC0
	.hword 0x7FE0,0x7FC0,0x7FA1,0x7F82,0x7F63,0x7F44,0x7F25,0x7F06
	.hword 0x7EE7,0x7EC8,0x7EA9,0x7E8A,0x7E6B,0x7E4C,0x7E2D,0x7E0E
	.hword 0x7DEF,0x7DD0,0x7DB1,0x7D92,0x7D73,0x7D54,0x7D35,0x7D16
	.hword 0x7CF7,0x7CD8,0x7CB9,0x7C9A,0x7C7B,0x7C5C,0x7C3D,0x7C1E

	.hword 0x7C1F,0x781F,0x743F,0x705F,0x6C7F,0x689F,0x64BF,0x60DF
	.hword 0x5CFF,0x591F,0x553F,0x515F,0x4D7F,0x499F,0x45BF,0x41DF
	.hword 0x3DFF,0x3A1F,0x363F,0x325F,0x2E7F,0x2A9F,0x26BF,0x22DF
	.hword 0x1EFF,0x1B1F,0x173F,0x135F,0x0F7F,0x0B9F,0x07BF,0x03DF
	.hword 0x03FF,0x03FF,0x07FF,0x0BFF,0x0FFF,0x13FF,0x17FF,0x1BFF
	.hword 0x1FFF,0x23FF,0x27FF,0x2BFF,0x2FFF,0x33FF,0x37FF,0x3BFF
	.hword 0x3FFF,0x43FF,0x47FF,0x4BFF,0x4FFF,0x53FF,0x57FF,0x5BFF
	.hword 0x5FFF,0x63FF,0x67FF,0x6BFF,0x6FFF,0x73FF,0x77FF,0x7BFF
	.size	garlic_fontPal, .-garlic_fontPal

@;}}BLOCK(garlic_font)