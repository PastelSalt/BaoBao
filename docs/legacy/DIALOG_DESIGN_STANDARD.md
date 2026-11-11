# Unified Dialog Design Standard - BaoBao App

## Overview
All dialogs in the BaoBao app now follow a consistent, unified design standard for a cohesive user experience.

## ✅ Unified Design Standard

### 1. **Dialog Container**
```xml
<FrameLayout/ConstraintLayout
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:background="@drawable/bamboo_dialog_bg"
    android:padding="24dp">
```
- **Background**: `@drawable/bamboo_dialog_bg` (consistent bamboo-themed background)
- **Padding**: `24dp` on all sides

### 2. **Standard Header Structure**

#### BaoBao Character Icon
```xml
<ImageView
    android:layout_width="100dp"
    android:layout_height="100dp"
    android:layout_gravity="center_horizontal"
    android:contentDescription="BaoBao character"
    android:src="@drawable/baobao_main_default"
    android:scaleType="fitCenter" />
```
- **Size**: `100dp x 100dp`
- **Position**: Center horizontal
- **Icon**: BaoBao character or logo

#### Dialog Title
```xml
<TextView
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:layout_gravity="center_horizontal"
    android:layout_marginTop="12dp"
    android:text="Dialog Title"
    android:textColor="@color/green"
    android:textSize="22sp"
    android:textStyle="bold"
    android:fontFamily="sans-serif-medium" />
```
- **Text Size**: `22sp`
- **Color**: `@color/green`
- **Style**: Bold
- **Font**: `sans-serif-medium`
- **Margin Top**: `12dp` from icon

#### Subtitle (Optional)
```xml
<TextView
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:layout_gravity="center_horizontal"
    android:layout_marginTop="4dp"
    android:text="Subtitle text"
    android:textColor="@color/green"
    android:textSize="14sp"
    android:alpha="0.8" />
```
- **Text Size**: `14sp`
- **Color**: `@color/green` with 0.8 alpha (80% opacity)
- **Margin Top**: `4dp` from title

#### Decorative Bamboo Divider
```xml
<View
    android:layout_width="60dp"
    android:layout_height="3dp"
    android:layout_gravity="center_horizontal"
    android:layout_marginTop="8dp"
    android:layout_marginBottom="16dp"
    android:background="@color/green"
    android:alpha="0.4" />
```
- **Width**: `60dp`
- **Height**: `3dp`
- **Color**: `@color/green` with 0.4 alpha (40% opacity)
- **Margins**: `8dp` top, `16dp` bottom

### 3. **Content Cards**

#### Card Container
```xml
<com.google.android.material.card.MaterialCardView
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginBottom="16dp"
    app:cardBackgroundColor="@color/white"
    app:cardCornerRadius="16dp"
    app:cardElevation="2dp"
    app:strokeColor="@color/green"
    app:strokeWidth="1dp">
```
- **Corner Radius**: `16dp` (consistent across all cards)
- **Elevation**: `2dp` (subtle shadow)
- **Stroke**: `1dp` width, `@color/green`
- **Background**: `@color/white`
- **Margin Bottom**: `16dp` (spacing between cards)

#### Card Content Padding
```xml
<LinearLayout
    android:padding="20dp">
```
- **Padding**: `20dp` inside all cards

#### Section Headers Within Cards
```xml
<TextView
    android:text="Section Title"
    android:textColor="@color/green"
    android:textSize="16sp"
    android:textStyle="bold"
    android:fontFamily="sans-serif-medium" />
```
- **Text Size**: `16sp`
- **Color**: `@color/green`
- **Style**: Bold
- **Font**: `sans-serif-medium`

### 4. **Bottom Button Area**

#### Single Button Layout (Settings)
```xml
<LinearLayout
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginTop="8dp"
    android:orientation="vertical">

    <MaterialButton
        android:layout_width="match_parent"
        android:layout_height="56dp"
        android:background="@drawable/bamboo_button_tan"
        app:cornerRadius="16dp" />

    <MaterialButton
        android:layout_width="match_parent"
        android:layout_height="56dp"
        android:layout_marginTop="8dp" />
</LinearLayout>
```

#### Two-Button Layout (Customize)
```xml
<LinearLayout
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="horizontal"
    android:gravity="center">

    <MaterialButton
        android:layout_width="0dp"
        android:layout_height="56dp"
        android:layout_weight="1"
        android:layout_marginEnd="8dp" />

    <MaterialButton
        android:layout_width="0dp"
        android:layout_height="56dp"
        android:layout_weight="1"
        android:layout_marginStart="8dp" />
</LinearLayout>
```

**Button Specifications:**
- **Height**: `56dp` (consistent touch target)
- **Corner Radius**: `16dp`
- **Text Size**: `15-16sp`
- **Text Style**: Bold, no all caps
- **Spacing**: `8dp` between buttons

### 5. **Color Palette**

- **Primary Green**: `@color/green` - Headers, titles, strokes
- **Background**: `@color/white` - Card backgrounds
- **Accent Colors**: 
  - Light Yellow: `@color/light_yellow` (Happy mood)
  - Light Cream: `@color/light_cream` (Okay mood)
  - Light Blue: `@color/light_blue` (Sad mood)
  - Light Purple: `@color/light_purple` (Anxious mood)
  - Light Gray: `@color/light_gray` (Tired mood)
  - Pale Green: `@color/pale_green` (Character areas)

## Applied to All Dialogs

### ✅ 1. Settings Dialog (`dialog_settings.xml`)

**Header:**
- BaoBao icon (100dp)
- Title: "⚙️ Settings" (22sp)
- Subtitle: "Adjust your preferences" (14sp)
- Bamboo divider

**Content:**
- Audio Settings Card (16dp corner radius, 1dp stroke)
- Character & Speech Bubble Card

**Buttons:**
- Sign Out (full width, tan background)
- Close (full width, text button)

### ✅ 2. Mood Selection Dialog (`dialog_mood_selection.xml`)

**Header:**
- BaoBao logo (100dp)
- Title: "How are you feeling?" (22sp, green)
- Subtitle: "Let's talk about it! 🐼" (14sp, green 80%)
- Bamboo divider

**Content:**
- 5 Mood Cards in grid layout
- Each card: 110dp height, 16dp corner radius
- Larger icons: 56dp x 56dp

**No Buttons** (cards are selectable, auto-dismiss)

### ✅ 3. Customize Dialog (`dialog_customize.xml`)

**Header:**
- BaoBao icon (100dp)
- Title: "🎨 Customize BaoBao" (22sp)
- Subtitle: "Personalize your experience" (14sp)
- Bamboo divider

**Content:**
- BGM Collection Card (16dp corner radius, 1dp stroke)
- Outfit Collection Card (16dp corner radius, 1dp stroke)
- Character & Speech Bubble Card (16dp corner radius)

**Buttons:**
- Shop (outlined, 50% width)
- Close (filled green, 50% width)

## Design Consistency Checklist

✅ **Header Components:**
- [x] BaoBao icon at 100dp x 100dp
- [x] Title at 22sp, bold, green
- [x] Subtitle at 14sp, green 80% alpha
- [x] Bamboo divider (60dp x 3dp, green 40% alpha)
- [x] Consistent spacing (12dp, 4dp, 8dp, 16dp)

✅ **Content Cards:**
- [x] 16dp corner radius (all cards)
- [x] 2dp elevation (all cards)
- [x] 1dp green stroke (all cards)
- [x] White background
- [x] 20dp internal padding
- [x] 16dp bottom margin

✅ **Typography:**
- [x] Dialog titles: 22sp bold
- [x] Subtitles: 14sp
- [x] Section headers: 16sp bold
- [x] Body text: 14sp
- [x] Font: sans-serif-medium

✅ **Spacing:**
- [x] Dialog padding: 24dp
- [x] Card margins: 16dp bottom
- [x] Section spacing: 16dp
- [x] Button spacing: 8dp

✅ **Colors:**
- [x] Primary: Green for headers/titles
- [x] Background: White for cards
- [x] Strokes: 1dp green
- [x] Consistent accent colors

## Benefits of Unified Design

1. **Visual Cohesion**: All dialogs look like they belong to the same app
2. **User Familiarity**: Users quickly learn the dialog pattern
3. **Maintainability**: Easy to update design consistently
4. **Professional Appearance**: Polished, well-designed UI
5. **Accessibility**: Consistent touch targets and text sizes
6. **Brand Identity**: Reinforced bamboo theme throughout

## Before & After Comparison

### Before:
- ❌ Settings: Simple text header
- ❌ Mood Selection: Large BaoBao logo (123dp)
- ❌ Customize: Card-wrapped header with different styling
- ❌ Inconsistent card corner radius (16dp, 20dp)
- ❌ Inconsistent text sizes (18sp, 20sp, 24sp)
- ❌ Different elevation values (2dp, 3dp, 4dp)

### After:
- ✅ All dialogs: Standard 100dp BaoBao icon
- ✅ All titles: 22sp, bold, green
- ✅ All subtitles: 14sp, green 80%
- ✅ All cards: 16dp corner radius
- ✅ All cards: 2dp elevation, 1dp green stroke
- ✅ All spacing: Consistent 16dp, 8dp, 4dp
- ✅ Unified bamboo theme throughout

## Implementation Summary

**Files Modified:**
1. `dialog_settings.xml` - Standardized header, added BaoBao icon
2. `dialog_mood_selection.xml` - Adjusted icon size, title size, spacing
3. `dialog_customize.xml` - Removed card wrapper, standardized all cards

**Build Status:**
✅ **BUILD SUCCESSFUL** - All changes compile without errors

**Testing Checklist:**
- [ ] Settings dialog displays with new header
- [ ] Mood selection dialog shows consistent styling
- [ ] Customize dialog matches design standard
- [ ] All dialogs feel cohesive and consistent
- [ ] Icons are properly sized at 100dp
- [ ] Text is readable at standardized sizes
- [ ] Card corners are uniformly rounded
- [ ] Spacing feels balanced throughout

---

**Date**: February 8, 2026  
**Status**: ✅ Complete  
**Standard**: Unified across all 3 dialogs  
**Build**: Successful

