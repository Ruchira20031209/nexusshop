package com.nexusshope.dao;

import com.nexusshope.utill.DBUtil;

import java.sql.Connection;
import java.sql.SQLException;

public abstract class AbstractDAO {
    protected Connection openConnection() throws SQLException {
        return DBUtil.getConnection();
    }
}
