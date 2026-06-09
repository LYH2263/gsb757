package com.bookstore.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CartItem {
    private int id;
    private int userId;
    private int bookId;
    private int quantity;

    // Detailed book info for display
    private Book book;
}
