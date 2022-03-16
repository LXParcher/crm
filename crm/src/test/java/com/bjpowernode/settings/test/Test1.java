package com.bjpowernode.settings.test;

import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.MD5Util;

public class Test1 {
    public static void main(String[] args) {

        /*String expireTime = "2022-03-15 16:10:00";
        String sysTime = DateTimeUtil.getSysTime();
        int isExpire = expireTime.compareTo(sysTime);
        *//* 1：expireTime > sysTime 有效
           -1：expireTime < sysTime 失效
           0： expireTime = sysTime 相等
         *//*
        System.out.println(isExpire);*/

        String pwd = "123";
        pwd = MD5Util.getMD5(pwd);
        System.out.println(pwd);
    }
}
