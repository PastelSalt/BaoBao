package com.example.baobao.database

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.firstOrNull
import java.security.MessageDigest

class UserRepository(private val userDao: UserDao) {

    // Authentication methods
    suspend fun login(username: String, password: String): UserData? {
        val user = userDao.getUserByUsername(username) ?: return null
        val passwordHash = hashPassword(password)

        return if (user.passwordHash == passwordHash) {
            // Update last login time
            userDao.updateLastLogin(user.userId, System.currentTimeMillis())
            user
        } else {
            null
        }
    }

    suspend fun signup(username: String, password: String): UserData? {
        // Check if username already exists
        if (userDao.getUserByUsername(username) != null) {
            return null // Username taken
        }

        // Create new user
        val newUser = UserData(
            username = username,
            passwordHash = hashPassword(password)
        )

        val userId = userDao.insertUserData(newUser)
        return userDao.getUserById(userId.toInt())
    }

    suspend fun getAllUsers(): List<UserData> {
        return userDao.getAllUsers()
    }

    suspend fun createGuestAccount(): UserData? {
        // Create a unique guest username with timestamp
        val guestUsername = "guest_${System.currentTimeMillis()}"

        val guestUser = UserData(
            username = guestUsername,
            passwordHash = "" // No password for guest
        )

        val userId = userDao.insertUserData(guestUser)
        return userDao.getUserById(userId.toInt())
    }

    suspend fun deleteUser(userId: Int) {
        val user = userDao.getUserById(userId)
        if (user != null) {
            userDao.deleteUser(userId)
        }
    }

    fun isGuestAccount(username: String): Boolean {
        return username.startsWith("guest_")
    }

    private fun hashPassword(password: String): String {
        val bytes = MessageDigest.getInstance("SHA-256").digest(password.toByteArray())
        return bytes.joinToString("") { "%02x".format(it) }
    }

    // Current user data access (requires userId from SessionManager)
    fun getUserDataFlow(userId: Int): Flow<UserData?> = userDao.getUserData(userId)

    suspend fun getUserDataOnce(userId: Int): UserData? = userDao.getUserDataOnce(userId)

    val allPurchases: Flow<List<Purchase>> = userDao.getAllPurchases()

    // Currency operations
    suspend fun getCurrency(userId: Int): Int {
        return userDao.getUserDataOnce(userId)?.currency ?: 3000
    }

    suspend fun addCurrency(userId: Int, amount: Int) {
        val current = getCurrency(userId)
        userDao.updateCurrency(userId, current + amount)
    }

    suspend fun spendCurrency(userId: Int, amount: Int): Boolean {
        val current = getCurrency(userId)
        return if (current >= amount) {
            userDao.updateCurrency(userId, current - amount)
            true
        } else {
            false
        }
    }

    suspend fun setCurrency(userId: Int, amount: Int) {
        userDao.updateCurrency(userId, amount)
    }

    // Purchase operations
    suspend fun purchaseItem(userId: Int, itemType: String, itemId: String, itemName: String, cost: Int): Boolean {
        // Check if already purchased
        if (userDao.isPurchased(itemType, itemId)) {
            return false
        }

        // Try to spend currency
        if (spendCurrency(userId, cost)) {
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
                    val userData = userDao.getUserDataOnce(userId)
                    val purchased = userData?.purchasedBgm?.split(",")?.filter { it.isNotEmpty() }?.toMutableList() ?: mutableListOf()
                    if (!purchased.contains(itemId)) {
                        purchased.add(itemId)
                        userDao.updatePurchasedBgm(userId, purchased.joinToString(","))
                    }
                }
                "theme" -> {
                    val userData = userDao.getUserDataOnce(userId)
                    val purchased = userData?.purchasedThemes?.split(",")?.filter { it.isNotEmpty() }?.toMutableList() ?: mutableListOf()
                    if (!purchased.contains(itemId)) {
                        purchased.add(itemId)
                        userDao.updatePurchasedThemes(userId, purchased.joinToString(","))
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
    suspend fun getPurchasedBgmList(userId: Int): List<String> {
        val userData = userDao.getUserDataOnce(userId)
        return userData?.purchasedBgm?.split(",")?.filter { it.isNotEmpty() } ?: emptyList()
    }

    suspend fun getSelectedBgm(userId: Int): String {
        return userDao.getUserDataOnce(userId)?.selectedBgm ?: "kakushigoto"
    }

    suspend fun setSelectedBgm(userId: Int, bgmId: String) {
        userDao.updateSelectedBgm(userId, bgmId)
    }

    suspend fun purchaseBgm(userId: Int, bgmId: String) {
        val userData = userDao.getUserDataOnce(userId) ?: return
        val purchased = userData.purchasedBgm.split(",").filter { it.isNotEmpty() }.toMutableList()
        if (!purchased.contains(bgmId)) {
            purchased.add(bgmId)
            userDao.updatePurchasedBgm(userId, purchased.joinToString(","))
        }
    }

    // Theme operations
    suspend fun getPurchasedThemesList(userId: Int): List<String> {
        val userData = userDao.getUserDataOnce(userId)
        return userData?.purchasedThemes?.split(",")?.filter { it.isNotEmpty() } ?: emptyList()
    }

    suspend fun getSelectedTheme(userId: Int): String {
        return userDao.getUserDataOnce(userId)?.selectedTheme ?: "default"
    }

    suspend fun setSelectedTheme(userId: Int, themeId: String) {
        userDao.updateSelectedTheme(userId, themeId)
    }

    // Outfit operations
    suspend fun getPurchasedOutfitsList(userId: Int): List<String> {
        val userData = userDao.getUserDataOnce(userId)
        return userData?.purchasedOutfits?.split(",")?.filter { it.isNotEmpty() } ?: listOf("outfit1")
    }

    suspend fun getSelectedOutfit(userId: Int): String {
        return userDao.getUserDataOnce(userId)?.selectedOutfit ?: "outfit1"
    }

    suspend fun setSelectedOutfit(userId: Int, outfitId: String) {
        userDao.updateSelectedOutfit(userId, outfitId)
    }

    suspend fun purchaseOutfit(userId: Int, outfitId: String) {
        val userData = userDao.getUserDataOnce(userId) ?: return
        val purchased = userData.purchasedOutfits.split(",").filter { it.isNotEmpty() }.toMutableList()
        if (!purchased.contains(outfitId)) {
            purchased.add(outfitId)
            userDao.updatePurchasedOutfits(userId, purchased.joinToString(","))
        }
    }

    // Background operations
    suspend fun getPurchasedBackgroundsList(userId: Int): List<String> {
        val userData = userDao.getUserDataOnce(userId)
        return userData?.purchasedBackgrounds?.split(",")?.filter { it.isNotEmpty() } ?: listOf("default")
    }

    suspend fun getSelectedBackground(userId: Int): String {
        return userDao.getUserDataOnce(userId)?.selectedBackground ?: "default"
    }

    suspend fun setSelectedBackground(userId: Int, backgroundId: String) {
        userDao.updateSelectedBackground(userId, backgroundId)
    }

    suspend fun purchaseBackground(userId: Int, backgroundId: String) {
        val userData = userDao.getUserDataOnce(userId) ?: return
        val purchased = userData.purchasedBackgrounds.split(",").filter { it.isNotEmpty() }.toMutableList()
        if (!purchased.contains(backgroundId)) {
            purchased.add(backgroundId)
            userDao.updatePurchasedBackgrounds(userId, purchased.joinToString(","))
        }
    }

    // User data operations
    suspend fun updateUserData(userData: UserData) {
        userDao.updateUserData(userData)
    }

    suspend fun initializeUserIfNeeded() {
        // No longer auto-initializes - users must sign up
    }

    // ========== CONVENIENCE METHODS (backward compatibility) ==========
    // These methods use SessionManager to get current user ID automatically
    // Allows existing code to work without passing userId everywhere

    suspend fun getCurrency(): Int {
        val userId = SessionManager.getCurrentUserId()
        if (userId == -1) return 3000
        return getCurrency(userId)
    }

    suspend fun addCurrency(amount: Int) {
        val userId = SessionManager.getCurrentUserId()
        if (userId == -1) return
        addCurrency(userId, amount)
    }

    suspend fun spendCurrency(amount: Int): Boolean {
        val userId = SessionManager.getCurrentUserId()
        if (userId == -1) return false
        return spendCurrency(userId, amount)
    }

    suspend fun getPurchasedBgmList(): List<String> {
        val userId = SessionManager.getCurrentUserId()
        if (userId == -1) return emptyList()
        return getPurchasedBgmList(userId)
    }

    suspend fun getSelectedBgm(): String {
        val userId = SessionManager.getCurrentUserId()
        if (userId == -1) return "kakushigoto"
        return getSelectedBgm(userId)
    }

    suspend fun setSelectedBgm(bgmId: String) {
        val userId = SessionManager.getCurrentUserId()
        if (userId == -1) return
        setSelectedBgm(userId, bgmId)
    }

    suspend fun purchaseBgm(bgmId: String) {
        val userId = SessionManager.getCurrentUserId()
        if (userId == -1) return
        purchaseBgm(userId, bgmId)
    }

    suspend fun getPurchasedOutfitsList(): List<String> {
        val userId = SessionManager.getCurrentUserId()
        if (userId == -1) return listOf("outfit1")
        return getPurchasedOutfitsList(userId)
    }

    suspend fun getSelectedOutfit(): String {
        val userId = SessionManager.getCurrentUserId()
        if (userId == -1) return "outfit1"
        return getSelectedOutfit(userId)
    }

    suspend fun setSelectedOutfit(outfitId: String) {
        val userId = SessionManager.getCurrentUserId()
        if (userId == -1) return
        setSelectedOutfit(userId, outfitId)
    }

    suspend fun purchaseOutfit(outfitId: String) {
        val userId = SessionManager.getCurrentUserId()
        if (userId == -1) return
        purchaseOutfit(userId, outfitId)
    }

    suspend fun getPurchasedBackgroundsList(): List<String> {
        val userId = SessionManager.getCurrentUserId()
        if (userId == -1) return listOf("default")
        return getPurchasedBackgroundsList(userId)
    }

    suspend fun getSelectedBackground(): String {
        val userId = SessionManager.getCurrentUserId()
        if (userId == -1) return "default"
        return getSelectedBackground(userId)
    }

    suspend fun setSelectedBackground(backgroundId: String) {
        val userId = SessionManager.getCurrentUserId()
        if (userId == -1) return
        setSelectedBackground(userId, backgroundId)
    }

    suspend fun purchaseBackground(backgroundId: String) {
        val userId = SessionManager.getCurrentUserId()
        if (userId == -1) return
        purchaseBackground(userId, backgroundId)
    }

    suspend fun getUserData(): UserData {
        val userId = SessionManager.getCurrentUserId()
        if (userId == -1) return UserData(username = "guest")
        return getUserDataSuspend(userId)
    }

    // Internal method with explicit name to avoid confusion
    private suspend fun getUserDataSuspend(userId: Int): UserData {
        return userDao.getUserDataOnce(userId) ?: UserData(username = "unknown")
    }
}
