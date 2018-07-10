#!/bin/bash
###############################################
## Author  : admin@zhaowenyu.com
## Version : v1.0
## Charset : set encoding=utf8 
###############################################

filename=$0
action=$1 # -i/--install 执行安装软件
script_name="./tengine-2.2.0-install.sh"

init() {

    TMP_INSTALL="/tmp/tengine-install-tmp/"
    [ -d $TMP_INSTALL ] || mkdir -p $TMP_INSTALL 
    cd $TMP_INSTALL 
    [ -f install.log ] && echo '' > install.log || touch install.log

    #if [ "$filename" = "$script_name" ];then
    #    mkdir /usr/local/tengine
    #else
    #    echo "[ERROR] 脚本执行方法错误，请使用相对路径"
    #    usage
    #    exit 1
    #fi
}

get_software() {
    OPENSSL_URL='https://wenyu-soft.oss-cn-hangzhou.aliyuncs.com/tengine-install-tools/openssl-1.0.2.tar.gz'
    PCRE_URL='https://wenyu-soft.oss-cn-hangzhou.aliyuncs.com/tengine-install-tools/pcre-8.39.tar.gz'
    TENGINE_URL='https://wenyu-soft.oss-cn-hangzhou.aliyuncs.com/tengine-install-tools/tengine-2.2.0.tar.gz'
    ZLIB_URL='https://wenyu-soft.oss-cn-hangzhou.aliyuncs.com/tengine-install-tools/zlib-1.2.11.tar.gz'

    for soft in "$OPENSSL_URL $PCRE_URL $TENGINE_URL $ZLIB_URL"
    do
         echo "==> $soft"
         wget -o $TMP_INSTALL/install.log  $soft
    done
}

check_env() {
    which gcc &>/dev/null
    RETURN=$?
    if [ $RETURN -ne 0 ];then
        echo "[ERROR] 没有安装GCC"
        echo "yum安装方法：yum install  gcc make gcc-c++ perl -y"
        echo "deb安装方法：apt-get install gcc make gcc-c++ perl -y"
        exit 1
    fi

    which wget
    RETURN2=$?
    if [ $RETURN2 -ne 0 ];then
        echo "yum -y install wget"
    fi
}

extract_tar() {
    if [ -f 'tengine-2.2.0.tar.gz' -a -f 'zlib-1.2.11.tar.gz' -a -f  'pcre-8.39.tar.gz' -a -f 'openssl-1.0.2.tar.gz' ]; then
        tar xf zlib-1.2.11.tar.gz   -C $TMP_INSTALL
        tar xf pcre-8.39.tar.gz     -C $TMP_INSTALL 
        tar xf openssl-1.0.2.tar.gz -C $TMP_INSTALL 
        tar xf tengine-2.2.0.tar.gz -C $TMP_INSTALL 
    else
        echo "can't find the software, Please wait download"
        exit 1
    fi
}

compile() {
    cd $TMP_INSTALL/tengine-2.2.0 && ./configure --prefix=/usr/local/tengine --with-zlib=/$TMP_INSTALL/zlib-1.2.11 --with-pcre=/$TMP_INSTALL/pcre-8.39 --with-openssl=/$TMP_INSTALL/openssl-1.0.2
    make && make install
}

clean_env() {
    #rm -fr  /tmp/zlib-1.2.11  /tmp/pcre-8.39  /tmp/openssl-1.0.2 /tmp/tengine-2.2.0
    #
    echo "clean ok"
}

chown_tengine() {
    id nginx &> /dev/null || useradd nginx -s /sbin/nologin
    [ -f /usr/local/tengine/conf/nginx.conf ] && sed -i '1a user nginx;'  /usr/local/tengine/conf/nginx.conf || echo "/usr/local/tengine/conf/nginx.conf 不存在"
    chown -R nginx.nginx /usr/local/tengine
}

install() {
    check_env
    get_software
    extract_tar
    compile
    clean_env
    chown_tengine
}

usage() {
    echo ""
    echo "                   Tengine自动安装脚步使用方法"
    echo "##################################################################"
    echo "# $filename -h/--help    : 输出帮助信息"
    echo "# $filename -i/--install : 开始编译安装"
    echo "# 1.安装需要使用相对路径执行名：$filename"
    echo "# 2.安装过程出现错误需要处理"
    echo "# 3.默认会将软件安装在: /usr/local/tengine"
    echo "##################################################################"
    echo ""
    exit 0
}

devopt() {
    echo ""
    echo "##########################################################################"
    echo "# 运行Tengine服务可以选择以下两种方式："
    echo "# 1./usr/local/tengine/tengine {start|stop|restart|reload|status|help}"
    echo "# 2./usr/local/tengine/sbin/nginx -c /usr/local/tengine/conf/nginx.conf"
    echo "##########################################################################"
    echo ""
}

main() {
    if [[ "$action" = "-i" || "$action" = "--install" ]];then
        init
        install
        devopt
    else
        usage
    fi 
}

main;
