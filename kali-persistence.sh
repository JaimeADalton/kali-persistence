#!/bin/bash

# En gparted En sistemas de archivos seleccionamos "sin formatear" la particion libre,  Aplicamos los cambios, 
#Manual https://gnulinuxvagos.es/topic/6100-kali-linux-en-usb-con-persistencia-de-datos-cifrado/

echo "Escribe la ruta de la particion (i.e. /dev/sdX1)"
read ruta

#Cifrar la partición con cryptsetup
echo "Cifrar la partición con cryptsetup"
cryptsetup --verbose luksFormat $ruta

#Ahora vamos a darle formato a dicha partición y prepararla para usarla en kali linux. 
#Abrimos la partición que acabamos de cifrar (nos pedirá la contraseña que acabamos de establecer):
cryptsetup open $ruta miusb
echo "Formateamos la partición:"
mkfs.ext4 -L persistence /dev/mapper/miusb
e2label /dev/mapper/miusb persistence

#Creamos el punto de montaje:
echo "Creamos el punto de montaje miusb"
mkdir -p /mnt/miusb
mount /dev/mapper/miusb /mnt/miusb

echo "/ union" > /mnt/miusb/persistence.conf
echo "Desmontamos el disco miusb"
umount /dev/mapper/miusb
echo "Fin de la configuracion, cree una carpeta en el escritorio y reinicie para verificar que todo ha ido correcto."
