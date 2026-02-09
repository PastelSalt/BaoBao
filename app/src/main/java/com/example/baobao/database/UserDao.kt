package com.example.baobao.database

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface UserDao {
    // Authentication queries
    @Query("SELECT * FROM user_data WHERE username = :username LIMIT 1")
    suspend fun getUserByUsername(username: String): UserData?

    @Query("SELECT * FROM user_data")
    suspend fun getAllUsers(): List<UserData>

    @Query("SELECT * FROM user_data WHERE userId = :userId")
    suspend fun getUserById(userId: Int): UserData?

    @Query("UPDATE user_data SET lastLoginAt = :timestamp WHERE userId = :userId")
    suspend fun updateLastLogin(userId: Int, timestamp: Long)

    @Query("DELETE FROM user_data WHERE userId = :userId")
    suspend fun deleteUser(userId: Int)

    // User Data queries
    @Query("SELECT * FROM user_data WHERE userId = :userId")
    fun getUserData(userId: Int): Flow<UserData?>

    @Query("SELECT * FROM user_data WHERE userId = :userId")
    suspend fun getUserDataOnce(userId: Int): UserData?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUserData(userData: UserData): Long

    @Update
    suspend fun updateUserData(userData: UserData)

    @Query("UPDATE user_data SET currency = :currency WHERE userId = :userId")
    suspend fun updateCurrency(userId: Int, currency: Int)

    @Query("UPDATE user_data SET purchasedBgm = :purchasedBgm WHERE userId = :userId")
    suspend fun updatePurchasedBgm(userId: Int, purchasedBgm: String)

    @Query("UPDATE user_data SET purchasedThemes = :purchasedThemes WHERE userId = :userId")
    suspend fun updatePurchasedThemes(userId: Int, purchasedThemes: String)

    @Query("UPDATE user_data SET selectedBgm = :selectedBgm WHERE userId = :userId")
    suspend fun updateSelectedBgm(userId: Int, selectedBgm: String)

    @Query("UPDATE user_data SET selectedTheme = :selectedTheme WHERE userId = :userId")
    suspend fun updateSelectedTheme(userId: Int, selectedTheme: String)

    @Query("UPDATE user_data SET purchasedOutfits = :purchasedOutfits WHERE userId = :userId")
    suspend fun updatePurchasedOutfits(userId: Int, purchasedOutfits: String)

    @Query("UPDATE user_data SET selectedOutfit = :selectedOutfit WHERE userId = :userId")
    suspend fun updateSelectedOutfit(userId: Int, selectedOutfit: String)

    @Query("UPDATE user_data SET purchasedBackgrounds = :purchasedBackgrounds WHERE userId = :userId")
    suspend fun updatePurchasedBackgrounds(userId: Int, purchasedBackgrounds: String)

    @Query("UPDATE user_data SET selectedBackground = :selectedBackground WHERE userId = :userId")
    suspend fun updateSelectedBackground(userId: Int, selectedBackground: String)

    // Purchase queries
    @Query("SELECT * FROM purchases WHERE itemType = :itemType")
    fun getPurchasesByType(itemType: String): Flow<List<Purchase>>

    @Query("SELECT * FROM purchases")
    fun getAllPurchases(): Flow<List<Purchase>>

    @Insert
    suspend fun insertPurchase(purchase: Purchase)

    @Query("SELECT EXISTS(SELECT 1 FROM purchases WHERE itemType = :itemType AND itemId = :itemId)")
    suspend fun isPurchased(itemType: String, itemId: String): Boolean

    @Query("DELETE FROM purchases WHERE itemType = :itemType AND itemId = :itemId")
    suspend fun deletePurchase(itemType: String, itemId: String)
}
