#!/bin/bash

###wzget
function wzget()
{
    echo_color "开始校验下载地址..." sky-blue
    local f_url=$1
    local f_name=$2
    local status_code=$(curl --head --location -k --connect-timeout 5 --write-out %{http_code} --silent --output /dev/null ${f_url})
    if [ "$status_code" != "200" ] && [ "$status_code" != "403" ] && [ "$status_code" != "502" ]; then
        echo_color "下载文件服务器资源异常：$f_name，错误码：$status_code" red
        echo_color "请检查网络后再次重试或截图反馈!" red
        #echo_color "下载地址为：$f_url" red
        local status_code=$(curl --head --location --connect-timeout 5 --write-out %{http_code} --silent --output /dev/null ${f_url})
        if [ "$status_code" != "200" ] ; then
            exit 0
        else
            wzget $f_url $f_name 
        fi
    else
        wget -q --show-progress -O $f_name --no-check-certificate $f_url
        if [ $? -eq 0 ]; then
            echo_color ""
        else
            echo_color "下载失败、请保持网络稳定重新执行脚本！！！！$status_code " red
            sleep 10
            main
        fi
        #echo_color "尝试下载：$f_name" yellow
        #wget -q --show-progress -O $f_name $f_url
        local filesize=`ls -l $f_name | awk '{ print $5 }'`
        if [ $filesize -eq 73 ] || [ $filesize -eq 113 ]; then
            echo_color "`cat $f_name`" red
            echo_color "下载文件大小异常:$f_name，请检查输入是否错误! \n并且请检查网络后再次重试或截图反馈!" red
            #echo_color "下载地址为：$f_url" red
	        echo ">>> 未找到您的版本号主题，请联系管理员添加后再试！"
	        echo ">>> 5秒后返回主菜单！"
	        echo " "
	        sleep 5
	        clear
	        fafa
			fafa_choice
			#main
            #exit 0
         else
            extension="${f_name##*.}"
            if [ "$extension" == "apk" ]; then
                if [[ "1" == "1" ]]; then
                    echo_color "$f_name 下载成功" green
                else
                    if ! command -v zipinfo > /dev/null 2>&1; then
                        echo_color "环境异常自动修复中!!!!" red
                        apk add unzip > /dev/null 2>&1
                        apt install unzip -y > /dev/null 2>&1
                        echo_color ""
                        echo_color "请重新输入代码开始，或卸载软件重新安装!!!"
                        echo_color ""
                    else
                        command -v zipinfo wget
                        echo_color "#####################"
                        echo_color "$f_name下载文件校验失败，您在下载过程中未保持网络稳定!!!!" red
                        echo_color ""
                        echo_color "请确保网络稳定后再次重试即可!!!"
                        echo_color ""
                    fi
                    sleep 10
                    main
                fi
            else
                echo_color "Pass" green
            fi
        fi
    fi
}








###echo_color
function echo_color() {
        if [ $# -ne 2 ];then
                echo -e "\033[34m$1\033[0m"
        elif [ $2 == 'red' ];then
                echo -e "\033[31m$1\033[0m"
        elif [ $2 == 'green' ];then
                echo -e "\033[32m$1\033[0m"
        elif [ $2 == 'yellow' ];then
                echo -e "\033[33m$1\033[0m"
        elif [ $2 == 'blue' ];then
                echo -e "\033[34m$1\033[0m"
        elif [ $2 == 'plum' ];then
                echo -e "\033[35m$1\033[0m"
        elif [ $2 == 'sky-blue' ];then
                echo -e "\033[36m$1\033[0m"
        elif [ $2 == 'white' ];then
                echo -e "\033[37m$1\033[0m"
        fi
}







###Path_fix
function Path_fix()
{
    #Path_fix
    cd ~
    tmpdir=`pwd`
    Work_Path="$tmpdir/A2"
    mkdir $Work_Path 2>/dev/null
    cd $Work_Path
    pwd
}





###check_dependencies
function check_dependencies() {
    if ! command -v ip > /dev/null 2>&1 || ! command -v adb > /dev/null 2>&1 || ! command -v wget > /dev/null 2>&1 || ! command -v unzip > /dev/null 2>&1 || ! command -v zipinfo > /dev/null 2>&1 || ! command -v curl > /dev/null 2>&1; then
        echo_color "检测到iproute2、android-tools或wget未安装" yellow
        sleep 2
        echo_color "正在安装所需环境包，请等待..."
        if [[ "$1" == "ish" ]]; then
            sed -i 's/dl-cdn.alpinelinux.org/mirrors.cernet.edu.cn/g' /etc/apk/repositories
            cat /etc/apk/repositories |grep "apk.ish.app" && wget -O  /etc/apk/repositories http://car.fa-fa.cc/tmp/ish/ish.tmp
            apk update  >/dev/null 2>&1
            apk add  wget unzip bash curl android-tools openssl openssl-dev  >/dev/null 2>&1

        elif [[ "$1" == "termux" ]]; then
            sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.cernet.edu.cn/termux/apt/termux-main stable main@' $PREFIX/etc/apt/sources.list
            apt update -y  >/dev/null 2>&1
            apt -o DPkg::Options::="--force-confnew"  upgrade -y  >/dev/null 2>&1
            sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.cernet.edu.cn/termux/apt/termux-main stable main@' $PREFIX/etc/apt/sources.list
            apt update -y  >/dev/null 2>&1
            pkg install iproute2 android-tools wget openssl unzip -y  >/dev/null 2>&1
        else
        	sleep 2
            echo_color "未知环境请再次确认！" red
        fi
    fi
    sleep 2
    echo_color "所需环境包已安装完成。" green
}



###Env_fix
function Env_fix()
{
    #Env_fix
    clear
    Alpine_Env_Check="/etc/apk/repositories"
    Termux_Env_Check="/etc/apt/sources.list"
    CentOS_Env_Check="/etc/redhat-release"
    echo_color "当前脚本执行环境检测中..."
    if [  -f "$Alpine_Env_Check"  ];then
        echo_color "当前为ish Shell Alpine环境，安卓请使用Termux执行本脚本" white
        sleep 1
        check_dependencies ish
    elif [  -f "$PREFIX/$Termux_Env_Check"  ];then
        echo_color "当前为Termux Shell环境，苹果请使用ish Shell执行本脚本" white
        sleep 1
        check_dependencies termux
    elif [  -f "$CentOS_Env_Check"  ];then
        echo_color "当前为CentOS Shell环境，苹果请使用ish Shell、安卓请使用Termux执行本脚本" white
        sleep 1
        check_dependencies centos
        exit 0
    else
    	sleep 2
        echo_color "环境异常，自动退出！" red
        exit 0
    fi
    sleep 2
    echo_color "执行环境已全部通过检测！" yellow
    sleep 2
}





###policy_control_z
function policy_control_z()
{
package_name=$1
policy_control=`adb shell "settings get global policy_control"|awk -F"=" '{print $2}'`
result=$(echo $policy_control | grep "${package_name}")
if [[ "$result" != "" ]];then
  echo_color "$package_name已存在policy"
else
  echo_color "$package_name添加进policy"
  if [[ "$policy_control" == "" ]];then
    echo_color "获取policy_control失败"
    adb shell "settings put global policy_control immersive.full=$package_name"
  elif [[ "$policy_control" == "*" ]];then
    echo_color "adb shell \"settings put global policy_control immersive.full=$package_name\""
    adb shell "settings put global policy_control immersive.full=$package_name"
  else
    echo_color "adb shell \"settings put global policy_control immersive.full=$policy_control,$package_name\""
    adb shell "settings put global policy_control immersive.full=$policy_control,$package_name"
  fi
fi
}




###is_ap_hy_tk
function is_ap_hy_tk()
{
	Incremental=$1
    #Adb_Init
	#adb shell "cat /system/build.prop | grep ro.build.version.incremental" | awk -F"=" '{print $2}'
	#Incremental=`adb shell "cat /system/build.prop | grep ro.build.version.incremental" | awk -F"=" '{print $2}'`
	if [ ! $Incremental ];then
	    echo_color "未能自动识别版本信息，请截图反馈..." red
	    exit 0
	fi
	if echo "$Incremental" | grep -q "PSOP4"; then
	    echo_color "坦克车主，请确认，只能用通用的高德脚本!!!!" red
	    echo_color "坦克车主，请确认，只能用通用的高德脚本!!!!" red
	    echo_color "坦克车主，请确认，只能用通用的高德脚本!!!!" red
	    
	elif echo "$Incremental" | grep -q "BSOP2"; then
	    echo_color "安波福车机，请确认，只能用安波福适配的高德脚本" red
	    echo_color "安波福车机，请确认，只能用安波福适配的高德脚本" red
	    echo_color "安波福车机，请确认，只能用安波福适配的高德脚本" red
	    
	elif echo "$Incremental" | grep -q "eng.Jenkin"; then
	    echo_color "华阳车机，请确认，只能用华阳适配的高德脚本" red
	    echo_color "华阳车机，请确认，只能用华阳适配的高德脚本" red
	    echo_color "华阳车机，请确认，只能用华阳适配的高德脚本" red
	else
	    echo_color "未能自动识别对应脚本信息$Incremental,建议截图反馈至管理员！"
	fi
}




function clear_amap_all()
{
    Adb_Init
    adb shell "cat /system/build.prop | grep ro.build.version.incremental" | awk -F"=" '{print $2}'
    Incremental=`adb shell "cat /system/build.prop | grep ro.build.version.incremental" | awk -F"=" '{print $2}'`
    if [ ! $Incremental ];then
	    echo_color "未能自动识别版本信息，请截图反馈..." red
	    exit 0
	fi
    echo_color "释放进程...."
	adb shell "killall com.autonavi.amapauto 2>/dev/null"
	adb shell "killall com.autonavi.amapauto:push 2>/dev/null"
	adb shell "killall com.autonavi.amapauto:locationservice 2>/dev/null"
	adb shell "pm clear com.autonavi.amapauto"
	echo_color "卸载升级或者清理手动升级残留"
	adb shell "pm uninstall com.autonavi.amapauto >/dev/null"
	adb shell "pm uninstall --user 0 com.autonavi.amapauto >/dev/null"
	echo_color "查看Packages list信息"
	adb shell "pm list packages amap"
	adb shell "pm list packages -f amap"
	adb shell "pm list packages -u amap"
	echo_color "清理所有++++++++++++++"
	adb shell '[ -d "/system/app/AutoMap" ] && ls -la /system/app/AutoMap/'
	adb shell '[ -d "/system/app/AutoMap" ] && echo '' > /system/app/AutoMap/AutoMap.apk'
	adb shell '[ -d "/system/app/AutoMap" ] && rm -rf "/system/app/AutoMap"'
	adb shell '[ -d "/system/app/Navigation" ] && ls -la /system/app/Navigation/'
	adb shell '[ -d "/system/app/Navigation" ] && echo '' > /system/app/Navigation/Navigation.apk'
	adb shell '[ -d "/system/app/Navigation" ] && rm -rf "/system/app/Navigation"'
	echo_color "清理新版插件残留..." red
	adb shell "killall com.autohelper" >/dev/null 2>&1
	adb shell "pm uninstall com.autohelper" >/dev/null 2>&1
	adb shell "rm -rf /system/app/AutoHelper"
	adb shell pm list packages | grep "com.autohelper"
	
	if echo "$Incremental" | grep -q "eng.Jenkin"; then
	    echo_color "华阳主机、强制清理!!!!" red
		#误装处理
		adb shell '[ -d "/system/app/AutoMap" ] && ls -la /system/app/AutoMap/'
		adb shell '[ -d "/system/app/AutoMap" ] && echo '' > /system/app/AutoMap/AutoMap.apk'
		adb shell '[ -d "/system/app/AutoMap" ] && rm -rf "/system/app/AutoMap"'
	else
	    echo_color "安波福主机、强制清理!!!!" red
	    #误装处理
	    adb shell '[ -d "/system/app/Navigation" ] && ls -la /system/app/Navigation/'
		adb shell '[ -d "/system/app/Navigation" ] && echo '' > /system/app/Navigation/Navigation.apk'
		adb shell '[ -d "/system/app/Navigation" ] && rm -rf "/system/app/Navigation"'
	fi
	echo_color "清理用户目录"
    adb shell "rm -rf /data/user/0/com.autonavi.amapauto"
    adb shell "rm -rf /data/user_de/0/com.autonavi.amapauto"
    adb shell "rm -rf /data/app/*/com.autonavi.amapauto*"
    adb shell "rm -rf /data/media/0/amapauto9"
    adb shell "rm -rf /sdcard/amapauto9"
    adb shell "rm -rf /sdcard/Android/data/com.autonavi.amapauto"
    echo_color "清理结束，请在重启后重新跑正确的安装脚本...."
    ReBoot
	
}








###Adbd
function Adbd()
{
    echo_color ""
    #Adb_Init
	echo_color "启用会打开车机adbd自启存在车机adb调试网络暴露风险!" red
	echo_color "确认自行承担自启adbd带来的所有风险？" red
    #echo_color "确认是否开启车机ADB网络调试功能开机自启(1开启/0关闭): " red
	num=1

	case $num in
		1)
			Adb_Init
			Incremental=`adb shell "cat /system/build.prop | grep ro.build.version.incremental" | awk -F"=" '{print $2}'`
            if echo "$Incremental" | grep -q "BSOP2"; then
                echo_color ""
                clear
                menu
                exit 0
            fi
			echo_color "选择了开启" red
			echo_color ""
			echo_color "检查adb是否自启" yellow
        	adb_check=`adb shell "cat /system/build.prop|grep 5555" | awk -F"=" '{print $2}'`
        	if [ "$adb_check" == "5555" ]; then
        		echo_color "adb自启检查通过" green
        	else
        		echo_color "adb自启检查不通过，修复中..." yellow
        		adb shell "sed -i '/service.adb.tcp.port/d' /system/build.prop"
        		adb shell "echo 'service.adb.tcp.port=5555' >>/system/build.prop"
        		adb shell "cat /system/build.prop|grep 5555"
        		echo_color "adb开启成功，启用会打开车机adb自启存在车机adb调试网络暴露风险！" yellow
        	fi
        	echo_color "再次检查adb是否自启" yellow
        	adb_check=`adb shell "cat /system/build.prop|grep 5555" | awk -F"=" '{print $2}'`
        	if [ "$adb_check" == "5555" ]; then
        		echo_color "adb自启OK" green
        	else
        		echo_color "adb自启检查不通过，修复中..." yellow
        		adb shell "sed -i '/service.adb.tcp.port/d' /system/build.prop"
        		adb shell "echo 'service.adb.tcp.port=5555' >>/system/build.prop"
        		adb shell "cat /system/build.prop|grep 5555"
        		echo_color "adb开启成功，启用会打开车机adb自启存在车机adb调试网络暴露风险！" yellow
        	fi
			;;
		0)
		    echo_color "选择了关闭" red
			echo_color ""
			echo_color "检查adb是否自启" yellow
			Adb_Init
        	adb_check=`adb shell "cat /system/build.prop|grep 5555" | awk -F"=" '{print $2}'`
        	if [ "$adb_check" == "5555" ]; then
        		echo_color "adb存在自启配置" green
        		adb shell "sed -i '/service.adb.tcp.port/d' /system/build.prop"
        		adb shell "cat /system/build.prop|grep 5555"
        		echo_color "adb自启关闭成功，重启生效!" yellow
        		ReBoot
        	else
        		echo_color "adbd自启已关闭" green
        	fi
		    ;;
		*)
		    main
		    ;;
	esac
}






###Adb_ROOT
function Adb_ROOT()
{
	echo_color " "
	read -p "请手动输入车机的IP地址确认无误后回车：" carip
	echo_color "车机IP为：$carip"
	echo_color "连接车机中...如卡住请确认车机IP是否正确并在车机工装模式中已开启TCP/IP"
	export ANDROID_ADB_SERVER_PORT=12888
	echo_color "尝试连接该IP"
	while true
	do
		str_refused=$(adb connect $carip | grep refused)
		if [[ $str_refused == "" ]]; then
			echo_color "adb设备连接测试01" yellow
		else
			echo_color "adb设备连接异常，连接$carip被拒绝，请确认车机IP是否正确并在车机工装模式中已开启TCP/IP" red
			read -p "请手动输入车机的IP地址确认无误后回车：" carip
		fi
		str_faied=$(adb connect $carip | grep failed)
		if [[ $str_faied == "" ]]; then
			echo_color "adb设备连接测试02" yellow
			break
		else
			echo_color "adb设备连接异常，请确认正确ip后手动输入!" red
			read -p "请手动输入车机的IP地址确认无误后回车：" carip
		fi
	done
	adb connect $carip
	echo_color "获取root权限" yellow
	adb root
	echo_color "等待车机连接，如卡住请确认车机IP是否正确并在车机工装模式中已开启TCP/IP" yellow
	adb wait-for-device
	echo_color "挂载system为读写" yellow
	adb remount
	echo_color "等待车机连接，如卡住请确认车机IP是否正确并在车机工装模式中已开启TCP/IP" yellow
	adb wait-for-device
	adb connect $carip
	echo_color "获取root权限" yellow
	adb root
	echo_color "等待车机连接，如卡住请确认车机IP是否正确并在车机工装模式中已开启TCP/IP" yellow
	adb wait-for-device
	echo_color "挂载system为读写" yellow
	adb remount
	echo_color "等待车机连接，如卡住请确认车机IP是否正确并在车机工装模式中已开启TCP/IP" yellow
	adb wait-for-device
	str=$(adb devices | grep "\<device\>")
	if [[ $str != "" ]]; then
		echo_color "adb设备连接正常" green
	else
		echo_color "adb设备连接异常，一般重新开热点、退甲壳虫、清除termux数据重来可解决!" red
		exit 0
	fi
	echo_color "已成功获取root权限，退出即可！" green
}





###Adb_Init
function Adb_Init()
{
	if [  -f "$Alpine_Env_Check"  ]; then
		read -p "请手动输入车机的IP地址确认无误后回车：" carip
	else
		carip=`ip neigh|head -n 1|awk '{print $1}'`
	fi
	if [ ! $carip ]; then
	  echo_color "请开启手机热点车机连接至热点再重新执行、或者手动输入IP" red
	  read -p "请手动输入车机的IP地址确认无误后回车：" carip
	else
	  echo_color "获取到车机IP" green
	fi
	echo_color "车机IP为：$carip"
	echo_color "连接车机中...如卡住请确认车机IP是否正确并在车机工装模式中已开启TCP/IP"
	export ANDROID_ADB_SERVER_PORT=12888
	echo_color "尝试连接该IP"
	while true
	do
		str_refused=$(adb connect $carip | grep refused)
		if [[ $str_refused == "" ]]; then
			echo_color "adb设备连接测试01" yellow
		else
			echo_color "adb设备连接异常，连接$carip被拒绝，请确认车机IP是否正确并在车机工装模式中已开启TCP/IP" red
			read -p "请手动输入车机的IP地址确认无误后回车：" carip
		fi
		str_faied=$(adb connect $carip | grep failed)
		if [[ $str_faied == "" ]]; then
			echo_color "adb设备连接测试02" yellow
			break
		else
			echo_color "adb设备连接异常，请确认正确ip后手动输入!" red
			read -p "请手动输入车机的IP地址确认无误后回车：" carip
		fi
	done
	adb connect $carip
	echo_color "获取root权限" yellow
	adb root
	echo_color "等待车机连接，如卡住请确认车机IP是否正确并在车机工装模式中已开启TCP/IP" yellow
	adb wait-for-device
	echo_color "挂载system为读写" yellow
	adb remount
	echo_color "等待车机连接，如卡住请确认车机IP是否正确并在车机工装模式中已开启TCP/IP" yellow
	adb wait-for-device
	adb connect $carip
	echo_color "获取root权限" yellow
	adb root
	echo_color "等待车机连接，如卡住请确认车机IP是否正确并在车机工装模式中已开启TCP/IP" yellow
	adb wait-for-device
	echo_color "挂载system为读写" yellow
	adb remount
	echo_color "等待车机连接，如卡住请确认车机IP是否正确并在车机工装模式中已开启TCP/IP" yellow
	adb wait-for-device
	str=$(adb devices | grep "\<device\>")
	if [[ $str != "" ]]; then
		echo_color "adb设备连接正常" green
	else
		echo_color "adb设备连接异常，一般重新开热点、退甲壳虫、清除termux数据重来可解决!" red
		exit 0
	fi
}


###ReBoot
function ReBoot()
{
	echo_color "操作完成, 车机将在10秒后重启, 如果你不希望重启, 请在10秒内关闭此窗口！" red
	sleep 10
	echo_color "开始执行车机重启！" yellow
	adb shell reboot
	echo_color "执行车机重启完成！" green
	echo_color "如有问题请长截图反馈！" green
}







###AutoMap
function AutoMap()
{
	cd $Work_Path
	AutoMap_Check_Script_Url="https://dzsms.gwm.com.cn/haval/automap/check.sh"
	AutoMap_Apk="AutoMap.apk"
	AutoMap_Zip="AutoMap.zip"
	AutoMap_Tar="AutoMap.tar"
	Flag=0
	bak=0
	is_ap_hy_tk "BSOP2"
    #read -p "请输入数字选择升级全屏版|快捷键|回退(2/1/0):" select_num
    list_url="https://dzsms.gwm.com.cn/haval/automap/beta.csv"
    echo_color "输入菜单后下载失败一般是直链获取失败反馈管理员修复" yellow
    read -p "请输入数字选择升级全屏版|快捷键|回退(2/1/0):" select_num
    
    list_data=`curl -ss -k $list_url|grep "^$select_num,"`
    #echo_color "$list_data"
    if [[ "$list_data" == "" ]];then
    	echo_color "输入错误，请截图反馈至管理员，或重新输入代码重新执行脚本" red
    	exit 0
    else
    	#list菜单
    	read AutoMap_Url md51 tips bak <<< $(echo "$list_data"|awk -F, '{print $2,$3,$4,$5}')
    fi
    if [[ "$AutoMap_Url" == "" ]];then
    	echo_color "获取数据失败，请截图反馈至管理员，或者保持网络畅通再重试一下" red
    	exit 0
    else
    	echo_color "您选择的是:$select_num:$tips"
    	sleep 3
    fi

	filename=""
	wget -q --show-progress -O check.sh --no-check-certificate $AutoMap_Check_Script_Url
	if [[ "$bak" == "0" ]]; then
		echo_color "开始升级预处理"
		cd $Work_Path
		rm -rf tmp
		mkdir tmp
		cd tmp
		wzget $AutoMap_Url $AutoMap_Apk
		md5a=`md5sum $AutoMap_Apk |awk '{print $1}'`
		echo_color "$md5a:$md51"
		if [[ "$md5a" == "$md51" ]];then
			echo_color "开始解包"
			unzip -o $AutoMap_Apk >/dev/null 2>&1
			echo_color "解包完成..."
			echo_color "开始打包必要文件"
			rm -rf automap
			mkdir -p automap/lib
			mv lib/armeabi-v7a automap/lib/arm
			cp $AutoMap_Apk automap/AutoMap.apk
			rm -rf $Work_Path/$AutoMap_Tar
			cd automap/ && tar -cvpf $Work_Path/$AutoMap_Tar *
			find ./ -type f -print0|xargs -0 md5sum >$Work_Path/$AutoMap_Tar.md5
			sed -i 's/.\//\/system\/app\/AutoMap\//' $Work_Path/$AutoMap_Tar.md5
			cd $Work_Path/ && rm -rf $Work_Path/tmp 
			ls -l $AutoMap_Tar*
			echo_color "预处理完成"
			filename="$AutoMap_Tar"
		else
			echo_color "下载失败、请保持网络稳定重新执行脚本!!!" red
			exit 0
		fi
		
	else
		echo_color "开始回退预处理"
		cd $Work_Path
		#wget -q --show-progress -O $AutoMap_Zip $AutoMap_Backup_Zip_Url
		#wget -q --show-progress -O $AutoMap_Zip $AutoMap_Url
		Adb_Init
		adb shell "cat /system/build.prop | grep ro.build.version.incremental" | awk -F"=" '{print $2}'
		Incremental=`adb shell "cat /system/build.prop | grep ro.build.version.incremental" | awk -F"=" '{print $2}'`
		if [ ! $Incremental ];then
		    echo_color "未能自动识别版本信息，请截图反馈..." red
		    exit 0
		fi
		if echo "$Incremental" | grep -q "PSOP4"; then
		    #需要修改为坦克的备份包
		    AutoMap_Url="https://dzsms.gwm.com.cn/haval/automap/tk300/automap.zip"
		    md51="d4eeb264afaeb9a99b825fb8b376df83"
		    echo_color "欢迎尊贵的坦克车主..."
		else
		    echo_color "欢迎尊贵的哈弗车主..."
		fi
		wzget $AutoMap_Url $AutoMap_Zip
		md5a=`md5sum $AutoMap_Zip |awk '{print $1}'`
		if [[ "$md5a" == "$md51" ]];then
			rm -rf amap_backup.*
			unzip -d $Work_Path $AutoMap_Zip >/dev/null 2>&1
			ls -l amap_backup*
			echo_color "预处理完成"
			filename="amap_backup.tar"
		else
			echo_color "下载失败、请保持网络稳定重新执行脚本!!!" red
			exit 0
		fi
		
	fi
	Adb_Init
	if [[ "$filename" != "" ]];then
		echo_color "释放进程...."
		adb shell "killall com.autonavi.amapauto 2>/dev/null"
		adb shell "killall com.autonavi.amapauto:push 2>/dev/null"
		adb shell "killall com.autonavi.amapauto:locationservice 2>/dev/null"

	adb shell "pm clear com.autonavi.amapauto"

		echo_color "卸载升级或者清理手动升级残留"
		adb shell "pm uninstall com.autonavi.amapauto >/dev/null"
		adb shell "pm uninstall --user 0 com.autonavi.amapauto >/dev/null"
		echo_color "查看Packages list信息"
		adb shell "pm list packages amap"
		adb shell "pm list packages -u amap"
		echo_color "释放空间...."
		adb shell "echo '' > /system/app/AutoMap/AutoMap.apk"
		echo_color "删除原车高德地图系统文件"
		adb shell "rm -rf /system/app/AutoMap/*"

	echo_color "测试清理用户目录"
	adb shell "rm -rf /data/user/0/com.autonavi.amapauto"
	adb shell "rm -rf /data/user_de/0/com.autonavi.amapauto"
	adb shell "rm -rf /data/app/*/com.autonavi.amapauto*"
	adb shell "rm -rf /data/media/0/amapauto9"
	adb shell "rm -rf /sdcard/amapauto9"
	adb shell "rm -rf /sdcard/Android/data/com.autonavi.amapauto"

	if [[ "$bak" == "1" ]]; then
		echo_color "清理新版插件残留..." red
		adb shell "killall com.autohelper" >/dev/null 2>&1
		adb shell "pm uninstall com.autohelper >/dev/null"
		adb shell "rm -rf /system/app/AutoHelper"
		adb shell pm list packages | grep "com.autohelper"
	fi
	adb shell '[ -d "/system/app/AutoMap" ] || mkdir -p "/system/app/AutoMap"'
		
		echo_color "上传替换高德包"
		adb push $filename /data/local/tmp/
		adb push $filename.md5 /data/local/tmp/
		adb push check.sh /data/local/tmp/
		adb shell chmod 777 /data/local/tmp/check.sh
		echo_color "执行替换操作"
		adb shell "tar -xvpf /data/local/tmp/$filename -C /system/app/AutoMap/"
		echo_color "校验文件完整性"
		adb shell "/data/local/tmp/check.sh $filename"
		echo_color "修复文件权限"
		adb shell "chown -R root:root /system/app/AutoMap/"
		adb shell "chmod -R 755 /system/app/AutoMap/"
		adb shell "chmod -R 644 /system/app/AutoMap/AutoMap.apk"
		adb shell "chmod -R 644 /system/app/AutoMap/lib/arm/*"
		if [[ "$bak" == "9" ]]; then
			echo_color "dex2oat优化处理"
			adb shell "mkdir -p /system/app/AutoMap/oat/arm"
			adb shell "/system/bin/dex2oat --dex-file=/system/app/AutoMap/AutoMap.apk  --oat-file=/system/app/AutoMap/oat/arm/AutoMap.odex"
			adb shell "chmod -R 755 /system/app/AutoMap/oat"
			adb shell "chmod -R 644 /system/app/AutoMap/oat/arm/*"
			adb shell "ls -la /system/app/AutoMap/oat/arm/*"
			echo_color "dex2oat优化处理end"
		else
			echo_color "Pass" green
		fi
		echo_color "恢复APP状态及还原安装"
		adb shell "pm enable com.autonavi.amapauto"
		adb shell "pm unhide com.autonavi.amapauto"
		adb shell "pm default-state --user 0 com.autonavi.amapauto"
		echo_color "测试清理步骤"
		adb shell "rm -rf /data/system/package_cache/1/AutoMap*"
		echo_color "等待10秒后开始还原"
		sleep 10
		echo_color "尝试还原"
		adb shell "cmd package install-existing com.autonavi.amapauto"
		echo_color "查看Packages list信息"
		adb shell "pm list packages amap"
		adb shell "pm list packages -u amap"
		echo_color "清理数据"
		adb shell "pm clear com.autonavi.amapauto"
		echo_color "开始检测当前车机的全屏配置规则"
		adb shell "settings get global policy_control"
		if [[ "$select_num" == "4" ]];then
			echo_color "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			echo_color "Beta版本自带左侧手势侧滑回桌面!!!"
			sleep 3
			adb shell "settings put global policy_control null"
		elif [[ "$select_num" == "3" ]];then
			echo_color "快捷键版本将恢复配置为默认设置、会覆盖之前的设置!!!"
			echo_color "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			adb shell "settings put global policy_control null"
		elif [[ "$select_num" == "2" ]];then
			#echo_color "全屏版本将只设置高德为全屏、会覆盖之前的设置!!!"
			echo_color "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			#adb shell "settings put global policy_control immersive.full=com.autonavi.amapauto"
			policy_control_z "com.autonavi.amapauto"
		elif [[ "$select_num" == "1" ]];then
			echo_color "快捷键版本将恢复配置为默认设置、会覆盖之前的设置!!!"
			echo_color "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			adb shell "settings put global policy_control null"
		elif [[ "$select_num" == "0" ]];then
			echo_color "原厂版本将恢复配置为默认设置、会覆盖之前的设置!!!"
			echo_color "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			adb shell "settings put global policy_control null"
		else
			echo_color "全屏配置规则设置完成" green
		fi
		echo_color "开始检测当前车机的全屏配置规则"
		adb shell "settings get global policy_control"
		echo_color "建议配合群文件手势控制软件使用全屏版"
		ReBoot
		
	else
		echo_color "预处理失败、请截图反馈" red
		exit 0
	fi
    #exit 0
    
}




###AutoMapBeta
function AutoMapBeta()
{
    clear
	cd $Work_Path
	AutoMap_Check_Script_Url="https://dzsms.gwm.com.cn/haval/automap/check.sh"
	AutoMap_Apk="AutoMap.apk"
	AutoMap_Zip="AutoMap.zip"
	AutoMap_Tar="AutoMap.tar"
	Flag=0
	bak=0
    #read -p "请根据提示输入数字选择:" select_num
    list_url="https://dzsms.gwm.com.cn/haval/automap/beta.csv"
    echo_color " "
    echo_color "开始获取更新内容......"
    sleep 1
    wget -T 9 -O amapnote.md --no-check-certificate https://dzsms.gwm.com.cn/haval/automap/amapnote.md >/dev/null 2>&1 && cat amapnote.md|head -n 18
    
    echo_color "↓↓↓重要消息↓↓↓" sky-blue
    is_ap_hy_tk "BSOP2"
	#echo_color "请确认！安波福主机专用,其他主机不要刷！" red
    #sleep 3
    echo_color " "
    echo_color "输入菜单后下载失败一般是直链获取失败反馈管理员修复" yellow
    read -p "请根据提示输入数字选择|或者回退(280/0):" select_num
    
    file_data=`curl -ss -k $list_url`
    list_data=`echo -e "$file_data"|grep "^$select_num,"`
    #echo_color "$list_data"
    if [[ "$list_data" == "" ]];then
    	echo_color "输入错误，请截图反馈至管理员，或重新输入代码重新执行脚本" red
	exit 0
    else
    	#list菜单
    	#read AutoMap_Url md51 tips bak split <<< $(echo "$list_data"|awk -F, '{print $2,$3,$4,$5,$6}')
    	read AutoMap_Url md51 tips bak split plugin<<< $(echo "$list_data"|awk -F, '{print $2,$3,$4,$5,$6,$9}')
    fi
    if [[ "$AutoMap_Url" == "" ]];then
    	echo_color "获取数据失败，请截图反馈至管理员，或者保持网络畅通再重试一下" red
    	exit 0
    else
    	echo_color "您选择的是:$select_num:$tips"
     	sleep 3
    fi

	filename=""
	if [[ "$plugin" == "1" ]];then
		echo_color "插件下载中..."
		read plugin_url plugin_md5 <<< $(echo -e "$file_data"|grep "^AutoHelper"|awk -F, '{print $2,$3}')
		wzget $plugin_url AutoHelper.apk
		plugin_md5_local=`md5sum AutoHelper.apk |awk '{print $1}'`
		if [[ "$plugin_md5_local" != "$plugin_md5" ]];then
			echo_color "$plugin_md5_local:$plugin_md5"
			echo_color "插件下载失败、请保持网络稳定重新执行脚本!!!" red
			exit 0
		fi
	fi
	
	wget -q --show-progress -O check.sh --no-check-certificate $AutoMap_Check_Script_Url
	if [[ "$bak" == "0" || "$bak" == "9" ]]; then
		echo_color "开始升级预处理"
		cd $Work_Path
		rm -rf tmp
		mkdir tmp
		cd tmp
		#wget -q --show-progress -O $AutoMap_Apk $AutoMap_Url
		wzget $AutoMap_Url $AutoMap_Apk
		md5a=`md5sum $AutoMap_Apk |awk '{print $1}'`
		echo_color "$md5a:$md51"
		if [[ "$md5a" == "$md51" ]];then
		    echo_color "检查是否分离so库文件"
			if [[ "$split" == "1" ]];then
				echo_color "so库分离,正在下载库文件"
				read lib_url lib_md5 <<< $(echo "$list_data"|awk -F, '{print $7,$8}')
				wzget "$lib_url" lib.zip
				lib_md5_local=`md5sum lib.zip |awk '{print $1}'`
				if [[ "$lib_md5_local" == "$lib_md5" ]];then
					echo_color "开始解压"
					unzip -o lib.zip >/dev/null 2>&1
				else
					echo_color "$lib_md5_local:$lib_md5"
					echo_color "下载失败、请保持网络稳定重新执行脚本!!!" red
					exit 0
				fi
			else
				echo_color "非分离库,开始解包"
				unzip -o $AutoMap_Apk >/dev/null 2>&1
			fi
			#echo_color "开始解包"
			#unzip -o $AutoMap_Apk >/dev/null 2>&1
			echo_color "解包完成..."
			echo_color "开始打包必要文件"
			rm -rf automap
			mkdir -p automap/lib
			mv lib/armeabi-v7a automap/lib/arm
			cp $AutoMap_Apk automap/AutoMap.apk
			rm -rf $Work_Path/$AutoMap_Tar
			cd automap/ && tar -cvpf $Work_Path/$AutoMap_Tar * >/dev/null 2>&1
			find ./ -type f -print0|xargs -0 md5sum >$Work_Path/$AutoMap_Tar.md5
			sed -i 's/.\//\/system\/app\/AutoMap\//' $Work_Path/$AutoMap_Tar.md5
			cd $Work_Path/ && rm -rf $Work_Path/tmp 
			ls -l $AutoMap_Tar*
			echo_color "预处理完成"
			filename="$AutoMap_Tar"
		else
			echo_color "下载失败、请保持网络稳定重新执行脚本!!!" red
			exit 0
		fi
		
	else
		echo_color "开始回退预处理"
		cd $Work_Path
		#wget -q --show-progress -O $AutoMap_Zip $AutoMap_Backup_Zip_Url
		#wget -q --show-progress -O $AutoMap_Zip $AutoMap_Url
		Adb_Init
		adb shell "cat /system/build.prop | grep ro.build.version.incremental" | awk -F"=" '{print $2}'
		Incremental=`adb shell "cat /system/build.prop | grep ro.build.version.incremental" | awk -F"=" '{print $2}'`
		if [ ! $Incremental ];then
		    echo_color "未能自动识别版本信息，请截图反馈..." red
		    exit 0
		fi
		if echo "$Incremental" | grep -q "PSOP4"; then
		    #需要修改为坦克的备份包
		    AutoMap_Url="https://dzsms.gwm.com.cn/haval/automap/tk300/automap.zip"
		    md51="d4eeb264afaeb9a99b825fb8b376df83"
		    echo_color "欢迎尊贵的坦克车主..."
		else
		    echo_color "欢迎尊贵的哈弗车主..."
		fi
		wzget $AutoMap_Url $AutoMap_Zip
		md5a=`md5sum $AutoMap_Zip |awk '{print $1}'`
		if [[ "$md5a" == "$md51" ]];then
			rm -rf amap_backup.*
			unzip -d $Work_Path $AutoMap_Zip >/dev/null 2>&1
			ls -l amap_backup*
			echo_color "预处理完成"
			filename="amap_backup.tar"
		else
			echo_color "下载失败、请保持网络稳定重新执行脚本!!!" red
			exit 0
		fi
		
	fi
	Adb_Init
	if [[ "$filename" != "" ]];then
		echo_color "释放进程...."
		adb shell "killall com.autonavi.amapauto 2>/dev/null"
		adb shell "killall com.autonavi.amapauto:push 2>/dev/null"
		adb shell "killall com.autonavi.amapauto:locationservice 2>/dev/null"
	adb shell "pm clear com.autonavi.amapauto"
		echo_color "卸载升级或者清理手动升级残留"
		adb shell "pm uninstall com.autonavi.amapauto >/dev/null"
		adb shell "pm uninstall --user 0 com.autonavi.amapauto >/dev/null"
		echo_color "查看Packages list信息"
		adb shell "pm list packages amap"
		adb shell "pm list packages -u amap"
	echo_color "释放空间...."
	adb shell "echo '' > /system/app/AutoMap/AutoMap.apk"
		echo_color "删除原车高德地图系统文件"
		adb shell "rm -rf /system/app/AutoMap/*"
	#误装处理
	adb shell '[ -d "/system/app/Navigation" ] || echo '' > /system/app/Navigation/Navigation.apk'
	adb shell '[ -d "/system/app/Navigation" ] || rm -rf "/system/app/Navigation"'
	adb shell "rm -rf /system/app/Navigation/*"
		echo_color "测试清理用户目录"
		adb shell "rm -rf /data/user/0/com.autonavi.amapauto"
		adb shell "rm -rf /data/user_de/0/com.autonavi.amapauto"
		adb shell "rm -rf /data/app/*/com.autonavi.amapauto*"
		adb shell "rm -rf /data/media/0/amapauto9"
		adb shell "rm -rf /sdcard/amapauto9"
		adb shell "rm -rf /sdcard/Android/data/com.autonavi.amapauto"

       if [[ "$plugin" == "1" ]];then
			echo_color "安装桌面组件显示插件"
			adb shell '[ -d "/system/app/AutoHelper" ] || mkdir -p "/system/app/AutoHelper"'
			adb push AutoHelper.apk /system/app/AutoHelper/
			adb shell "chmod -R 755 /system/app/AutoHelper/"
		    adb shell "chmod -R 644 /system/app/AutoHelper/AutoHelper.apk"
			adb shell '[ -d "/system/app/AutoHelper/oat/arm64/" ] || mkdir -p "/system/app/AutoHelper/oat/arm64/"'
			adb shell "dex2oat --dex-file=/system/app/AutoHelper/AutoHelper.apk --oat-file=/system/app/AutoHelper/oat/arm64/AutoHelper.odex"
			adb shell "cmd package install-existing com.autohelper"
			adb shell pm list packages | grep "com.autohelper"
		fi

		if [[ "$bak" == "1" ]]; then
		    echo_color "清理新版插件残留..." red
		    adb shell "killall com.autohelper" >/dev/null 2>&1
		    adb shell "pm uninstall com.autohelper" >/dev/null 2>&1
		    adb shell "rm -rf /system/app/AutoHelper"
		    adb shell pm list packages | grep "com.autohelper"
		fi
		adb shell '[ -d "/system/app/AutoMap" ] || mkdir -p "/system/app/AutoMap"'
		echo_color "上传替换高德包"
		
		adb push $filename /data/local/tmp/
		adb push $filename.md5 /data/local/tmp/
		adb push check.sh /data/local/tmp/
		adb shell chmod 777 /data/local/tmp/check.sh
		echo_color "执行替换操作"
		adb shell "tar -xvpf /data/local/tmp/$filename -C /system/app/AutoMap/"
		echo_color "校验文件完整性"
		adb shell "/data/local/tmp/check.sh $filename"
		echo_color "修复文件权限"
		adb shell "chown -R root:root /system/app/AutoMap/"
		adb shell "chmod -R 755 /system/app/AutoMap/"
		adb shell "chmod -R 644 /system/app/AutoMap/AutoMap.apk"
		adb shell "chmod -R 644 /system/app/AutoMap/lib/arm/*"
		if [[ "$bak" == "99" ]]; then
			echo_color "dex2oat优化处理"
			adb shell "mkdir -p /system/app/AutoMap/oat/arm"
			adb shell "/system/bin/dex2oat --dex-file=/system/app/AutoMap/AutoMap.apk  --oat-file=/system/app/AutoMap/oat/arm/AutoMap.odex"
			adb shell "chmod -R 755 /system/app/AutoMap/oat"
			adb shell "chmod -R 644 /system/app/AutoMap/oat/arm/*"
			adb shell "ls -la /system/app/AutoMap/oat/arm/*"
			echo_color "dex2oat优化处理end"
		else
			echo_color "Pass" green
		fi
		echo_color "恢复APP状态及还原安装"
		adb shell "pm enable com.autonavi.amapauto"
		adb shell "pm unhide com.autonavi.amapauto"
		adb shell "pm default-state --user 0 com.autonavi.amapauto"
		echo_color "测试清理步骤"
		adb shell "rm -rf /data/system/package_cache/1/AutoMap*"
		echo_color "等待10秒后开始还原"
		sleep 10
		echo_color "尝试还原"
		adb shell "cmd package install-existing com.autonavi.amapauto"
		echo_color "查看Packages list信息"
		adb shell "pm list packages amap"
		adb shell "pm list packages -u amap"
		echo_color "清理数据"
		adb shell "pm clear com.autonavi.amapauto"
		#echo_color "尝试自动授权..."
		#test_grant 0
		echo_color "开始检测当前车机的全屏配置规则"
		adb shell "settings get global policy_control"
		#echo_color $select_num
		if [[ "$select_num" == "1" ]];then
			echo_color "适配版本自带左侧手势侧滑回桌面!!!"
			echo_color "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			sleep 3
			adb shell "settings put global policy_control null"
		elif [[ "$select_num" == "7500" ]];then
			echo_color "全屏版本将只设置高德为全屏、会覆盖之前的设置!!!"
			echo_color "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			adb shell "settings put global policy_control immersive.navigation=com.autonavi.amapauto"
			policy_control_z "com.autonavi.amapauto"
		elif [[ "$select_num" == "9306" || "$select_num" == "9305" || "$select_num" == "7501" ]];then
			echo_color "适配版本将恢复配置为默认设置、可在五指双击功能中按需设置!!!"
			echo_color "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			adb shell "settings put global policy_control null"
		elif [[ "$select_num" == "0" ]];then
			echo_color "原厂版本将恢复配置为默认设置、会覆盖之前的设置!!!"
			echo_color "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			adb shell "settings put global policy_control null"
		else
			echo_color "安波福主机-全屏配置规则设置完成" green
		fi
		echo_color "开始检测当前车机的全屏配置规则"
		adb shell "settings get global policy_control"
		echo_color "建议配合手势控制软件使用全屏版" yellow
		ReBoot
		
	else
		echo_color "预处理失败、请截图反馈" red
		exit 0
	fi
    #exit 0
    
}







###AutoMap HY
function Navigation()
{
    clear
	cd $Work_Path
	AutoMap_Check_Script_Url="https://dzsms.gwm.com.cn/haval/automap/check_hy.sh"
	AutoMap_Apk="Navigation.apk"
	AutoMap_Zip="Navigation.zip"
	AutoMap_Tar="Navigation.tar"
	Flag=0
	bak=0
	#echo_color "华阳主机专用(1001-1004),其他主机不要刷！" red
	#echo_color "华阳主机专用(1001-1004),其他主机不要刷！" yellow
    #sleep 3
    list_url="https://dzsms.gwm.com.cn/haval/automap/beta.csv"
    echo_color " "
    echo_color "开始获取更新内容......"
    sleep 1
    wget -T 9 -O amapnote.md --no-check-certificate https://dzsms.gwm.com.cn/haval/automap/amapnote.md >/dev/null 2>&1 && cat amapnote.md|head -n 18
    
    echo_color "↓↓↓重要消息↓↓↓" sky-blue
    is_ap_hy_tk "eng.Jenkin"
    #echo_color "请确认！华阳主机专用,其他主机不要刷！" red
    #sleep 3
    echo_color " "
    echo_color "输入菜单后下载失败一般是直链获取失败反馈管理员修复" yellow
    read -p "请根据提示输入数字选择|或者回退(280/0):" select_num
    
    file_data=`curl -ss -k $list_url`
    list_data=`echo -e "$file_data"|grep "^$select_num,"`
    #echo_color "$list_data"
    if [[ "$list_data" == "" ]];then
    	echo_color "输入错误，请截图反馈至管理员，或重新输入代码重新执行脚本" red
    	exit 0
    else
    	#list菜单
    	#read AutoMap_Url md51 tips bak <<< $(echo "$list_data"|awk -F, '{print $2,$3,$4,$5}')
    	read AutoMap_Url md51 tips bak split plugin<<< $(echo "$list_data"|awk -F, '{print $2,$3,$4,$5,$6,$9}')
    fi
    if [[ "$AutoMap_Url" == "" ]];then
    	echo_color "获取数据失败，请截图反馈至管理员，或者保持网络畅通再重试一下" red
    	exit 0
    else
    	echo_color "您选择的是:$select_num:$tips"
    	sleep 3
    fi

	filename=""
	if [[ "$plugin" == "1" ]];then
		echo_color "插件下载中..."
		read plugin_url plugin_md5 <<< $(echo -e "$file_data"|grep "^AutoHelper"|awk -F, '{print $2,$3}')
		wzget $plugin_url AutoHelper.apk
		plugin_md5_local=`md5sum AutoHelper.apk |awk '{print $1}'`
		if [[ "$plugin_md5_local" != "$plugin_md5" ]];then
			echo_color "$plugin_md5_local:$plugin_md5"
			echo_color "插件下载失败、请保持网络稳定重新执行脚本!!!" red
			exit 0
		fi
	fi
	wzget  $AutoMap_Check_Script_Url check.sh
	echo_color "开始预处理"
	cd $Work_Path
	rm -rf tmp
	mkdir tmp
	cd tmp
	if [[ "$bak" == "0" || "$bak" == "9" ]]; then
		wzget  $AutoMap_Url $AutoMap_Apk
	else
	    wzget "https://dzsms.gwm.com.cn/haval/automap/Navigation.apk" $AutoMap_Apk
	    md51="2e1c8cc244fd71dc8436e99a3f8455b5"
	fi
	if [[ "1" == "1" ]]; then
		md5a=`md5sum $AutoMap_Apk |awk '{print $1}'`
		echo_color "$md5a:$md51"
		if [[ "$md5a" == "$md51" ]];then
		    echo_color "检查是否分离so库文件"
			if [[ "$split" == "1" ]];then
				echo_color "so库分离,正在下载库文件"
				read lib_url lib_md5 <<< $(echo "$list_data"|awk -F, '{print $7,$8}')
				wzget "$lib_url" lib.zip
				lib_md5_local=`md5sum lib.zip |awk '{print $1}'`
				if [[ "$lib_md5_local" == "$lib_md5" ]];then
					echo_color "开始解压"
					unzip -o lib.zip >/dev/null 2>&1
				else
					echo_color "$lib_md5_local:$lib_md5"
					echo_color "下载失败、请保持网络稳定重新执行脚本!!!" red
					exit 0
				fi
			else
				echo_color "非分离库,开始解包"
				unzip -o $AutoMap_Apk >/dev/null 2>&1
			fi
			#echo_color "开始解包"
			#unzip -o $AutoMap_Apk >/dev/null 2>&1
			echo_color "解包完成..."
			echo_color "开始打包必要文件"
			rm -rf Navigation
			mkdir -p Navigation/lib
			mv lib/armeabi-v7a Navigation/lib/arm >/dev/null 2>&1
			mv lib/arm64-v8a Navigation/lib/arm >/dev/null 2>&1
			cp $AutoMap_Apk Navigation/Navigation.apk
			rm -rf $Work_Path/$AutoMap_Tar
			cd Navigation/ && tar -cvpf $Work_Path/$AutoMap_Tar * >/dev/null 2>&1
			find ./ -type f -print0|xargs -0 md5sum >$Work_Path/$AutoMap_Tar.md5
			sed -i 's/.\//\/system\/app\/Navigation\//' $Work_Path/$AutoMap_Tar.md5
			cd $Work_Path/ && rm -rf $Work_Path/tmp
			ls -l $AutoMap_Tar*
			echo_color "预处理完成"
			filename="$AutoMap_Tar"
		else
			echo_color "下载失败、请保持网络稳定重新执行脚本!!!" red
			exit 0
		fi
		
	else
		echo_color "无用"
		
	fi
	Adb_Init
	if [[ "$filename" != "" ]];then
		echo_color "释放进程...."
		adb shell "killall com.autonavi.amapauto 2>/dev/null"
		adb shell "killall com.autonavi.amapauto:push 2>/dev/null"
		adb shell "killall com.autonavi.amapauto:locationservice 2>/dev/null"
		echo_color "卸载升级或者清理手动升级残留"
		adb shell "pm clear com.autonavi.amapauto"
		adb shell "pm uninstall com.autonavi.amapauto >/dev/null"
		adb shell "pm uninstall --user 0 com.autonavi.amapauto >/dev/null"
		echo_color "查看Packages list信息"
		adb shell "pm list packages amap"
		adb shell "pm list packages -u amap"
		echo_color "释放空间...."
		adb shell "echo '' > /system/app/Navigation/Navigation.apk"
		echo_color "删除原车高德地图系统文件"
		adb shell "rm -rf /system/app/Navigation/*"
		#误装处理
		adb shell '[ -d "/system/app/AutoMap" ] || echo '' > /system/app/AutoMap/AutoMap.apk'
		adb shell '[ -d "/system/app/AutoMap" ] || rm -rf "/system/app/AutoMap"'
		adb shell "rm -rf /system/app/AutoMap/*"
		echo_color "测试清理用户目录"
		adb shell "rm -rf /data/user/0/com.autonavi.amapauto"
		adb shell "rm -rf /data/user_de/0/com.autonavi.amapauto"
		adb shell "rm -rf /data/app/*/com.autonavi.amapauto*"
		adb shell "rm -rf /data/media/0/amapauto9"
		adb shell "rm -rf /sdcard/amapauto9"
		adb shell "rm -rf /sdcard/Android/data/com.autonavi.amapauto"
		adb shell "rm -rf /storage/emulated/0/Android/data/com.autonavi.amapauto"
# 		adb shell '[ -d "/storage/emulated/0/Android/data/com.autonavi.amapauto/files" ] || mkdir -p "/storage/emulated/0/Android/data/com.autonavi.amapauto/files"'
# 		adb shell '[ -d "/sdcard/amapauto9" ] || mkdir -p "/sdcard/amapauto9"'

	    if [[ "$plugin" == "1" ]];then
			echo_color "安装桌面组件显示插件"
			adb shell '[ -d "/system/app/AutoHelper" ] || mkdir -p "/system/app/AutoHelper"'
			adb push AutoHelper.apk /system/app/AutoHelper/
			adb shell "chmod -R 755 /system/app/AutoHelper/"
		    adb shell "chmod -R 644 /system/app/AutoHelper/AutoHelper.apk"
			adb shell '[ -d "/system/app/AutoHelper/oat/arm64/" ] || mkdir -p "/system/app/AutoHelper/oat/arm64/"'
			adb shell "dex2oat --dex-file=/system/app/AutoHelper/AutoHelper.apk --oat-file=/system/app/AutoHelper/oat/arm64/AutoHelper.odex"
			adb shell "cmd package install-existing com.autohelper"
			adb shell pm list packages | grep "com.autohelper"
		fi

		if [[ "$bak" == "1" ]]; then
		    echo_color "清理新版插件残留..." red
		    adb shell "killall com.autohelper" >/dev/null 2>&1
		    adb shell "pm uninstall com.autohelper" >/dev/null 2>&1
		    adb shell "rm -rf /system/app/AutoHelper"
		    adb shell pm list packages | grep "com.autohelper"
		fi
		adb shell '[ -d "/system/app/Navigation" ] || mkdir -p "/system/app/Navigation"'
		echo_color "上传替换高德包"
		adb push $filename /data/local/tmp/
		adb push $filename.md5 /data/local/tmp/
		adb push check.sh /data/local/tmp/
		adb shell chmod 777 /data/local/tmp/check.sh
		echo_color "执行替换操作"
		adb shell "tar -xvpf /data/local/tmp/$filename -C /system/app/Navigation/"
		echo_color "校验文件完整性"
		adb shell "/data/local/tmp/check.sh $filename"
		echo_color "修复文件权限"
		adb shell "chown -R root:root /system/app/Navigation/"
		adb shell "chmod -R 755 /system/app/Navigation/"
		adb shell "chmod -R 644 /system/app/Navigation/Navigation.apk"
		adb shell "chmod -R 644 /system/app/Navigation/lib/arm/*"
		if [[ "$bak" == "29" ]]; then
			echo_color "dex2oat优化处理"
			adb shell "mkdir -p /system/app/Navigation/oat/arm64"
			adb shell "dex2oat --dex-file=/system/app/Navigation/Navigation.apk  --oat-file=/system/app/Navigation/oat/arm64/Navigation.odex"
			adb shell "chmod -R 755 /system/app/Navigation/oat"
			adb shell "chmod -R 644 /system/app/Navigation/oat/arm64/*"
			adb shell "ls -la /system/app/Navigation/oat/arm64/*"
			echo_color "dex2oat优化处理end"
		else
			echo_color "Pass" green
		fi
		echo_color "恢复APP状态及还原安装"
		adb shell "pm enable com.autonavi.amapauto"
		adb shell "pm unhide com.autonavi.amapauto"
		adb shell "pm default-state --user 0 com.autonavi.amapauto"
		echo_color "测试清理步骤"
		adb shell "rm -rf /data/system/package_cache/1/AutoMap*"
		adb shell "rm -rf /data/system/package_cache/1/Navigation"
		echo_color "等待10秒后开始还原"
		sleep 10
		echo_color "尝试还原"
		adb shell "cmd package install-existing com.autonavi.amapauto"
		echo_color "查看Packages list信息"
		adb shell "pm list packages amap"
		adb shell "pm list packages -u amap"
		#echo_color "清理数据"
		#adb shell "pm clear com.autonavi.amapauto"
        echo_color "尝试自动授权..."
        test_grant 0

        #echo_color "请再次输入车机IP，以便执行检查全屏规则"
        #cd $Work_Path
	    #Adb_Init

		echo_color "开始检测当前车机的全屏配置规则"
		adb shell "settings get global policy_control"
		#echo_color $select_num
		if [[ "$select_num" == "1" ]];then
			echo_color "适配版本自带左侧手势侧滑回桌面!!!"
			echo_color "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			sleep 3
			adb shell "settings put global policy_control null"
		elif [[ "$select_num" == "7500" ]];then
			echo_color "全屏版本将只设置高德为全屏、会覆盖之前的设置!!!"
			echo_color "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			policy_control_z "com.autonavi.amapauto"
			#adb shell "settings put global policy_control immersive.full=com.autonavi.amapauto"
		elif [[ "$select_num" == "9306" || "$select_num" == "9305" || "$select_num" == "7501" ]];then
			echo_color "适配版本将恢复配置为默认设置、可在五指双击功能中按需设置!!!"
			echo_color "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			adb shell "settings put global policy_control null"
		elif [[ "$select_num" == "0" ]];then
			echo_color "原厂版本将恢复配置为默认设置、会覆盖之前的设置!!!"
			echo_color "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			adb shell "settings put global policy_control null"
		else
			echo_color "华阳主机-全屏配置规则设置完成" green
		fi
		echo_color "如全屏适配失败，请再跑一次脚本，选择菜单6，再输入4，根据菜单单独全屏适配。" yellow
		ReBoot
		
	else
		echo_color "预处理失败、请截图反馈" red
		exit 0
	fi
}











###quanping
function quanping()
{
    cd $Work_Path
	Adb_Init
	sleep 3
	clear
	echo "开始检测当前车机的全屏配置规则"
	adb shell "settings get global policy_control"
	echo "1、设置所有第三方APP全屏"
	echo "2、恢复系统默认设置"
	echo "3、可自定义全屏包名"
	echo "4、在现有的基础上配置高德为全屏(修复侧边栏重叠问题)"
	echo ""
	read -p "请输入数字选择:" num

	case $num in
		1)
			echo "设置所有第三方APP全屏"
			adb shell settings put global policy_control immersive.navigation=apps,-com.tencent.wecarflow,-com.android.cts.priv.ctsshim,-com.aptiv.thememanager,-com.tencent.tai.pal.platform.app,-com.edog.car,-com.gwm.app.bookshelf,-com.gwm.app.smartmanual,-com.gwmv3.vehicle,-com.aptiv.mediator,-com.gwm.app.onlinevideo,-com.redbend.client,-com.iflytek.cutefly.speechclient.hmi,-com.android.certinstaller,-com.aptiv.dlna,-com.gwmv3.launcher,-com.gwm.app.weather,-com.aptiv.camera,-com.gwmv3.media,-com.android.se,-com.gwmv3.photo,-com.gwmv3.radio,-com.gwmv3.dlna,-com.gwm.app.themestore,-com.hanvon.inputmethod.callaime,-com.gwmv3.setting,-com.gwm.app.iotapp,-com.ss.android.ugc.aweme,-com.android.packageinstaller,-com.gwmv3.dvr,-com.aptiv.thirdmediaparty,-com.gwmv3.personalcenter,-com.aptiv.car,-net.easyconn,-com.gwmv3.engineermode,-com.gwm.app.appstore,-com.aptiv.carplay,-com.android.systemui,-com.aptiv.media,-com.aptiv.radio,-com.aptiv.multidisplay,-com.gwm.app.etcp,-com.gwmv3.theme0201,-com.gwmv3.theme0301,-com.gwmv3.theme0302,-com.gwmv3.theme0401,-com.tencent.sotainstaller,-com.tencent.enger
			;;
		2)
			echo "恢复系统默认设置"
			adb shell settings put global policy_control null
			;;
		3)
			echo "可自定义全屏包名，多个app请用,号隔开,例如输入 com.autonavi.amapauto,cn.kuwo.kwmusiccar"
			read -p "请输入自定义全屏包名确认无误后回车:" pkg_name
			adb shell settings put global policy_control immersive.navigation=$pkg_name
			;;
		4)
			echo "开始设置"
			policy_control_z "com.autonavi.amapauto"
			;;

		5)
			echo "华阳主机高德去除状态栏-测试"
			adb shell settings put global policy_control immersive.status=com.autonavi.amapauto
			;;

		*)
			echo "error"
	esac
	echo "开始检测当前车机的全屏配置规则"
	adb shell "settings get global policy_control"
	echo "操作完成！"
}


###rootinstallenger
function rootinstallenger()
{
    echo "安卓已Root手机的安装工装模式...有空弄一下。"
	#判断是否su
	#判断完整root还是magisk
	#判断系统分区是否可读写
	#如果是可写hosts，覆写hosts记录
	#如果magisk install hosts module
	#修改模块host链接文件 重启手机
	#验证hosts是否生效等等
    #sleep 5
    #exit 0
}



###LogSubmit
function LogSubmit()
{
    clear
    echo "临时信息收集...."
    Adb_Init
    adb shell "cat /system/build.prop | grep ro.build.version.incremental"
    echo "请复制上面的结果给，并说明你的版本...."
    #exit 0
    echo "将自动抓取30S的log至手机download目录"
    echo "请务必提前执行：termux-setup-storage,否则没有权限访问存储空间!!!"
    sleep 2
    current=`date "+%Y-%m-%d %H:%M:%S"`
    timeStamp=`date -d "$current" +%s`
    currentTimeStamp=$((timeStamp*1000+10#`date "+%N"`/1000000))
    Log_file="AAAA_test_log_$currentTimeStamp.log"
    Log_Path="/sdcard/Download"
    echo "当前脚本执行环境检测中....."
    flag=`echo "check log Permission ???">$Log_Path/$Log_file|grep Permission`
    if [[ $flag=="" ]];then
        echo "权限检测通过"
        echo "pass!!!"
    else
        echo "请务必提前执行：termux-setup-storage,否则没有权限访问存储空间!!!"
        sleep 5
        exit 0
    fi
    echo "开始...."
    echo "请提前连接好车机,建议复现bug后再执行!!!"
    sleep 3
    #Adb_Init
    echo "log默认将抓取20秒，请耐心等待!!!"
    adb shell "logcat">$Log_Path/$Log_file & sleep 20;adb shell "killall logcat"
    echo "log抓取结束,保存目录为：$Log_Path/$Log_file,如果没有自动上传成功请手动用微信反馈至群内..."
    echo "end......"
    sleep 5
    exit 0
}





function test_grant()
{
    
    if [[ "$1" == "0" ]];then
        echo_color ""
    else
        Adb_Init
        echo_color "########################" yellow
        adb shell "dumpsys package com.autonavi.amapauto"
        echo_color "########################" yellow
        grant "com.autonavi.amapauto" "android.permission.FOREGROUND_SERVICE"
        grant "com.autonavi.amapauto" "android.permission.ACCESS_NETWORK_STATE"
        grant "com.autonavi.amapauto" "android.permission.INTERNET"
        grant "com.autonavi.amapauto" "android.permission.RECEIVE_BOOT_COMPLETED"
        grant "com.autonavi.amapauto" "android.permission.ACCESS_WIFI_STATE"
        grant "com.autonavi.amapauto" "android.permission.ACCESS_LOCATION_EXTRA_COMMANDS"
        grant "com.autonavi.amapauto" "android.permission.ACCESS_COARSE_LOCATION"
        grant "com.autonavi.amapauto" "android.permission.RECORD_AUDIO"
        grant "com.autonavi.amapauto" "android.permission.SYSTEM_ALERT_WINDOW"
        grant "com.autonavi.amapauto" "android.permission.GET_TASKS"
        grant "com.autonavi.amapauto" "android.permission.BLUETOOTH_ADMIN"
        grant "com.autonavi.amapauto" "android.permission.BLUETOOTH"
        grant "com.autonavi.amapauto" "android.permission.CAMERA"
    fi
    grant "com.autonavi.amapauto" "android.permission.WRITE_EXTERNAL_STORAGE"
    grant "com.autonavi.amapauto" "android.permission.LOCAL_MAC_ADDRESS"
    grant "com.autonavi.amapauto" "android.permission.WRITE_MEDIA_STORAGE"
    grant "com.autonavi.amapauto" "android.permission.MANAGE_USB"
    grant "com.autonavi.amapauto" "android.permission.READ_EXTERNAL_STORAGE"
    grant "com.autonavi.amapauto" "android.permission.WRITE_SETTINGS"
    grant "com.autonavi.amapauto" "android.permission.POST_NOTIFICATIONS"
    grant "com.autonavi.amapauto" "android.permission.ACCESS_FINE_LOCATION"
    grant "com.autonavi.amapauto" "android.permission.READ_PHONE_STATE"
    grant "com.autonavi.amapauto" "android.permission.READ_MEDIA_IMAGES"
    grant "com.autonavi.amapauto" "android.permission.ACCESS_MEDIA_LOCATION"
    
    adb shell "dumpsys package com.autonavi.amapauto" | grep -i  "runtime permissions:" -A 20
    sleep 5
    
}

# function test_clear()
# {
#     Adb_Init
#     adb shell "df -h"
#     echo_color "释放爱趣听...."
#     adb shell "echo '' > /system/app/wecarflow/wecarflow.apk"
#     adb shell "rm -rf  /system/app/wecarflow/*"
#     echo_color "释放高德...."
#     adb shell "echo '' > /system/app/AutoMap/AutoMap.apk"
#     echo_color "删除原车高德地图系统文件"
#     adb shell "rm -rf /system/app/AutoMap/*"
#     echo_color "测试清理用户目录"
#     adb shell "rm -rf /data/user/0/com.autonavi.amapauto"
#     adb shell "rm -rf /data/user_de/0/com.autonavi.amapauto"
#     adb shell "rm -rf /data/app/*/com.autonavi.amapauto*"
#     adb shell "rm -rf /data/media/0/amapauto9"
#     adb shell "rm -rf /sdcard/amapauto9"
#     adb shell "rm -rf /sdcard/Android/data/com.autonavi.amapauto"
#     echo_color "请截图反馈！！！"
#     adb shell "lpdump"
#     adb shell "df -h"
#     adb enable-verity
#     echo_color "重启中....如需恢复请通过主菜单安装！！！！！！！"
#     ReBoot
# }




function menu()
{
    cat <<eof
    
***************************************************
*                      90APT                    *
***************************************************


*  1.配置软件是否为全屏                          *

*  2.高德安波福       							*

*  3.高德华阳									 *

*  0.退出                                        *

***************************************************
Tips: 请开启工装模式中TCP/IP且车机连手机热点
刷来刷去，最终还是亿连自启动+VIVO车载+高德
如果你刷了车机地图后悔了，别忘了刷回原厂地图
***************************************************
eof

}
function usage()
{
    read -p "请看清对应操作输入数字选项后回车: " choice
    case $choice in

        1)
            quanping
            ;;

        2)
            AutoMapBeta
            ;;

        3)
            Navigation
            ;;
        0)
            exit 0
            ;;
		*)
            clear
            ;;

    esac
}
function  main()
{
    while true
    do
        #clear 
        menu
        usage
    done
}

Path_fix
Env_fix
#CheckUpdate
#byby
clear
main
