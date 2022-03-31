package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.exception.SaveActivityException;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.settings.service.impl.UserServiceImpl;
import com.bjpowernode.crm.utils.*;
import com.bjpowernode.crm.vo.PaginationVO;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.ActivityRemark;
import com.bjpowernode.crm.workbench.service.ActivityService;
import com.bjpowernode.crm.workbench.service.impl.ActivityServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActivityController extends HttpServlet {

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/workbench/activity/getUserList.do".equals(path)) {

            getUserList(request, response);

        }else if ("/workbench/activity/saveActivity.do".equals(path)) {

            save(request, response);

        }else if ("/workbench/activity/pageList.do".equals(path)) {

            pageList(request, response);

        }else if ("/workbench/activity/delete.do".equals(path)) {

            delete(request, response);

        }else if ("/workbench/activity/getUserListAndActivity.do".equals(path)) {

            getUserListAndActivity(request, response);

        }else if ("/workbench/activity/updateActivity.do".equals(path)) {

            updateActivity(request, response);

        }else if ("/workbench/activity/detail.do".equals(path)) {

            detail(request, response);

        }else if ("/workbench/activity/getRemarkListByActivityId.do".equals(path)) {

            getRemarkListByActivityId(request, response);

        }else if ("/workbench/activity/removeRemark.do".equals(path)) {

            removeRemark(request, response);

        }else if ("/workbench/activity/saveRemark.do".equals(path)) {

            saveRemark(request, response);

        }else if ("/workbench/activity/editRemark.do".equals(path)) {

            editRemark(request, response);

        }
    }

    private void editRemark(HttpServletRequest request, HttpServletResponse response) {
        String id = request.getParameter("id");
        String noteContent = request.getParameter("noteContent");
        String editTime = DateTimeUtil.getSysTime();
        String editBy = ((User)request.getSession(false).getAttribute("user")).getName();
        String editFlag = "1";

        ActivityRemark activityRemark = new ActivityRemark();

        activityRemark.setId(id);
        activityRemark.setNoteContent(noteContent);
        activityRemark.setEditBy(editBy);
        activityRemark.setEditTime(editTime);
        activityRemark.setEditFlag(editFlag);

        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        boolean success = activityService.editRemark(activityRemark);
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("success", success);
        map.put("ActivityRemark", activityRemark);
        PrintJson.printJsonObj(response, map);
    }

    private void saveRemark(HttpServletRequest request, HttpServletResponse response) {
        ActivityRemark activityRemark = new ActivityRemark();

        String id = UUIDUtil.getUUID();
        String noteContent = request.getParameter("noteContent");
        String createTime = DateTimeUtil.getSysTime();
        String createBy = ((User)request.getSession(false).getAttribute("user")).getName();
        String editFlag = "0";
        String activityId = request.getParameter("activityId");

        activityRemark.setId(id);
        activityRemark.setNoteContent(noteContent);
        activityRemark.setCreateTime(createTime);
        activityRemark.setCreateBy(createBy);
        activityRemark.setEditFlag(editFlag);
        activityRemark.setActivityId(activityId);

        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        boolean success = activityService.saveRemark(activityRemark);
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("success", success);
        map.put("ActivityRemark", activityRemark);
        PrintJson.printJsonObj(response, map);
    }

    private void removeRemark(HttpServletRequest request, HttpServletResponse response) {
        String remarkId = request.getParameter("remarkId");
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        boolean success = activityService.removeRemark(remarkId);
        PrintJson.printJsonFlag(response, success);

    }

    private void getRemarkListByActivityId(HttpServletRequest request, HttpServletResponse response) {
        String activityId = request.getParameter("activityId");

        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        List<ActivityRemark> activityRemarkList = activityService.getRemarkListByActivityId(activityId);

        PrintJson.printJsonObj(response, activityRemarkList);
    }

    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");

        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        Activity activity = activityService.detail(id);

        request.setAttribute("activity", activity);

        request.getRequestDispatcher("/workbench/activity/detail.jsp").forward(request, response);

    }

    private void updateActivity(HttpServletRequest request, HttpServletResponse response) {
        String id = request.getParameter("id");
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String cost = request.getParameter("cost");
        String description = request.getParameter("description");
        // 当前系统时间
        String editTime = DateTimeUtil.getSysTime();
        // 当前登录的用户
        String editBy = ((User)request.getSession(false).getAttribute("user")).getName();

        Activity activity = new Activity();
        activity.setId(id);
        activity.setOwner(owner);
        activity.setName(name);
        activity.setStartDate(startDate);
        activity.setEndDate(endDate);
        activity.setCost(cost);
        activity.setDescription(description);
        activity.setEditTime(editTime);
        activity.setEditBy(editBy);

        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        boolean success = false;
        try {
            success = activityService.updateActivity(activity);
            PrintJson.printJsonFlag(response, success);
        } catch (SaveActivityException e) {
            e.printStackTrace();
            PrintJson.printJsonFlag(response, false);
        }
    }

    private void getUserListAndActivity(HttpServletRequest request, HttpServletResponse response) {
        String id = request.getParameter("id");

        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        Map<String, Object> map = activityService.getUserListAndActivity(id);
        PrintJson.printJsonObj(response, map);

    }

    private void delete(HttpServletRequest request, HttpServletResponse response) {
        String[] ids = request.getParameterValues("id");

        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        boolean success = activityService.delete(ids);
        PrintJson.printJsonFlag(response, success);
    }

    private void pageList(HttpServletRequest request, HttpServletResponse response) {
        String name = request.getParameter("name");
        String owner = request.getParameter("owner");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String pageNoStr = request.getParameter("pageNo");
        String pageSizeStr = request.getParameter("pageSize");
        int pageNo = Integer.parseInt(pageNoStr);
        int pageSize = Integer.parseInt(pageSizeStr);
        // 计算略过的记录数
        int skipCount = (pageNo - 1) * pageSize;

        Map<String, Object> map = new HashMap<String, Object>();
        map.put("name", name);
        map.put("owner", owner);
        map.put("startDate", startDate);
        map.put("endDate", endDate);
        map.put("pageSize", pageSize);
        map.put("skipCount", skipCount);

        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        PaginationVO<Activity> paginationVO = activityService.pageList(map);
        PrintJson.printJsonObj(response, paginationVO);

    }

    private void save(HttpServletRequest request, HttpServletResponse response) {
        String id = UUIDUtil.getUUID();
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String cost = request.getParameter("cost");
        String description = request.getParameter("description");
        // 当前系统时间
        String createTime = DateTimeUtil.getSysTime();
        // 当前登录的用户
        String createBy = ((User)request.getSession(false).getAttribute("user")).getName();

        Activity activity = new Activity();
        activity.setId(id);
        activity.setOwner(owner);
        activity.setName(name);
        activity.setStartDate(startDate);
        activity.setEndDate(endDate);
        activity.setCost(cost);
        activity.setDescription(description);
        activity.setCreateTime(createTime);
        activity.setCreateBy(createBy);

        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        boolean success = false;
        try {
            success = activityService.save(activity);
            PrintJson.printJsonFlag(response, success);
        } catch (SaveActivityException e) {
            e.printStackTrace();
            PrintJson.printJsonFlag(response, false);
        }

    }

    private void getUserList(HttpServletRequest request, HttpServletResponse response) {
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> userList = userService.getUserList();
        PrintJson.printJsonObj(response, userList);
    }


}
