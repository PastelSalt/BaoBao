package com.example.baobao.database

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface UserDao {
    // User Data queries
    @Query("SELECT * FROM user_data WHERE userId = 1")
    fun getUserData(): Flow<UserData?>

    @Query("SELECT * FROM user_data WHERE userId = 1")
    suspend fun getUserDataOnce(): UserData?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUserData(userData: UserData)

    @Update
    suspend fun updateUserData(userData: UserData)

    @Query("UPDATE user_data SET currency = :currency WHERE userId = 1")
    suspend fun updateCurrency(currency: Int)

    @Query("UPDATE user_data SET purchasedBgm = :purchasedBgm WHERE userId = 1")
    suspend fun updatePurchasedBgm(purchasedBgm: String)

    @Query("UPDATE user_data SET purchasedThemes = :purchasedThemes WHERE userId = 1")
    suspend fun updatePurchasedThemes(purchasedThemes: String)

    @Query("UPDATE user_data SET selectedBgm = :selectedBgm WHERE userId = 1")
    suspend fun updateSelectedBgm(selectedBgm: String)

    @Query("UPDATE user_data SET selectedTheme = :selectedTheme WHERE userId = 1")
    suspend fun updateSelectedTheme(selectedTheme: String)

    @Query("UPDATE user_data SET purchasedOutfits = :purchasedOutfits WHERE userId = 1")
    suspend fun updatePurchasedOutfits(purchasedOutfits: String)

    @Query("UPDATE user_data SET selectedOutfit = :selectedOutfit WHERE userId = 1")
    suspend fun updateSelectedOutfit(selectedOutfit: String)

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
