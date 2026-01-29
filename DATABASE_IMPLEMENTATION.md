# Database Implementation Summary

## Overview
Implemented a complete Room database system for the BaoBao app to persist user data including currency and purchases.

## What Was Implemented

### 1. Database Dependencies Added
- **Room Database**: Version 2.6.1
  - `androidx.room:room-runtime`
  - `androidx.room:room-ktx`
  - `androidx.room:room-compiler` (using KSP)
- **Coroutines**: For async database operations
  - `kotlinx-coroutines-android`
  - `androidx.lifecycle:lifecycle-runtime-ktx`

### 2. Database Entities

#### UserData.kt
- Stores user account data
- Fields:
  - `userId`: Primary key (always 1 for single-user app)
  - `currency`: User's current currency (default: 1000)
  - `purchasedBgm`: Comma-separated list of purchased BGM IDs
  - `purchasedThemes`: Comma-separated list of purchased theme IDs
  - `selectedBgm`: Currently selected BGM (default: "kakushigoto")
  - `selectedTheme`: Currently selected theme (default: "default")

#### Purchase.kt
- Tracks all purchases made by the user
- Fields:
  - `id`: Auto-generated primary key
  - `itemType`: Type of item ("bgm", "theme", "outfit", etc.)
  - `itemId`: Unique identifier for the item
  - `itemName`: Display name of the item
  - `cost`: Purchase price
  - `purchaseDate`: Timestamp of purchase

### 3. Data Access Object (UserDao.kt)
Provides methods for:
- Getting user data (Flow for reactive updates)
- Updating currency
- Managing purchased items (BGM, themes)
- Managing selected preferences
- Querying purchase history
- Checking if items are purchased

### 4. Database Class (AppDatabase.kt)
- Room database with version 1
- Automatically initializes new users with 1000 currency
- Singleton pattern for single database instance
- Contains UserDao for data access

### 5. Repository Layer (UserRepository.kt)
Business logic layer providing:

#### Currency Operations
- `getCurrency()`: Get current currency balance
- `addCurrency(amount)`: Add currency (used by Claw Machine)
- `spendCurrency(amount)`: Spend currency (returns success/failure)
- `setCurrency(amount)`: Set currency to specific amount

#### Purchase Operations
- `purchaseItem(type, id, name, cost)`: Buy an item
- `isPurchased(type, id)`: Check if item is owned
- `getPurchasesByType(type)`: Get all purchases of a type

#### BGM Operations
- `getPurchasedBgmList()`: List of owned BGM IDs
- `getSelectedBgm()`: Currently playing BGM
- `setSelectedBgm(id)`: Change selected BGM

#### Theme Operations
- `getPurchasedThemesList()`: List of owned themes
- `getSelectedTheme()`: Current theme
- `setSelectedTheme(id)`: Change theme

### 6. Updated Activities

#### ClawMachineActivity.kt
- Initializes database and repository
- Uses `userRepository.addCurrency(amount)` to award random currency (10-100) per ball
- Removed SharedPreferences currency management

#### MainActivity.kt
- Initializes database and repository
- Ready to use database for BGM selection and purchases

#### ShopActivity.kt
- Initializes database and repository
- Uses `userRepository.getCurrency()` to display currency
- Ready for implementing purchase functionality

## Key Features

1. **Persistent Storage**: All data survives app restarts
2. **Initial Balance**: New accounts start with 1000 currency
3. **Random Rewards**: Claw machine awards 10-100 currency per caught ball
4. **Purchase Tracking**: Complete history of all purchases
5. **Reactive Updates**: Using Kotlin Flow for live data updates
6. **Type Safety**: Fully type-safe with Kotlin and Room

## How It Works

1. **First Launch**: Database creates UserData with 1000 currency
2. **Claw Machine**: 
   - Each ball has random value (10-100)
   - When caught, currency is added to database
3. **Shop**: 
   - Displays current currency from database
   - Can purchase items (to be fully implemented)
   - Deducts cost and records purchase
4. **Persistence**: All data automatically saved to SQLite database

## Next Steps for Full Integration

To complete the system, you need to:

1. **Shop Activity**: Implement actual purchase buttons
   ```kotlin
   lifecycleScope.launch {
       val success = userRepository.purchaseItem("bgm", "little", "Little BGM", 500)
       if (success) {
           // Show success message
           updateCurrencyDisplay()
       } else {
           // Show insufficient funds message
       }
   }
   ```

2. **Customization Dialog**: Check ownership before allowing selection
   ```kotlin
   lifecycleScope.launch {
       val isPurchased = userRepository.isPurchased("bgm", "little")
       if (isPurchased) {
           // Allow selection
           userRepository.setSelectedBgm("little")
       } else {
           // Show locked/purchase required message
       }
   }
   ```

3. **Load Selected Items**: On app start, load user preferences
   ```kotlin
   lifecycleScope.launch {
       val selectedBgm = userRepository.getSelectedBgm()
       // Apply the selected BGM
   }
   ```

## File Structure

```
app/src/main/java/com/example/baobao/
├── database/
│   ├── UserData.kt          # User account entity
│   ├── Purchase.kt          # Purchase history entity
│   ├── UserDao.kt           # Data access methods
│   ├── AppDatabase.kt       # Room database
│   └── UserRepository.kt    # Business logic layer
├── ClawMachineActivity.kt   # Updated to use database
├── MainActivity.kt          # Updated to use database
└── ShopActivity.kt          # Updated to use database
```

## Build Configuration

Modified files:
- `gradle/libs.versions.toml`: Added Room and Coroutines dependencies
- `app/build.gradle.kts`: Added Room, KSP, and Coroutines
- `build.gradle.kts`: Project-level configuration

The database implementation is complete and ready to use!
