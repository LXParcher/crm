package com.bjpowernode.crm.web.listener;

import com.bjpowernode.crm.settings.domain.DicValue;
import com.bjpowernode.crm.settings.service.DicService;
import com.bjpowernode.crm.settings.service.impl.DicServiceImpl;
import com.bjpowernode.crm.utils.ServiceFactory;
import com.sun.xml.internal.messaging.saaj.packaging.mime.util.LineInputStream;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.util.List;
import java.util.Map;

public class SysInitListener implements ServletContextListener {
    /*
        event:该参数能够取得监听的对象
            监听的是什么对象，就可以通过该参数取得什么对象
            例如我们现在监听的是上下文域对象，通过该参数就可以取得上下文域对象
     */

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // System.out.println("上下文域对象创建了");
        ServletContext application = sce.getServletContext();

        DicService ds = (DicService) ServiceFactory.getService(new DicServiceImpl());

        Map<String, List<DicValue>> map = ds.getAll();

        for (String key : map.keySet()) {
            application.setAttribute(key, map.get(key));
        }



    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("上下文域对象销毁了");
    }
}
