
# How to Use the Script

## Prepare the USB:
    Boot into the Arch Linux live environment from your bootable USB.
### Once you're in the live environment, download the script from git:
    git clone "link archScript" 
### Make the Script Executable:
      chmod +x archScript.sh
### Run the Script:
      ./archScript.sh
### Follow Prompts:
    You will be prompted to set the root password and create a user account.
    The script will install the system, set up GRUB for dual boot, and install NVIDIA drivers.

### Customize the ScriptTime Zone: 
    Replace Region/City with your actual time zone (e.g., America/New_York).
    Disk: Ensure /dev/sdb points to your desired SSD. 
    Double-check this before running the script to avoid overwriting your Windows disk.
    Locale: You can adjust the language if needed.
### Manual Steps After Installation
    If GRUB doesn't detect Windows, after rebooting into Arch, you may need to run:
      sudo os-prober
      sudo grub-mkconfig -o /boot/grub/grub.cfg
    This script should automate most of the installation process for you.
