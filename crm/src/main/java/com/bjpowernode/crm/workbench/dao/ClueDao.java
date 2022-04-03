package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.Clue;

import java.util.List;
import java.util.Map;

public interface ClueDao {


    int save(Clue clue);

    int getTotal();

    List<Clue> getClueList(Map<String, Object> map);

    Clue detail(String id);

    Clue getById(String clueId);

    int delete(String clueId);
}
