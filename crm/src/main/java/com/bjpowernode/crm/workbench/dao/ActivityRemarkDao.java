package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.ActivityRemark;

import java.util.List;

public interface ActivityRemarkDao {
    int getCountByActivityIds(String[] ids);

    int deleteByActivityIds(String[] ids);

    List<ActivityRemark> getRemarkListByActivityId(String activityId);

    int removeRemark(String remarkId);

    int saveRemark(ActivityRemark activityRemark);

    int editRemark(ActivityRemark activityRemark);

}
