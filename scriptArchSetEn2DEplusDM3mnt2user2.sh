echo "Installing Arch-Linux"
echo "set a name to the computer : "
read psname
echo "set a password for root : "
read passwd_
echo "set a name for first user : "
read username
#echo " (look at partitions and disks : disk - /dev/sda, /dev/sda1 - partition)"
#echo "(if written Created a new DOS disklabel, then it will be in  mbr)"
#echo "(creating a section(partition -n)".
#echo "(choose primary) -p"
#echo "(select the section (partition) number -1)"
#echo "2048 – (make sure 2048 is there, otherwise ,"
#echo " then when installing the bootloader grub will write an error"
#echo " that it cannot install due to the wrong size)"
#echo "press Enter if everything is ok: "
#echo "save changes -w -q"
(
echo n;
echo p;
echo 1;
echo 2048;
echo -e "\n";
echo w;
echo q
) | fdisk /dev/sda

#echo "(make sure the section is created  /dev/sda1 and all sizes are what we need )"
fdisk -l
#echo "(set the file system ext4 for section /dev/sda1)"
mkfs.ext4 /dev/sda1
#echo "(mount the disk into a directory  /mnt In order to have further access to files on this section)"
mount /dev/sda1 /mnt
pacstrap /mnt base linux linux-firmware base-devel
#echo "(we generate an fstab file that contains the UUID of the partitions, this is necessary then so that the system knows where to mount our partitions at boot time, if this is not done, then it simply will not boot with us)" 
genfstab -U /mnt  >> /mnt/etc/fstab 
#echo "(we say which time zone will be used )"
arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/Europe/Tallinn /etc/localtime"
#echo "(sets the time, allows you to set the BIOS time in accordance with the system time )"
arch-chroot /mnt /bin/bash -c "hwclock --systohc"
#echo "set a name to the computer : "
arch-chroot /mnt /bin/bash -c "echo $pcname > /etc/hostname "
#echo "(install the text editor nano and vim )" 
arch-chroot /mnt /bin/bash -c "yes | pacman -S vim nano "
#echo "(install the network service package )"
arch-chroot /mnt /bin/bash -c "yes | pacman -S networkmanager "
#echo "(we use the service NetworkManager at startup )"
arch-chroot /mnt /bin/bash -c "yes | systemctl enable NetworkManager "
#echo "(install the bootloader  grub)"
arch-chroot /mnt /bin/bash -c "yes | pacman -S grub "
#echo "(select the required locales, uncomment  en_US.UTF-8 UTF-8)" 
arch-chroot /mnt /bin/bash -c "sed '/en_US.UTF-8 UTF-8/s/^#//' -i /etc/locale.gen"
#echo "(we generate the necessary locales that have been uncommitted)"
arch-chroot /mnt /bin/bash -c "locale.gen"
#echo "https://wiki.gentoo.org/wiki/Initramfs/Guide/ru)"
arch-chroot /mnt /bin/bash -c "mkinitcpio -P"
#echo "(set the root password to the user )"
echo "root:$passwd_" | arch-chroot /mnt chpasswd
#echo "(install the grub bootloader to disk )"
arch-chroot /mnt /bin/bash -c "grub-install /dev/sda "
#echo "(generate a bootloader config file with various parameters , if you do not do it, then you will not have a choice of OS)
#exit (выход из chroot)"
arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg "

#
#reboot
echo "(would you like to set DN and DE? Set 'enter' )"
read enter_
#-------------echo 'Add user'-----
arch-chroot /mnt /bin/bash -c "useradd -m -g users -G wheel -s /bin/bash $username"
#-------------echo 'set password for user'-----
arch-chroot /mnt /bin/bash -c "passwd $username"
#--------------echo 'set SUDO'---------------
#echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers



#-------------echo 'Updating the OS------------------
arch-chroot /mnt /bin/bash -c "pacman -Syu --noconfirm"
#-------------echo 'We put X and drivers------------------
#gui_install="xorg-server xorg-drivers xorg-xinit"
arch-chroot /mnt /bin/bash -c  "pacman -S xorg-server xorg-drivers xorg-xinit --noconfirm" #$gui_install
##------------echo "DE selection and install?"------------------

read -p "1 - XFCE, 2 - Gnome 3 - Deepin: " vm_setting
#-------------echo 'We put X and drivers------------------
#arch-chroot /mnt /bin/bash -c  "pacman -S xorg xorg-xinit mesa"
#------------------------------
if [[ $vm_setting == 1 ]]; then
# pacman -S xorg xorg-xinit mesa
#arch-chroot /mnt /bin/bash -c "pacman -S --noconfirm deepin deepin-extra"
arch-chroot /mnt /bin/bash -c "pacman -S xfce4 xfce4-goodies --noconfirm"
  # pacman -S xfce4 xfce4-goodies --noconfirm
elif [[ $vm_setting == 2 ]]; then
# pacman -S xorg xorg-xinit mesa
arch-chroot /mnt /bin/bash -c "pacman -S gnome gnome-extra --noconfirm"
  #pacman -Sy plasma-meta kdebase --noconfirm
elif [[ $vm_setting == 3 ]]; then
# pacman -S xorg xorg-xinit mesa
# pacman -S deepin deepin-extra	
arch-chroot /mnt /bin/bash -c  "pacman -S deepin deepin-extra --noconfirm"  
fi
###-----------echo "DM selection and install?"------------------
read -p "1 - sddm, 2 - lxdm: " dm_setting
if [[ $dm_setting == 1 ]]; then

arch-chroot /mnt /bin/bash -c  "pacman -S sddm sddm-kcm --noconfirm"
arch-chroot /mnt /bin/bash -c  "systemctl enable sddm"

  # pacman -Sy sddm sddm-kcm --noconfirm
  # systemctl enable sddm.service -f
elif [[ $dm_setting == 2 ]]; then
arch-chroot /mnt /bin/bash -c  "pacman -S lxdm --noconfirm --noconfirm"
arch-chroot /mnt /bin/bash -c  "systemctl enable lxdm"
fi
####-----------echo "Putting the fonts"------------------
arch-chroot /mnt /bin/bash -c  "pacman -S ttf-liberation ttf-dejavu --noconfirm"

reboot