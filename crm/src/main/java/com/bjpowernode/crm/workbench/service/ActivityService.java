package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.exception.SaveActivityException;
import com.bjpowernode.crm.vo.PaginationVO;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.ActivityRemark;

import java.util.List;
import java.util.Map;

public interface ActivityService {
    boolean save(Activity activity) throws SaveActivityException;

    PaginationVO<Activity> pageList(Map<String, Object> map);

    boolean delete(String[] ids);

    Map<String, Object> getUserListAndActivity(String id);

    boolean updateActivity(Activity activity) throws SaveActivityException;

    Activity detail(String id);

    List<ActivityRemark> getRemarkListByActivityId(String activityId);

    boolean removeRemark(String remarkId);

    boolean saveRemark(ActivityRemark activityRemark);

    boolean editRemark(ActivityRemark activityRemark);
}
