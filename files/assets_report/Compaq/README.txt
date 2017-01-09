HP Array Configuration Utility CLI
Version 8.28.13.0 (windows32)
4/14/2009


Description
-----------

   The Array Configuration Utility CLI is a commandline-based disk 
   configuration program for Smart Array Controllers and 
   RAID Array Controllers. 

  
Support
-------

Supported Operating Systems

  Microsoft Windows 2000
  Microsoft Windows Server 2003
  Microsoft Windows Server 2003 64-bit ES
  Microsoft Windows Server 2008

Supported Controllers

  Smart Array products:
     Smart Array 5312 Controller
     Smart Array 5302 Controller
     Smart Array 5304 Controller
     Smart Array 532 Controller
     Smart Array 5i Controller  
     Smart Array 641 Controller
     Smart Array 642 Controller
     Smart Array 6400 Controller
     Smart Array 6400 EM Controller
     Smart Array 6i Controller
     Smart Array P600 Controller
     Smart Array P400 Controller
     Smart Array P400i Controller
     Smart Array E200 Controller
     Smart Array E200i Controller
     Smart Array P800 Controller
     Smart Array E500 Controller
     Smart Array P700m Contoller
     Smart Array P410i Controller
     Smart Array P411 Controller
     Smart Array P212 Controller
     Smart Array P410i ZMR Controller
     Smart Array P411 ZMR Controller
     Smart Array P212 ZMR Controller
     Smart Array B110i SATA RAID

  MSA products:
     MSA500 Controller
     MSA500 G2 Controller
     MSA1000 Controller     
     MSA1500 CS Controller
     MSA20 Controller  

Installing & Running the Array Configuration Utility CLI
--------------------------------------------------------------

  Run the CLI:
    1. Install the CLI component onto your system.
    2. When component installation is complete, click Start and navigate to 
       Programs, HP System Tools, HP Array Configuration Utility CLI.
       By default this will run the CLI in command prompt environment.

       The CLI can also be started by changing to the directory in which it
       was installed and doing the following:
       
       To enter the ACU CLI console type:
       hpacucli

       Commands can also be executed  from outside the 
       ACU CLI console using the syntax:
       hpacucli <console command>

       Type "hpacucli help" or type "help" at the CLI prompt for usage details. 
       
       
  Exiting CLI:
    1. To exit the ACU CLI, type "exit" while at the CLI command console.


Additional Notes
----------------
* The availability of RAID 1 and RAID 1+0 fault tolerance settings is dependant 
  upon the number of physical drives selected when creating a logical drive. When two
  drives are selected the RAID 1 setting is made available. When four or more physical
  drives have been selected, RAID 1+0 will replace RAID 1.
* When creating logical drives on an existing array, the user can target the array
  by specifying drives=<all drives in array> in the create operation. Example:
     ctrl ch=rack1 create type=ld drives=1:1,1:2,1:3 size=333
  Where array A has drives 1:1,1:2,1:3 and at least 333 MB available free space. 
* CLI now has simple return codes. A failure returns 1 and a 
  success returns 0. 
* Except for show commands, the CLI locks each external controller on which it 
  performs an operation when the command starts and unlocks it when the command is   
  complete. This prevents the CLI from tying up a controller, but also prevents 
  errors from occurring while another configuration utility is being run. The   
  CLI does not attempt to lock controllers when performing a show command, nor 
  does it lock controllers for an entire session. Note that this differs from ACU's
  session-style locking scheme. 

Known Issues
------------

* When using the CLI console, pressing the up arrow does not cycle
  through commands in Linux.
* CLI commands are not editable when they wrap to the next line.  


Feedback
--------

  For support for ACU CLI or Smart Array controllers, please visit the web at 
    http://support.hp.com.
  For feedback or suggestions on ACU CLI, please send comments to acu@hp.com;
    however, we regret support cannot be provided through this address.