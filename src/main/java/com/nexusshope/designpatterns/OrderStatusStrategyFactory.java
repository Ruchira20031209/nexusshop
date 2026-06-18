package com.nexusshope.designpatterns;

import com.nexusshope.designpatterns.OrderStatusStrategy;
import com.nexusshope.designpatterns.ConfirmedStatusStrategy;
import com.nexusshope.designpatterns.ProcessingStatusStrategy;
import com.nexusshope.designpatterns.ShippedStatusStrategy;
import com.nexusshope.designpatterns.DeliveredStatusStrategy;

import java.util.HashMap;
import java.util.Map;

public class OrderStatusStrategyFactory {
    private static final Map<String, OrderStatusStrategy> strategies = new HashMap<>();

    static {
        strategies.put("CONFIRMED", new ConfirmedStatusStrategy());
        strategies.put("PROCESSING", new ProcessingStatusStrategy());
        strategies.put("SHIPPED", new ShippedStatusStrategy());
        strategies.put("DELIVERED", new DeliveredStatusStrategy());
    }

    public static OrderStatusStrategy getStrategy(String currentStatus) {
        OrderStatusStrategy strategy = strategies.get(currentStatus);
        if (strategy == null) {
            throw new IllegalArgumentException("No strategy found for status: " + currentStatus);
        }
        return strategy;
    }

    public static boolean isValidTransition(String currentStatus) {
        return strategies.containsKey(currentStatus) &&
                !"DELIVERED".equals(currentStatus); // No transitions from DELIVERED
    }
}