#!/system/bin/sh

PARAM_PATH=$1
PARAM_LINK_PATH="/dev/block/param"

# Wait until finishing driver loading.
sleep 2

# Make param link and change permission.
if [ -e $PARAM_PATH ]; then
	chown system.system $PARAM_PATH
	chmod 0660 $PARAM_PATH

	# Remove if param link is exist.
	if [ -e $PARAM_LINK_PATH ]; then
		rm $PARAM_LINK_PATH
	fi

	# Make param link.
	ln -s $PARAM_PATH $PARAM_LINK_PATH
fi

# Original prepare_param.sh end ---------------------------

# Copyright 2011-2014 sakuramilk ma34s homuhomu rara7886 pinelibg
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# ---------------------------------------------

busybox_install()
{
	${BUSYBOX} ln -sf /system/etc/busybox_file /system/xbin/busybox

	if [ -f /system/xbin/su ]; then
		${BUSYBOX} cp /system/xbin/su /system/xbin/su.bak
	fi

	${BUSYBOX} --install -s /system/xbin

	${BUSYBOX} rm /system/xbin/su
	if [ -f /system/xbin/su.bak ]; then
		${BUSYBOX} mv /system/xbin/su.bak /system/xbin/su
		${BUSYBOX} chown 0.0 /system/xbin/su
		${BUSYBOX} chmod 755 /system/xbin/su
	fi
}

mount_fake()
{
	${BUSYBOX} rm /system/bin/mount

	cat <<-'EOF' >>/system/bin/mount
	#!/system/bin/sh
	if [ $1 = "-o" ]; then
	    /system/xbin/busybox mount $@
	else
	    /system/bin/toolbox mount $@
	fi
	EOF

	${BUSYBOX} chown 0.2000 /system/bin/mount
	${BUSYBOX} chmod 755 /system/bin/mount
}

felica_enable()
{
	if [ -f /system/app/SysScope.apk ]; then
		 ${BUSYBOX} rm /system/app/SysScope.apk
	fi
}

get_supersu_files()
{
	apk_path=$1

	if [ ! -f $apk_path ]; then
		return
	fi

	if [ -d /system/etc/SuperSU ]; then
		${BUSYBOX} rm -r /system/etc/SuperSU
	fi
	${BUSYBOX} mkdir /system/etc/SuperSU
	${BUSYBOX} chown 0.0 /system/etc/SuperSU
	${BUSYBOX} chmod 755 /system/etc/SuperSU

	${BUSYBOX} unzip -o -q $apk_path -d /system/etc/SuperSU

	${BUSYBOX} chown -R 0.0 /system/etc/SuperSU
	${BUSYBOX} chmod -R 755 /system/etc/SuperSU
}

supersu_extract()
{
	apk_path=`${BUSYBOX} ls /data/app/eu.chainfire.supersu-[12].apk 2>/dev/null`
	if [ -n "$apk_path" ]; then
		get_supersu_files $apk_path
	fi
}

supersu_install()
{
	if [ ! -d /system/etc/SuperSU ]; then
		return
	fi

	${BUSYBOX} cp /system/etc/SuperSU/assets/supersu.arm.png /system/xbin/daemonsu
	${BUSYBOX} chown 0.0 /system/xbin/daemonsu
	${BUSYBOX} chmod 755 /system/xbin/daemonsu

	if [ ! -d /system/bin/.ext ]; then
		${BUSYBOX} mkdir /system/bin/.ext
		${BUSYBOX} chown 0.0 /system/bin/.ext
		${BUSYBOX} chmod 755 /system/bin/.ext
	fi
	${BUSYBOX} cp /system/etc/SuperSU/assets/supersu.arm.png /system/bin/.ext/.su
	${BUSYBOX} chown 0.0 /system/bin/.ext/.su
	${BUSYBOX} chmod 755 /system/bin/.ext/.su

	${BUSYBOX} cp /system/bin/.ext/.su /system/xbin/su
	${BUSYBOX} chown 0.0 /system/xbin/su
	${BUSYBOX} chmod 755 /system/xbin/su

	${BUSYBOX} cp /system/etc/SuperSU/assets/install-recovery.sh /system/etc/install-recovery.sh
	${BUSYBOX} chown 0.0 /system/etc/install-recovery.sh
	${BUSYBOX} chmod 755 /system/etc/install-recovery.sh

	if [ ! -d /system/etc/init.d ]; then
		${BUSYBOX} mkdir /system/etc/init.d
		${BUSYBOX} chown 0.0 /system/etc/init.d
		${BUSYBOX} chmod 755 /system/etc/init.d
	fi
	${BUSYBOX} cp /system/etc/SuperSU/assets/99SuperSUDaemon /system/etc/init.d/99SuperSUDaemon
	${BUSYBOX} chown 0.2000 /system/etc/init.d/99SuperSUDaemon
	${BUSYBOX} chmod 755 /system/etc/init.d/99SuperSUDaemon

	echo 1 > /system/etc/.installed_su_daemon
	${BUSYBOX} chown 0.0 /system/etc/.installed_su_daemon
	${BUSYBOX} chmod 644 /system/etc/.installed_su_daemon

	if [ ! -d /system/addon.d ]; then
		${BUSYBOX} mkdir /system/addon.d
		${BUSYBOX} chown 0.0 /system/addon.d
		${BUSYBOX} chmod 755 /system/addon.d
	fi
	${BUSYBOX} cp /system/etc/SuperSU/assets/99-supersu.sh /system/addon.d/99-supersu.sh
	${BUSYBOX} chown 0.0 /system/addon.d/99-supersu.sh
	${BUSYBOX} chmod 755 /system/addon.d/99-supersu.sh
}

supersu_clean()
{
	if [ -d /system/etc/SuperSU ]; then
		${BUSYBOX} rm -r /system/etc/SuperSU
	fi
}

run_daemonsu()
{
	if [ -f /system/xbin/daemonsu ]; then
		/system/xbin/daemonsu --auto-daemon &
	fi
}

run_initd()
{
	if [ -d /system/etc/init.d ]; then
		${BUSYBOX} run-parts /system/etc/init.d
	fi
}

# main script start ---------------------------

BUSYBOX="/system/etc/busybox_file"

${BUSYBOX} mount -o remount,rw /system

busybox_install

felica_enable

mount_fake

if [ ! -x /system/xbin/daemonsu ]; then
	supersu_extract
	supersu_install
	supersu_clean
fi

run_daemonsu

${BUSYBOX} mount -o remount,ro /system

run_initd

