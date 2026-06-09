package com.bookstore.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Order {
    private int id;
    private int userId;
    private BigDecimal totalAmount;
    private String status;
    private Date createdAt;

    private List<OrderItem> items;
}
