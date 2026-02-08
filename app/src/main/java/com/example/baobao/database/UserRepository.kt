package com.example.baobao.database

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.firstOrNull

class UserRepository(private val userDao: UserDao) {

    val userData: Flow<UserData?> = userDao.getUserData()
    val allPurchases: Flow<List<Purchase>> = userDao.getAllPurchases()

    // Currency operations
    suspend fun getCurrency(): Int {
        return userDao.getUserDataOnce()?.currency ?: 1000
    }

    suspend fun addCurrency(amount: Int) {
        val current = getCurrency()
        userDao.updateCurrency(current + amount)
    }

    suspend fun spendCurrency(amount: Int): Boolean {
        val current = getCurrency()
        return if (current >= amount) {
            userDao.updateCurrency(current - amount)
            true
        } else {
            false
        }
    }

    suspend fun setCurrency(amount: Int) {
        userDao.updateCurrency(amount)
    }

    // Purchase operations
    suspend fun purchaseItem(itemType: String, itemId: String, itemName: String, cost: Int): Boolean {
        // Check if already purchased
        if (userDao.isPurchased(itemType, itemId)) {
            return false
        }

        // Try to spend currency
        if (spendCurrency(cost)) {
            // Record purchase
            userDao.insertPurchase(
                Purchase(
                    itemType = itemType,
                    itemId = itemId,
                    itemName = itemName,
                    cost = cost
                )
            )

            // Update purchased list based on type
            when (itemType) {
                "bgm" -> {
                    val userData = userDao.getUserDataOnce()
                    val purchased = userData?.purchasedBgm?.split(",")?.filter { it.isNotEmpty() }?.toMutableList() ?: mutableListOf()
                    if (!purchased.contains(itemId)) {
                        purchased.add(itemId)
                        userDao.updatePurchasedBgm(purchased.joinToString(","))
                    }
                }
                "theme" -> {
                    val userData = userDao.getUserDataOnce()
                    val purchased = userData?.purchasedThemes?.split(",")?.filter { it.isNotEmpty() }?.toMutableList() ?: mutableListOf()
                    if (!purchased.contains(itemId)) {
                        purchased.add(itemId)
                        userDao.updatePurchasedThemes(purchased.joinToString(","))
                    }
                }
            }
            return true
        }
        return false
    }

    suspend fun isPurchased(itemType: String, itemId: String): Boolean {
        return userDao.isPurchased(itemType, itemId)
    }

    fun getPurchasesByType(itemType: String): Flow<List<Purchase>> {
        return userDao.getPurchasesByType(itemType)
    }

    // BGM operations
    suspend fun getPurchasedBgmList(): List<String> {
        val userData = userDao.getUserDataOnce()
        return userData?.purchasedBgm?.split(",")?.filter { it.isNotEmpty() } ?: emptyList()
    }

    suspend fun getSelectedBgm(): String {
        return userDao.getUserDataOnce()?.selectedBgm ?: "kakushigoto"
    }

    suspend fun setSelectedBgm(bgmId: String) {
        userDao.updateSelectedBgm(bgmId)
    }

    suspend fun purchaseBgm(bgmId: String) {
        val userData = userDao.getUserDataOnce() ?: return
        val purchased = userData.purchasedBgm.split(",").filter { it.isNotEmpty() }.toMutableList()
        if (!purchased.contains(bgmId)) {
            purchased.add(bgmId)
            userDao.updatePurchasedBgm(purchased.joinToString(","))
        }
    }

    // Theme operations
    suspend fun getPurchasedThemesList(): List<String> {
        val userData = userDao.getUserDataOnce()
        return userData?.purchasedThemes?.split(",")?.filter { it.isNotEmpty() } ?: emptyList()
    }

    suspend fun getSelectedTheme(): String {
        return userDao.getUserDataOnce()?.selectedTheme ?: "default"
    }

    suspend fun setSelectedTheme(themeId: String) {
        userDao.updateSelectedTheme(themeId)
    }

    // Outfit operations
    suspend fun getPurchasedOutfitsList(): List<String> {
        val userData = userDao.getUserDataOnce()
        return userData?.purchasedOutfits?.split(",")?.filter { it.isNotEmpty() } ?: listOf("outfit1")
    }

    suspend fun getSelectedOutfit(): String {
        return userDao.getUserDataOnce()?.selectedOutfit ?: "outfit1"
    }

    suspend fun setSelectedOutfit(outfitId: String) {
        userDao.updateSelectedOutfit(outfitId)
    }

    suspend fun purchaseOutfit(outfitId: String) {
        val userData = userDao.getUserDataOnce() ?: return
        val purchased = userData.purchasedOutfits.split(",").filter { it.isNotEmpty() }.toMutableList()
        if (!purchased.contains(outfitId)) {
            purchased.add(outfitId)
            userDao.updatePurchasedOutfits(purchased.joinToString(","))
        }
    }

    // User data operations
    suspend fun getUserData(): UserData {
        return userDao.getUserDataOnce() ?: UserData()
    }

    suspend fun updateUserData(userData: UserData) {
        userDao.updateUserData(userData)
    }

    suspend fun initializeUserIfNeeded() {
        val existing = userDao.getUserDataOnce()
        if (existing == null) {
            userDao.insertUserData(UserData())
        }
    }
}
