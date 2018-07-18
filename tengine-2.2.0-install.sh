#!/bin/bash
###############################################
## Author  : admin@zhaowenyu.com
## Version : v1.0
## Charset : set encoding=utf8 
###############################################

filename=$0
action=$1 # -i/--install 执行安装软件
script_name="./tengine-2.2.0-install.sh"
TMP_INSTALL="/tmp/tengine-install-tmp/"

get_software() {
    OPENSSL_URL='https://wenyu-soft.oss-cn-hangzhou.aliyuncs.com/tengine-install-tools/openssl-1.0.2.tar.gz'
    PCRE_URL='https://wenyu-soft.oss-cn-hangzhou.aliyuncs.com/tengine-install-tools/pcre-8.39.tar.gz'
    TENGINE_URL='https://wenyu-soft.oss-cn-hangzhou.aliyuncs.com/tengine-install-tools/tengine-2.2.0.tar.gz'
    ZLIB_URL='https://wenyu-soft.oss-cn-hangzhou.aliyuncs.com/tengine-install-tools/zlib-1.2.11.tar.gz'

    if [ ! -f openssl-1.0.2.tar.gz ];then
        wget $OPENSSL_URL
    fi

    if [ ! -f pcre-8.39.tar.gz ];then
        wget $PCRE_URL
    fi

    if [ ! -f zlib-1.2.11.tar.gz ];then
        wget $ZLIB_URL

    fi

    if [ ! -f tengine-2.2.0.tar.gz ];then
        wget $TENGINE_URL
    fi

}

check_env() {
    if [ -d $TMP_INSTALL ];then
        rm -fr $TMP_INSTALL
        mkdir -p $TMP_INSTALL
    else
        mkdir -p $TMP_INSTALL 
    fi

    which gcc &>/dev/null
    RETURN=$?
    if [ $RETURN -ne 0 ];then
        echo "[ERROR] 没有安装GCC"
        echo "yum安装方法：yum install  gcc make gcc-c++ perl -y"
        echo "deb安装方法：apt-get install gcc make gcc-c++ perl -y"
        exit 1
    fi

    which wget &>/dev/null
    RETURN2=$?
    if [ $RETURN2 -ne 0 ];then
        echo "[ERROR] 没有安装wget"
        echo "yum安装方法：yum install  wget -y"
        echo "deb安装方法：apt-get install wget-y"
        exit 1
    fi
}

extract_tar() {
    if [ -f 'tengine-2.2.0.tar.gz' -a -f 'zlib-1.2.11.tar.gz' -a -f  'pcre-8.39.tar.gz' -a -f 'openssl-1.0.2.tar.gz' ]; then
        tar xf zlib-1.2.11.tar.gz   -C $TMP_INSTALL
        tar xf pcre-8.39.tar.gz     -C $TMP_INSTALL 
        tar xf openssl-1.0.2.tar.gz -C $TMP_INSTALL 
        tar xf tengine-2.2.0.tar.gz -C $TMP_INSTALL 
    else
        echo "can't find the software in current directory, Please wait download"
        exit 1
    fi
}

compile() {
    cd $TMP_INSTALL/tengine-2.2.0 && ./configure --prefix=/usr/local/tengine --with-zlib=/$TMP_INSTALL/zlib-1.2.11 --with-pcre=/$TMP_INSTALL/pcre-8.39 --with-openssl=/$TMP_INSTALL/openssl-1.0.2
    make && make install
}

clean_env() {
    rm -fr  $TMP_INSTALL 
    echo "clean ok"
}

tengine_script() {
    cd -
    cp -f tengine /usr/local/tengine/
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
    tengine_script
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
        install
        devopt
    else
        usage
    fi 
}

main;
