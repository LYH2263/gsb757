package com.bookstore.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Book {
    private int id;
    private String title;
    private String author;
    private BigDecimal price;
    private String description;
    private String imageUrl;
}
