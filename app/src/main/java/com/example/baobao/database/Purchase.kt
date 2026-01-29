package com.example.baobao.database

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "purchases")
data class Purchase(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val itemType: String, // "bgm", "theme", "outfit", etc.
    val itemId: String, // "kakushigoto", "little", "ordinary_days", etc.
    val itemName: String, // Display name
    val cost: Int, // How much it cost
    val purchaseDate: Long = System.currentTimeMillis()
)
