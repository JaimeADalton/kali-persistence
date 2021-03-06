#!/bin/bash

# En gparted En sistemas de archivos seleccionamos "sin formatear" la particion libre,  Aplicamos los cambios, 
#Manual https://gnulinuxvagos.es/topic/6100-kali-linux-en-usb-con-persistencia-de-datos-cifrado/
if [ $DISTRO = kali ]; then
DISTRO=$(cat /etc/os-release | grep ID | cut -d= -f2 | head -n1)
read -p "Escribe la ruta de la particion (i.e. /dev/sdX1): " ruta

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

#Añadimos la clave para poder acceder a los repositorios de kali
apt-key adv --keyserver hkp://keys.gnupg.net --recv-keys 7D8D0BF6

echo "¿Desea actualizar Kali? (s/n)"
read opcion
case $opcion in
    s|S)
       apt update
       apt dist-upgrade -y
    ;;
    n|N)
       echo "Fin de la configuracion, cree una carpeta en el escritorio y reinicie para verificar que todo ha ido correcto."
       exit 1
    ;;
    *)
       echo "Desconozco esa opción"
    ;;
esac
else
    echo "Ejecuta este codigo solo en Kali linux"
fi
