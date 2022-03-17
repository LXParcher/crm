package com.bjpowernode.crm.web.filter;

import com.bjpowernode.crm.settings.domain.User;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class LoginFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) resp;

        String path = request.getServletPath();

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (path.contains("login") || user != null) {
            chain.doFilter(req, resp);
        }else {
            /*
            对于路径的使用，一律使用绝对路径
            关于转发和重定向的路径的写法如下：
            转发：
                使用的是一种特殊的绝对路径的使用方式，这种绝对路径前面不加/项目名，这种路径也称为内部路径
            重定向：
                使用的是传统绝对路径的写法，前面必须以/项目名开头，后面跟具体的资源路径

            为什么使用重定向，使用转发不行吗？
                转发之后，地址栏路径不变，停留在老路径
                我们应该为用户跳转到登录页时，将浏览器的地址栏设置为登录页的路径
             */

            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }
}
