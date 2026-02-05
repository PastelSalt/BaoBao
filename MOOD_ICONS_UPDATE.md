# Mood Selection Icons Update

## Summary
Updated the mood selection buttons to use custom BaoBao character images instead of emoji for Happy, Okay, and Tired moods. Sad and Anxious moods remain as emoji placeholders until custom images are ready.

## Changes Made

### ✅ Implemented Mood Icons

#### 1. Happy Mood
- **Image**: `happyface_default.png`
- **Size**: 50dp × 50dp (activity), 42dp × 42dp (dialog)
- **Replaced**: 😊 emoji
- **Status**: ✅ Complete

#### 2. Okay Mood
- **Image**: `okayface_default.png`
- **Size**: 50dp × 50dp (activity), 42dp × 42dp (dialog)
- **Replaced**: 😐 emoji
- **Status**: ✅ Complete

#### 3. Tired Mood
- **Image**: `tiredface_default.png`
- **Size**: 50dp × 50dp (activity), 42dp × 42dp (dialog)
- **Replaced**: 😴 emoji
- **Status**: ✅ Complete

### 🚧 Pending Mood Icons

#### 4. Sad Mood
- **Current**: 😢 emoji (placeholder)
- **Available Image**: `outfit2_fullbody_sad.png` (fullbody version exists)
- **Status**: ⏳ Waiting for `sadface_default.png`

#### 5. Anxious Mood
- **Current**: 😰 emoji (placeholder)
- **Available Image**: None yet
- **Status**: ⏳ Waiting for `anxiousface_default.png`

## Technical Implementation

### Files Modified

1. **activity_mood_selection.xml**
   - Replaced TextView emojis with ImageView components for Happy, Okay, Tired
   - Maintained TextView emojis for Sad and Anxious (pending)

2. **dialog_mood_selection.xml**
   - Replaced TextView emojis with ImageView components for Happy, Okay, Tired
   - Maintained TextView emojis for Sad and Anxious (pending)

### Code Changes

#### Before (TextView with Emoji):
```xml
<TextView
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="😊"
    android:textSize="40sp" />
```

#### After (ImageView with Custom Icon):
```xml
<ImageView
    android:layout_width="50dp"
    android:layout_height="50dp"
    android:contentDescription="Happy mood icon"
    android:scaleType="fitCenter"
    android:src="@drawable/happyface_default" />
```

## Image Specifications

### Activity Layout (activity_mood_selection.xml)
- Image size: **50dp × 50dp**
- Scale type: `fitCenter`
- Margin top (text label): 4dp

### Dialog Layout (dialog_mood_selection.xml)
- Image size: **42dp × 42dp**
- Scale type: `fitCenter`
- Margin top (text label): 4dp

## Available Images in Drawable Folder

### Face Icons (Used):
✅ `happyface_default.png` - Happy mood icon
✅ `okayface_default.png` - Okay mood icon
✅ `tiredface_default.png` - Tired mood icon

### Full Body Images (Available but not used in mood selection):
- `outfit2_fullbody_happy.png`
- `outfit2_fullbody_sad.png`
- `outfit2_fullbody_tired.png`

### Missing Icons (Needed):
❌ `sadface_default.png` - For Sad mood button
❌ `anxiousface_default.png` - For Anxious mood button

## Next Steps

### To Complete Sad Mood Icon:
1. Create or obtain `sadface_default.png` image (50dp recommended size)
2. Place in `app/src/main/res/drawable/`
3. Update both layout files:

**activity_mood_selection.xml** (around line 236):
```xml
<!-- Replace this TextView -->
<TextView
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="😢"
    android:textSize="40sp" />

<!-- With this ImageView -->
<ImageView
    android:layout_width="50dp"
    android:layout_height="50dp"
    android:contentDescription="Sad mood icon"
    android:scaleType="fitCenter"
    android:src="@drawable/sadface_default" />
```

**dialog_mood_selection.xml** (around line 171):
```xml
<!-- Replace this TextView -->
<TextView
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="😢"
    android:textSize="32sp" />

<!-- With this ImageView -->
<ImageView
    android:layout_width="42dp"
    android:layout_height="42dp"
    android:contentDescription="Sad mood icon"
    android:scaleType="fitCenter"
    android:src="@drawable/sadface_default" />
```

### To Complete Anxious Mood Icon:
1. Create or obtain `anxiousface_default.png` image (50dp recommended size)
2. Place in `app/src/main/res/drawable/`
3. Update both layout files:

**activity_mood_selection.xml** (around line 277):
```xml
<!-- Replace this TextView -->
<TextView
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="😰"
    android:textSize="40sp" />

<!-- With this ImageView -->
<ImageView
    android:layout_width="50dp"
    android:layout_height="50dp"
    android:contentDescription="Anxious mood icon"
    android:scaleType="fitCenter"
    android:src="@drawable/anxiousface_default" />
```

**dialog_mood_selection.xml** (around line 212):
```xml
<!-- Replace this TextView -->
<TextView
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="😰"
    android:textSize="32sp" />

<!-- With this ImageView -->
<ImageView
    android:layout_width="42dp"
    android:layout_height="42dp"
    android:contentDescription="Anxious mood icon"
    android:scaleType="fitCenter"
    android:src="@drawable/anxiousface_default" />
```

## Build Status
✅ **BUILD SUCCESSFUL** - All changes compile without errors

## Visual Layout

### Current Mood Selection Appearance:

```
┌─────────────────────────────┐
│      BaoBao Character       │
├─────────────────────────────┤
│  How are you feeling now?   │
├─────────────────────────────┤
│  ┌──────────┐  ┌──────────┐ │
│  │  [IMG]   │  │  [IMG]   │ │  ← Custom Images
│  │  Happy   │  │  Okay    │ │
│  └──────────┘  └──────────┘ │
│  ┌──────────┐  ┌──────────┐ │
│  │    😢    │  │    😰    │ │  ← Emoji Placeholders
│  │   Sad    │  │ Anxious  │ │
│  └──────────┘  └──────────┘ │
│  ┌─────────────────────────┐│
│  │         [IMG]           ││  ← Custom Image
│  │         Tired           ││
│  └─────────────────────────┘│
└─────────────────────────────┘
```

[IMG] = Custom BaoBao character face images
😢😰 = Temporary emoji placeholders

## Benefits

1. **Consistent Branding**: BaoBao character faces instead of generic emoji
2. **Better Visual Identity**: Custom artwork matches app's theme
3. **Improved UX**: Larger, clearer mood icons
4. **Scalable**: Easy to add remaining icons when ready
5. **Accessible**: Proper contentDescription for screen readers

## Testing

After adding Sad and Anxious icons, test:
- [ ] All mood buttons display correct images
- [ ] Images scale properly in both activity and dialog
- [ ] Images are centered within cards
- [ ] Text labels appear below images with proper spacing
- [ ] Icons look good on different screen sizes
- [ ] No layout overflow or clipping issues

---

**Date**: February 5, 2026
**Status**: Partial Implementation (3/5 complete)
**Next**: Add sadface_default.png and anxiousface_default.png
