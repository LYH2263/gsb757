package com.bookstore.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderItem {
    private int id;
    private int orderId;
    private int bookId;
    private int quantity;
    private BigDecimal price;

    private Book book;
}
