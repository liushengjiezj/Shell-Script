#!/usr/bin/env bash
# Author: Shengjie.Liu
# Date: 2019-04-15
# Version: 1.0
# Description: 权限检查
# How to use: sh +x permission_check.sh

#清空上次运行后产生的文件
if [[ -f permission_old.txt ]]; then
    rm permission_old.txt permission_new.txt
fi

#读取apk文件地址
read -p "请输入上个版本apk文件存放地址：" apk_old
read -p "请输入最新版本apk文件存放地址：" apk_new

#检查apk size
k_size_old=`ls -s -k ${apk_old} | awk '{print $1}'`
m_size_old=`awk 'BEGIN{printf "%.2f\n", "'${k_size_old}'"/'1024'}'`

k_size_new=`ls -s -k ${apk_new} | awk '{print $1}'`
m_size_new=`awk 'BEGIN{printf "%.2f\n", "'${k_size_new}'"/'1024'}'`

#aapt命令解析apk,输出权限到文件
aapt d badging ${apk_old} | grep "uses-permission:" | awk -F "'" '{print $2}' > permission_old.txt
aapt d badging ${apk_new} | grep "uses-permission:" | awk -F "'" '{print $2}' > permission_new.txt

#遍历新版本权限列表，对比旧版本权限列表是否相同，不同则为新增
for x in $(cat permission_new.txt); do
    if cat permission_old.txt | grep ${x} > /dev/null; then
        echo "hello, world" > /dev/null
    else
        echo ${x} >> permission_increase.txt
    fi
done

#遍历旧版本权限列表，对比新版本权限列表是否相同，不同则为新减少
for y in $(cat permission_old.txt); do
    if cat permission_new.txt | grep ${y} > /dev/null; then
        echo "hello, world" > /dev/null
    else
        echo ${y} >> permission_decrease.txt
    fi
done

#判断permission_increase.txt是否存在：存在，输出新增权限提醒；不存在，输出无新增权限
if [[ ! -f permission_increase.txt ]]; then
    echo "无新增权限"
else
    echo "新增权限："
    cat permission_increase.txt
    #删除新增权限文件
    rm permission_increase.txt
fi

#判断permission_decrease.txt是否存在：存在，输出新减少权限提醒；不存在，输出无新减少权限
if [[ ! -f permission_decrease.txt ]]; then
    echo "无新减少权限"
else
    echo "新减少权限："
    cat permission_decrease.txt
    #删除新减少权限文件
    rm permission_decrease.txt
fi

#输出apk size
echo "上个版本apk size: ${m_size_old}MB"
echo "最新版本apk size: ${m_size_new}MB"
