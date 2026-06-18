package com.nexusshope.designpatterns;

import com.nexusshope.model.Order;
import java.sql.SQLException;

public interface OrderStatusStrategy {
    boolean canTransitionFrom(String currentStatus);
    String getNextStatus();
    void validateTransition(Order order) throws IllegalStateException;
    void executePreTransition(Order order) throws SQLException;
    void executePostTransition(Order order) throws SQLException;
    String getActionButtonText();
    String getActionButtonIcon();
    String getStatusColor();
}