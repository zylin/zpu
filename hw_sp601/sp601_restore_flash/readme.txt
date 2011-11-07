*******************************************************************************
** © Copyright 2010 Xilinx, Inc. All rights reserved.
** This file contains confidential and proprietary information of Xilinx, Inc. and 
** is protected under U.S. and international copyright and other intellectual property laws.
*******************************************************************************
**   ____  ____ 
**  /   /\/   / 
** /___/  \  /   Vendor: Xilinx 
** \   \   \/    
**  \   \        readme.txt
**  /   /        
** /___/   /\    
** \   \  /  \   Associated Filename: <rdf0004.zip>
**  \___\/\___\ 
** 
**  Device: Spartan-6 FPGA
**  Purpose:XTP040 is a tutorial for restoring the flash contents on the SP601 evaluation board
**  to the original factory settings..
**  Reference: xtp040.pdf
**   
*******************************************************************************
**
**  Disclaimer: 
**
**		This disclaimer is not a license and does not grant any rights to the materials 
**              distributed herewith. Except as otherwise provided in a valid license issued to you 
**              by Xilinx, and to the maximum extent permitted by applicable law: 
**              (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
**              AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
**              INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
**              FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
**              or tort, including negligence, or under any other theory of liability) for any loss or damage 
**              of any kind or nature related to, arising under or in connection with these materials, 
**              including for any direct, or any indirect, special, incidental, or consequential loss 
**              or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
**              as a result of any action brought by a third party) even if such damage or loss was 
**              reasonably foreseeable or Xilinx had been advised of the possibility of the same.


**  Critical Applications:
**
**		Xilinx products are not designed or intended to be fail-safe, or for use in any application 
**		requiring fail-safe performance, such as life-support or safety devices or systems, 
**		Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
**		or any other applications that could lead to death, personal injury, or severe property or 
**		environmental damage (individually and collectively, "Critical Applications"). Customer assumes 
**		the sole risk and liability of any use of Xilinx products in Critical Applications, subject only 
**		to applicable laws and regulations governing limitations on product liability.

**  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.

*******************************************************************************

** IMPORTANT NOTES **

The SP601 Restoring Flash Contents step-by-step instructions are described in xtp040.pdf

The files in the ces_grade_silicon folder are for use with S6 CES silicon.


Files to aid the user in generating and programming the SP601 P30T and Platform Flash PROMs have been included 
in this zip file. Before using any of the files listed below, the SP601 DIP Switches must be set as described 
in xtp040.pdf.

BPI Flash - The 28F128J3D flash device on the SP601 board
	make_bpi_mcs.bat
		Recreates the BIST J3D MCS file. Assumes sp601_bist download.bit FPGA memory is initialized with the bootloader 
		application and that the download.bit was generated with -g StartUpClk:CCLK. Requires the sp601_bist design to be
		located in the same location as this directory (e.g. ../sp601_bist)
	
	impact -batch sp601_program_bpi.cmd
		Programs the J3D PROM with the SP601_J3D_BIST.mcs file.
	
	impact -batch SP601_J3D_BIST_Verify.cmd
		Verifies the J3D PROM against the SP601_J3D_BIST.mcs file.
	
	impact -batch SP601_J3D_Blank_check.cmd
		Checks to see if the J3D PROM is blank.
	
	impact -batch SP601_J3D_Erase.cmd
		Erases the entire J3D PROM.
	
	impact -batch SP601_J3D_Readback.cmd
		Reads back the current contents of the J3D PROM.

SPI Flash - The W25Q64BV flash device on the SP601 board
	make_spi_mcs.bat
		Recreates the BRD W25Q64BV MCS file. Requires the sp601_brd design to be
		located in the same location as this directory (e.g. ../sp601_brd)
	
	impact -batch sp601_program_spi.cmd
		Programs the W25Q64BV PROM with the SP601_SPI_BRD_v2_0.mcs file.
	
	impact -batch SP601_SPI_BRD_v2.0_Verify.cmd
		Verifies the W25Q64BV PROM against the SP601_SPI_BRD_v2_0.mcs file.
	
	impact -batch SP601_W25Q64BV_Blank_check.cmd
		Checks to see if the W25Q64BV PROM is blank.
	
	impact -batch SP601_W25Q64BV_Erase.cmd
		Erases the entire W25Q64BV PROM.
	
	impact -batch SP601_W25Q64BV_Readback.cmd
		Reads back the current contents of the W25Q64BV PROM.
