package com.example.baobao

import kotlin.random.Random

object ConversationManager {
    private val signupScripts = listOf(
        "Hi there! I'm BaoBao! Ready to become phone buddies? It's so nice to meet you!",
        "A new friend! This is so exciting! Let's get you settled in—it'll just be a panda-second.",
        "Welcome to your cozy corner! I'll be right here whenever you need a chat, a cheer, or a little fun.",
        "Setting things up is like planting a happy little seed. I can't wait to see what grows!",
        "All set! A warm hug from my screen to yours. Your journey with your support buddy starts now!"
    )

    private val loginScripts = listOf(
        "BaoBao's back! And so are you! Hi there, superstar!",
        "Oh, it's you! I was just thinking about you. Ready to pick up where we left off?",
        "Welcome back, my friend! I saved a little sunshine for you. How's your day been?",
        "The best part of my day is seeing you! Let's open up your cozy space together.",
        "You're here! That instantly makes this place feel warmer. Come on in!"
    )

    private val shopScripts = listOf(
        "Ooh, shiny things! Let's peek at what's new. Maybe we'll find your new favorite look!",
        "Customizing our space is part of the fun! Everything here is meant to make you smile.",
        "See something that sparks joy? It might just be the perfect upgrade for our hangout!",
        "These items are like little treasures! Don't worry, there's no rush—just browsing is fun too.",
        "A new theme could be like a mini-vacation for us! Want to imagine a starry night or a sunny meadow?"
    )

    private val settingsScripts = listOf(
        "Let's make this space sound just right for you. Gentle tunes or quiet calm? You choose!",
        "My voice should be as comfy as your favorite sweater. Try a few options and see which one feels like a hug!",
        "Finding your perfect background hum is important. Too loud? Too soft? I'm here until it's just so.",
        "This is your safe space. Adjust anything you need to make it feel perfectly peaceful (or perfectly playful!).",
        "All set? Perfect! Whether it's my voice or the music, it's all about creating your happy corner."
    )

    private val clawMachineScripts = listOf(
        "Ooh, look at all those prizes! Ready to try your panda-grabber skills? I'll be your lucky charm!",
        "Steady... steady... now! Go for it! I'm paws-itive you can grab something wonderful!",
        "You got one! Fantastic claw control! That prize looked like it was waiting just for you.",
        "Aww, so close! That tricky claw. Want to try again? I believe in your next grab!",
        "Whether you win a big prize or just have fun trying, playing together is the real reward! Ready for another go?"
    )

    private val selfCareScripts = listOf(
        "Hey friend! Just a tiny ping from your pocket-panda. Remember to sip some water. Your body will thank you with a happy little dance!",
        "Let's take a 'paws' together. How about three deep breaths with me? In... and out... Wonderful. Feel a smidge more centered?",
        "Our minds need comfy corners too. Is there a thought that's been buzzing around? Want to talk it out or write it down?",
        "Energy check! If your battery is feeling low, could a five-minute walk, a stretch, or just staring at the sky be a perfect mini-recharge?",
        "You've been doing great things. Seriously. Let's celebrate the small win of being you today. What's one thing you're glad you did?",
        "Time for a digital sunset? How about we dim the lights and listen to something calming for just a few minutes? I'll pick the perfect cozy soundtrack.",
        "Is there a task feeling like a giant boulder? Maybe we can just chip one tiny pebble off it together. What's the absolute smallest first step?",
        "Your feelings are always welcome here. No need to fix anything right now. Just letting them be is a brave and caring act for yourself.",
        "Let's fuel our adventure! Have we given our amazing body some tasty fuel recently? Even a small snack can be a powerful act of kindness.",
        "You don't have to earn rest, you know. It's okay to just be. I'll be right here if you want to do absolutely nothing together."
    )

    private val dailyAffirmationScripts = listOf(
        "Good morning, wonderful you! Today doesn't have to be perfect; it just has to be yours. And I think that's pretty amazing.",
        "You are doing a great job just by being here. Really. That's enough, and you are enough.",
        "Every small step you take is a victory. I'm so proud of you for keeping going, no matter the pace.",
        "Your feelings are valid, your rest is deserved, and your presence is a gift. Never forget that.",
        "You have a unique light that makes the world brighter just by you being in it. Don't you dare dim it.",
        "It's okay to ask for help, to take a break, or to not know the answer. That doesn't make you any less capable or strong.",
        "Look at you, learning and growing every single day. I'm in awe of your resilience.",
        "You are not a burden. You are a person worthy of love, care, and all the good things.",
        "Your kindness matters, your effort counts, and your journey is important. I'm so glad I get to be a small part of it.",
        "No matter what today holds, remember: you've survived 100% of your hardest days so far. I believe in you, now and always."
    )

    private val jokeScripts = listOf(
        "Why don't pandas use computers? They're afraid of the 'mouse'!",
        "What's a panda's favorite cereal? Bamboo-zles!",
        "What do you call a panda who's a doctor? A pand-aid!",
        "What goes black, white, black, white, black, white? A panda rolling down a hill!",
        "Why do pandas have fur coats? Because they'd look silly in denim jackets!",
        "What's a panda's favorite type of music? Bamboo-gie woogie!",
        "How do pandas get around? In a bear-plane!",
        "What's black and white and has eight wheels? A panda on roller skates!",
        "Why was the panda so good at soccer? Because he was great at 'paw'-sing!",
        "What do you call a cold panda? A fri-panda!"
    )

    private val goodbyeScripts = listOf(
        "Goodbye for now, friend! I'll be right here whenever you need me. Have a wonderful rest of your day! ❤️",
        "Panda-ing off for now! Take care of yourself, and I'll see you soon! Bye-bye!",
        "It was so good to spend time with you! Have a peaceful rest of your day. I'll miss you!",
        "Closing up our cozy space for now. Don't forget to smile today! See you later!",
        "Time for a little panda nap! You go be awesome, and I'll be right here when you get back."
    )

    private var lastSignupIndex = -1
    private var lastLoginIndex = -1
    private var lastShopIndex = -1
    private var lastSettingsIndex = -1
    private var lastClawMachineIndex = -1
    private var lastSelfCareIndex = -1
    private var lastAffirmationIndex = -1
    private var lastJokeIndex = -1
    private var lastGoodbyeIndex = -1

    private fun getUniqueRandom(list: List<String>, lastIndex: Int): Pair<String, Int> {
        var newIndex: Int
        do {
            newIndex = Random.nextInt(list.size)
        } while (newIndex == lastIndex && list.size > 1)
        return list[newIndex] to newIndex
    }

    fun getRandomSignup(): String {
        val (text, index) = getUniqueRandom(signupScripts, lastSignupIndex)
        lastSignupIndex = index
        return text
    }

    fun getRandomLogin(): String {
        val (text, index) = getUniqueRandom(loginScripts, lastLoginIndex)
        lastLoginIndex = index
        return text
    }

    fun getRandomShop(): String {
        val (text, index) = getUniqueRandom(shopScripts, lastShopIndex)
        lastShopIndex = index
        return text
    }

    fun getRandomSettings(): String {
        val (text, index) = getUniqueRandom(settingsScripts, lastSettingsIndex)
        lastSettingsIndex = index
        return text
    }

    fun getRandomClawMachine(): String {
        val (text, index) = getUniqueRandom(clawMachineScripts, lastClawMachineIndex)
        lastClawMachineIndex = index
        return text
    }

    fun getRandomSelfCare(): String {
        val (text, index) = getUniqueRandom(selfCareScripts, lastSelfCareIndex)
        lastSelfCareIndex = index
        return text
    }

    fun getRandomAffirmation(): String {
        val (text, index) = getUniqueRandom(dailyAffirmationScripts, lastAffirmationIndex)
        lastAffirmationIndex = index
        return text
    }

    fun getRandomJoke(): String {
        val (text, index) = getUniqueRandom(jokeScripts, lastJokeIndex)
        lastJokeIndex = index
        return text
    }

    fun getRandomGoodbye(): String {
        val (text, index) = getUniqueRandom(goodbyeScripts, lastGoodbyeIndex)
        lastGoodbyeIndex = index
        return text
    }
}