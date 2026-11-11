# BaoBao Outfit System Implementation Guide

## Overview
The BaoBao app now includes a complete outfit purchase and customization system. Users can purchase new outfits from the shop using in-game currency (bamboo) and switch between owned outfits through the customize dialog.

## Current Outfits

### Outfit 1: Classic Bao (Default)
- **ID**: `outfit1`
- **Price**: Free (Default outfit)
- **Status**: Always owned
- **Assets Required**:
  - `mainscreen_outfit1_fullbody_happy.png`
  - `mainscreen_outfit1_fullbody_hello.png`
  - `mainscreen_outfit1_fullbody_sad.png`
  - `mainscreen_outfit1_fullbody_tired.png`

### Outfit 2: Blue Bao
- **ID**: `outfit2`
- **Price**: 1000 ✷
- **Status**: Must be purchased
- **Assets Required**:
  - `mainscreen_outfit2_fullbody_happy.png`
  - `mainscreen_outfit2_fullbody_hello.png`
  - `mainscreen_outfit2_fullbody_sad.png`
  - `mainscreen_outfit2_fullbody_tired.png`

## System Architecture

### 1. Database Layer

#### UserData.kt
```kotlin
val purchasedOutfits: String = "outfit1" // Comma-separated list
val selectedOutfit: String = "outfit1"   // Currently equipped outfit
```

#### UserDao.kt
```kotlin
@Query("UPDATE user_data SET purchasedOutfits = :purchasedOutfits WHERE userId = 1")
suspend fun updatePurchasedOutfits(purchasedOutfits: String)

@Query("UPDATE user_data SET selectedOutfit = :selectedOutfit WHERE userId = 1")
suspend fun updateSelectedOutfit(selectedOutfit: String)
```

#### UserRepository.kt
Key methods:
- `getPurchasedOutfitsList()`: Returns list of owned outfits
- `getSelectedOutfit()`: Returns currently equipped outfit
- `setSelectedOutfit(outfitId)`: Updates equipped outfit
- `purchaseOutfit(outfitId)`: Adds outfit to purchase list

### 2. Character Image Management

#### CharacterImageManager.kt
Handles all outfit-related image resources:

```kotlin
// Set outfit globally
CharacterImageManager.setOutfit("outfit2")

// Get image for current outfit
val imageRes = CharacterImageManager.getCharacterImage(Emotion.HAPPY)

// Get image for specific outfit
val imageRes = CharacterImageManager.getCharacterImage(Emotion.HAPPY, "outfit2")
```

Supported emotions per outfit:
- HAPPY
- HELLO
- SAD
- TIRED
- ANXIOUS (fallback to SAD)
- OKAY (fallback to HELLO)

### 3. Shop Integration

#### ShopActivity.kt
Features:
- Displays Blue Bao outfit card in the outfit section
- Shows outfit price (1000 ✷)
- Indicates ownership status
- Updates UI based on user's currency
- Handles purchase transaction
- Updates character preview

Purchase flow:
1. Check if user has enough currency
2. Check if outfit already owned
3. Deduct currency from user account
4. Add outfit to purchased list
5. Update UI and show success message

### 4. Customization Dialog

#### DialogManager.kt
The customize dialog allows users to:
- View all owned BGMs
- View all owned outfits
- Switch between owned outfits
- Preview outfit on character icon
- Navigate to shop for more items

Outfit selection flow:
1. Load purchased outfits from database
2. Display outfit buttons dynamically
3. Highlight currently selected outfit
4. On selection:
   - Save to database
   - Update CharacterImageManager
   - Update character preview
   - Show confirmation message

### 5. MainActivity Integration

#### Outfit Loading
On app startup (`onCreate`):
```kotlin
lifecycleScope.launch {
    val selectedOutfit = userRepository.getSelectedOutfit()
    CharacterImageManager.setOutfit(selectedOutfit)
    binding.characterImage.setImageResource(CharacterImageManager.getHelloImage())
}
```

On app resume (`onResume`):
```kotlin
lifecycleScope.launch {
    val selectedOutfit = userRepository.getSelectedOutfit()
    CharacterImageManager.setOutfit(selectedOutfit)
    
    if (!conversationController.isConversationMode) {
        binding.characterImage.setImageResource(CharacterImageManager.getHelloImage())
    }
}
```

## User Experience Flow

### Purchasing an Outfit
1. User opens Shop from main screen
2. User browses outfit section
3. User sees Blue Bao outfit card with price
4. User taps on outfit card
5. System checks currency and ownership
6. If affordable and not owned:
   - Currency deducted
   - Outfit added to inventory
   - Success toast shown
   - BaoBao speaks about new outfit
7. Outfit card updates to "✓ Owned"

### Equipping an Outfit
1. User taps customize button on main screen
2. Customize dialog opens
3. User sees "Your Outfit Collection" section
4. All owned outfits displayed as buttons
5. Currently equipped outfit is highlighted
6. User taps desired outfit button
7. Character preview updates immediately
8. Outfit selection saved to database
9. BaoBao confirms outfit change
10. User closes dialog
11. Main screen character reflects new outfit

## Adding New Outfits

To add a new outfit (e.g., "outfit3" - Red Bao):

### Step 1: Add Image Assets
Place these files in `app/src/main/res/drawable/`:
```
mainscreen_outfit3_fullbody_happy.png
mainscreen_outfit3_fullbody_hello.png
mainscreen_outfit3_fullbody_sad.png
mainscreen_outfit3_fullbody_tired.png
```

### Step 2: Update CharacterImageManager
Add outfit handler in `CharacterImageManager.kt`:

```kotlin
fun getCharacterImage(emotion: Emotion, outfit: String? = null): Int {
    val selectedOutfit = outfit ?: currentOutfit
    
    return when (selectedOutfit) {
        "outfit1" -> getOutfit1Image(emotion)
        "outfit2" -> getOutfit2Image(emotion)
        "outfit3" -> getOutfit3Image(emotion)  // Add this
        else -> getOutfit1Image(emotion)
    }
}

// Add this method
private fun getOutfit3Image(emotion: Emotion): Int {
    return when (emotion) {
        Emotion.HAPPY -> R.drawable.mainscreen_outfit3_fullbody_happy
        Emotion.HELLO -> R.drawable.mainscreen_outfit3_fullbody_hello
        Emotion.SAD -> R.drawable.mainscreen_outfit3_fullbody_sad
        Emotion.TIRED -> R.drawable.mainscreen_outfit3_fullbody_tired
        Emotion.ANXIOUS -> R.drawable.mainscreen_outfit3_fullbody_sad
        Emotion.OKAY -> R.drawable.mainscreen_outfit3_fullbody_hello
        Emotion.DEFAULT -> R.drawable.mainscreen_outfit3_fullbody_hello
    }
}
```

Update availability:
```kotlin
fun isOutfitAvailable(outfitName: String): Boolean {
    return outfitName in listOf("outfit1", "outfit2", "outfit3")
}

fun getAvailableOutfits(): List<String> {
    return listOf("outfit1", "outfit2", "outfit3")
}

fun getAvailableEmotions(): List<Emotion> {
    return when (currentOutfit) {
        "outfit1" -> listOf(Emotion.HAPPY, Emotion.HELLO, Emotion.SAD, Emotion.TIRED)
        "outfit2" -> listOf(Emotion.HAPPY, Emotion.HELLO, Emotion.SAD, Emotion.TIRED)
        "outfit3" -> listOf(Emotion.HAPPY, Emotion.HELLO, Emotion.SAD, Emotion.TIRED)
        else -> listOf(Emotion.DEFAULT)
    }
}
```

### Step 3: Add Shop Card
In `activity_shop.xml`, add after Blue Bao card:

```xml
<!-- Red Bao Outfit -->
<FrameLayout
    android:id="@+id/outfitRedBaoCard"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:layout_marginEnd="16dp"
    android:background="@drawable/bamboo_status_bg"
    android:padding="12dp"
    android:clickable="true"
    android:focusable="true">

    <LinearLayout
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:gravity="center_horizontal"
        android:orientation="vertical">

        <FrameLayout
            android:layout_width="120dp"
            android:layout_height="140dp"
            android:background="@drawable/bamboo_button_pale_green"
            android:padding="8dp">

            <ImageView
                android:layout_width="match_parent"
                android:layout_height="match_parent"
                android:contentDescription="Red Bao Outfit"
                android:src="@drawable/mainscreen_outfit3_fullbody_hello"
                android:scaleType="centerCrop" />
        </FrameLayout>

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="10dp"
            android:fontFamily="sans-serif-medium"
            android:text="Red Bao"
            android:textColor="@color/black"
            android:textSize="14sp"
            android:textStyle="bold" />

        <TextView
            android:id="@+id/outfitRedBaoPrice"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="4dp"
            android:fontFamily="sans-serif-medium"
            android:text="1500 ✷"
            android:textColor="@color/green"
            android:textSize="13sp"
            android:textStyle="bold" />
    </LinearLayout>
</FrameLayout>
```

### Step 4: Add Shop Logic
In `ShopActivity.kt`:

```kotlin
private fun setupOutfitPurchases() {
    // Blue Bao
    binding.outfitBlueBaoCard.setOnClickListener {
        SoundManager.playClickSound(this)
        purchaseOutfit("outfit2", 1000, "Blue Bao")
    }
    
    // Red Bao - Add this
    binding.outfitRedBaoCard.setOnClickListener {
        SoundManager.playClickSound(this)
        purchaseOutfit("outfit3", 1500, "Red Bao")
    }

    updateOutfitPurchaseStates()
}

private fun updateOutfitPurchaseStates() {
    lifecycleScope.launch {
        val purchasedOutfits = userRepository.getPurchasedOutfitsList()
        val currency = userRepository.getCurrency()

        updateOutfitCardState(
            binding.outfitBlueBaoCard,
            binding.outfitBlueBaoPrice,
            "outfit2",
            1000,
            purchasedOutfits,
            currency
        )
        
        // Add this
        updateOutfitCardState(
            binding.outfitRedBaoCard,
            binding.outfitRedBaoPrice,
            "outfit3",
            1500,
            purchasedOutfits,
            currency
        )
    }
}
```

### Step 5: Update Dialog Names
In `DialogManager.kt`:

```kotlin
val outfitNames = mapOf(
    "outfit1" to "Classic Bao (Default)",
    "outfit2" to "Blue Bao",
    "outfit3" to "Red Bao"  // Add this
)
```

## Technical Details

### Database Version
- Current version: 3
- Previous version: 2
- Migration strategy: `fallbackToDestructiveMigration` (for development)

### Currency System
- Earned through Claw Machine game (10-100 ✷ per ball)
- Used to purchase outfits and BGM
- Stored in Room database

### State Management
- Outfit selection persists across app sessions
- Outfit changes reflect immediately in UI
- Character images update based on current outfit and emotion

## Testing Checklist

- [ ] Default outfit (outfit1) is equipped on first launch
- [ ] Blue Bao outfit appears in shop with correct price
- [ ] Purchase fails when insufficient currency
- [ ] Purchase succeeds and deducts correct amount
- [ ] Purchased outfit appears in customize dialog
- [ ] Outfit selection updates character preview
- [ ] Selected outfit persists after app restart
- [ ] Character emotions work correctly with all outfits
- [ ] Shop card shows "✓ Owned" after purchase
- [ ] Conversation mode maintains outfit selection
- [ ] Mood changes maintain outfit selection

## Future Enhancements

1. **Outfit Animations**: Add transition animations when switching outfits
2. **Outfit Preview**: Full-screen preview before purchase
3. **Outfit Collections**: Bundle multiple outfits as themed sets
4. **Seasonal Outfits**: Time-limited special outfits
5. **Outfit Achievements**: Unlock outfits through gameplay milestones
6. **Mix & Match**: Separate tops, bottoms, accessories
7. **Color Variants**: Same outfit with different color options

## Troubleshooting

### Outfit not showing after purchase
- Check database: outfit should be in `purchasedOutfits` field
- Verify CharacterImageManager has outfit handler
- Ensure image assets exist in drawable folder

### Character showing wrong outfit
- Check `selectedOutfit` in database
- Verify `CharacterImageManager.setOutfit()` is called
- Check `onResume()` loads outfit correctly

### Shop card not updating
- Ensure `updateOutfitPurchaseStates()` is called in `onResume()`
- Check currency deduction logic
- Verify outfit is added to purchased list

---

**Implementation Date**: February 8, 2026  
**Database Version**: 3  
**Status**: ✅ Complete and Functional

