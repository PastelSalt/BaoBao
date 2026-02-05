# Splash Screen Implementation

## Summary
The splash screen has been simplified and fixed. The automatic Android 12+ splash screen API is not being used, and the app uses a simple custom splash screen activity instead.

## Implementation Details

### Flow
1. **App Launch** → `SecondSplashActivity` (defined as LAUNCHER in AndroidManifest.xml)
2. **First Image (1.5s)** → Shows `baobaotextlogo.png`
3. **Second Image (1.5s)** → Shows `moesoft_nobg.png`
4. **Navigate** → Transitions to `AuthActivity`

### Key Files

#### SecondSplashActivity.kt
- **Duration**: Total 3 seconds (1.5s per image)
- **First Image**: `baobaotextlogo.png` (BaoBao text logo)
- **Second Image**: `moesoft_nobg.png` (Moesoft logo)
- **Layout**: Programmatically created with simple ImageView
- **No Dependencies**: Uses only standard Android APIs (no Glide or other libraries)
- **Error Handling**: Falls back to immediate navigation if any error occurs

#### AndroidManifest.xml
- `SecondSplashActivity` is set as the LAUNCHER activity
- Uses `Theme.BaoBao.NoActionBar` for fullscreen experience
- Portrait orientation locked

### What Was Fixed
1. **Compilation Error**: Fixed nullable binding issue in `AuthActivity.kt`
   - Changed `binding.property` to safe unwrapping with `val bind = binding ?: return`
2. **Simplified Logic**: Removed any complex image loading (no Glide dependency)
3. **Clean Implementation**: Simple, straightforward splash with proper error handling

### Configuration
To adjust timing, modify these constants in `SecondSplashActivity.kt`:
```kotlin
companion object {
    private const val FIRST_IMAGE_DURATION = 1500L  // Time to show first image (ms)
    private const val TOTAL_DURATION = 3000L        // Total splash time (ms)
}
```

### Memory Management
- Handler callbacks are properly cleaned up in `onPause()` and `onDestroy()`
- ImageView drawable is cleared on destroy to free memory
- Activity flags prevent multiple instances

## No Automatic Splash Screen API
The project does NOT use the Android 12+ Splash Screen API (`androidx.core:core-splashscreen`):
- No splash screen library dependency in gradle
- No `windowSplashScreenBackground` or related attributes in themes
- Simple custom activity-based implementation for full control
