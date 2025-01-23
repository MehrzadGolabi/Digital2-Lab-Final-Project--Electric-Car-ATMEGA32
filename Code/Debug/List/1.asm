
;CodeVisionAVR C Compiler V3.14 Advanced
;(C) Copyright 1998-2014 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Build configuration    : Debug
;Chip type              : ATmega32
;Program type           : Application
;Clock frequency        : 8.000000 MHz
;Memory model           : Small
;Optimize for           : Size
;(s)printf features     : int, width
;(s)scanf features      : int, width
;External RAM size      : 0
;Data Stack size        : 512 byte(s)
;Heap size              : 0 byte(s)
;Promote 'char' to 'int': Yes
;'char' is unsigned     : Yes
;8 bit enums            : Yes
;Global 'const' stored in FLASH: Yes
;Enhanced function parameter passing: Yes
;Enhanced core instructions: On
;Automatic register allocation for global variables: On
;Smart register allocation: On

	#define _MODEL_SMALL_

	#pragma AVRPART ADMIN PART_NAME ATmega32
	#pragma AVRPART MEMORY PROG_FLASH 32768
	#pragma AVRPART MEMORY EEPROM 1024
	#pragma AVRPART MEMORY INT_SRAM SIZE 2048
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x60

	#define CALL_SUPPORTED 1

	.LISTMAC
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU USR=0xB
	.EQU UDR=0xC
	.EQU SPSR=0xE
	.EQU SPDR=0xF
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E
	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUCR=0x35
	.EQU GICR=0x3B
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __SRAM_START=0x0060
	.EQU __SRAM_END=0x085F
	.EQU __DSTACK_SIZE=0x0200
	.EQU __HEAP_SIZE=0x0000
	.EQU __CLEAR_SRAM_SIZE=__SRAM_END-__SRAM_START+1

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ANDI R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ORI  R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __CLRD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+(@1))
	LDI  R31,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	LDI  R22,BYTE3(2*@0+(@1))
	LDI  R23,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTW2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	LDI  R24,BYTE3(2*@0+(@1))
	LDI  R25,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+(@2))
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+(@3))
	LDI  R@1,HIGH(@2+(@3))
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+(@3))
	LDI  R@1,HIGH(@2*2+(@3))
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+(@1)
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+(@1)
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	LDS  R22,@0+(@1)+2
	LDS  R23,@0+(@1)+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+(@2)
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+(@3)
	LDS  R@1,@2+(@3)+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+(@1)
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	LDS  R24,@0+(@1)+2
	LDS  R25,@0+(@1)+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+(@1),R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	STS  @0+(@1)+2,R22
	STS  @0+(@1)+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+(@1),R0
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+(@1),R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+(@1),R@2
	STS  @0+(@1)+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTBSR
	STD  Y+@1,R@0
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	PUSH R26
	PUSH R27
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMRDW
	POP  R27
	POP  R26
	ICALL
	.ENDM

	.MACRO __CALL2EX
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	CALL __EEPROMRDD
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R30,SPL
	IN   R31,SPH
	ADIW R30,@0+1
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1STACK
	IN   R30,SPL
	IN   R31,SPH
	ADIW R30,@0+1
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z
	MOVW R30,R0
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __GETBRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	LD   R@0,X
	.ENDM

	.MACRO __GETWRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	LD   R@0,X+
	LD   R@1,X
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	ST   Z,R@0
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

;NAME DEFINITIONS FOR GLOBAL VARIABLES ALLOCATED TO REGISTERS
	.DEF _fuel_level=R4
	.DEF _fuel_level_msb=R5
	.DEF _speed_value=R6
	.DEF _speed_value_msb=R7
	.DEF _steering_value=R8
	.DEF _steering_value_msb=R9
	.DEF _brake_applied=R10
	.DEF _brake_applied_msb=R11
	.DEF _headlights_on=R12
	.DEF _headlights_on_msb=R13

	.CSEG
	.ORG 0x00

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  0x00
	JMP  0x00
	JMP  _ext_int2_isr
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _timer0_ovf_isr
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _twi_int_handler
	JMP  0x00

_tbl10_G100:
	.DB  0x10,0x27,0xE8,0x3,0x64,0x0,0xA,0x0
	.DB  0x1,0x0
_tbl16_G100:
	.DB  0x0,0x10,0x0,0x1,0x10,0x0,0x1,0x0

;REGISTER BIT VARIABLES INITIALIZATION
__REG_BIT_VARS:
	.DW  0x0000

;GLOBAL REGISTER VARIABLES INITIALIZATION
__REG_VARS:
	.DB  0x64,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0

_0x0:
	.DB  0x25,0x30,0x32,0x64,0x3A,0x25,0x30,0x32
	.DB  0x64,0x3A,0x25,0x30,0x32,0x64,0x0,0x54
	.DB  0x69,0x6D,0x65,0x3A,0x20,0x0,0x69,0x6E
	.DB  0x74,0x65,0x72,0x72,0x75,0x70,0x74,0x20
	.DB  0x32,0xA,0xD,0x0,0x5B,0x44,0x42,0x47
	.DB  0x5D,0x20,0x42,0x72,0x61,0x6B,0x65,0x20
	.DB  0x61,0x70,0x70,0x6C,0x69,0x65,0x64,0x2E
	.DB  0xD,0xA,0x0,0x5B,0x44,0x42,0x47,0x5D
	.DB  0x20,0x42,0x72,0x61,0x6B,0x65,0x20,0x72
	.DB  0x65,0x6C,0x65,0x61,0x73,0x65,0x64,0x2E
	.DB  0xD,0xA,0x0,0x53,0x79,0x73,0x74,0x65
	.DB  0x6D,0x20,0x49,0x6E,0x69,0x74,0x2E,0x2E
	.DB  0x2E,0xD,0xA,0x0,0x54,0x63,0x72,0x69
	.DB  0x74,0x3D,0x37,0x30,0x43,0x0,0x20,0x4D
	.DB  0x65,0x68,0x72,0x7A,0x61,0x64,0x47,0x6F
	.DB  0x6C,0x61,0x62,0x69,0x0,0x41,0x5A,0x20
	.DB  0x44,0x69,0x67,0x69,0x74,0x61,0x6C,0x32
	.DB  0x20,0x70,0x72,0x6A,0x0,0x20,0x55,0x73
	.DB  0x65,0x20,0x74,0x68,0x65,0x20,0x62,0x75
	.DB  0x74,0x74,0x6F,0x6E,0x73,0x0,0x74,0x6F
	.DB  0x20,0x6E,0x61,0x76,0x69,0x67,0x61,0x74
	.DB  0x65,0x20,0x6D,0x65,0x6E,0x75,0x0,0x53
	.DB  0x70,0x65,0x65,0x64,0x3D,0x25,0x64,0x2C
	.DB  0x20,0x53,0x74,0x65,0x65,0x72,0x69,0x6E
	.DB  0x67,0x3D,0x25,0x64,0x2C,0x20,0x54,0x65
	.DB  0x6D,0x70,0x3D,0x25,0x64,0x2C,0x20,0x46
	.DB  0x75,0x65,0x6C,0x3D,0x25,0x64,0x2C,0x20
	.DB  0x64,0x69,0x72,0x65,0x63,0x74,0x69,0x6F
	.DB  0x6E,0x46,0x6C,0x61,0x67,0x3D,0x25,0x64
	.DB  0x20,0x2C,0x20,0x42,0x72,0x61,0x6B,0x65
	.DB  0x3D,0x25,0x64,0xD,0xA,0x0,0x5B,0x44
	.DB  0x42,0x47,0x5D,0x20,0x4B,0x65,0x79,0x31
	.DB  0x20,0x3D,0x3E,0x20,0x6D,0x65,0x6E,0x75
	.DB  0x3D,0x25,0x64,0xD,0xA,0x0,0x5B,0x44
	.DB  0x42,0x47,0x5D,0x20,0x4B,0x65,0x79,0x32
	.DB  0x20,0x3D,0x3E,0x20,0x6D,0x65,0x6E,0x75
	.DB  0x3D,0x25,0x64,0xD,0xA,0x0,0x5B,0x44
	.DB  0x42,0x47,0x5D,0x20,0x4B,0x65,0x79,0x33
	.DB  0x20,0x3D,0x3E,0x20,0x68,0x65,0x61,0x64
	.DB  0x6C,0x69,0x67,0x68,0x74,0x73,0x5F,0x6F
	.DB  0x6E,0x3D,0x25,0x64,0xD,0xA,0x0,0x5B
	.DB  0x44,0x42,0x47,0x5D,0x20,0x4B,0x65,0x79
	.DB  0x34,0x20,0x3D,0x3E,0x20,0x68,0x6F,0x6E
	.DB  0x6B,0xD,0xA,0x0,0x73,0x70,0x65,0x65
	.DB  0x64,0x3A,0x20,0x20,0x20,0x25,0x64,0x0
	.DB  0x6D,0x65,0x6E,0x75,0x3D,0x20,0x20,0x20
	.DB  0x25,0x64,0x0,0x74,0x65,0x6D,0x70,0x3A
	.DB  0x20,0x20,0x20,0x25,0x64,0x0,0x66,0x75
	.DB  0x65,0x6C,0x3A,0x20,0x20,0x20,0x25,0x64
	.DB  0x0
_0x2020003:
	.DB  0x7

__GLOBAL_INI_TBL:
	.DW  0x01
	.DW  0x02
	.DW  __REG_BIT_VARS*2

	.DW  0x0A
	.DW  0x04
	.DW  __REG_VARS*2

	.DW  0x07
	.DW  _0xC
	.DW  _0x0*2+15

	.DW  0x11
	.DW  _0x4D
	.DW  _0x0*2+83

	.DW  0x0A
	.DW  _0x4D+17
	.DW  _0x0*2+100

	.DW  0x0F
	.DW  _0x4D+27
	.DW  _0x0*2+110

	.DW  0x10
	.DW  _0x4D+42
	.DW  _0x0*2+125

	.DW  0x11
	.DW  _0x4D+58
	.DW  _0x0*2+141

	.DW  0x11
	.DW  _0x4D+75
	.DW  _0x0*2+158

	.DW  0x01
	.DW  _twi_result
	.DW  _0x2020003*2

_0xFFFFFFFF:
	.DW  0

#define __GLOBAL_INI_TBL_PRESENT 1

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  GICR,R31
	OUT  GICR,R30
	OUT  MCUCR,R30

;CLEAR R2-R14
	LDI  R24,(14-2)+1
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(__CLEAR_SRAM_SIZE)
	LDI  R25,HIGH(__CLEAR_SRAM_SIZE)
	LDI  R26,__SRAM_START
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x260

	.CSEG
;/*******************************************************
;This program was created by the
;CodeWizardAVR V3.14 Advanced
;Automatic Program Generator
;© Copyright 1998-2014 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com
;
;Project : Az Digital 2 Project
;Version :
;Date    : 22/01/2025
;Author  :
;Company :
;Comments:
;
;
;Chip type               : ATmega32
;Program type            : Application
;AVR Core Clock frequency: 8.000000 MHz
;Memory model            : Small
;External RAM size       : 0
;Data Stack size         : 512
;*******************************************************/
;
;#include <mega32.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif
;#include <stdbool.h>
;#include <delay.h>
;#include <stdio.h>
;#include <twi.h>
;
;
;// --------------------------------- definitions ---------------------------------------
;
;#define LCD_I2C_ADDR       0x3F
;
;// LM75 with A2=0, A1=1, A0=1
;#define LM75_I2C_ADDR      0x4B
;
;volatile int seconds = 0, minutes = 0, hours = 0;
;volatile int second_flag = 0;  // <--- ADDED: signals when 1 second passed
;
;int fuel_level          = 100;
;int speed_value         = 0;  // from ADC (PA0)
;int steering_value      = 0;  // from ADC (PA1)
;//int direction           = 0;  // 0=Stop, 1=FWD, -1=REV
;int brake_applied       = 0;
;int headlights_on       = 0;
;int current_menu        = 0;
;long int baseSpeed      = 0;
;long int scaledSpeed    = 0;
;long int steer_offset   = 0;
;long int offsetScaled   = 0;
;long int leftSpeedVal   = 0;
;long int rightSpeedVal  = 0;
;#define PWM_TOP 40000
;bool lcd_timer_on       = false;
;char buffer[17];
;char buffer2[17];
;int temp                = 0;
;int directionFlag       = 0;   // -1 => rev, 0 => stop, +1 => fwd
;bool int_button_used    = false;
;bool turn_brake_light   = false;
;static int toggle       = 0;
;int toggle_4            = 0;
;char buffer_time[17];  // Enough for "HH:MM:SS" plus a null terminator
;int firstKey;
;int secondKey;
;
;
;
;
;
;
;//---------------------------------------------------------------------------
;// Function Prototypes
;//---------------------------------------------------------------------------
;
;// Keypad
;int  read_keypad_2x2(void);
;
;// Car control helpers
;void update_fuel_usage(void);
;void beep_when_reverse(void);
;
;// ------------------------ PCF8574 ----------------------------------------------------
;#define LCD_EN             0x04  // Enable bit
;#define LCD_RW             0x02  // Read/Write bit
;#define LCD_RS             0x01  // Register Select bit
;#define LCD_BACKLIGHT      0x08  // Backlight bit
;
;//---------------------- LCD FUNCTIONS -------------------------------------------------
;
;bool twi_lcd_write(int data)
; 0000 005D {

	.CSEG
_twi_lcd_write:
; .FSTART _twi_lcd_write
; 0000 005E     unsigned char tx_data = (unsigned char)(data & 0xFF);
; 0000 005F 
; 0000 0060     // Keep backlight on:
; 0000 0061     tx_data |= LCD_BACKLIGHT;
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
;	data -> Y+1
;	tx_data -> R17
	LDD  R30,Y+1
	MOV  R17,R30
	ORI  R17,LOW(8)
; 0000 0062 
; 0000 0063     // Send 1 byte to the PCF8574
; 0000 0064     return twi_master_trans(LCD_I2C_ADDR, &tx_data, 1, 0, 0);
	LDI  R30,LOW(63)
	ST   -Y,R30
	IN   R30,SPL
	IN   R31,SPH
	ST   -Y,R31
	ST   -Y,R30
	PUSH R17
	CALL SUBOPT_0x0
	POP  R17
	LDD  R17,Y+0
	ADIW R28,3
	RET
; 0000 0065 }
; .FEND
;
;// Send a 4-bit nibble to the LCD.
;void lcd_send_nibble(int nibble, int mode)
; 0000 0069 {
_lcd_send_nibble:
; .FSTART _lcd_send_nibble
; 0000 006A     int data_out = (nibble & 0xF0) | mode; // upper nibble + RS/RW bits
; 0000 006B 
; 0000 006C     // EN=0
; 0000 006D     twi_lcd_write(data_out);
	CALL SUBOPT_0x1
;	nibble -> Y+4
;	mode -> Y+2
;	data_out -> R16,R17
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	ANDI R30,LOW(0xF0)
	ANDI R31,HIGH(0xF0)
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	OR   R30,R26
	OR   R31,R27
	MOVW R16,R30
	MOVW R26,R16
	RCALL _twi_lcd_write
; 0000 006E 
; 0000 006F     // Pulse EN=1
; 0000 0070     twi_lcd_write(data_out | LCD_EN);
	MOVW R30,R16
	ORI  R30,4
	MOVW R26,R30
	RCALL _twi_lcd_write
; 0000 0071     delay_us(1);
	__DELAY_USB 3
; 0000 0072 
; 0000 0073     // EN=0
; 0000 0074     twi_lcd_write(data_out & ~LCD_EN);
	MOVW R30,R16
	ANDI R30,LOW(0xFFFB)
	MOVW R26,R30
	RCALL _twi_lcd_write
; 0000 0075     delay_us(50);
	__DELAY_USB 133
; 0000 0076 }
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x208000A
; .FEND
;
;// Send a full byte (cmd/data) in 4-bit mode
;void lcd_send_byte(int value, int mode)
; 0000 007A {
_lcd_send_byte:
; .FSTART _lcd_send_byte
; 0000 007B     // High nibble
; 0000 007C     lcd_send_nibble(value & 0xF0, mode);
	ST   -Y,R27
	ST   -Y,R26
;	value -> Y+2
;	mode -> Y+0
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	CALL SUBOPT_0x2
; 0000 007D     // Low nibble
; 0000 007E     lcd_send_nibble((value << 4) & 0xF0, mode);
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	CALL __LSLW4
	CALL SUBOPT_0x2
; 0000 007F }
	RJMP _0x2080006
; .FEND
;
;// Send a command (RS=0)
;void lcd_cmd(int cmd)
; 0000 0083 {
_lcd_cmd:
; .FSTART _lcd_cmd
; 0000 0084     lcd_send_byte(cmd, 0);
	CALL SUBOPT_0x3
;	cmd -> Y+0
	LDI  R26,LOW(0)
	LDI  R27,0
	RCALL _lcd_send_byte
; 0000 0085 }
	RJMP _0x2080007
; .FEND
;
;// Send data (RS=1)
;void lcd_data(int data)
; 0000 0089 {
_lcd_data:
; .FSTART _lcd_data
; 0000 008A     lcd_send_byte(data, LCD_RS);
	CALL SUBOPT_0x3
;	data -> Y+0
	LDI  R26,LOW(1)
	LDI  R27,0
	RCALL _lcd_send_byte
; 0000 008B }
	RJMP _0x2080007
; .FEND
;
;void lcd_init(void)
; 0000 008E {
_lcd_init:
; .FSTART _lcd_init
; 0000 008F     delay_ms(20);
	LDI  R26,LOW(20)
	CALL SUBOPT_0x4
; 0000 0090 
; 0000 0091     // HD44780 spec init: send 0x30 (8-bit mode) three times
; 0000 0092     lcd_send_nibble(0x30, 0);
; 0000 0093     delay_ms(5);
	LDI  R26,LOW(5)
	CALL SUBOPT_0x4
; 0000 0094     lcd_send_nibble(0x30, 0);
; 0000 0095     delay_us(100);
	CALL SUBOPT_0x5
; 0000 0096     lcd_send_nibble(0x30, 0);
	LDI  R30,LOW(48)
	LDI  R31,HIGH(48)
	CALL SUBOPT_0x6
; 0000 0097     delay_us(100);
; 0000 0098 
; 0000 0099     // Switch to 4-bit mode
; 0000 009A     lcd_send_nibble(0x20, 0);
	LDI  R30,LOW(32)
	LDI  R31,HIGH(32)
	CALL SUBOPT_0x6
; 0000 009B     delay_us(100);
; 0000 009C 
; 0000 009D     // 4-bit, 2 lines, 5x8
; 0000 009E     lcd_cmd(0x28);
	LDI  R26,LOW(40)
	LDI  R27,0
	RCALL _lcd_cmd
; 0000 009F     // Display off
; 0000 00A0     lcd_cmd(0x08);
	LDI  R26,LOW(8)
	LDI  R27,0
	RCALL _lcd_cmd
; 0000 00A1     // Clear
; 0000 00A2     lcd_cmd(0x01);
	CALL SUBOPT_0x7
; 0000 00A3     delay_ms(2);
	LDI  R26,LOW(2)
	LDI  R27,0
	CALL _delay_ms
; 0000 00A4     // Entry mode: increment, no shift
; 0000 00A5     lcd_cmd(0x06);
	LDI  R26,LOW(6)
	LDI  R27,0
	RCALL _lcd_cmd
; 0000 00A6     // Display on, cursor off
; 0000 00A7     lcd_cmd(0x0C);
	LDI  R26,LOW(12)
	LDI  R27,0
	RCALL _lcd_cmd
; 0000 00A8 }
	RET
; .FEND
;
;// Print a string at the current cursor
;void lcd_print(char *str)
; 0000 00AC {
_lcd_print:
; .FSTART _lcd_print
; 0000 00AD     while (*str)
	ST   -Y,R27
	ST   -Y,R26
;	*str -> Y+0
_0x3:
	LD   R26,Y
	LDD  R27,Y+1
	LD   R30,X
	CPI  R30,0
	BREQ _0x5
; 0000 00AE         lcd_data(*str++);
	LD   R30,X+
	ST   Y,R26
	STD  Y+1,R27
	LDI  R31,0
	MOVW R26,R30
	RCALL _lcd_data
	RJMP _0x3
_0x5:
; 0000 00AF }
	RJMP _0x2080007
; .FEND
;
;// Move cursor to (col, row) on a 16×2 display
;void lcd_gotoxy(int col, int row)
; 0000 00B3 {
_lcd_gotoxy:
; .FSTART _lcd_gotoxy
; 0000 00B4     int address;
; 0000 00B5     switch (row)
	CALL SUBOPT_0x1
;	col -> Y+4
;	row -> Y+2
;	address -> R16,R17
	LDD  R30,Y+2
	LDD  R31,Y+2+1
; 0000 00B6     {
; 0000 00B7         case 0: address = 0x00 + col; break; // row 0 base: 0x00
	SBIW R30,0
	BRNE _0x9
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	ADIW R30,0
	MOVW R16,R30
	RJMP _0x8
; 0000 00B8         case 1: address = 0x40 + col; break; // row 1 base: 0x40
_0x9:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0xB
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	SUBI R30,LOW(-64)
	SBCI R31,HIGH(-64)
	MOVW R16,R30
	RJMP _0x8
; 0000 00B9         default: address = 0x00; break;
_0xB:
	__GETWRN 16,17,0
; 0000 00BA     }
_0x8:
; 0000 00BB     lcd_cmd(0x80 | address);
	MOVW R30,R16
	ORI  R30,0x80
	MOVW R26,R30
	RCALL _lcd_cmd
; 0000 00BC }
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x208000A
; .FEND
;
;
;//-------------------------Menus codes -----------------------------------------------------
;
;void display_time_on_lcd(void)
; 0000 00C2 {
_display_time_on_lcd:
; .FSTART _display_time_on_lcd
; 0000 00C3 
; 0000 00C4     // Format the time as "HH:MM:SS"
; 0000 00C5     sprintf(buffer_time, "%02d:%02d:%02d", hours, minutes, seconds);
	LDI  R30,LOW(_buffer_time)
	LDI  R31,HIGH(_buffer_time)
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x0,0
	ST   -Y,R31
	ST   -Y,R30
	LDS  R30,_hours
	LDS  R31,_hours+1
	CALL SUBOPT_0x8
	LDS  R30,_minutes
	LDS  R31,_minutes+1
	CALL SUBOPT_0x8
	LDS  R30,_seconds
	LDS  R31,_seconds+1
	CALL SUBOPT_0x8
	LDI  R24,12
	CALL _sprintf
	ADIW R28,16
; 0000 00C6 
; 0000 00C7     // place it at row=0, col=0
; 0000 00C8     lcd_gotoxy(0, 0);
	CALL SUBOPT_0x9
	LDI  R27,0
	RCALL _lcd_gotoxy
; 0000 00C9     lcd_print("Time: ");
	__POINTW2MN _0xC,0
	RCALL _lcd_print
; 0000 00CA     lcd_print(buffer_time);
	LDI  R26,LOW(_buffer_time)
	LDI  R27,HIGH(_buffer_time)
	RCALL _lcd_print
; 0000 00CB }
	RET
; .FEND

	.DSEG
_0xC:
	.BYTE 0x7
;
;
;
;
;// ------------------------ LM75 Routines ------------------------
;
;// Write an arbitrary register in the LM75 (e.g. config, TOS, THYST)
;bool lm75_write_register(unsigned char reg, unsigned char *data, unsigned char length)
; 0000 00D4 {

	.CSEG
_lm75_write_register:
; .FSTART _lm75_write_register
; 0000 00D5     // For the LM75, the first byte is the register pointer
; 0000 00D6     // The following bytes are the data to write
; 0000 00D7     unsigned char tx_buffer[1 + 2]; // up to 1 register + 2 data bytes
; 0000 00D8     unsigned char i;
; 0000 00D9 
; 0000 00DA     if (length > 2) return false; // LM75 typically only needs up to 2 bytes
	ST   -Y,R26
	SBIW R28,3
	ST   -Y,R17
;	reg -> Y+7
;	*data -> Y+5
;	length -> Y+4
;	tx_buffer -> Y+1
;	i -> R17
	LDD  R26,Y+4
	CPI  R26,LOW(0x3)
	BRLO _0xD
	LDI  R30,LOW(0)
	RJMP _0x208000B
; 0000 00DB 
; 0000 00DC     tx_buffer[0] = reg;
_0xD:
	LDD  R30,Y+7
	STD  Y+1,R30
; 0000 00DD     for (i = 0; i < length; i++)
	LDI  R17,LOW(0)
_0xF:
	LDD  R30,Y+4
	CP   R17,R30
	BRSH _0x10
; 0000 00DE         tx_buffer[1 + i] = data[i];
	MOV  R30,R17
	LDI  R31,0
	ADIW R30,1
	MOVW R26,R28
	ADIW R26,1
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	LDD  R26,Y+5
	LDD  R27,Y+5+1
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	LD   R30,X
	MOVW R26,R0
	ST   X,R30
	SUBI R17,-1
	RJMP _0xF
_0x10:
; 0000 00E0 return twi_master_trans(0x4B, tx_buffer, (1 + length), 0, 0);
	LDI  R30,LOW(75)
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,2
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+7
	SUBI R30,-LOW(1)
	ST   -Y,R30
	CALL SUBOPT_0x9
	CALL _twi_master_trans
_0x208000B:
	LDD  R17,Y+0
	ADIW R28,8
	RET
; 0000 00E1 }
; .FEND
;
;// Set the LM75 configuration register (register 1).
;// For default (continuous, comparator mode, active-low OS), pass config=0.
;bool lm75_write_config(unsigned char config)
; 0000 00E6 {
_lm75_write_config:
; .FSTART _lm75_write_config
; 0000 00E7     unsigned char data = config;
; 0000 00E8     return lm75_write_register(1, &data, 1);
	ST   -Y,R26
	ST   -Y,R17
;	config -> Y+1
;	data -> R17
	LDD  R17,Y+1
	LDI  R30,LOW(1)
	ST   -Y,R30
	IN   R30,SPL
	IN   R31,SPH
	ST   -Y,R31
	ST   -Y,R30
	PUSH R17
	LDI  R26,LOW(1)
	RCALL _lm75_write_register
	POP  R17
	LDD  R17,Y+0
	RJMP _0x2080007
; 0000 00E9 }
; .FEND
;
;// Set TOS (Overtemp Shutdown) register to 'tempC' degrees
;bool lm75_set_tos(int tempC)
; 0000 00ED {
_lm75_set_tos:
; .FSTART _lm75_set_tos
; 0000 00EE     // TOS is 2 bytes. In default 9-bit mode, the high byte has the sign+integer bits,
; 0000 00EF     // and the fraction bit is bit 0. We'll ignore fractions and set TOS = tempC.0
; 0000 00F0     // So upper byte = tempC, lower byte = 0.
; 0000 00F1     //
; 0000 00F2     // Example: 70 => 0x46 => 70 decimal.
; 0000 00F3     // This sets TOS to +70.0 °C
; 0000 00F4     unsigned char temp_data[2];
; 0000 00F5     temp_data[0] = (unsigned char)(tempC & 0x7F); // sign=0, store up to 127
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,2
;	tempC -> Y+2
;	temp_data -> Y+0
	LDD  R30,Y+2
	ANDI R30,0x7F
	ST   Y,R30
; 0000 00F6     temp_data[1] = 0x00;
	LDI  R30,LOW(0)
	STD  Y+1,R30
; 0000 00F7 
; 0000 00F8     return lm75_write_register(3, temp_data, 2); // TOS register = 3
	LDI  R30,LOW(3)
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(2)
	RCALL _lm75_write_register
	RJMP _0x2080006
; 0000 00F9 }
; .FEND
;
;// Read the LM75 temperature (register 0) as an integer.
;// If 9-bit resolution (default), bit 7 of the lower byte is the 0.5 fraction bit.
;int lm75_read_temp(void)
; 0000 00FE {
_lm75_read_temp:
; .FSTART _lm75_read_temp
; 0000 00FF     unsigned char reg_pointer = 0;  // Temperature register = 0
; 0000 0100     unsigned char rx_data[2];
; 0000 0101     int tempC = 0;
; 0000 0102 
; 0000 0103     // First, set the register pointer to 0 with a write transaction
; 0000 0104     // but we don't send any data beyond the pointer.
; 0000 0105     if (!twi_master_trans(LM75_I2C_ADDR, &reg_pointer, 1, 0, 0))
	SBIW R28,2
	CALL __SAVELOCR4
;	reg_pointer -> R17
;	rx_data -> Y+4
;	tempC -> R18,R19
	LDI  R17,0
	__GETWRN 18,19,0
	LDI  R30,LOW(75)
	ST   -Y,R30
	IN   R30,SPL
	IN   R31,SPH
	ST   -Y,R31
	ST   -Y,R30
	PUSH R17
	CALL SUBOPT_0x0
	POP  R17
	CPI  R30,0
	BRNE _0x11
; 0000 0106         return -1000; // indicate error
	LDI  R30,LOW(64536)
	LDI  R31,HIGH(64536)
	RJMP _0x2080009
; 0000 0107 
; 0000 0108     // Now read 2 bytes from the temperature register
; 0000 0109     // (rx_data[0] = MSB, rx_data[1] = LSB)
; 0000 010A     if (!twi_master_trans(LM75_I2C_ADDR, 0, 0, rx_data, 2))
_0x11:
	LDI  R30,LOW(75)
	ST   -Y,R30
	CALL SUBOPT_0xA
	LDI  R30,LOW(0)
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,8
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(2)
	CALL _twi_master_trans
	CPI  R30,0
	BRNE _0x12
; 0000 010B         return -1000; // indicate error
	LDI  R30,LOW(64536)
	LDI  R31,HIGH(64536)
	RJMP _0x2080009
; 0000 010C 
; 0000 010D     // In default 9-bit mode:
; 0000 010E     //  rx_data[0] bit 7 => sign (0 = positive)
; 0000 010F     //  rx_data[0] bits 6..0 => integer portion
; 0000 0110     //  rx_data[1] bit 7 => 0.5 fraction
; 0000 0111     //  We will do a simple rounding or floor approach.
; 0000 0112 
; 0000 0113     // Check sign bit (bit 7 of rx_data[0]):
; 0000 0114     if (rx_data[0] & 0x80)
_0x12:
	LDD  R30,Y+4
	ANDI R30,LOW(0x80)
	BREQ _0x13
; 0000 0115     {
; 0000 0116         // Negative temperature (simple approach).
; 0000 0117         // We won't fully implement negative decoding here, but you could.
; 0000 0118         return -999; // Or do a real sign extension
	LDI  R30,LOW(64537)
	LDI  R31,HIGH(64537)
	RJMP _0x2080009
; 0000 0119     }
; 0000 011A     else
_0x13:
; 0000 011B     {
; 0000 011C         // Positive: integer portion is bits 6..0
; 0000 011D         tempC = (rx_data[0] & 0x7F); // 0..127
	LDD  R30,Y+4
	LDI  R31,0
	ANDI R30,LOW(0x7F)
	ANDI R31,HIGH(0x7F)
	MOVW R18,R30
; 0000 011E         // If the fraction bit is set, we might add +0.5 or round up
; 0000 011F         // We'll do simple rounding to the nearest integer
; 0000 0120         if (rx_data[1] & 0x80)
	LDD  R30,Y+5
	ANDI R30,LOW(0x80)
	BREQ _0x15
; 0000 0121         {
; 0000 0122             // fraction = 0.5 => round up
; 0000 0123             tempC += 1;
	__ADDWRN 18,19,1
; 0000 0124         }
; 0000 0125     }
_0x15:
; 0000 0126     return tempC;
	MOVW R30,R18
_0x2080009:
	CALL __LOADLOCR4
_0x208000A:
	ADIW R28,6
	RET
; 0000 0127 }
; .FEND
;// ------------------------ LM75 Routines end------------------------
;
;
;// ---------------------------keypad---------------------------------
;int read_keypad_2x2(void)
; 0000 012D {
_read_keypad_2x2:
; .FSTART _read_keypad_2x2
; 0000 012E     int key = 0;
; 0000 012F 
; 0000 0130     //--- 1) Enable pull-ups on PA6..PA7 (the columns) ---
; 0000 0131     PORTA |= (1<<6) | (1<<7);
	ST   -Y,R17
	ST   -Y,R16
;	key -> R16,R17
	__GETWRN 16,17,0
	IN   R30,0x1B
	ORI  R30,LOW(0xC0)
	OUT  0x1B,R30
; 0000 0132 
; 0000 0133     //--- 2) Drive Row0=low (PA4=0), Row1=high (PA5=1) ---
; 0000 0134     PORTA &= ~(1<<4);  // row0=0
	CBI  0x1B,4
; 0000 0135     PORTA |=  (1<<5);  // row1=1
	SBI  0x1B,5
; 0000 0136     delay_ms(5);       // wait a bit for signals to settle
	LDI  R26,LOW(5)
	LDI  R27,0
	CALL _delay_ms
; 0000 0137 
; 0000 0138     // Check column lines (PA6, PA7)
; 0000 0139     if(!(PINA & (1<<6))) key = 1;  // Row0/Col0 => Key1
	SBIC 0x19,6
	RJMP _0x16
	__GETWRN 16,17,1
; 0000 013A     if(!(PINA & (1<<7))) key = 2;  // Row0/Col1 => Key2
_0x16:
	SBIC 0x19,7
	RJMP _0x17
	__GETWRN 16,17,2
; 0000 013B 
; 0000 013C     //--- 3) Drive Row0=high (PA4=1), Row1=low (PA5=0) ---
; 0000 013D     PORTA |=  (1<<4);
_0x17:
	SBI  0x1B,4
; 0000 013E     PORTA &= ~(1<<5);
	CBI  0x1B,5
; 0000 013F     delay_ms(5);
	LDI  R26,LOW(5)
	LDI  R27,0
	CALL _delay_ms
; 0000 0140 
; 0000 0141     // Check columns again
; 0000 0142     if(!(PINA & (1<<6))) key = 3;  // Row1/Col0 => Key3
	SBIC 0x19,6
	RJMP _0x18
	__GETWRN 16,17,3
; 0000 0143     if(!(PINA & (1<<7))) key = 4;  // Row1/Col1 => Key4
_0x18:
	SBIC 0x19,7
	RJMP _0x19
	__GETWRN 16,17,4
; 0000 0144 
; 0000 0145     //--- 4) Restore rows high (optional) ---
; 0000 0146     PORTA |= (1<<4) | (1<<5);
_0x19:
	IN   R30,0x1B
	ORI  R30,LOW(0x30)
	OUT  0x1B,R30
; 0000 0147 
; 0000 0148     return key;
	MOVW R30,R16
	LD   R16,Y+
	LD   R17,Y+
	RET
; 0000 0149 }
; .FEND
;
;
;int read_keypad_2x2_debounced(void)
; 0000 014D {
_read_keypad_2x2_debounced:
; .FSTART _read_keypad_2x2_debounced
; 0000 014E     // 1) Read raw key
; 0000 014F     firstKey = read_keypad_2x2();
	RCALL _read_keypad_2x2
	STS  _firstKey,R30
	STS  _firstKey+1,R31
; 0000 0150 
; 0000 0151     // 2) If no key is pressed => return 0
; 0000 0152     if(firstKey == 0)
	CALL SUBOPT_0xB
	SBIW R30,0
	BREQ _0x2080008
; 0000 0153         return 0;
; 0000 0154 
; 0000 0155     // 3) Wait a short debounce time
; 0000 0156     delay_ms(30);  // ~20ms is typical
	LDI  R26,LOW(30)
	LDI  R27,0
	CALL _delay_ms
; 0000 0157 
; 0000 0158     // 4) Read again
; 0000 0159     secondKey = read_keypad_2x2();
	RCALL _read_keypad_2x2
	STS  _secondKey,R30
	STS  _secondKey+1,R31
; 0000 015A 
; 0000 015B     // 5) If they match, return that key
; 0000 015C     if(secondKey == firstKey)
	CALL SUBOPT_0xB
	LDS  R26,_secondKey
	LDS  R27,_secondKey+1
	CP   R30,R26
	CPC  R31,R27
	BRNE _0x1B
; 0000 015D         return firstKey;
	CALL SUBOPT_0xB
	RET
; 0000 015E 
; 0000 015F     // 6) Otherwise, ignore (bounce) => return 0
; 0000 0160     return 0;
_0x1B:
_0x2080008:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	RET
; 0000 0161 }
; .FEND
;
;//---------------------------------------------------------------------------
;// Decrement fuel ~ once per second if direction != 0
;//---------------------------------------------------------------------------
;void update_fuel_usage(void)
; 0000 0167 {
_update_fuel_usage:
; .FSTART _update_fuel_usage
; 0000 0168     if(directionFlag!=0)
	LDS  R30,_directionFlag
	LDS  R31,_directionFlag+1
	SBIW R30,0
	BREQ _0x1C
; 0000 0169     {
; 0000 016A         if(fuel_level>0) fuel_level--;
	CLR  R0
	CP   R0,R4
	CPC  R0,R5
	BRGE _0x1D
	MOVW R30,R4
	SBIW R30,1
	MOVW R4,R30
; 0000 016B     }
_0x1D:
; 0000 016C }
_0x1C:
	RET
; .FEND
;
;//---------------------motor control ----------------------------------------
;void beep_when_reverse(void)
; 0000 0170 {
_beep_when_reverse:
; .FSTART _beep_when_reverse
; 0000 0171     toggle = !toggle;
	LDS  R30,_toggle_G000
	LDS  R31,_toggle_G000+1
	CALL __LNEGW1
	LDI  R31,0
	STS  _toggle_G000,R30
	STS  _toggle_G000+1,R31
; 0000 0172 
; 0000 0173     if(toggle)
	SBIW R30,0
	BREQ _0x1E
; 0000 0174         PORTC |=  (1<<6);
	SBI  0x15,6
; 0000 0175     else
	RJMP _0x1F
_0x1E:
; 0000 0176         PORTC &= ~(1<<6);
	CBI  0x15,6
; 0000 0177 
; 0000 0178     delay_ms(50);
_0x1F:
	LDI  R26,LOW(50)
	LDI  R27,0
	CALL _delay_ms
; 0000 0179 
; 0000 017A     PORTC &= ~(1<<6);  // ensure off
	CBI  0x15,6
; 0000 017B }
	RET
; .FEND
;
;void setLeftMotorDirection(int forward)
; 0000 017E {
_setLeftMotorDirection:
; .FSTART _setLeftMotorDirection
; 0000 017F     // If forward=1 => forward
; 0000 0180     // If forward=-1 => reverse
; 0000 0181     // If forward=0 => stop
; 0000 0182     // Example for 2 motors on left side sharing in1..in4
; 0000 0183     if(forward == 1)
	ST   -Y,R27
	ST   -Y,R26
;	forward -> Y+0
	LD   R26,Y
	LDD  R27,Y+1
	SBIW R26,1
	BRNE _0x20
; 0000 0184     {
; 0000 0185         // PC2=1, PC3=0, PC4=1, PC5=0 => forward
; 0000 0186         PORTC |=  (1<<2);
	SBI  0x15,2
; 0000 0187         PORTC &= ~(1<<3);
	CBI  0x15,3
; 0000 0188         PORTC |=  (1<<4);
	SBI  0x15,4
; 0000 0189         PORTC &= ~(1<<5);
	CBI  0x15,5
; 0000 018A     }
; 0000 018B     else if(forward == -1)
	RJMP _0x21
_0x20:
	LD   R26,Y
	LDD  R27,Y+1
	CPI  R26,LOW(0xFFFF)
	LDI  R30,HIGH(0xFFFF)
	CPC  R27,R30
	BRNE _0x22
; 0000 018C     {
; 0000 018D         // PC2=0, PC3=1, PC4=0, PC5=1 => reverse
; 0000 018E         PORTC &= ~(1<<2);
	CBI  0x15,2
; 0000 018F         PORTC |=  (1<<3);
	SBI  0x15,3
; 0000 0190         PORTC &= ~(1<<4);
	CBI  0x15,4
; 0000 0191         PORTC |=  (1<<5);
	SBI  0x15,5
; 0000 0192     }
; 0000 0193     else
	RJMP _0x23
_0x22:
; 0000 0194     {
; 0000 0195         // Stop: clear all
; 0000 0196         PORTC &= ~((1<<2)|(1<<3)|(1<<4)|(1<<5));
	IN   R30,0x15
	ANDI R30,LOW(0xC3)
	OUT  0x15,R30
; 0000 0197     }
_0x23:
_0x21:
; 0000 0198 }
	RJMP _0x2080007
; .FEND
;
;void setLeftMotorSpeed(long int duty)
; 0000 019B {
_setLeftMotorSpeed:
; .FSTART _setLeftMotorSpeed
; 0000 019C     if(duty < 0) duty = 0;
	CALL __PUTPARD2
;	duty -> Y+0
	LDD  R26,Y+3
	TST  R26
	BRPL _0x24
	LDI  R30,LOW(0)
	CALL __CLRD1S0
; 0000 019D     if(duty > PWM_TOP) duty = PWM_TOP;
_0x24:
	CALL SUBOPT_0xC
	BRLT _0x25
	CALL SUBOPT_0xD
; 0000 019E     OCR1A = duty; // PD5 => left side motors
_0x25:
	LD   R30,Y
	LDD  R31,Y+1
	OUT  0x2A+1,R31
	OUT  0x2A,R30
; 0000 019F }
	RJMP _0x2080006
; .FEND
;
;void setRightMotorSpeed(long int duty)
; 0000 01A2 {
_setRightMotorSpeed:
; .FSTART _setRightMotorSpeed
; 0000 01A3     if(duty < 0) duty = 0;
	CALL __PUTPARD2
;	duty -> Y+0
	LDD  R26,Y+3
	TST  R26
	BRPL _0x26
	LDI  R30,LOW(0)
	CALL __CLRD1S0
; 0000 01A4     if(duty > PWM_TOP) duty = PWM_TOP;
_0x26:
	CALL SUBOPT_0xC
	BRLT _0x27
	CALL SUBOPT_0xD
; 0000 01A5     OCR1B = duty; // PD4 => right side motors
_0x27:
	LD   R30,Y
	LDD  R31,Y+1
	OUT  0x28+1,R31
	OUT  0x28,R30
; 0000 01A6 }
	RJMP _0x2080006
; .FEND
;
;void setRightMotorDirection(int forward)
; 0000 01A9 {
_setRightMotorDirection:
; .FSTART _setRightMotorDirection
; 0000 01AA     if(forward == 1)
	ST   -Y,R27
	ST   -Y,R26
;	forward -> Y+0
	LD   R26,Y
	LDD  R27,Y+1
	SBIW R26,1
	BRNE _0x28
; 0000 01AB     {
; 0000 01AC         // PB4=1, PB5=0, PB6=1, PB7=0 => forward
; 0000 01AD         PORTB |=  (1<<4);
	SBI  0x18,4
; 0000 01AE         PORTB &= ~(1<<5);
	CBI  0x18,5
; 0000 01AF         PORTB |=  (1<<6);
	SBI  0x18,6
; 0000 01B0         PORTB &= ~(1<<7);
	CBI  0x18,7
; 0000 01B1     }
; 0000 01B2     else if(forward == -1)
	RJMP _0x29
_0x28:
	LD   R26,Y
	LDD  R27,Y+1
	CPI  R26,LOW(0xFFFF)
	LDI  R30,HIGH(0xFFFF)
	CPC  R27,R30
	BRNE _0x2A
; 0000 01B3     {
; 0000 01B4         // PB4=0, PB5=1, PB6=0, PB7=1 => reverse
; 0000 01B5         PORTB &= ~(1<<4);
	CBI  0x18,4
; 0000 01B6         PORTB |=  (1<<5);
	SBI  0x18,5
; 0000 01B7         PORTB &= ~(1<<6);
	CBI  0x18,6
; 0000 01B8         PORTB |=  (1<<7);
	SBI  0x18,7
; 0000 01B9     }
; 0000 01BA     else
	RJMP _0x2B
_0x2A:
; 0000 01BB     {
; 0000 01BC         // Stop
; 0000 01BD         PORTB &= ~((1<<4)|(1<<5)|(1<<6)|(1<<7));
	IN   R30,0x18
	ANDI R30,LOW(0xF)
	OUT  0x18,R30
; 0000 01BE     }
_0x2B:
_0x29:
; 0000 01BF }
_0x2080007:
	ADIW R28,2
	RET
; .FEND
;
;//---------------------motor control end --------------------------------------
;
;
;// External Interrupt 2 service routine
;interrupt [EXT_INT2] void ext_int2_isr(void)
; 0000 01C6 {
_ext_int2_isr:
; .FSTART _ext_int2_isr
	CALL SUBOPT_0xE
; 0000 01C7     printf("interrupt 2\n\r");
	__POINTW1FN _0x0,22
	CALL SUBOPT_0xF
; 0000 01C8     brake_applied = 1;
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	MOVW R10,R30
; 0000 01C9     int_button_used=!int_button_used;
	LDS  R30,_int_button_used
	CALL __LNEGB1
	STS  _int_button_used,R30
; 0000 01CA }
	RJMP _0x6F
; .FEND
;
;// Timer 0 overflow interrupt service routine
;interrupt [TIM0_OVF] void timer0_ovf_isr(void)
; 0000 01CE {
_timer0_ovf_isr:
; .FSTART _timer0_ovf_isr
	CALL SUBOPT_0xE
; 0000 01CF     static int count = 0;
; 0000 01D0     count++;
	LDI  R26,LOW(_count_S0000016000)
	LDI  R27,HIGH(_count_S0000016000)
	CALL SUBOPT_0x10
; 0000 01D1 
; 0000 01D2     // ~31 overflows per second
; 0000 01D3     if(count >= 31)
	LDS  R26,_count_S0000016000
	LDS  R27,_count_S0000016000+1
	SBIW R26,31
	BRLT _0x2C
; 0000 01D4     {
; 0000 01D5         count = 0;
	LDI  R30,LOW(0)
	STS  _count_S0000016000,R30
	STS  _count_S0000016000+1,R30
; 0000 01D6         seconds++;
	LDI  R26,LOW(_seconds)
	LDI  R27,HIGH(_seconds)
	CALL SUBOPT_0x10
; 0000 01D7         if(seconds >= 60)
	LDS  R26,_seconds
	LDS  R27,_seconds+1
	SBIW R26,60
	BRLT _0x2D
; 0000 01D8         {
; 0000 01D9             seconds=0;
	LDI  R30,LOW(0)
	STS  _seconds,R30
	STS  _seconds+1,R30
; 0000 01DA             minutes++;
	LDI  R26,LOW(_minutes)
	LDI  R27,HIGH(_minutes)
	CALL SUBOPT_0x10
; 0000 01DB             if(minutes >= 60)
	LDS  R26,_minutes
	LDS  R27,_minutes+1
	SBIW R26,60
	BRLT _0x2E
; 0000 01DC             {
; 0000 01DD                 minutes = 0;
	LDI  R30,LOW(0)
	STS  _minutes,R30
	STS  _minutes+1,R30
; 0000 01DE                 hours++;
	LDI  R26,LOW(_hours)
	LDI  R27,HIGH(_hours)
	CALL SUBOPT_0x10
; 0000 01DF                 if(hours >= 24) hours=0;
	LDS  R26,_hours
	LDS  R27,_hours+1
	SBIW R26,24
	BRLT _0x2F
	LDI  R30,LOW(0)
	STS  _hours,R30
	STS  _hours+1,R30
; 0000 01E0             }
_0x2F:
; 0000 01E1         }
_0x2E:
; 0000 01E2         // Decrement fuel if direction != 0
; 0000 01E3                update_fuel_usage();
_0x2D:
	RCALL _update_fuel_usage
; 0000 01E4 
; 0000 01E5         second_flag = 1;
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	STS  _second_flag,R30
	STS  _second_flag+1,R31
; 0000 01E6 
; 0000 01E7     }
; 0000 01E8 }
_0x2C:
_0x6F:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	LD   R25,Y+
	LD   R24,Y+
	LD   R23,Y+
	LD   R22,Y+
	LD   R15,Y+
	LD   R1,Y+
	LD   R0,Y+
	RETI
; .FEND
;
;// Voltage Reference: AREF pin
;#define ADC_VREF_TYPE ((0<<REFS1) | (0<<REFS0) | (0<<ADLAR))
;
;// Read the AD conversion result
;unsigned int read_adc(unsigned char adc_input)
; 0000 01EF {
_read_adc:
; .FSTART _read_adc
; 0000 01F0 ADMUX=adc_input | ADC_VREF_TYPE;
	ST   -Y,R26
;	adc_input -> Y+0
	LD   R30,Y
	OUT  0x7,R30
; 0000 01F1 // Delay needed for the stabilization of the ADC input voltage
; 0000 01F2 delay_us(10);
	__DELAY_USB 27
; 0000 01F3 // Start the AD conversion
; 0000 01F4 ADCSRA|=(1<<ADSC);
	SBI  0x6,6
; 0000 01F5 // Wait for the AD conversion to complete
; 0000 01F6 while ((ADCSRA & (1<<ADIF))==0);
_0x30:
	SBIS 0x6,4
	RJMP _0x30
; 0000 01F7 ADCSRA|=(1<<ADIF);
	SBI  0x6,4
; 0000 01F8 return ADCW;
	IN   R30,0x4
	IN   R31,0x4+1
	JMP  _0x2080005
; 0000 01F9 }
; .FEND
;
;
;void updateMotorControl(void)
; 0000 01FD {
_updateMotorControl:
; .FSTART _updateMotorControl
; 0000 01FE     // 1) Read speed pot
; 0000 01FF     int speed_adc = read_adc(0);  // 0..1023
; 0000 0200     // 2) Read steering pot
; 0000 0201     int steer_adc = read_adc(1);  // 0..1023
; 0000 0202 
; 0000 0203     // 3) Decide direction
; 0000 0204 
; 0000 0205     if(speed_adc > 512)
	CALL __SAVELOCR4
;	speed_adc -> R16,R17
;	steer_adc -> R18,R19
	LDI  R26,LOW(0)
	RCALL _read_adc
	MOVW R16,R30
	LDI  R26,LOW(1)
	RCALL _read_adc
	MOVW R18,R30
	__CPWRN 16,17,513
	BRLT _0x33
; 0000 0206         directionFlag = 1;
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	STS  _directionFlag,R30
	STS  _directionFlag+1,R31
; 0000 0207     else if(speed_adc < 512)
	RJMP _0x34
_0x33:
	__CPWRN 16,17,512
	BRGE _0x35
; 0000 0208         directionFlag = -1;
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	STS  _directionFlag,R30
	STS  _directionFlag+1,R31
; 0000 0209     else
	RJMP _0x36
_0x35:
; 0000 020A         directionFlag = 0;
	LDI  R30,LOW(0)
	STS  _directionFlag,R30
	STS  _directionFlag+1,R30
; 0000 020B 
; 0000 020C     // 4) Base speed = difference from 512 (max ~511)
; 0000 020D     //    map 0..511 => 0..PWM_TOP
; 0000 020E     baseSpeed = (directionFlag == 0) ? 0 : (speed_adc - 512);
_0x36:
_0x34:
	CALL SUBOPT_0x11
	SBIW R26,0
	BRNE _0x37
	__GETD1N 0x0
	RJMP _0x38
_0x37:
	MOVW R30,R16
	SUBI R30,LOW(512)
	SBCI R31,HIGH(512)
	CALL __CWD1
_0x38:
	CALL SUBOPT_0x12
; 0000 020F     if(directionFlag == -1)
	CALL SUBOPT_0x11
	CPI  R26,LOW(0xFFFF)
	LDI  R30,HIGH(0xFFFF)
	CPC  R27,R30
	BRNE _0x3A
; 0000 0210         baseSpeed = 512 - speed_adc; // if going reverse, speed is how far below 512
	LDI  R30,LOW(512)
	LDI  R31,HIGH(512)
	SUB  R30,R16
	SBC  R31,R17
	CALL __CWD1
	CALL SUBOPT_0x12
; 0000 0211 
; 0000 0212     if(baseSpeed < 0) baseSpeed = -baseSpeed; // just in case
_0x3A:
	LDS  R26,_baseSpeed+3
	TST  R26
	BRPL _0x3B
	CALL SUBOPT_0x13
	CALL __ANEGD1
	CALL SUBOPT_0x12
; 0000 0213 
; 0000 0214     // Scale to 0..PWM_TOP
; 0000 0215     // e.g. baseSpeed * PWM_TOP / 511
; 0000 0216     scaledSpeed = (baseSpeed * PWM_TOP) / 511;
_0x3B:
	CALL SUBOPT_0x13
	CALL SUBOPT_0x14
	__GETD1N 0x1FF
	CALL __DIVD21
	CALL SUBOPT_0x15
; 0000 0217     if(scaledSpeed < 0) scaledSpeed = 0;
	LDS  R26,_scaledSpeed+3
	TST  R26
	BRPL _0x3C
	LDI  R30,LOW(0)
	STS  _scaledSpeed,R30
	STS  _scaledSpeed+1,R30
	STS  _scaledSpeed+2,R30
	STS  _scaledSpeed+3,R30
; 0000 0218     if(scaledSpeed > PWM_TOP) scaledSpeed = PWM_TOP;
_0x3C:
	CALL SUBOPT_0x16
	CALL SUBOPT_0x17
	BRLT _0x3D
	CALL SUBOPT_0x18
	CALL SUBOPT_0x15
; 0000 0219 
; 0000 021A     // 5) Steering offset
; 0000 021B     // steer_adc ~ 0..1023
; 0000 021C     // If <512 => left turn => left side slower, right side faster
; 0000 021D     // If >512 => right turn => left side faster, right side slower
; 0000 021E     // If =512 => no offset
; 0000 021F     steer_offset = steer_adc - 512; // range ~ -512..+511
_0x3D:
	MOVW R30,R18
	SUBI R30,LOW(512)
	SBCI R31,HIGH(512)
	CALL __CWD1
	STS  _steer_offset,R30
	STS  _steer_offset+1,R31
	STS  _steer_offset+2,R22
	STS  _steer_offset+3,R23
; 0000 0220 
; 0000 0221     // leftSpeed = scaledSpeed - offset
; 0000 0222     // rightSpeed= scaledSpeed + offset
; 0000 0223     // offsetScaled = (steer_offset * PWM_TOP) / 512
; 0000 0224     offsetScaled = (steer_offset * PWM_TOP) / 512;
	CALL SUBOPT_0x14
	__GETD1N 0x200
	CALL __DIVD21
	STS  _offsetScaled,R30
	STS  _offsetScaled+1,R31
	STS  _offsetScaled+2,R22
	STS  _offsetScaled+3,R23
; 0000 0225     leftSpeedVal  = scaledSpeed - offsetScaled;
	LDS  R26,_offsetScaled
	LDS  R27,_offsetScaled+1
	LDS  R24,_offsetScaled+2
	LDS  R25,_offsetScaled+3
	LDS  R30,_scaledSpeed
	LDS  R31,_scaledSpeed+1
	LDS  R22,_scaledSpeed+2
	LDS  R23,_scaledSpeed+3
	CALL __SUBD12
	CALL SUBOPT_0x19
; 0000 0226     rightSpeedVal = scaledSpeed + offsetScaled;
	LDS  R30,_offsetScaled
	LDS  R31,_offsetScaled+1
	LDS  R22,_offsetScaled+2
	LDS  R23,_offsetScaled+3
	CALL SUBOPT_0x16
	CALL __ADDD12
	CALL SUBOPT_0x1A
; 0000 0227 
; 0000 0228     // clamp them
; 0000 0229     if(leftSpeedVal < 0)   leftSpeedVal = 0;
	LDS  R26,_leftSpeedVal+3
	TST  R26
	BRPL _0x3E
	LDI  R30,LOW(0)
	STS  _leftSpeedVal,R30
	STS  _leftSpeedVal+1,R30
	STS  _leftSpeedVal+2,R30
	STS  _leftSpeedVal+3,R30
; 0000 022A     if(leftSpeedVal > PWM_TOP)  leftSpeedVal = PWM_TOP;
_0x3E:
	CALL SUBOPT_0x1B
	CALL SUBOPT_0x17
	BRLT _0x3F
	CALL SUBOPT_0x18
	CALL SUBOPT_0x19
; 0000 022B     if(rightSpeedVal < 0)  rightSpeedVal = 0;
_0x3F:
	LDS  R26,_rightSpeedVal+3
	TST  R26
	BRPL _0x40
	LDI  R30,LOW(0)
	STS  _rightSpeedVal,R30
	STS  _rightSpeedVal+1,R30
	STS  _rightSpeedVal+2,R30
	STS  _rightSpeedVal+3,R30
; 0000 022C     if(rightSpeedVal > PWM_TOP) rightSpeedVal = PWM_TOP;
_0x40:
	CALL SUBOPT_0x1C
	CALL SUBOPT_0x17
	BRLT _0x41
	CALL SUBOPT_0x18
	CALL SUBOPT_0x1A
; 0000 022D 
; 0000 022E     // 6) Set directions
; 0000 022F     // If directionFlag= 1 => forward. If -1 => reverse. If 0 => stop all.
; 0000 0230     setLeftMotorDirection(directionFlag);
_0x41:
	CALL SUBOPT_0x11
	RCALL _setLeftMotorDirection
; 0000 0231     setRightMotorDirection(directionFlag);
	CALL SUBOPT_0x11
	RCALL _setRightMotorDirection
; 0000 0232 
; 0000 0233     // 7) Set speeds (PWM)
; 0000 0234     if(directionFlag == 0)
	LDS  R30,_directionFlag
	LDS  R31,_directionFlag+1
	SBIW R30,0
	BRNE _0x42
; 0000 0235     {
; 0000 0236         // Stopped
; 0000 0237         setLeftMotorSpeed(0);
	CALL SUBOPT_0x1D
	CALL SUBOPT_0x1E
; 0000 0238         setRightMotorSpeed(0);
	RJMP _0x6D
; 0000 0239     }
; 0000 023A     else if((brake_applied)&&(directionFlag!=0)) //Brake logic
_0x42:
	MOV  R0,R10
	OR   R0,R11
	BREQ _0x45
	CALL SUBOPT_0x11
	SBIW R26,0
	BRNE _0x46
_0x45:
	RJMP _0x44
_0x46:
; 0000 023B         {
; 0000 023C               setLeftMotorSpeed(0); // Stopped
	CALL SUBOPT_0x1D
	CALL SUBOPT_0x1E
; 0000 023D               setRightMotorSpeed(0); // Stopped
	CALL SUBOPT_0x1F
; 0000 023E               setLeftMotorDirection(0);
; 0000 023F               setRightMotorDirection(0);
; 0000 0240               turn_brake_light = true;
	LDI  R30,LOW(1)
	STS  _turn_brake_light,R30
; 0000 0241               printf("[DBG] Brake applied.\r\n");
	__POINTW1FN _0x0,36
	CALL SUBOPT_0xF
; 0000 0242 
; 0000 0243             if((int_button_used== false)&&(brake_applied))
	LDS  R26,_int_button_used
	CPI  R26,LOW(0x0)
	BRNE _0x48
	MOV  R0,R10
	OR   R0,R11
	BRNE _0x49
_0x48:
	RJMP _0x47
_0x49:
; 0000 0244             {
; 0000 0245                 brake_applied=0;
	CLR  R10
	CLR  R11
; 0000 0246                 turn_brake_light = false;
	LDI  R30,LOW(0)
	STS  _turn_brake_light,R30
; 0000 0247                 printf("[DBG] Brake released.\r\n");
	__POINTW1FN _0x0,59
	CALL SUBOPT_0xF
; 0000 0248             }
; 0000 0249         }
_0x47:
; 0000 024A     else if(temp>70)
	RJMP _0x4A
_0x44:
	LDS  R26,_temp
	LDS  R27,_temp+1
	CPI  R26,LOW(0x47)
	LDI  R30,HIGH(0x47)
	CPC  R27,R30
	BRLT _0x4B
; 0000 024B     {
; 0000 024C               setLeftMotorSpeed(0); // Stopped
	CALL SUBOPT_0x1D
	CALL SUBOPT_0x1E
; 0000 024D               setRightMotorSpeed(0); // Stopped
	CALL SUBOPT_0x1F
; 0000 024E               setLeftMotorDirection(0);
; 0000 024F               setRightMotorDirection(0);
; 0000 0250     }
; 0000 0251     else
	RJMP _0x4C
_0x4B:
; 0000 0252     {
; 0000 0253         setLeftMotorSpeed(leftSpeedVal);
	CALL SUBOPT_0x1B
	RCALL _setLeftMotorSpeed
; 0000 0254         setRightMotorSpeed(rightSpeedVal);
	CALL SUBOPT_0x1C
_0x6D:
	RCALL _setRightMotorSpeed
; 0000 0255     }
_0x4C:
_0x4A:
; 0000 0256 }
	CALL __LOADLOCR4
_0x2080006:
	ADIW R28,4
	RET
; .FEND
;
;
;void main(void)
; 0000 025A {
_main:
; .FSTART _main
; 0000 025B // -----------------------------------Declare your local variables here-----------------------------------------
; 0000 025C 
; 0000 025D 
; 0000 025E 
; 0000 025F 
; 0000 0260 
; 0000 0261 //--------------------------------------------------------------------------------------------------------------
; 0000 0262 
; 0000 0263 // Input/Output Ports initialization
; 0000 0264 {
; 0000 0265 // Port A initialization
; 0000 0266 // Function: Bit7=In Bit6=In Bit5=out Bit4=out Bit3=In Bit2=In Bit1=In Bit0=In
; 0000 0267 DDRA=(0<<DDA7) | (0<<DDA6) | (1<<DDA5) | (1<<DDA4) | (0<<DDA3) | (0<<DDA2) | (0<<DDA1) | (0<<DDA0);
	LDI  R30,LOW(48)
	OUT  0x1A,R30
; 0000 0268 // State: Bit7=T Bit6=T Bit5=T Bit4=T Bit3=T Bit2=T Bit1=T Bit0=T
; 0000 0269 PORTA=(0<<PORTA7) | (0<<PORTA6) | (1<<PORTA5) | (1<<PORTA4) | (0<<PORTA3) | (0<<PORTA2) | (0<<PORTA1) | (0<<PORTA0);
	OUT  0x1B,R30
; 0000 026A 
; 0000 026B // Port B initialization
; 0000 026C // Function: Bit7=Out Bit6=Out Bit5=Out Bit4=Out Bit3=Out Bit2=Out Bit1=In Bit0=In
; 0000 026D DDRB=(1<<DDB7) | (1<<DDB6) | (1<<DDB5) | (1<<DDB4) | (1<<DDB3) | (1<<DDB2) | (0<<DDB1) | (0<<DDB0);
	LDI  R30,LOW(252)
	OUT  0x17,R30
; 0000 026E // State: Bit7=0 Bit6=0 Bit5=0 Bit4=0 Bit3=1 Bit2=1 Bit1=T Bit0=T
; 0000 026F PORTB=(0<<PORTB7) | (0<<PORTB6) | (0<<PORTB5) | (0<<PORTB4) | (1<<PORTB3) | (1<<PORTB2) | (0<<PORTB1) | (0<<PORTB0);
	LDI  R30,LOW(12)
	OUT  0x18,R30
; 0000 0270 
; 0000 0271 // Port C initialization
; 0000 0272 // Function: Bit7=Out Bit6=Out Bit5=Out Bit4=Out Bit3=Out Bit2=Out Bit1=In Bit0=In
; 0000 0273 DDRC=(1<<DDC7) | (1<<DDC6) | (1<<DDC5) | (1<<DDC4) | (1<<DDC3) | (1<<DDC2) | (0<<DDC1) | (0<<DDC0);
	LDI  R30,LOW(252)
	OUT  0x14,R30
; 0000 0274 // State: Bit7=0 Bit6=0 Bit5=0 Bit4=0 Bit3=0 Bit2=0 Bit1=T Bit0=T
; 0000 0275 PORTC=(0<<PORTC7) | (0<<PORTC6) | (0<<PORTC5) | (0<<PORTC4) | (0<<PORTC3) | (0<<PORTC2) | (0<<PORTC1) | (0<<PORTC0);
	LDI  R30,LOW(0)
	OUT  0x15,R30
; 0000 0276 
; 0000 0277 // Port D initialization
; 0000 0278 // Function: Bit7=In Bit6=Out Bit5=Out Bit4=Out Bit3=In Bit2=In Bit1=In Bit0=In
; 0000 0279 DDRD=(0<<DDD7) | (1<<DDD6) | (1<<DDD5) | (1<<DDD4) | (0<<DDD3) | (0<<DDD2) | (0<<DDD1) | (0<<DDD0);
	LDI  R30,LOW(112)
	OUT  0x11,R30
; 0000 027A // State: Bit7=T Bit6=0 Bit5=0 Bit4=0 Bit3=T Bit2=T Bit1=T Bit0=T
; 0000 027B PORTD=(0<<PORTD7) | (0<<PORTD6) | (0<<PORTD5) | (0<<PORTD4) | (0<<PORTD3) | (0<<PORTD2) | (0<<PORTD1) | (0<<PORTD0);
	LDI  R30,LOW(0)
	OUT  0x12,R30
; 0000 027C }
; 0000 027D 
; 0000 027E // Timer/Counter 0 initialization
; 0000 027F {
; 0000 0280 // Clock source: System Clock
; 0000 0281 // Clock value: 7.813 kHz
; 0000 0282 // Mode: Normal top=0xFF
; 0000 0283 // OC0 output: Disconnected
; 0000 0284 // Timer Period: 32.768 ms
; 0000 0285 TCCR0=(0<<WGM00) | (0<<COM01) | (0<<COM00) | (0<<WGM01) | (1<<CS02) | (0<<CS01) | (1<<CS00);
	LDI  R30,LOW(5)
	OUT  0x33,R30
; 0000 0286 TCNT0=0x00;
	LDI  R30,LOW(0)
	OUT  0x32,R30
; 0000 0287 OCR0=0x00;
	OUT  0x3C,R30
; 0000 0288 }
; 0000 0289 // Timer/Counter 1 initialization
; 0000 028A {
; 0000 028B // Clock source: System Clock
; 0000 028C // Clock value: 1000.000 kHz
; 0000 028D // Mode: Ph. & fr. cor. PWM top=ICR1
; 0000 028E // OC1A output: Inverted PWM
; 0000 028F // OC1B output: Inverted PWM
; 0000 0290 // Noise Canceler: Off
; 0000 0291 // Input Capture on Falling Edge
; 0000 0292 // Timer Period: 0.1 s
; 0000 0293 // Output Pulse(s):
; 0000 0294 // OC1A Period: 0.1 s Width: 0 us
; 0000 0295 // OC1B Period: 0.1 s Width: 0 us
; 0000 0296 // Timer1 Overflow Interrupt: Off
; 0000 0297 // Input Capture Interrupt: Off
; 0000 0298 // Compare A Match Interrupt: Off
; 0000 0299 // Compare B Match Interrupt: Off
; 0000 029A TCCR1A=(1<<COM1A1) | (1<<COM1A0) | (1<<COM1B1) | (1<<COM1B0) | (0<<WGM11) | (0<<WGM10);
	LDI  R30,LOW(240)
	OUT  0x2F,R30
; 0000 029B TCCR1B=(0<<ICNC1) | (0<<ICES1) | (1<<WGM13) | (0<<WGM12) | (0<<CS12) | (1<<CS11) | (0<<CS10);
	LDI  R30,LOW(18)
	OUT  0x2E,R30
; 0000 029C TCNT1H=0x00;
	LDI  R30,LOW(0)
	OUT  0x2D,R30
; 0000 029D TCNT1L=0x00;
	OUT  0x2C,R30
; 0000 029E ICR1H=0xC3;
	LDI  R30,LOW(195)
	OUT  0x27,R30
; 0000 029F ICR1L=0x50;
	LDI  R30,LOW(80)
	OUT  0x26,R30
; 0000 02A0 OCR1AH=0xC3;
	LDI  R30,LOW(195)
	OUT  0x2B,R30
; 0000 02A1 OCR1AL=0x50;
	LDI  R30,LOW(80)
	OUT  0x2A,R30
; 0000 02A2 OCR1BH=0xC3;
	LDI  R30,LOW(195)
	OUT  0x29,R30
; 0000 02A3 OCR1BL=0x50;
	LDI  R30,LOW(80)
	OUT  0x28,R30
; 0000 02A4 }
; 0000 02A5 // Timer(s)/Counter(s) Interrupt(s) initialization
; 0000 02A6 TIMSK=(0<<OCIE2) | (0<<TOIE2) | (0<<TICIE1) | (0<<OCIE1A) | (0<<OCIE1B) | (0<<TOIE1) | (0<<OCIE0) | (1<<TOIE0);
	LDI  R30,LOW(1)
	OUT  0x39,R30
; 0000 02A7 
; 0000 02A8 // External Interrupt(s) initialization
; 0000 02A9 {
; 0000 02AA // INT0: Off
; 0000 02AB // INT1: Off
; 0000 02AC // INT2: On
; 0000 02AD // INT2 Mode: Rising Edge
; 0000 02AE GICR|=(0<<INT1) | (0<<INT0) | (1<<INT2);
	IN   R30,0x3B
	ORI  R30,0x20
	OUT  0x3B,R30
; 0000 02AF MCUCR=(0<<ISC11) | (0<<ISC10) | (0<<ISC01) | (0<<ISC00);
	LDI  R30,LOW(0)
	OUT  0x35,R30
; 0000 02B0 MCUCSR=(1<<ISC2);
	LDI  R30,LOW(64)
	OUT  0x34,R30
; 0000 02B1 GIFR=(0<<INTF1) | (0<<INTF0) | (1<<INTF2);
	LDI  R30,LOW(32)
	OUT  0x3A,R30
; 0000 02B2 }
; 0000 02B3 // USART initialization
; 0000 02B4 {
; 0000 02B5 // Communication Parameters: 8 Data, 1 Stop, No Parity
; 0000 02B6 // USART Receiver: Off
; 0000 02B7 // USART Transmitter: On
; 0000 02B8 // USART Mode: Asynchronous
; 0000 02B9 // USART Baud Rate: 9600
; 0000 02BA UCSRA=(0<<RXC) | (0<<TXC) | (0<<UDRE) | (0<<FE) | (0<<DOR) | (0<<UPE) | (0<<U2X) | (0<<MPCM);
	LDI  R30,LOW(0)
	OUT  0xB,R30
; 0000 02BB UCSRB=(0<<RXCIE) | (0<<TXCIE) | (0<<UDRIE) | (0<<RXEN) | (1<<TXEN) | (0<<UCSZ2) | (0<<RXB8) | (0<<TXB8);
	LDI  R30,LOW(8)
	OUT  0xA,R30
; 0000 02BC UCSRC=(1<<URSEL) | (0<<UMSEL) | (0<<UPM1) | (0<<UPM0) | (0<<USBS) | (1<<UCSZ1) | (1<<UCSZ0) | (0<<UCPOL);
	LDI  R30,LOW(134)
	OUT  0x20,R30
; 0000 02BD UBRRH=0x00;
	LDI  R30,LOW(0)
	OUT  0x20,R30
; 0000 02BE UBRRL=0x33;
	LDI  R30,LOW(51)
	OUT  0x9,R30
; 0000 02BF }
; 0000 02C0 // ADC initialization
; 0000 02C1 {
; 0000 02C2 // ADC Clock frequency: 1000.000 kHz
; 0000 02C3 // ADC Voltage Reference: AREF pin
; 0000 02C4 // ADC Auto Trigger Source: ADC Stopped
; 0000 02C5 ADMUX=ADC_VREF_TYPE;
	LDI  R30,LOW(0)
	OUT  0x7,R30
; 0000 02C6 ADCSRA=(1<<ADEN) | (0<<ADSC) | (0<<ADATE) | (0<<ADIF) | (0<<ADIE) | (0<<ADPS2) | (1<<ADPS1) | (1<<ADPS0);
	LDI  R30,LOW(131)
	OUT  0x6,R30
; 0000 02C7 SFIOR=(0<<ADTS2) | (0<<ADTS1) | (0<<ADTS0);
	LDI  R30,LOW(0)
	OUT  0x30,R30
; 0000 02C8 }
; 0000 02C9 // TWI initialization
; 0000 02CA {
; 0000 02CB // Mode: TWI Master
; 0000 02CC // Bit Rate: 400 kHz
; 0000 02CD     twi_master_init(400);
	LDI  R26,LOW(400)
	LDI  R27,HIGH(400)
	CALL _twi_master_init
; 0000 02CE 
; 0000 02CF }
; 0000 02D0 // Initialize the LCD
; 0000 02D1     {
; 0000 02D2     lcd_init();
	RCALL _lcd_init
; 0000 02D3     lcd_cmd(0x01); // Clear display
	CALL SUBOPT_0x7
; 0000 02D4     }
; 0000 02D5 // Configure the LM75:
; 0000 02D6 {
; 0000 02D7     // 1) Put the config register = 0 => default: comparator mode, active-low OS, 9-bit, continuous
; 0000 02D8     lm75_write_config(0x00);
	LDI  R26,LOW(0)
	RCALL _lm75_write_config
; 0000 02D9     // 2) Set TOS = 70 °C
; 0000 02DA     lm75_set_tos(70);
	LDI  R26,LOW(70)
	LDI  R27,0
	RCALL _lm75_set_tos
; 0000 02DB }
; 0000 02DC // Print initial message
; 0000 02DD {
; 0000 02DE     lcd_gotoxy(0, 0);
	CALL SUBOPT_0x9
	LDI  R27,0
	RCALL _lcd_gotoxy
; 0000 02DF     lcd_print("System Init...\r\n");
	__POINTW2MN _0x4D,0
	CALL SUBOPT_0x20
; 0000 02E0     lcd_gotoxy(0, 1);
	CALL SUBOPT_0x21
; 0000 02E1     lcd_print("Tcrit=70C");
	__POINTW2MN _0x4D,17
	CALL SUBOPT_0x22
; 0000 02E2     delay_ms(1000);
; 0000 02E3     lcd_cmd(0x01); // Clear
; 0000 02E4     lcd_print(" MehrzadGolabi");
	__POINTW2MN _0x4D,27
	CALL SUBOPT_0x20
; 0000 02E5     lcd_gotoxy(0, 1);
	CALL SUBOPT_0x21
; 0000 02E6     lcd_print("AZ Digital2 prj");
	__POINTW2MN _0x4D,42
	CALL SUBOPT_0x22
; 0000 02E7     delay_ms(1000);
; 0000 02E8     lcd_cmd(0x01); // Clear
; 0000 02E9     lcd_print(" Use the buttons");
	__POINTW2MN _0x4D,58
	CALL SUBOPT_0x20
; 0000 02EA     lcd_gotoxy(0, 1);
	CALL SUBOPT_0x21
; 0000 02EB     lcd_print("to navigate menu");
	__POINTW2MN _0x4D,75
	RCALL _lcd_print
; 0000 02EC     delay_ms(1500);
	LDI  R26,LOW(1500)
	LDI  R27,HIGH(1500)
	CALL _delay_ms
; 0000 02ED     //lcd_cmd(0x01); // Clear
; 0000 02EE 
; 0000 02EF }
; 0000 02F0 
; 0000 02F1 // Global enable interrupts
; 0000 02F2 #asm("sei")
	sei
; 0000 02F3 
; 0000 02F4 while (1)
_0x4E:
; 0000 02F5       {
; 0000 02F6       // Read ADC
; 0000 02F7         speed_value    = read_adc(0); // pot on PA0
	LDI  R26,LOW(0)
	RCALL _read_adc
	MOVW R6,R30
; 0000 02F8         steering_value = read_adc(1); // pot on PA1
	LDI  R26,LOW(1)
	RCALL _read_adc
	MOVW R8,R30
; 0000 02F9 
; 0000 02FA       // Temp
; 0000 02FB       temp = lm75_read_temp();
	RCALL _lm75_read_temp
	STS  _temp,R30
	STS  _temp+1,R31
; 0000 02FC 
; 0000 02FD       // Debug stuff
; 0000 02FE       printf("Speed=%d, Steering=%d, Temp=%d, Fuel=%d, directionFlag=%d , Brake=%d\r\n",
; 0000 02FF        speed_value, steering_value, temp, fuel_level, directionFlag, brake_applied);
	__POINTW1FN _0x0,175
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R6
	CALL SUBOPT_0x8
	MOVW R30,R8
	CALL SUBOPT_0x8
	CALL SUBOPT_0x23
	MOVW R30,R4
	CALL SUBOPT_0x8
	LDS  R30,_directionFlag
	LDS  R31,_directionFlag+1
	CALL SUBOPT_0x8
	MOVW R30,R10
	CALL SUBOPT_0x8
	LDI  R24,24
	CALL _printf
	ADIW R28,26
; 0000 0300 
; 0000 0301       // keyboard handle menu, toggles, etc.
; 0000 0302         {
; 0000 0303             int key = read_keypad_2x2_debounced();
; 0000 0304             switch(key)
	SBIW R28,2
;	key -> Y+0
	RCALL _read_keypad_2x2_debounced
	ST   Y,R30
	STD  Y+1,R31
; 0000 0305             {
; 0000 0306                 case 1:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x54
; 0000 0307                     current_menu++;
	LDI  R26,LOW(_current_menu)
	LDI  R27,HIGH(_current_menu)
	CALL SUBOPT_0x10
; 0000 0308                     if(current_menu>4) current_menu=0;
	LDS  R26,_current_menu
	LDS  R27,_current_menu+1
	SBIW R26,5
	BRLT _0x55
	LDI  R30,LOW(0)
	STS  _current_menu,R30
	STS  _current_menu+1,R30
; 0000 0309                     printf("[DBG] Key1 => menu=%d\r\n", current_menu);
_0x55:
	__POINTW1FN _0x0,246
	CALL SUBOPT_0x24
	CALL SUBOPT_0x25
; 0000 030A                     lcd_cmd(0x01);
; 0000 030B                 break;
	RJMP _0x53
; 0000 030C 
; 0000 030D                 case 2:
_0x54:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x56
; 0000 030E                     current_menu--;
	LDI  R26,LOW(_current_menu)
	LDI  R27,HIGH(_current_menu)
	LD   R30,X+
	LD   R31,X+
	SBIW R30,1
	ST   -X,R31
	ST   -X,R30
; 0000 030F                     lcd_timer_on = false;
	LDI  R30,LOW(0)
	STS  _lcd_timer_on,R30
; 0000 0310                     if(current_menu<0) current_menu=4;
	LDS  R26,_current_menu+1
	TST  R26
	BRPL _0x57
	LDI  R30,LOW(4)
	LDI  R31,HIGH(4)
	STS  _current_menu,R30
	STS  _current_menu+1,R31
; 0000 0311                     printf("[DBG] Key2 => menu=%d\r\n", current_menu);
_0x57:
	__POINTW1FN _0x0,270
	CALL SUBOPT_0x24
	CALL SUBOPT_0x25
; 0000 0312                     lcd_cmd(0x01);
; 0000 0313                 break;
	RJMP _0x53
; 0000 0314 
; 0000 0315                 case 3:
_0x56:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x58
; 0000 0316                     // Toggle headlights (PD6)
; 0000 0317                     headlights_on = !headlights_on;
	MOVW R30,R12
	CALL __LNEGW1
	MOV  R12,R30
	CLR  R13
; 0000 0318                     lcd_timer_on = false;
	LDI  R30,LOW(0)
	STS  _lcd_timer_on,R30
; 0000 0319                     if(headlights_on)
	MOV  R0,R12
	OR   R0,R13
	BREQ _0x59
; 0000 031A                         PORTD |=  (1<<6);
	SBI  0x12,6
; 0000 031B                     else
	RJMP _0x5A
_0x59:
; 0000 031C                         PORTD &= ~(1<<6);
	CBI  0x12,6
; 0000 031D                     printf("[DBG] Key3 => headlights_on=%d\r\n", headlights_on);
_0x5A:
	__POINTW1FN _0x0,294
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R12
	CALL SUBOPT_0x8
	CALL SUBOPT_0x25
; 0000 031E                     lcd_cmd(0x01);
; 0000 031F                 break;
	RJMP _0x53
; 0000 0320 
; 0000 0321                 case 4:
_0x58:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0x5E
; 0000 0322                     toggle_4=!toggle_4;
	CALL SUBOPT_0x26
	CALL __LNEGW1
	LDI  R31,0
	STS  _toggle_4,R30
	STS  _toggle_4+1,R31
; 0000 0323                     lcd_timer_on = false;
	LDI  R30,LOW(0)
	STS  _lcd_timer_on,R30
; 0000 0324                     if(toggle_4)
	CALL SUBOPT_0x26
	SBIW R30,0
	BREQ _0x5C
; 0000 0325                         PORTC |=  (1<<6);
	SBI  0x15,6
; 0000 0326                     else
	RJMP _0x5D
_0x5C:
; 0000 0327                         PORTC &= ~(1<<6);
	CBI  0x15,6
; 0000 0328                     printf("[DBG] Key4 => honk\r\n", toggle_4);
_0x5D:
	__POINTW1FN _0x0,327
	ST   -Y,R31
	ST   -Y,R30
	CALL SUBOPT_0x26
	CALL SUBOPT_0x8
	CALL SUBOPT_0x25
; 0000 0329                     lcd_cmd(0x01);
; 0000 032A                 break;
; 0000 032B 
; 0000 032C                 default:
_0x5E:
; 0000 032D                     // No key
; 0000 032E                 break;
; 0000 032F             }
_0x53:
; 0000 0330         }
	ADIW R28,2
; 0000 0331 
; 0000 0332       // Brake light => PC7
; 0000 0333         if(turn_brake_light)
	LDS  R30,_turn_brake_light
	CPI  R30,0
	BREQ _0x5F
; 0000 0334             PORTC |=  (1<<7);
	SBI  0x15,7
; 0000 0335         else
	RJMP _0x60
_0x5F:
; 0000 0336             PORTC &= ~(1<<7);
	CBI  0x15,7
; 0000 0337 
; 0000 0338       // Motor Control
; 0000 0339        updateMotorControl();
_0x60:
	RCALL _updateMotorControl
; 0000 033A 
; 0000 033B       // Beeping
; 0000 033C        if (directionFlag==-1)
	CALL SUBOPT_0x11
	CPI  R26,LOW(0xFFFF)
	LDI  R30,HIGH(0xFFFF)
	CPC  R27,R30
	BRNE _0x61
; 0000 033D        {
; 0000 033E               beep_when_reverse();
	RCALL _beep_when_reverse
; 0000 033F        }
; 0000 0340 
; 0000 0341        // LCD logic
; 0000 0342         if(second_flag)
_0x61:
	LDS  R30,_second_flag
	LDS  R31,_second_flag+1
	SBIW R30,0
	BRNE PC+2
	RJMP _0x62
; 0000 0343         {
; 0000 0344             second_flag = 0;  // reset the flag
	LDI  R30,LOW(0)
	STS  _second_flag,R30
	STS  _second_flag+1,R30
; 0000 0345 
; 0000 0346             // If lcd_timer_on => show time
; 0000 0347             if(lcd_timer_on)
	LDS  R30,_lcd_timer_on
	CPI  R30,0
	BREQ _0x63
; 0000 0348             {
; 0000 0349                 display_time_on_lcd();
	RCALL _display_time_on_lcd
; 0000 034A             }
; 0000 034B 
; 0000 034C             // We also handle menu updates once per second
; 0000 034D             switch(current_menu)
_0x63:
	LDS  R30,_current_menu
	LDS  R31,_current_menu+1
; 0000 034E             {
; 0000 034F                 case 1:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x67
; 0000 0350                     lcd_timer_on = true;
	LDI  R30,LOW(1)
	RJMP _0x6E
; 0000 0351                 break;
; 0000 0352 
; 0000 0353                 case 2:
_0x67:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x68
; 0000 0354                     lcd_timer_on = false;
	CALL SUBOPT_0x27
; 0000 0355                     sprintf(buffer,"speed:   %d", speed_value);
	__POINTW1FN _0x0,348
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R6
	CALL SUBOPT_0x8
	CALL SUBOPT_0x28
; 0000 0356                     lcd_gotoxy(0,0);
	CALL SUBOPT_0x9
	CALL SUBOPT_0x29
; 0000 0357                     lcd_print(buffer);
; 0000 0358 
; 0000 0359                     sprintf(buffer2,"menu=   %d", current_menu);
	CALL SUBOPT_0x28
; 0000 035A                     lcd_gotoxy(0,1);
	CALL SUBOPT_0xA
	CALL SUBOPT_0x21
; 0000 035B                     lcd_print(buffer2);
	CALL SUBOPT_0x2A
; 0000 035C                 break;
	RJMP _0x66
; 0000 035D 
; 0000 035E                 case 3:
_0x68:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x69
; 0000 035F                     lcd_timer_on = false;
	CALL SUBOPT_0x27
; 0000 0360                     sprintf(buffer,"temp:   %d", temp);
	__POINTW1FN _0x0,371
	ST   -Y,R31
	ST   -Y,R30
	CALL SUBOPT_0x23
	CALL SUBOPT_0x28
; 0000 0361                     lcd_gotoxy(0,0);
	CALL SUBOPT_0x9
	CALL SUBOPT_0x29
; 0000 0362                     lcd_print(buffer);
; 0000 0363 
; 0000 0364                     sprintf(buffer2,"menu=   %d", current_menu);
	CALL SUBOPT_0x28
; 0000 0365                     lcd_gotoxy(0,1);
	CALL SUBOPT_0xA
	CALL SUBOPT_0x21
; 0000 0366                     lcd_print(buffer2);
	CALL SUBOPT_0x2A
; 0000 0367                 break;
	RJMP _0x66
; 0000 0368 
; 0000 0369                 case 4:
_0x69:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0x6B
; 0000 036A                     lcd_timer_on = false;
	CALL SUBOPT_0x27
; 0000 036B                     sprintf(buffer,"fuel:   %d", fuel_level);
	__POINTW1FN _0x0,382
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R4
	CALL SUBOPT_0x8
	CALL SUBOPT_0x28
; 0000 036C                     lcd_gotoxy(0,0);
	CALL SUBOPT_0x9
	CALL SUBOPT_0x29
; 0000 036D                     lcd_print(buffer);
; 0000 036E 
; 0000 036F                     sprintf(buffer2,"menu=   %d", current_menu);
	CALL SUBOPT_0x28
; 0000 0370                     lcd_gotoxy(0,1);
	CALL SUBOPT_0xA
	CALL SUBOPT_0x21
; 0000 0371                     lcd_print(buffer2);
	CALL SUBOPT_0x2A
; 0000 0372                 break;
	RJMP _0x66
; 0000 0373 
; 0000 0374                 default:
_0x6B:
; 0000 0375                     // No menu
; 0000 0376                     lcd_timer_on = false;
	LDI  R30,LOW(0)
_0x6E:
	STS  _lcd_timer_on,R30
; 0000 0377                 break;
; 0000 0378             }
_0x66:
; 0000 0379         }
; 0000 037A 
; 0000 037B 
; 0000 037C         delay_ms(100);
_0x62:
	LDI  R26,LOW(100)
	LDI  R27,0
	CALL _delay_ms
; 0000 037D 
; 0000 037E       }
	RJMP _0x4E
; 0000 037F }
_0x6C:
	RJMP _0x6C
; .FEND

	.DSEG
_0x4D:
	.BYTE 0x5C
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif

	.CSEG
_putchar:
; .FSTART _putchar
	ST   -Y,R26
putchar0:
     sbis usr,udre
     rjmp putchar0
     ld   r30,y
     out  udr,r30
_0x2080005:
	ADIW R28,1
	RET
; .FEND
_put_usart_G100:
; .FSTART _put_usart_G100
	ST   -Y,R27
	ST   -Y,R26
	LDD  R26,Y+2
	RCALL _putchar
	LD   R26,Y
	LDD  R27,Y+1
	CALL SUBOPT_0x10
	RJMP _0x2080003
; .FEND
_put_buff_G100:
; .FSTART _put_buff_G100
	CALL SUBOPT_0x1
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,2
	CALL __GETW1P
	SBIW R30,0
	BREQ _0x2000010
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,4
	CALL __GETW1P
	MOVW R16,R30
	SBIW R30,0
	BREQ _0x2000012
	__CPWRN 16,17,2
	BRLO _0x2000013
	MOVW R30,R16
	SBIW R30,1
	MOVW R16,R30
	__PUTW1SNS 2,4
_0x2000012:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,2
	CALL SUBOPT_0x10
	SBIW R30,1
	LDD  R26,Y+4
	STD  Z+0,R26
_0x2000013:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL __GETW1P
	TST  R31
	BRMI _0x2000014
	CALL SUBOPT_0x10
_0x2000014:
	RJMP _0x2000015
_0x2000010:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	ST   X+,R30
	ST   X,R31
_0x2000015:
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,5
	RET
; .FEND
__print_G100:
; .FSTART __print_G100
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,6
	CALL __SAVELOCR6
	LDI  R17,0
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
_0x2000016:
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	ADIW R30,1
	STD  Y+18,R30
	STD  Y+18+1,R31
	SBIW R30,1
	LPM  R30,Z
	MOV  R18,R30
	CPI  R30,0
	BRNE PC+2
	RJMP _0x2000018
	MOV  R30,R17
	CPI  R30,0
	BRNE _0x200001C
	CPI  R18,37
	BRNE _0x200001D
	LDI  R17,LOW(1)
	RJMP _0x200001E
_0x200001D:
	CALL SUBOPT_0x2B
_0x200001E:
	RJMP _0x200001B
_0x200001C:
	CPI  R30,LOW(0x1)
	BRNE _0x200001F
	CPI  R18,37
	BRNE _0x2000020
	CALL SUBOPT_0x2B
	RJMP _0x20000CC
_0x2000020:
	LDI  R17,LOW(2)
	LDI  R20,LOW(0)
	LDI  R16,LOW(0)
	CPI  R18,45
	BRNE _0x2000021
	LDI  R16,LOW(1)
	RJMP _0x200001B
_0x2000021:
	CPI  R18,43
	BRNE _0x2000022
	LDI  R20,LOW(43)
	RJMP _0x200001B
_0x2000022:
	CPI  R18,32
	BRNE _0x2000023
	LDI  R20,LOW(32)
	RJMP _0x200001B
_0x2000023:
	RJMP _0x2000024
_0x200001F:
	CPI  R30,LOW(0x2)
	BRNE _0x2000025
_0x2000024:
	LDI  R21,LOW(0)
	LDI  R17,LOW(3)
	CPI  R18,48
	BRNE _0x2000026
	ORI  R16,LOW(128)
	RJMP _0x200001B
_0x2000026:
	RJMP _0x2000027
_0x2000025:
	CPI  R30,LOW(0x3)
	BREQ PC+2
	RJMP _0x200001B
_0x2000027:
	CPI  R18,48
	BRLO _0x200002A
	CPI  R18,58
	BRLO _0x200002B
_0x200002A:
	RJMP _0x2000029
_0x200002B:
	LDI  R26,LOW(10)
	MUL  R21,R26
	MOV  R21,R0
	MOV  R30,R18
	SUBI R30,LOW(48)
	ADD  R21,R30
	RJMP _0x200001B
_0x2000029:
	MOV  R30,R18
	CPI  R30,LOW(0x63)
	BRNE _0x200002F
	CALL SUBOPT_0x2C
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	LDD  R26,Z+4
	ST   -Y,R26
	CALL SUBOPT_0x2D
	RJMP _0x2000030
_0x200002F:
	CPI  R30,LOW(0x73)
	BRNE _0x2000032
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x2E
	CALL _strlen
	MOV  R17,R30
	RJMP _0x2000033
_0x2000032:
	CPI  R30,LOW(0x70)
	BRNE _0x2000035
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x2E
	CALL _strlenf
	MOV  R17,R30
	ORI  R16,LOW(8)
_0x2000033:
	ORI  R16,LOW(2)
	ANDI R16,LOW(127)
	LDI  R19,LOW(0)
	RJMP _0x2000036
_0x2000035:
	CPI  R30,LOW(0x64)
	BREQ _0x2000039
	CPI  R30,LOW(0x69)
	BRNE _0x200003A
_0x2000039:
	ORI  R16,LOW(4)
	RJMP _0x200003B
_0x200003A:
	CPI  R30,LOW(0x75)
	BRNE _0x200003C
_0x200003B:
	LDI  R30,LOW(_tbl10_G100*2)
	LDI  R31,HIGH(_tbl10_G100*2)
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R17,LOW(5)
	RJMP _0x200003D
_0x200003C:
	CPI  R30,LOW(0x58)
	BRNE _0x200003F
	ORI  R16,LOW(8)
	RJMP _0x2000040
_0x200003F:
	CPI  R30,LOW(0x78)
	BREQ PC+2
	RJMP _0x2000071
_0x2000040:
	LDI  R30,LOW(_tbl16_G100*2)
	LDI  R31,HIGH(_tbl16_G100*2)
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R17,LOW(4)
_0x200003D:
	SBRS R16,2
	RJMP _0x2000042
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x2F
	LDD  R26,Y+11
	TST  R26
	BRPL _0x2000043
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	CALL __ANEGW1
	STD  Y+10,R30
	STD  Y+10+1,R31
	LDI  R20,LOW(45)
_0x2000043:
	CPI  R20,0
	BREQ _0x2000044
	SUBI R17,-LOW(1)
	RJMP _0x2000045
_0x2000044:
	ANDI R16,LOW(251)
_0x2000045:
	RJMP _0x2000046
_0x2000042:
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x2F
_0x2000046:
_0x2000036:
	SBRC R16,0
	RJMP _0x2000047
_0x2000048:
	CP   R17,R21
	BRSH _0x200004A
	SBRS R16,7
	RJMP _0x200004B
	SBRS R16,2
	RJMP _0x200004C
	ANDI R16,LOW(251)
	MOV  R18,R20
	SUBI R17,LOW(1)
	RJMP _0x200004D
_0x200004C:
	LDI  R18,LOW(48)
_0x200004D:
	RJMP _0x200004E
_0x200004B:
	LDI  R18,LOW(32)
_0x200004E:
	CALL SUBOPT_0x2B
	SUBI R21,LOW(1)
	RJMP _0x2000048
_0x200004A:
_0x2000047:
	MOV  R19,R17
	SBRS R16,1
	RJMP _0x200004F
_0x2000050:
	CPI  R19,0
	BREQ _0x2000052
	SBRS R16,3
	RJMP _0x2000053
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LPM  R18,Z+
	STD  Y+6,R30
	STD  Y+6+1,R31
	RJMP _0x2000054
_0x2000053:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LD   R18,X+
	STD  Y+6,R26
	STD  Y+6+1,R27
_0x2000054:
	CALL SUBOPT_0x2B
	CPI  R21,0
	BREQ _0x2000055
	SUBI R21,LOW(1)
_0x2000055:
	SUBI R19,LOW(1)
	RJMP _0x2000050
_0x2000052:
	RJMP _0x2000056
_0x200004F:
_0x2000058:
	LDI  R18,LOW(48)
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	CALL __GETW1PF
	STD  Y+8,R30
	STD  Y+8+1,R31
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,2
	STD  Y+6,R30
	STD  Y+6+1,R31
_0x200005A:
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CP   R26,R30
	CPC  R27,R31
	BRLO _0x200005C
	SUBI R18,-LOW(1)
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	SUB  R30,R26
	SBC  R31,R27
	STD  Y+10,R30
	STD  Y+10+1,R31
	RJMP _0x200005A
_0x200005C:
	CPI  R18,58
	BRLO _0x200005D
	SBRS R16,3
	RJMP _0x200005E
	SUBI R18,-LOW(7)
	RJMP _0x200005F
_0x200005E:
	SUBI R18,-LOW(39)
_0x200005F:
_0x200005D:
	SBRC R16,4
	RJMP _0x2000061
	CPI  R18,49
	BRSH _0x2000063
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	SBIW R26,1
	BRNE _0x2000062
_0x2000063:
	RJMP _0x20000CD
_0x2000062:
	CP   R21,R19
	BRLO _0x2000067
	SBRS R16,0
	RJMP _0x2000068
_0x2000067:
	RJMP _0x2000066
_0x2000068:
	LDI  R18,LOW(32)
	SBRS R16,7
	RJMP _0x2000069
	LDI  R18,LOW(48)
_0x20000CD:
	ORI  R16,LOW(16)
	SBRS R16,2
	RJMP _0x200006A
	ANDI R16,LOW(251)
	ST   -Y,R20
	CALL SUBOPT_0x2D
	CPI  R21,0
	BREQ _0x200006B
	SUBI R21,LOW(1)
_0x200006B:
_0x200006A:
_0x2000069:
_0x2000061:
	CALL SUBOPT_0x2B
	CPI  R21,0
	BREQ _0x200006C
	SUBI R21,LOW(1)
_0x200006C:
_0x2000066:
	SUBI R19,LOW(1)
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	SBIW R26,2
	BRLO _0x2000059
	RJMP _0x2000058
_0x2000059:
_0x2000056:
	SBRS R16,0
	RJMP _0x200006D
_0x200006E:
	CPI  R21,0
	BREQ _0x2000070
	SUBI R21,LOW(1)
	LDI  R30,LOW(32)
	ST   -Y,R30
	CALL SUBOPT_0x2D
	RJMP _0x200006E
_0x2000070:
_0x200006D:
_0x2000071:
_0x2000030:
_0x20000CC:
	LDI  R17,LOW(0)
_0x200001B:
	RJMP _0x2000016
_0x2000018:
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	CALL __GETW1P
	CALL __LOADLOCR6
	ADIW R28,20
	RET
; .FEND
_sprintf:
; .FSTART _sprintf
	PUSH R15
	MOV  R15,R24
	SBIW R28,6
	CALL __SAVELOCR4
	CALL SUBOPT_0x30
	SBIW R30,0
	BRNE _0x2000072
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x2080004
_0x2000072:
	MOVW R26,R28
	ADIW R26,6
	CALL __ADDW2R15
	MOVW R16,R26
	CALL SUBOPT_0x30
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R30,LOW(0)
	STD  Y+8,R30
	STD  Y+8+1,R30
	MOVW R26,R28
	ADIW R26,10
	CALL SUBOPT_0x31
	LDI  R30,LOW(_put_buff_G100)
	LDI  R31,HIGH(_put_buff_G100)
	ST   -Y,R31
	ST   -Y,R30
	MOVW R26,R28
	ADIW R26,10
	RCALL __print_G100
	MOVW R18,R30
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(0)
	ST   X,R30
	MOVW R30,R18
_0x2080004:
	CALL __LOADLOCR4
	ADIW R28,10
	POP  R15
	RET
; .FEND
_printf:
; .FSTART _printf
	PUSH R15
	MOV  R15,R24
	SBIW R28,6
	ST   -Y,R17
	ST   -Y,R16
	MOVW R26,R28
	ADIW R26,4
	CALL __ADDW2R15
	MOVW R16,R26
	LDI  R30,LOW(0)
	STD  Y+4,R30
	STD  Y+4+1,R30
	STD  Y+6,R30
	STD  Y+6+1,R30
	MOVW R26,R28
	ADIW R26,8
	CALL SUBOPT_0x31
	LDI  R30,LOW(_put_usart_G100)
	LDI  R31,HIGH(_put_usart_G100)
	ST   -Y,R31
	ST   -Y,R30
	MOVW R26,R28
	ADIW R26,8
	RCALL __print_G100
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,8
	POP  R15
	RET
; .FEND
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif

	.DSEG

	.CSEG
_twi_master_init:
; .FSTART _twi_master_init
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
	SET
	BLD  R2,1
	LDI  R30,LOW(7)
	STS  _twi_result,R30
	LDI  R30,LOW(0)
	STS  _twi_slave_rx_handler_G101,R30
	STS  _twi_slave_rx_handler_G101+1,R30
	STS  _twi_slave_tx_handler_G101,R30
	STS  _twi_slave_tx_handler_G101+1,R30
	SBI  0x15,1
	SBI  0x15,0
	OUT  0x36,R30
	IN   R30,0x1
	ANDI R30,LOW(0xFC)
	OUT  0x1,R30
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	LDI  R26,LOW(4000)
	LDI  R27,HIGH(4000)
	CALL __DIVW21U
	MOV  R17,R30
	CPI  R17,8
	BRLO _0x2020004
	SUBI R17,LOW(8)
_0x2020004:
	OUT  0x0,R17
	IN   R30,0x36
	ANDI R30,LOW(0x80)
	ORI  R30,LOW(0x45)
	OUT  0x36,R30
	LDD  R17,Y+0
_0x2080003:
	ADIW R28,3
	RET
; .FEND
_twi_master_trans:
; .FSTART _twi_master_trans
	ST   -Y,R26
	SBIW R28,4
	SBRS R2,1
	RJMP _0x2020005
	LDD  R30,Y+10
	LSL  R30
	STS  _slave_address_G101,R30
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	STS  _twi_tx_buffer_G101,R30
	STS  _twi_tx_buffer_G101+1,R31
	LDI  R30,LOW(0)
	STS  _twi_tx_index,R30
	LDD  R30,Y+7
	STS  _bytes_to_tx_G101,R30
	LDD  R30,Y+5
	LDD  R31,Y+5+1
	STS  _twi_rx_buffer_G101,R30
	STS  _twi_rx_buffer_G101+1,R31
	LDI  R30,LOW(0)
	STS  _twi_rx_index,R30
	LDD  R30,Y+4
	STS  _bytes_to_rx_G101,R30
	LDI  R30,LOW(6)
	STS  _twi_result,R30
	sei
	LDD  R30,Y+7
	CPI  R30,0
	BREQ _0x2020006
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	SBIW R30,0
	BRNE _0x2020007
	RJMP _0x2080002
_0x2020007:
	LDD  R30,Y+4
	CPI  R30,0
	BREQ _0x2020009
	LDD  R26,Y+5
	LDD  R27,Y+5+1
	SBIW R26,0
	BREQ _0x202000A
_0x2020009:
	RJMP _0x2020008
_0x202000A:
	RJMP _0x2080002
_0x2020008:
	SET
	RJMP _0x2020065
_0x2020006:
	LDD  R30,Y+4
	CPI  R30,0
	BREQ _0x202000C
	LDD  R30,Y+5
	LDD  R31,Y+5+1
	SBIW R30,0
	BREQ _0x2080002
	LDS  R30,_slave_address_G101
	ORI  R30,1
	STS  _slave_address_G101,R30
	CLT
_0x2020065:
	BLD  R2,0
	CLT
	BLD  R2,1
	IN   R30,0x36
	ANDI R30,LOW(0xF)
	ORI  R30,LOW(0xA0)
	OUT  0x36,R30
	__GETD1N 0x7A120
	CALL __PUTD1S0
_0x202000E:
	SBRC R2,1
	RJMP _0x2020010
	CALL __GETD1S0
	SBIW R30,1
	SBCI R22,0
	SBCI R23,0
	CALL __PUTD1S0
	BRNE _0x2020011
	LDI  R30,LOW(5)
	STS  _twi_result,R30
	SET
	BLD  R2,1
	RJMP _0x2080002
_0x2020011:
	RJMP _0x202000E
_0x2020010:
_0x202000C:
	LDS  R26,_twi_result
	LDI  R30,LOW(0)
	CALL __EQB12
	RJMP _0x2080001
_0x2020005:
_0x2080002:
	LDI  R30,LOW(0)
_0x2080001:
	ADIW R28,11
	RET
; .FEND
_twi_int_handler:
; .FSTART _twi_int_handler
	ST   -Y,R0
	ST   -Y,R1
	ST   -Y,R15
	ST   -Y,R22
	ST   -Y,R23
	ST   -Y,R24
	ST   -Y,R25
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
	CALL __SAVELOCR6
	LDS  R17,_twi_rx_index
	LDS  R16,_twi_tx_index
	LDS  R19,_bytes_to_tx_G101
	LDS  R18,_twi_result
	MOV  R30,R17
	LDS  R26,_twi_rx_buffer_G101
	LDS  R27,_twi_rx_buffer_G101+1
	LDI  R31,0
	ADD  R30,R26
	ADC  R31,R27
	MOVW R20,R30
	IN   R30,0x1
	ANDI R30,LOW(0xF8)
	CPI  R30,LOW(0x8)
	BRNE _0x2020017
	LDI  R18,LOW(0)
	RJMP _0x2020018
_0x2020017:
	CPI  R30,LOW(0x10)
	BRNE _0x2020019
_0x2020018:
	LDS  R30,_slave_address_G101
	RJMP _0x2020067
_0x2020019:
	CPI  R30,LOW(0x18)
	BREQ _0x202001D
	CPI  R30,LOW(0x28)
	BRNE _0x202001E
_0x202001D:
	CP   R16,R19
	BRSH _0x202001F
	MOV  R30,R16
	SUBI R16,-1
	LDS  R26,_twi_tx_buffer_G101
	LDS  R27,_twi_tx_buffer_G101+1
	LDI  R31,0
	ADD  R26,R30
	ADC  R27,R31
	LD   R30,X
_0x2020067:
	OUT  0x3,R30
	IN   R30,0x36
	ANDI R30,LOW(0xF)
	ORI  R30,0x80
	OUT  0x36,R30
	RJMP _0x2020020
_0x202001F:
	LDS  R30,_bytes_to_rx_G101
	CP   R17,R30
	BRSH _0x2020021
	LDS  R30,_slave_address_G101
	ORI  R30,1
	STS  _slave_address_G101,R30
	CLT
	BLD  R2,0
	IN   R30,0x36
	ANDI R30,LOW(0xF)
	ORI  R30,LOW(0xA0)
	OUT  0x36,R30
	RJMP _0x2020016
_0x2020021:
	RJMP _0x2020022
_0x2020020:
	RJMP _0x2020016
_0x202001E:
	CPI  R30,LOW(0x50)
	BRNE _0x2020023
	IN   R30,0x3
	MOVW R26,R20
	ST   X,R30
	SUBI R17,-LOW(1)
	RJMP _0x2020024
_0x2020023:
	CPI  R30,LOW(0x40)
	BRNE _0x2020025
_0x2020024:
	LDS  R30,_bytes_to_rx_G101
	SUBI R30,LOW(1)
	CP   R17,R30
	BRLO _0x2020026
	IN   R30,0x36
	ANDI R30,LOW(0xF)
	ORI  R30,0x80
	RJMP _0x2020068
_0x2020026:
	IN   R30,0x36
	ANDI R30,LOW(0xF)
	ORI  R30,LOW(0xC0)
_0x2020068:
	OUT  0x36,R30
	RJMP _0x2020016
_0x2020025:
	CPI  R30,LOW(0x58)
	BRNE _0x2020028
	IN   R30,0x3
	MOVW R26,R20
	ST   X,R30
	SUBI R17,-LOW(1)
	RJMP _0x2020029
_0x2020028:
	CPI  R30,LOW(0x20)
	BRNE _0x202002A
_0x2020029:
	RJMP _0x202002B
_0x202002A:
	CPI  R30,LOW(0x30)
	BRNE _0x202002C
_0x202002B:
	RJMP _0x202002D
_0x202002C:
	CPI  R30,LOW(0x48)
	BRNE _0x202002E
_0x202002D:
	CPI  R18,0
	BRNE _0x202002F
	SBRS R2,0
	RJMP _0x2020030
	CP   R16,R19
	BRLO _0x2020032
	RJMP _0x2020033
_0x2020030:
	LDS  R30,_bytes_to_rx_G101
	CP   R17,R30
	BRSH _0x2020034
_0x2020032:
	LDI  R18,LOW(4)
_0x2020034:
_0x2020033:
_0x202002F:
_0x2020022:
	RJMP _0x2020069
_0x202002E:
	CPI  R30,LOW(0x38)
	BRNE _0x2020037
	LDI  R18,LOW(2)
	IN   R30,0x36
	ANDI R30,LOW(0xF)
	ORI  R30,0x80
	RJMP _0x202006A
_0x2020037:
	CPI  R30,LOW(0x68)
	BREQ _0x202003A
	CPI  R30,LOW(0x78)
	BRNE _0x202003B
_0x202003A:
	LDI  R18,LOW(2)
	RJMP _0x202003C
_0x202003B:
	CPI  R30,LOW(0x60)
	BREQ _0x202003F
	CPI  R30,LOW(0x70)
	BRNE _0x2020040
_0x202003F:
	LDI  R18,LOW(0)
_0x202003C:
	LDI  R17,LOW(0)
	CLT
	BLD  R2,0
	LDS  R30,_twi_rx_buffer_size_G101
	CPI  R30,0
	BRNE _0x2020041
	LDI  R18,LOW(1)
	IN   R30,0x36
	ANDI R30,LOW(0xF)
	ORI  R30,0x80
	RJMP _0x202006B
_0x2020041:
	IN   R30,0x36
	ANDI R30,LOW(0xF)
	ORI  R30,LOW(0xC0)
_0x202006B:
	OUT  0x36,R30
	RJMP _0x2020016
_0x2020040:
	CPI  R30,LOW(0x80)
	BREQ _0x2020044
	CPI  R30,LOW(0x90)
	BRNE _0x2020045
_0x2020044:
	SBRS R2,0
	RJMP _0x2020046
	LDI  R18,LOW(1)
	RJMP _0x2020047
_0x2020046:
	IN   R30,0x3
	MOVW R26,R20
	ST   X,R30
	SUBI R17,-LOW(1)
	LDS  R30,_twi_rx_buffer_size_G101
	CP   R17,R30
	BRSH _0x2020048
	LDS  R30,_twi_slave_rx_handler_G101
	LDS  R31,_twi_slave_rx_handler_G101+1
	SBIW R30,0
	BRNE _0x2020049
	LDI  R18,LOW(6)
	RJMP _0x2020047
_0x2020049:
	LDI  R26,LOW(0)
	__CALL1MN _twi_slave_rx_handler_G101,0
	CPI  R30,0
	BREQ _0x202004A
	IN   R30,0x36
	ANDI R30,LOW(0xF)
	ORI  R30,LOW(0xC0)
	OUT  0x36,R30
	RJMP _0x2020016
_0x202004A:
	RJMP _0x202004B
_0x2020048:
	SET
	BLD  R2,0
_0x202004B:
	RJMP _0x202004C
_0x2020045:
	CPI  R30,LOW(0x88)
	BRNE _0x202004D
_0x202004C:
	RJMP _0x202004E
_0x202004D:
	CPI  R30,LOW(0x98)
	BRNE _0x202004F
_0x202004E:
	IN   R30,0x36
	ANDI R30,LOW(0xF)
	ORI  R30,0x80
	OUT  0x36,R30
	RJMP _0x2020016
_0x202004F:
	CPI  R30,LOW(0xA0)
	BRNE _0x2020050
	IN   R30,0x36
	ANDI R30,LOW(0xF)
	ORI  R30,LOW(0xC0)
	OUT  0x36,R30
	SET
	BLD  R2,1
	LDS  R30,_twi_slave_rx_handler_G101
	LDS  R31,_twi_slave_rx_handler_G101+1
	SBIW R30,0
	BREQ _0x2020051
	LDI  R26,LOW(1)
	__CALL1MN _twi_slave_rx_handler_G101,0
	RJMP _0x2020052
_0x2020051:
	LDI  R18,LOW(6)
_0x2020052:
	RJMP _0x2020016
_0x2020050:
	CPI  R30,LOW(0xB0)
	BRNE _0x2020053
	LDI  R18,LOW(2)
	RJMP _0x2020054
_0x2020053:
	CPI  R30,LOW(0xA8)
	BRNE _0x2020055
_0x2020054:
	LDS  R30,_twi_slave_tx_handler_G101
	LDS  R31,_twi_slave_tx_handler_G101+1
	SBIW R30,0
	BREQ _0x2020056
	LDI  R26,LOW(0)
	__CALL1MN _twi_slave_tx_handler_G101,0
	MOV  R19,R30
	CPI  R30,0
	BREQ _0x2020058
	LDI  R18,LOW(0)
	RJMP _0x2020059
_0x2020056:
_0x2020058:
	LDI  R18,LOW(6)
	RJMP _0x2020047
_0x2020059:
	LDI  R16,LOW(0)
	CLT
	BLD  R2,0
	RJMP _0x202005A
_0x2020055:
	CPI  R30,LOW(0xB8)
	BRNE _0x202005B
_0x202005A:
	SBRS R2,0
	RJMP _0x202005C
	LDI  R18,LOW(1)
	RJMP _0x2020047
_0x202005C:
	MOV  R30,R16
	SUBI R16,-1
	LDS  R26,_twi_tx_buffer_G101
	LDS  R27,_twi_tx_buffer_G101+1
	LDI  R31,0
	ADD  R26,R30
	ADC  R27,R31
	LD   R30,X
	OUT  0x3,R30
	CP   R16,R19
	BRSH _0x202005D
	IN   R30,0x36
	ANDI R30,LOW(0xF)
	ORI  R30,LOW(0xC0)
	RJMP _0x202006C
_0x202005D:
	SET
	BLD  R2,0
	IN   R30,0x36
	ANDI R30,LOW(0xF)
	ORI  R30,0x80
_0x202006C:
	OUT  0x36,R30
	RJMP _0x2020016
_0x202005B:
	CPI  R30,LOW(0xC0)
	BREQ _0x2020060
	CPI  R30,LOW(0xC8)
	BRNE _0x2020061
_0x2020060:
	IN   R30,0x36
	ANDI R30,LOW(0xF)
	ORI  R30,LOW(0xC0)
	OUT  0x36,R30
	LDS  R30,_twi_slave_tx_handler_G101
	LDS  R31,_twi_slave_tx_handler_G101+1
	SBIW R30,0
	BREQ _0x2020062
	LDI  R26,LOW(1)
	__CALL1MN _twi_slave_tx_handler_G101,0
_0x2020062:
	RJMP _0x2020035
_0x2020061:
	CPI  R30,0
	BRNE _0x2020016
	LDI  R18,LOW(3)
_0x2020047:
_0x2020069:
	IN   R30,0x36
	ANDI R30,LOW(0xF)
	ORI  R30,LOW(0xD0)
_0x202006A:
	OUT  0x36,R30
_0x2020035:
	SET
	BLD  R2,1
_0x2020016:
	STS  _twi_rx_index,R17
	STS  _twi_tx_index,R16
	STS  _twi_result,R18
	STS  _bytes_to_tx_G101,R19
	CALL __LOADLOCR6
	ADIW R28,6
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	LD   R25,Y+
	LD   R24,Y+
	LD   R23,Y+
	LD   R22,Y+
	LD   R15,Y+
	LD   R1,Y+
	LD   R0,Y+
	RETI
; .FEND

	.CSEG

	.CSEG
_strlen:
; .FSTART _strlen
	ST   -Y,R27
	ST   -Y,R26
    ld   r26,y+
    ld   r27,y+
    clr  r30
    clr  r31
strlen0:
    ld   r22,x+
    tst  r22
    breq strlen1
    adiw r30,1
    rjmp strlen0
strlen1:
    ret
; .FEND
_strlenf:
; .FSTART _strlenf
	ST   -Y,R27
	ST   -Y,R26
    clr  r26
    clr  r27
    ld   r30,y+
    ld   r31,y+
strlenf0:
	lpm  r0,z+
    tst  r0
    breq strlenf1
    adiw r26,1
    rjmp strlenf0
strlenf1:
    movw r30,r26
    ret
; .FEND

	.DSEG
_twi_tx_index:
	.BYTE 0x1
_twi_rx_index:
	.BYTE 0x1
_twi_result:
	.BYTE 0x1
_seconds:
	.BYTE 0x2
_minutes:
	.BYTE 0x2
_hours:
	.BYTE 0x2
_second_flag:
	.BYTE 0x2
_current_menu:
	.BYTE 0x2
_baseSpeed:
	.BYTE 0x4
_scaledSpeed:
	.BYTE 0x4
_steer_offset:
	.BYTE 0x4
_offsetScaled:
	.BYTE 0x4
_leftSpeedVal:
	.BYTE 0x4
_rightSpeedVal:
	.BYTE 0x4
_lcd_timer_on:
	.BYTE 0x1
_buffer:
	.BYTE 0x11
_buffer2:
	.BYTE 0x11
_temp:
	.BYTE 0x2
_directionFlag:
	.BYTE 0x2
_int_button_used:
	.BYTE 0x1
_turn_brake_light:
	.BYTE 0x1
_toggle_G000:
	.BYTE 0x2
_toggle_4:
	.BYTE 0x2
_buffer_time:
	.BYTE 0x11
_firstKey:
	.BYTE 0x2
_secondKey:
	.BYTE 0x2
_count_S0000016000:
	.BYTE 0x2
_slave_address_G101:
	.BYTE 0x1
_twi_tx_buffer_G101:
	.BYTE 0x2
_bytes_to_tx_G101:
	.BYTE 0x1
_twi_rx_buffer_G101:
	.BYTE 0x2
_bytes_to_rx_G101:
	.BYTE 0x1
_twi_rx_buffer_size_G101:
	.BYTE 0x1
_twi_slave_rx_handler_G101:
	.BYTE 0x2
_twi_slave_tx_handler_G101:
	.BYTE 0x2

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x0:
	LDI  R30,LOW(1)
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	JMP  _twi_master_trans

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1:
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
	ST   -Y,R16
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x2:
	ANDI R30,LOW(0xF0)
	ANDI R31,HIGH(0xF0)
	ST   -Y,R31
	ST   -Y,R30
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	JMP  _lcd_send_nibble

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x3:
	ST   -Y,R27
	ST   -Y,R26
	LD   R30,Y
	LDD  R31,Y+1
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x4:
	LDI  R27,0
	CALL _delay_ms
	LDI  R30,LOW(48)
	LDI  R31,HIGH(48)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	JMP  _lcd_send_nibble

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x5:
	__DELAY_USW 200
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x6:
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	CALL _lcd_send_nibble
	RJMP SUBOPT_0x5

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:11 WORDS
SUBOPT_0x7:
	LDI  R26,LOW(1)
	LDI  R27,0
	JMP  _lcd_cmd

;OPTIMIZER ADDED SUBROUTINE, CALLED 19 TIMES, CODE SIZE REDUCTION:33 WORDS
SUBOPT_0x8:
	CALL __CWD1
	CALL __PUTPARD1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:12 WORDS
SUBOPT_0x9:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0xA:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xB:
	LDS  R30,_firstKey
	LDS  R31,_firstKey+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0xC:
	CALL __GETD2S0
	__CPD2N 0x9C41
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0xD:
	__GETD1N 0x9C40
	CALL __PUTD1S0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:8 WORDS
SUBOPT_0xE:
	ST   -Y,R0
	ST   -Y,R1
	ST   -Y,R15
	ST   -Y,R22
	ST   -Y,R23
	ST   -Y,R24
	ST   -Y,R25
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0xF:
	ST   -Y,R31
	ST   -Y,R30
	LDI  R24,0
	CALL _printf
	ADIW R28,2
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:18 WORDS
SUBOPT_0x10:
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x11:
	LDS  R26,_directionFlag
	LDS  R27,_directionFlag+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x12:
	STS  _baseSpeed,R30
	STS  _baseSpeed+1,R31
	STS  _baseSpeed+2,R22
	STS  _baseSpeed+3,R23
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x13:
	LDS  R30,_baseSpeed
	LDS  R31,_baseSpeed+1
	LDS  R22,_baseSpeed+2
	LDS  R23,_baseSpeed+3
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x14:
	__GETD2N 0x9C40
	CALL __MULD12
	MOVW R26,R30
	MOVW R24,R22
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x15:
	STS  _scaledSpeed,R30
	STS  _scaledSpeed+1,R31
	STS  _scaledSpeed+2,R22
	STS  _scaledSpeed+3,R23
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x16:
	LDS  R26,_scaledSpeed
	LDS  R27,_scaledSpeed+1
	LDS  R24,_scaledSpeed+2
	LDS  R25,_scaledSpeed+3
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x17:
	__CPD2N 0x9C41
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x18:
	__GETD1N 0x9C40
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x19:
	STS  _leftSpeedVal,R30
	STS  _leftSpeedVal+1,R31
	STS  _leftSpeedVal+2,R22
	STS  _leftSpeedVal+3,R23
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x1A:
	STS  _rightSpeedVal,R30
	STS  _rightSpeedVal+1,R31
	STS  _rightSpeedVal+2,R22
	STS  _rightSpeedVal+3,R23
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x1B:
	LDS  R26,_leftSpeedVal
	LDS  R27,_leftSpeedVal+1
	LDS  R24,_leftSpeedVal+2
	LDS  R25,_leftSpeedVal+3
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x1C:
	LDS  R26,_rightSpeedVal
	LDS  R27,_rightSpeedVal+1
	LDS  R24,_rightSpeedVal+2
	LDS  R25,_rightSpeedVal+3
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x1D:
	__GETD2N 0x0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1E:
	CALL _setLeftMotorSpeed
	RJMP SUBOPT_0x1D

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x1F:
	CALL _setRightMotorSpeed
	LDI  R26,LOW(0)
	LDI  R27,0
	CALL _setLeftMotorDirection
	LDI  R26,LOW(0)
	LDI  R27,0
	JMP  _setRightMotorDirection

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x20:
	CALL _lcd_print
	RJMP SUBOPT_0xA

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x21:
	LDI  R26,LOW(1)
	LDI  R27,0
	JMP  _lcd_gotoxy

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x22:
	CALL _lcd_print
	LDI  R26,LOW(1000)
	LDI  R27,HIGH(1000)
	CALL _delay_ms
	RJMP SUBOPT_0x7

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x23:
	LDS  R30,_temp
	LDS  R31,_temp+1
	RJMP SUBOPT_0x8

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x24:
	ST   -Y,R31
	ST   -Y,R30
	LDS  R30,_current_menu
	LDS  R31,_current_menu+1
	RJMP SUBOPT_0x8

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x25:
	LDI  R24,4
	CALL _printf
	ADIW R28,6
	RJMP SUBOPT_0x7

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x26:
	LDS  R30,_toggle_4
	LDS  R31,_toggle_4+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x27:
	LDI  R30,LOW(0)
	STS  _lcd_timer_on,R30
	LDI  R30,LOW(_buffer)
	LDI  R31,HIGH(_buffer)
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x28:
	LDI  R24,4
	CALL _sprintf
	ADIW R28,8
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:23 WORDS
SUBOPT_0x29:
	LDI  R27,0
	CALL _lcd_gotoxy
	LDI  R26,LOW(_buffer)
	LDI  R27,HIGH(_buffer)
	CALL _lcd_print
	LDI  R30,LOW(_buffer2)
	LDI  R31,HIGH(_buffer2)
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x0,360
	RJMP SUBOPT_0x24

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x2A:
	LDI  R26,LOW(_buffer2)
	LDI  R27,HIGH(_buffer2)
	JMP  _lcd_print

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:13 WORDS
SUBOPT_0x2B:
	ST   -Y,R18
	LDD  R26,Y+13
	LDD  R27,Y+13+1
	LDD  R30,Y+15
	LDD  R31,Y+15+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x2C:
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	SBIW R30,4
	STD  Y+16,R30
	STD  Y+16+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x2D:
	LDD  R26,Y+13
	LDD  R27,Y+13+1
	LDD  R30,Y+15
	LDD  R31,Y+15+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x2E:
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	ADIW R26,4
	CALL __GETW1P
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x2F:
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	ADIW R26,4
	CALL __GETW1P
	STD  Y+10,R30
	STD  Y+10+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x30:
	MOVW R26,R28
	ADIW R26,12
	CALL __ADDW2R15
	CALL __GETW1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x31:
	CALL __ADDW2R15
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R17
	ST   -Y,R16
	RET


	.CSEG
_delay_ms:
	adiw r26,0
	breq __delay_ms1
__delay_ms0:
	wdr
	__DELAY_USW 0x7D0
	sbiw r26,1
	brne __delay_ms0
__delay_ms1:
	ret

__ADDW2R15:
	CLR  R0
	ADD  R26,R15
	ADC  R27,R0
	RET

__ADDD12:
	ADD  R30,R26
	ADC  R31,R27
	ADC  R22,R24
	ADC  R23,R25
	RET

__SUBD12:
	SUB  R30,R26
	SBC  R31,R27
	SBC  R22,R24
	SBC  R23,R25
	RET

__ANEGW1:
	NEG  R31
	NEG  R30
	SBCI R31,0
	RET

__ANEGD1:
	COM  R31
	COM  R22
	COM  R23
	NEG  R30
	SBCI R31,-1
	SBCI R22,-1
	SBCI R23,-1
	RET

__LSLW4:
	LSL  R30
	ROL  R31
__LSLW3:
	LSL  R30
	ROL  R31
__LSLW2:
	LSL  R30
	ROL  R31
	LSL  R30
	ROL  R31
	RET

__CWD1:
	MOV  R22,R31
	ADD  R22,R22
	SBC  R22,R22
	MOV  R23,R22
	RET

__EQB12:
	CP   R30,R26
	LDI  R30,1
	BREQ __EQB12T
	CLR  R30
__EQB12T:
	RET

__LNEGB1:
	TST  R30
	LDI  R30,1
	BREQ __LNEGB1F
	CLR  R30
__LNEGB1F:
	RET

__LNEGW1:
	OR   R30,R31
	LDI  R30,1
	BREQ __LNEGW1F
	LDI  R30,0
__LNEGW1F:
	RET

__MULD12U:
	MUL  R23,R26
	MOV  R23,R0
	MUL  R22,R27
	ADD  R23,R0
	MUL  R31,R24
	ADD  R23,R0
	MUL  R30,R25
	ADD  R23,R0
	MUL  R22,R26
	MOV  R22,R0
	ADD  R23,R1
	MUL  R31,R27
	ADD  R22,R0
	ADC  R23,R1
	MUL  R30,R24
	ADD  R22,R0
	ADC  R23,R1
	CLR  R24
	MUL  R31,R26
	MOV  R31,R0
	ADD  R22,R1
	ADC  R23,R24
	MUL  R30,R27
	ADD  R31,R0
	ADC  R22,R1
	ADC  R23,R24
	MUL  R30,R26
	MOV  R30,R0
	ADD  R31,R1
	ADC  R22,R24
	ADC  R23,R24
	RET

__MULD12:
	RCALL __CHKSIGND
	RCALL __MULD12U
	BRTC __MULD121
	RCALL __ANEGD1
__MULD121:
	RET

__DIVW21U:
	CLR  R0
	CLR  R1
	LDI  R25,16
__DIVW21U1:
	LSL  R26
	ROL  R27
	ROL  R0
	ROL  R1
	SUB  R0,R30
	SBC  R1,R31
	BRCC __DIVW21U2
	ADD  R0,R30
	ADC  R1,R31
	RJMP __DIVW21U3
__DIVW21U2:
	SBR  R26,1
__DIVW21U3:
	DEC  R25
	BRNE __DIVW21U1
	MOVW R30,R26
	MOVW R26,R0
	RET

__DIVD21U:
	PUSH R19
	PUSH R20
	PUSH R21
	CLR  R0
	CLR  R1
	CLR  R20
	CLR  R21
	LDI  R19,32
__DIVD21U1:
	LSL  R26
	ROL  R27
	ROL  R24
	ROL  R25
	ROL  R0
	ROL  R1
	ROL  R20
	ROL  R21
	SUB  R0,R30
	SBC  R1,R31
	SBC  R20,R22
	SBC  R21,R23
	BRCC __DIVD21U2
	ADD  R0,R30
	ADC  R1,R31
	ADC  R20,R22
	ADC  R21,R23
	RJMP __DIVD21U3
__DIVD21U2:
	SBR  R26,1
__DIVD21U3:
	DEC  R19
	BRNE __DIVD21U1
	MOVW R30,R26
	MOVW R22,R24
	MOVW R26,R0
	MOVW R24,R20
	POP  R21
	POP  R20
	POP  R19
	RET

__DIVD21:
	RCALL __CHKSIGND
	RCALL __DIVD21U
	BRTC __DIVD211
	RCALL __ANEGD1
__DIVD211:
	RET

__CHKSIGND:
	CLT
	SBRS R23,7
	RJMP __CHKSD1
	RCALL __ANEGD1
	SET
__CHKSD1:
	SBRS R25,7
	RJMP __CHKSD2
	CLR  R0
	COM  R26
	COM  R27
	COM  R24
	COM  R25
	ADIW R26,1
	ADC  R24,R0
	ADC  R25,R0
	BLD  R0,0
	INC  R0
	BST  R0,0
__CHKSD2:
	RET

__GETW1P:
	LD   R30,X+
	LD   R31,X
	SBIW R26,1
	RET

__GETW1PF:
	LPM  R0,Z+
	LPM  R31,Z
	MOV  R30,R0
	RET

__GETD1S0:
	LD   R30,Y
	LDD  R31,Y+1
	LDD  R22,Y+2
	LDD  R23,Y+3
	RET

__GETD2S0:
	LD   R26,Y
	LDD  R27,Y+1
	LDD  R24,Y+2
	LDD  R25,Y+3
	RET

__PUTD1S0:
	ST   Y,R30
	STD  Y+1,R31
	STD  Y+2,R22
	STD  Y+3,R23
	RET

__CLRD1S0:
	ST   Y,R30
	STD  Y+1,R30
	STD  Y+2,R30
	STD  Y+3,R30
	RET

__PUTPARD1:
	ST   -Y,R23
	ST   -Y,R22
	ST   -Y,R31
	ST   -Y,R30
	RET

__PUTPARD2:
	ST   -Y,R25
	ST   -Y,R24
	ST   -Y,R27
	ST   -Y,R26
	RET

__SAVELOCR6:
	ST   -Y,R21
__SAVELOCR5:
	ST   -Y,R20
__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR6:
	LDD  R21,Y+5
__LOADLOCR5:
	LDD  R20,Y+4
__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

;END OF CODE MARKER
__END_OF_CODE:
