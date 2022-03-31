package com.bjpowernode.crm.workbench.service.impl;

import com.bjpowernode.crm.exception.SaveActivityException;
import com.bjpowernode.crm.settings.dao.UserDao;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.vo.PaginationVO;
import com.bjpowernode.crm.workbench.dao.ActivityDao;
import com.bjpowernode.crm.workbench.dao.ActivityRemarkDao;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.ActivityRemark;
import com.bjpowernode.crm.workbench.service.ActivityService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActivityServiceImpl implements ActivityService {
    private ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);
    private ActivityRemarkDao activityRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ActivityRemarkDao.class);

    @Override
    public boolean save(Activity activity) throws SaveActivityException {
        int count = activityDao.save(activity);
        if (count != 1) {
            throw new SaveActivityException("市场活动添加失败");
        }
        return true;
    }

    @Override
    public PaginationVO<Activity> pageList(Map<String, Object> map) {

        int total = activityDao.getTotalByCondition(map);
        List<Activity> activityList = activityDao.getActivityListByCondition(map);
        PaginationVO<Activity> paginationVO = new PaginationVO<Activity>();
        paginationVO.setTotal(total);
        paginationVO.setDataList(activityList);
        return paginationVO;
    }

    @Override
    public boolean delete(String[] ids) {
        // 查询出需要删除的备注的数量
        int toDeleteRemarkCount = activityRemarkDao.getCountByActivityIds(ids);
        // 删除备注，返回受到影响的条数
        int deletedRemarkCount = activityRemarkDao.deleteByActivityIds(ids);

        if (deletedRemarkCount != toDeleteRemarkCount) return false;

        // 删除市场活动
        int deletedActivityCount = activityDao.delete(ids);

        if (deletedActivityCount != ids.length) return false;

        return true;
    }

    @Override
    public Map<String, Object> getUserListAndActivity(String id) {
        Map<String, Object> map = new HashMap<String, Object>();

        // 取uList
        List<User> userList = userDao.getUserList();
        // 取activity
        Activity activity = activityDao.getById(id);
        // 将uList和activity打包到map中
        map.put("uList", userList);
        map.put("activity", activity);
        // 返回map
        return map;
    }

    @Override
    public boolean updateActivity(Activity activity) throws SaveActivityException {
        int count = activityDao.updateActivity(activity);
        if (count != 1) {
            throw new SaveActivityException("市场活动修改失败");
        }
        return true;
    }

    @Override
    public Activity detail(String id) {
        return activityDao.detail(id);
    }

    @Override
    public List<ActivityRemark> getRemarkListByActivityId(String activityId) {
        List<ActivityRemark> activityRemarkList = activityRemarkDao.getRemarkListByActivityId(activityId);
        return activityRemarkList;
    }

    @Override
    public boolean removeRemark(String remarkId) {
        int count =  activityRemarkDao.removeRemark(remarkId);
        if (count == 1) return true;
        return false;
    }

    @Override
    public boolean saveRemark(ActivityRemark activityRemark) {
        int count = activityRemarkDao.saveRemark(activityRemark);
        if (count == 1) return true;
        return false;
    }

    @Override
    public boolean editRemark(ActivityRemark activityRemark) {
        int count = activityRemarkDao.editRemark(activityRemark);
        if (count == 1) return true;
        return false;
    }
}
