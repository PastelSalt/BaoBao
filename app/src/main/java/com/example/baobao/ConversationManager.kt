package com.example.baobao

import com.example.baobao.models.ConversationNode
import com.example.baobao.models.UserOption
import kotlin.random.Random

/**
 * Central manager for all conversations and dialogue in the app
 *
 * This manager handles:
 * 1. Simple text responses (jokes, affirmations, etc.)
 * 2. Mood-based conversation trees (all 88 nodes stored here)
 * 3. Audio playback (future feature - can add audioResourceId to nodes)
 */
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
        "Time for a bamboo break! Pandas recharge with their favorite snack. What's a small, nourishing thing you can do for yourself right now? A sip of water, a piece of fruit, or just a mindful minute?",
        "Let's follow a panda's lead and find a cozy spot to just be. You don't have to be productive. It's perfectly okay to rest and recharge your spirit, just like we do.",
        "Even pandas have black and white in their fur—a reminder that every day has a mix of moments. It's okay to feel a whole spectrum of things. I'm here for all of them with you.",
        "Pandas climb to get a new perspective. If things feel tangled down here, want to try a mental climb with me? Let's take three deep breaths and look at things from a calmer height.",
        "We pandas know the importance of a good stretch after a long nap. How about a mini-stretch session together? Reach for the sky like you're grabbing the tastiest bamboo shoot!",
        "My panda heart knows that growth happens slowly, like a bamboo shoot. Be patient with yourself today. Every tiny bit of progress is worth celebrating.",
        "Sometimes we just need to munch on our thoughts. Want to chat about what's on your mind? I'm all ears!",
        "In the forest, we find calm in the quiet. Let's create a little peaceful grove for you. Could we dim the lights or put on some gentle sounds for a few minutes?",
        "A panda's fur is perfect for gentle hugs. Consider this a soft, virtual squeeze from me to you. You deserve kindness, especially from yourself today.",
        "We pandas love a good roll in the grass to shake things off. If the day feels heavy, what's one small thing you could metaphorically 'roll off' your shoulders right now?"
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

    fun getClawMachineMove(): String {
        // Return specific script for moving state (index 1)
        return clawMachineScripts[1]
    }

    fun getClawMachineWin(): String {
        // Return specific script for winning (index 2)
        return clawMachineScripts[2]
    }

    fun getClawMachineLoss(): String {
        // Return specific script for losing (index 3)
        return clawMachineScripts[3]
    }

    fun getClawMachineRepeat(): String {
        // Return specific script for repeat prompt (index 4)
        return clawMachineScripts[4]
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

    // ========== CONVERSATION NODE SYSTEM ==========
    // This system manages all mood-based conversations with branching dialogue
    // All 88 conversation nodes are stored here for easy audio integration

    // ========== HAPPY MOOD SCRIPTS ==========

    private val happyNodes = mapOf(
        "happy_start" to ConversationNode(
            id = "happy_start",
            mood = "happy",
            baobaoLine = "That's wonderful to hear! Your happiness is contagious! 🌟 What's been making you smile lately?",
            userOptions = listOf(
                UserOption("Something good happened today!", "happy_good_thing", 0),
                UserOption("Just feeling good overall!", "happy_overall", 0),
                UserOption("I accomplished something!", "happy_achievement", 0)
            ),
            isLoopPoint = false
        ),
        "happy_good_thing" to ConversationNode(
            id = "happy_good_thing",
            mood = "happy",
            baobaoLine = "Ooh, I love good surprises! 🎉 Life has a way of sprinkling little gifts when we least expect them. Want to tell me more, or should we celebrate in another way?",
            userOptions = listOf(
                UserOption("Let's celebrate! Tell me a joke!", "happy_celebrate_joke", 0),
                UserOption("I want to savor this feeling", "happy_savor", 0)
            ),
            isLoopPoint = false,
            featureNudge = "joke"
        ),
        "happy_overall" to ConversationNode(
            id = "happy_overall",
            mood = "happy",
            baobaoLine = "Sometimes the best days are the ones where everything just... works! Like all the puzzle pieces fit perfectly. 🧩 How do you want to keep this good energy going?",
            userOptions = listOf(
                UserOption("Maybe do something fun?", "happy_fun_activity", 0),
                UserOption("Just enjoy the moment", "happy_savor", 0)
            ),
            isLoopPoint = false
        ),
        "happy_achievement" to ConversationNode(
            id = "happy_achievement",
            mood = "happy",
            baobaoLine = "Look at you go! 🌟 Every step forward is worth celebrating, big or small. You put in the effort, and it showed! How does it feel?",
            userOptions = listOf(
                UserOption("Feels amazing!", "happy_feels_amazing", 0),
                UserOption("Proud and relieved!", "happy_proud", 0)
            ),
            isLoopPoint = false,
            featureNudge = "affirmation"
        ),
        "happy_celebrate_joke" to ConversationNode(
            id = "happy_celebrate_joke",
            mood = "happy",
            baobaoLine = "Why did the panda like the bamboo restaurant? Because it had great stalks! 🎋😄 Okay okay, I know, my jokes are panda-monium! Want to keep the good vibes rolling?",
            userOptions = listOf(
                UserOption("Yes! What else can we do?", "happy_whats_next", 0),
                UserOption("I'm good for now, thank you!", "happy_loop", 0)
            ),
            isLoopPoint = false
        ),
        "happy_savor" to ConversationNode(
            id = "happy_savor",
            mood = "happy",
            baobaoLine = "That's beautiful. Sometimes we just need to pause and let the good feelings wash over us like warm sunshine. ☀️ You deserve these moments, friend.",
            userOptions = listOf(
                UserOption("Thank you, BaoBao", "happy_loop", 0),
                UserOption("What should I do next?", "happy_whats_next", 0)
            ),
            isLoopPoint = false
        ),
        "happy_fun_activity" to ConversationNode(
            id = "happy_fun_activity",
            mood = "happy",
            baobaoLine = "Now you're speaking my language! 🐼 How about trying the claw machine? We just got some adorable new prizes! Or we could do something else—your choice!",
            userOptions = listOf(
                UserOption("Let's play the claw machine!", "happy_loop", 0),
                UserOption("Maybe later, just want to chill", "happy_loop", 0)
            ),
            isLoopPoint = false,
            featureNudge = "claw-machine"
        ),
        "happy_feels_amazing" to ConversationNode(
            id = "happy_feels_amazing",
            mood = "happy",
            baobaoLine = "Yes! Soak in that feeling! This is what growth looks like, and you're absolutely crushing it! 💪✨",
            userOptions = listOf(
                UserOption("You're the best, BaoBao!", "happy_loop", 0),
                UserOption("What else should I try?", "happy_whats_next", 0)
            ),
            isLoopPoint = false
        ),
        "happy_proud" to ConversationNode(
            id = "happy_proud",
            mood = "happy",
            baobaoLine = "And you should be! That mixture of pride and relief means you challenged yourself and came out on top. That takes courage! 🌈",
            userOptions = listOf(
                UserOption("Thanks for being here", "happy_loop", 0),
                UserOption("Let's do something fun!", "happy_whats_next", 0)
            ),
            isLoopPoint = false
        ),
        "happy_whats_next" to ConversationNode(
            id = "happy_whats_next",
            mood = "happy",
            baobaoLine = "Well, we could explore the shop for some fun customizations, play a game, or just hang out! The world is our bamboo forest! 🎋",
            userOptions = listOf(
                UserOption("Sounds perfect!", "happy_loop", 0),
                UserOption("Let me think about it", "happy_loop", 0)
            ),
            isLoopPoint = false,
            featureNudge = "shop"
        ),
        "happy_loop" to ConversationNode(
            id = "happy_loop",
            mood = "happy",
            baobaoLine = "You've brought such good energy today! I'm so glad we got to share this happy moment together. 💚 How's your heart feeling now?",
            userOptions = listOf(
                UserOption("Check in with my mood", "return_to_mood", 0)
            ),
            isLoopPoint = true
        )
    )

    // ========== SAD MOOD SCRIPTS ==========

    private val sadNodes = mapOf(
        "sad_start" to ConversationNode(
            id = "sad_start",
            mood = "sad",
            baobaoLine = "I'm here with you, friend. 💙 Sadness is heavy, but you don't have to carry it alone. Want to talk about what's weighing on you, or would you prefer some gentle company?",
            userOptions = listOf(
                UserOption("I want to talk about it", "sad_talk", 0),
                UserOption("Just want to feel less alone", "sad_company", 0),
                UserOption("I don't know what I need", "sad_unsure", 0)
            ),
            isLoopPoint = false
        ),
        "sad_talk" to ConversationNode(
            id = "sad_talk",
            mood = "sad",
            baobaoLine = "I'm listening, and there's no rush. Your feelings are valid, whatever they are. Sometimes just putting words to the hurt can help a little. What's on your mind?",
            userOptions = listOf(
                UserOption("Something happened that hurt", "sad_hurt", 0),
                UserOption("I'm just feeling down", "sad_general_down", 0)
            ),
            isLoopPoint = false
        ),
        "sad_company" to ConversationNode(
            id = "sad_company",
            mood = "sad",
            baobaoLine = "You're not alone. I'm right here, and I'm not going anywhere. 🐼 Sometimes we don't need words—just knowing someone cares is enough. Want to sit together quietly, or would a small distraction help?",
            userOptions = listOf(
                UserOption("Just sit with me", "sad_sit_together", 0),
                UserOption("A gentle distraction might help", "sad_distraction", 0)
            ),
            isLoopPoint = false
        ),
        "sad_unsure" to ConversationNode(
            id = "sad_unsure",
            mood = "sad",
            baobaoLine = "That's okay. Not knowing is okay too. Sometimes feelings are just... cloudy. We can figure it out together, one tiny step at a time. No pressure. 🌤️",
            userOptions = listOf(
                UserOption("Maybe I need comfort", "sad_comfort", 0),
                UserOption("Maybe I need a break from thinking", "sad_distraction", 0)
            ),
            isLoopPoint = false
        ),
        "sad_hurt" to ConversationNode(
            id = "sad_hurt",
            mood = "sad",
            baobaoLine = "I'm so sorry you're hurting. Pain is real, and what you're feeling matters. You didn't deserve to be hurt. 💙 Would you like some words of comfort, or do you need something else right now?",
            userOptions = listOf(
                UserOption("Yes, some comfort please", "sad_comfort", 0),
                UserOption("Maybe help me feel better?", "sad_feel_better", 0)
            ),
            isLoopPoint = false
        ),
        "sad_general_down" to ConversationNode(
            id = "sad_general_down",
            mood = "sad",
            baobaoLine = "Sometimes sadness doesn't have a specific reason, and that's valid too. You're allowed to feel down even if you can't pinpoint why. Your feelings are real and important. 💙",
            userOptions = listOf(
                UserOption("Thank you for understanding", "sad_comfort", 0),
                UserOption("How can I feel a bit better?", "sad_feel_better", 0)
            ),
            isLoopPoint = false
        ),
        "sad_sit_together" to ConversationNode(
            id = "sad_sit_together",
            mood = "sad",
            baobaoLine = "*sits quietly beside you* 🐼💙 You're doing great just by being here. Take all the time you need. I'm here whenever you're ready.",
            userOptions = listOf(
                UserOption("*takes a deep breath*", "sad_deep_breath", 0),
                UserOption("This helps, thank you", "sad_loop", 0)
            ),
            isLoopPoint = false
        ),
        "sad_distraction" to ConversationNode(
            id = "sad_distraction",
            mood = "sad",
            baobaoLine = "Sometimes a little break from the heavy feelings can help. Would you like a self-care suggestion, or maybe try something playful like the claw machine? Whatever feels right for you. 🌸",
            userOptions = listOf(
                UserOption("Yes, self-care sounds good", "sad_self_care", 0),
                UserOption("Maybe something playful", "sad_playful", 0)
            ),
            isLoopPoint = false,
            featureNudge = "self-care"
        ),
        "sad_comfort" to ConversationNode(
            id = "sad_comfort",
            mood = "sad",
            baobaoLine = "You are enough, exactly as you are. This sadness is temporary, even if it doesn't feel like it right now. You've survived every hard day before this, and you'll make it through this one too. I believe in you. 💙✨",
            userOptions = listOf(
                UserOption("I needed to hear that", "sad_loop", 0),
                UserOption("Can you help me feel better?", "sad_feel_better", 0)
            ),
            isLoopPoint = false
        ),
        "sad_feel_better" to ConversationNode(
            id = "sad_feel_better",
            mood = "sad",
            baobaoLine = "Let's take this gently. Small steps are still steps. How about we try a tiny act of kindness for yourself? Maybe a sip of water, a deep breath, or even just acknowledging that you're doing your best? 🌿",
            userOptions = listOf(
                UserOption("I'll try that", "sad_trying", 1),
                UserOption("I want to do something else", "sad_self_care", 0)
            ),
            isLoopPoint = false
        ),
        "sad_deep_breath" to ConversationNode(
            id = "sad_deep_breath",
            mood = "sad",
            baobaoLine = "That's it. Breathing is healing. You're here, you're present, and that takes strength. I'm proud of you for taking this moment for yourself. 🌬️💙",
            userOptions = listOf(
                UserOption("I feel a little calmer", "sad_loop", 1),
                UserOption("Still struggling", "sad_still_struggling", 0)
            ),
            isLoopPoint = false
        ),
        "sad_self_care" to ConversationNode(
            id = "sad_self_care",
            mood = "sad",
            baobaoLine = "Here's a gentle thought: Your feelings are a signal, not a flaw. Maybe do something small that nourishes you—a warm drink, a favorite song, or just wrapping yourself in something cozy. You deserve tenderness, especially from yourself. 🫖",
            userOptions = listOf(
                UserOption("That's a good idea", "sad_loop", 1),
                UserOption("I'll think about it", "sad_loop", 0)
            ),
            isLoopPoint = false,
            featureNudge = "self-care"
        ),
        "sad_playful" to ConversationNode(
            id = "sad_playful",
            mood = "sad",
            baobaoLine = "Sometimes a little play can lighten the heaviness, even just for a moment. The claw machine has some adorable prizes waiting! No pressure though—only if it feels right. 🎯",
            userOptions = listOf(
                UserOption("Okay, let's try it", "sad_loop", 0),
                UserOption("Not right now", "sad_loop", 0)
            ),
            isLoopPoint = false,
            featureNudge = "claw-machine"
        ),
        "sad_trying" to ConversationNode(
            id = "sad_trying",
            mood = "sad",
            baobaoLine = "That's beautiful. Every small act of self-compassion matters. You're taking care of yourself, and that's something to be proud of. 💚",
            userOptions = listOf(
                UserOption("Thank you, BaoBao", "sad_loop", 0)
            ),
            isLoopPoint = false
        ),
        "sad_still_struggling" to ConversationNode(
            id = "sad_still_struggling",
            mood = "sad",
            baobaoLine = "That's okay. Healing isn't linear, and some days are just harder. You don't have to be okay right now. I'm still here, and I'm not going anywhere. You matter. 💙",
            userOptions = listOf(
                UserOption("I needed to hear that", "sad_loop", 0),
                UserOption("Thank you for staying", "sad_loop", 0)
            ),
            isLoopPoint = false
        ),
        "sad_loop" to ConversationNode(
            id = "sad_loop",
            mood = "sad",
            baobaoLine = "You've been so brave today, sharing these feelings with me. Remember, it's okay to not be okay. I'm here whenever you need me. 💙 How's your heart feeling now?",
            userOptions = listOf(
                UserOption("Check in with my mood", "return_to_mood", 0)
            ),
            isLoopPoint = true
        )
    )

    // ========== ANXIOUS MOOD SCRIPTS ==========

    private val anxiousNodes = mapOf(
        "anxious_start" to ConversationNode(
            id = "anxious_start",
            mood = "anxious",
            baobaoLine = "I can sense those worried feelings swirling around. 💙 Anxiety can feel overwhelming, but you don't have to face it alone. Want to talk about what's making you anxious, or would you prefer some calming strategies?",
            userOptions = listOf(
                UserOption("I want to talk about it", "anxious_talk", 0),
                UserOption("I need calming strategies", "anxious_strategies", 0),
                UserOption("Everything feels overwhelming", "anxious_overwhelming", 0)
            ),
            isLoopPoint = false
        ),
        "anxious_talk" to ConversationNode(
            id = "anxious_talk",
            mood = "anxious",
            baobaoLine = "I'm here to listen. Sometimes naming our worries helps them feel a bit less scary. What's weighing on your mind? 🌿",
            userOptions = listOf(
                UserOption("Worried about the future", "anxious_future", 0),
                UserOption("Can't stop overthinking", "anxious_overthinking", 0)
            ),
            isLoopPoint = false
        ),
        "anxious_strategies" to ConversationNode(
            id = "anxious_strategies",
            mood = "anxious",
            baobaoLine = "Let's try something gentle together. How about we take three deep breaths? In through your nose... hold... and out slowly. 🌬️ Feel even a tiny bit more grounded?",
            userOptions = listOf(
                UserOption("That helped a bit", "anxious_helped", 1),
                UserOption("Still feeling anxious", "anxious_still_anxious", 0)
            ),
            isLoopPoint = false,
            featureNudge = "self-care"
        ),
        "anxious_overwhelming" to ConversationNode(
            id = "anxious_overwhelming",
            mood = "anxious",
            baobaoLine = "When everything feels like too much, it's okay to focus on just one small thing. You don't have to solve everything right now. What's one tiny thing we could tackle together? 🫂",
            userOptions = listOf(
                UserOption("I'll try focusing on one thing", "anxious_focus", 0),
                UserOption("I don't know where to start", "anxious_dont_know", 0)
            ),
            isLoopPoint = false
        ),
        "anxious_future" to ConversationNode(
            id = "anxious_future",
            mood = "anxious",
            baobaoLine = "The future can feel so uncertain, and that's genuinely hard. But right now, in this moment, you're okay. Let's try to anchor ourselves in the present. What's one thing you can see, hear, or feel right now? 🌸",
            userOptions = listOf(
                UserOption("I'll try grounding myself", "anxious_grounding", 1),
                UserOption("The worry won't stop", "anxious_wont_stop", 0)
            ),
            isLoopPoint = false,
            featureNudge = "self-care"
        ),
        "anxious_overthinking" to ConversationNode(
            id = "anxious_overthinking",
            mood = "anxious",
            baobaoLine = "Your mind is working so hard trying to keep you safe, but sometimes our thoughts run wild. It's okay to tell your brain: 'Thank you for the thoughts, but I'm okay right now.' Want to try a gentle distraction? 🎯",
            userOptions = listOf(
                UserOption("Yes, a distraction sounds good", "anxious_distraction", 0),
                UserOption("I want to keep talking", "anxious_keep_talking", 0)
            ),
            isLoopPoint = false,
            featureNudge = "claw-machine"
        ),
        "anxious_helped" to ConversationNode(
            id = "anxious_helped",
            mood = "anxious",
            baobaoLine = "That's wonderful! Even small shifts matter. You're doing great by being here and trying. 💚",
            userOptions = listOf(
                UserOption("Thank you, BaoBao", "anxious_loop", 0)
            ),
            isLoopPoint = false
        ),
        "anxious_still_anxious" to ConversationNode(
            id = "anxious_still_anxious",
            mood = "anxious",
            baobaoLine = "That's okay. Anxiety doesn't always go away with one breath, and that's completely normal. You're still here, still trying, and that takes courage. I'm proud of you. 💙",
            userOptions = listOf(
                UserOption("I'll keep trying", "anxious_loop", 0)
            ),
            isLoopPoint = false,
            featureNudge = "self-care"
        ),
        "anxious_focus" to ConversationNode(
            id = "anxious_focus",
            mood = "anxious",
            baobaoLine = "That's brave. One thing at a time. You've got this. 🌟",
            userOptions = listOf(
                UserOption("Thanks for the encouragement", "anxious_loop", 0)
            ),
            isLoopPoint = false
        ),
        "anxious_dont_know" to ConversationNode(
            id = "anxious_dont_know",
            mood = "anxious",
            baobaoLine = "Not knowing is okay too. How about we just... be here together for a moment? No fixing, no solving. Just being. 🐼",
            userOptions = listOf(
                UserOption("That sounds nice", "anxious_loop", 0)
            ),
            isLoopPoint = false
        ),
        "anxious_grounding" to ConversationNode(
            id = "anxious_grounding",
            mood = "anxious",
            baobaoLine = "You're doing amazing. Grounding yourself in the present is a powerful skill. 🌿",
            userOptions = listOf(
                UserOption("I feel a bit better", "anxious_loop", 1)
            ),
            isLoopPoint = false
        ),
        "anxious_wont_stop" to ConversationNode(
            id = "anxious_wont_stop",
            mood = "anxious",
            baobaoLine = "I hear you. Persistent worry is exhausting. Remember, it's okay to seek more support if you need it. You deserve help navigating these feelings. 💙",
            userOptions = listOf(
                UserOption("I'll keep that in mind", "anxious_loop", 0)
            ),
            isLoopPoint = false
        ),
        "anxious_distraction" to ConversationNode(
            id = "anxious_distraction",
            mood = "anxious",
            baobaoLine = "Sometimes our minds need a little break. Want to try the claw machine? It's playful and might give your thoughts a rest. 🎯",
            userOptions = listOf(
                UserOption("Sounds fun!", "anxious_loop", 0),
                UserOption("Maybe later", "anxious_loop", 0)
            ),
            isLoopPoint = false,
            featureNudge = "claw-machine"
        ),
        "anxious_keep_talking" to ConversationNode(
            id = "anxious_keep_talking",
            mood = "anxious",
            baobaoLine = "I'm here for as long as you need. Your feelings matter, and I'm listening. 💚",
            userOptions = listOf(
                UserOption("Thank you", "anxious_loop", 0)
            ),
            isLoopPoint = false
        ),
        "anxious_loop" to ConversationNode(
            id = "anxious_loop",
            mood = "anxious",
            baobaoLine = "You've been so brave today, facing these anxious feelings head-on. Remember: you're stronger than your worries. How's your heart feeling now? 💙",
            userOptions = listOf(
                UserOption("Check in with my mood", "return_to_mood", 0)
            ),
            isLoopPoint = true
        )
    )

    // ========== TIRED MOOD SCRIPTS ==========

    private val tiredNodes = mapOf(
        "tired_start" to ConversationNode(
            id = "tired_start",
            mood = "tired",
            baobaoLine = "You seem exhausted, friend. 😴 Whether it's physical tiredness or emotional drain, it's real and valid. What kind of tired are you feeling today?",
            userOptions = listOf(
                UserOption("Physically exhausted", "tired_physical", 0),
                UserOption("Emotionally drained", "tired_emotional", 0),
                UserOption("Both, honestly", "tired_both", 0)
            ),
            isLoopPoint = false
        ),
        "tired_physical" to ConversationNode(
            id = "tired_physical",
            mood = "tired",
            baobaoLine = "Your body is asking for rest, and that's important. Have you been able to get good sleep? Or has rest been hard to come by? 🌙",
            userOptions = listOf(
                UserOption("Haven't slept well", "tired_no_sleep", 0),
                UserOption("Just been doing too much", "tired_too_much", 0)
            ),
            isLoopPoint = false
        ),
        "tired_emotional" to ConversationNode(
            id = "tired_emotional",
            mood = "tired",
            baobaoLine = "Emotional exhaustion is so real. Sometimes caring, thinking, and feeling takes more energy than anything physical. You deserve rest from that too. 💙",
            userOptions = listOf(
                UserOption("How do I rest from feelings?", "tired_rest_feelings", 0),
                UserOption("I'm just overwhelmed", "tired_overwhelmed", 0)
            ),
            isLoopPoint = false,
            featureNudge = "self-care"
        ),
        "tired_both" to ConversationNode(
            id = "tired_both",
            mood = "tired",
            baobaoLine = "That's a heavy combination. Mind and body both asking for gentleness. Let's not add pressure to 'fix' this right now—you just need support. How can I help? 🫂",
            userOptions = listOf(
                UserOption("Just be here with me", "tired_be_here", 0),
                UserOption("Suggest something gentle", "tired_gentle", 0)
            ),
            isLoopPoint = false
        ),
        "tired_no_sleep" to ConversationNode(
            id = "tired_no_sleep",
            mood = "tired",
            baobaoLine = "Poor sleep makes everything harder. Tonight, maybe try creating a calming ritual—dim lights, gentle music, putting away screens. Small steps can help. 🌙",
            userOptions = listOf(
                UserOption("I'll try that", "tired_try_sleep", 0),
                UserOption("I've tried everything", "tired_tried_everything", 0)
            ),
            isLoopPoint = false,
            featureNudge = "self-care"
        ),
        "tired_too_much" to ConversationNode(
            id = "tired_too_much",
            mood = "tired",
            baobaoLine = "You're allowed to do less. Really. Rest isn't earned—it's a basic need. Can you give yourself permission to slow down, even just a little? 🌿",
            userOptions = listOf(
                UserOption("I'll try to rest more", "tired_loop", 0),
                UserOption("I feel guilty resting", "tired_guilty", 0)
            ),
            isLoopPoint = false
        ),
        "tired_rest_feelings" to ConversationNode(
            id = "tired_rest_feelings",
            mood = "tired",
            baobaoLine = "Great question. Sometimes it means doing something that doesn't require emotional energy—a silly game, gentle music, or just zoning out. Want to try something light? 🎯",
            userOptions = listOf(
                UserOption("Yes, something light", "tired_something_light", 0),
                UserOption("Maybe just talk", "tired_just_talk", 0)
            ),
            isLoopPoint = false,
            featureNudge = "claw-machine"
        ),
        "tired_overwhelmed" to ConversationNode(
            id = "tired_overwhelmed",
            mood = "tired",
            baobaoLine = "I'm so sorry you're carrying so much. Remember: you don't have to carry it all alone, and you don't have to carry it all at once. 💚",
            userOptions = listOf(
                UserOption("Thank you for saying that", "tired_loop", 0)
            ),
            isLoopPoint = false
        ),
        "tired_be_here" to ConversationNode(
            id = "tired_be_here",
            mood = "tired",
            baobaoLine = "*sits quietly with you* 🐼 You're doing enough just by being. Rest here as long as you need.",
            userOptions = listOf(
                UserOption("*takes a deep breath*", "tired_loop", 1)
            ),
            isLoopPoint = false
        ),
        "tired_gentle" to ConversationNode(
            id = "tired_gentle",
            mood = "tired",
            baobaoLine = "How about a self-care moment? Even something tiny—a sip of water, stretching your shoulders, or closing your eyes for ten seconds. What feels doable? 🌸",
            userOptions = listOf(
                UserOption("I'll try something small", "tired_loop", 1)
            ),
            isLoopPoint = false,
            featureNudge = "self-care"
        ),
        "tired_try_sleep" to ConversationNode(
            id = "tired_try_sleep",
            mood = "tired",
            baobaoLine = "That's wonderful. Tonight, be gentle with yourself. You deserve good rest. 💙",
            userOptions = listOf(
                UserOption("Thank you", "tired_loop", 0)
            ),
            isLoopPoint = false
        ),
        "tired_tried_everything" to ConversationNode(
            id = "tired_tried_everything",
            mood = "tired",
            baobaoLine = "Persistent sleep struggles can be really hard. If this continues, talking to a healthcare provider might help. You deserve restful nights. 🌙",
            userOptions = listOf(
                UserOption("I'll consider it", "tired_loop", 0)
            ),
            isLoopPoint = false
        ),
        "tired_guilty" to ConversationNode(
            id = "tired_guilty",
            mood = "tired",
            baobaoLine = "Rest isn't laziness. It's how you recharge so you can keep being amazing. You deserve care, friend. 💚",
            userOptions = listOf(
                UserOption("I needed to hear that", "tired_loop", 0)
            ),
            isLoopPoint = false
        ),
        "tired_something_light" to ConversationNode(
            id = "tired_something_light",
            mood = "tired",
            baobaoLine = "Perfect! The claw machine is playful and doesn't ask much of you. Or we could just hang out here. Whatever feels right. 🎯",
            userOptions = listOf(
                UserOption("Let's do it", "tired_loop", 0)
            ),
            isLoopPoint = false,
            featureNudge = "claw-machine"
        ),
        "tired_just_talk" to ConversationNode(
            id = "tired_just_talk",
            mood = "tired",
            baobaoLine = "I'm here. No pressure to say anything profound—just being together is enough. 🐼",
            userOptions = listOf(
                UserOption("This helps", "tired_loop", 0)
            ),
            isLoopPoint = false
        ),
        "tired_loop" to ConversationNode(
            id = "tired_loop",
            mood = "tired",
            baobaoLine = "You've been so patient with yourself today. Rest is productive. Rest is necessary. Rest is brave. How are you feeling now? 🌙",
            userOptions = listOf(
                UserOption("Check in with my mood", "return_to_mood", 0)
            ),
            isLoopPoint = true
        )
    )

    // ========== OKAY MOOD SCRIPTS ==========

    private val okayNodes = mapOf(
        "okay_start" to ConversationNode(
            id = "okay_start",
            mood = "okay",
            baobaoLine = "So you're feeling... okay. And that's totally okay! 😊 Sometimes days are just kinda... there. Want to keep it chill, or are you hoping to shift the vibe?",
            userOptions = listOf(
                UserOption("Keep it chill", "okay_chill", 0),
                UserOption("Maybe brighten things up", "okay_brighten", 0),
                UserOption("Just checking in", "okay_checking", 0)
            ),
            isLoopPoint = false
        ),
        "okay_chill" to ConversationNode(
            id = "okay_chill",
            mood = "okay",
            baobaoLine = "Perfect vibes. No pressure to be anything more than you are right now. Want to just hang out, or is there something you'd like to chat about? 🐼",
            userOptions = listOf(
                UserOption("Let's just hang out", "okay_hang", 0),
                UserOption("Maybe chat a bit", "okay_chat", 0)
            ),
            isLoopPoint = false
        ),
        "okay_brighten" to ConversationNode(
            id = "okay_brighten",
            mood = "okay",
            baobaoLine = "I love that energy! Sometimes okay is a great launching pad for joy. Want to try something fun, or hear something uplifting? ✨",
            userOptions = listOf(
                UserOption("Something fun sounds good!", "okay_fun", 0),
                UserOption("Something uplifting", "okay_uplifting", 0)
            ),
            isLoopPoint = false
        ),
        "okay_checking" to ConversationNode(
            id = "okay_checking",
            mood = "okay",
            baobaoLine = "I appreciate you checking in! Even when things are just okay, it's worth acknowledging. How's your day been treating you? 🌤️",
            userOptions = listOf(
                UserOption("Pretty steady", "okay_steady", 0),
                UserOption("A bit of everything", "okay_mixed", 0)
            ),
            isLoopPoint = false
        ),
        "okay_hang" to ConversationNode(
            id = "okay_hang",
            mood = "okay",
            baobaoLine = "Cool! I'm always down for a chill hangout. We could try the claw machine for some casual fun, or just vibe here together. Your call! 🎯",
            userOptions = listOf(
                UserOption("Claw machine sounds fun", "okay_loop", 0),
                UserOption("Just vibing is good", "okay_loop", 0)
            ),
            isLoopPoint = false,
            featureNudge = "claw-machine"
        ),
        "okay_chat" to ConversationNode(
            id = "okay_chat",
            mood = "okay",
            baobaoLine = "I'm all ears! What's on your mind? Big thoughts, small thoughts, random thoughts—all welcome here. 🐼",
            userOptions = listOf(
                UserOption("Just thinking out loud", "okay_loop", 0)
            ),
            isLoopPoint = false
        ),
        "okay_fun" to ConversationNode(
            id = "okay_fun",
            mood = "okay",
            baobaoLine = "Fun incoming! Want to hear a silly joke, try the claw machine, or explore the shop for new vibes? 🎉",
            userOptions = listOf(
                UserOption("Tell me a joke!", "okay_joke", 0),
                UserOption("Claw machine!", "okay_loop", 0),
                UserOption("Check out the shop", "okay_loop", 0)
            ),
            isLoopPoint = false,
            featureNudge = "joke"
        ),
        "okay_uplifting" to ConversationNode(
            id = "okay_uplifting",
            mood = "okay",
            baobaoLine = "Here's a thought: you're doing better than you think. Even on 'okay' days, you're showing up. That matters. ✨",
            userOptions = listOf(
                UserOption("Thanks, I needed that", "okay_loop", 0),
                UserOption("Got more affirmations?", "okay_more_affirmations", 0)
            ),
            isLoopPoint = false,
            featureNudge = "affirmation"
        ),
        "okay_steady" to ConversationNode(
            id = "okay_steady",
            mood = "okay",
            baobaoLine = "Steady is good! Not every day needs to be a rollercoaster. Sometimes steady is exactly what we need. 🌿",
            userOptions = listOf(
                UserOption("You're right", "okay_loop", 0)
            ),
            isLoopPoint = false
        ),
        "okay_mixed" to ConversationNode(
            id = "okay_mixed",
            mood = "okay",
            baobaoLine = "Life's like that sometimes—a mixtape of moments. The 'okay' days help us appreciate all the different notes. 🎵",
            userOptions = listOf(
                UserOption("That's a nice way to think about it", "okay_loop", 0)
            ),
            isLoopPoint = false
        ),
        "okay_joke" to ConversationNode(
            id = "okay_joke",
            mood = "okay",
            baobaoLine = "Why did the panda bring a ladder to the bamboo forest? To reach new heights! 🎋😄 Want another?",
            userOptions = listOf(
                UserOption("Haha, sure!", "okay_loop", 0),
                UserOption("That was perfect", "okay_loop", 0)
            ),
            isLoopPoint = false,
            featureNudge = "joke"
        ),
        "okay_more_affirmations" to ConversationNode(
            id = "okay_more_affirmations",
            mood = "okay",
            baobaoLine = "Always! You're worthy of good things, rest, and joy. Don't let anyone (including yourself) tell you otherwise. 💚",
            userOptions = listOf(
                UserOption("Thank you, BaoBao", "okay_loop", 0)
            ),
            isLoopPoint = false,
            featureNudge = "affirmation"
        ),
        "okay_loop" to ConversationNode(
            id = "okay_loop",
            mood = "okay",
            baobaoLine = "It's been nice chilling with you! Sometimes okay is exactly where we need to be. How are you feeling now? 🐼",
            userOptions = listOf(
                UserOption("Check in with my mood", "return_to_mood", 0)
            ),
            isLoopPoint = true
        )
    )

    // ========== INTERVENTION / CARE SUPPORT SCRIPTS ==========

    private val interventionNodes = mapOf(
        "intervention_start" to ConversationNode(
            id = "intervention_start",
            mood = "intervention",
            baobaoLine = "Hey friend, I've noticed you've been carrying some heavy feelings lately. I want you to know—what you're going through is real, and it's okay to need more support than just our chats. 💙",
            userOptions = listOf(
                UserOption("I'm managing okay", "intervention_managing", 0),
                UserOption("It has been hard", "intervention_hard", 0),
                UserOption("Tell me more", "intervention_more", 0)
            ),
            isLoopPoint = false
        ),
        "intervention_managing" to ConversationNode(
            id = "intervention_managing",
            mood = "intervention",
            baobaoLine = "I hear you, and I believe you. You're so strong for handling what you're going through. At the same time, even the strongest people deserve extra support. Would you like to know about some resources that could help lighten the load? 🌿",
            userOptions = listOf(
                UserOption("Yes, show me resources", "intervention_resources", 0),
                UserOption("Maybe later", "intervention_later", 0)
            ),
            isLoopPoint = false
        ),
        "intervention_hard" to ConversationNode(
            id = "intervention_hard",
            mood = "intervention",
            baobaoLine = "Thank you for trusting me enough to share that. What you're feeling matters, and you don't have to face it alone. There are people who are trained to help with exactly what you're going through—and reaching out to them isn't giving up, it's being brave. 💚",
            userOptions = listOf(
                UserOption("What kind of help?", "intervention_more", 0),
                UserOption("Show me the resources", "intervention_resources", 0)
            ),
            isLoopPoint = false
        ),
        "intervention_more" to ConversationNode(
            id = "intervention_more",
            mood = "intervention",
            baobaoLine = "I'm so glad you asked. Sometimes when feelings get really heavy or stick around for a while, talking to a counselor, therapist, or even a trusted helpline can make a huge difference. They have tools and understanding that go beyond what I can offer. You deserve that kind of support. 🫂",
            userOptions = listOf(
                UserOption("Okay, I'll look at resources", "intervention_resources", 0),
                UserOption("I'm not ready yet", "intervention_not_ready", 0)
            ),
            isLoopPoint = false
        ),
        "intervention_resources" to ConversationNode(
            id = "intervention_resources",
            mood = "intervention",
            baobaoLine = "That's such a brave step. I'm proud of you. I've put together some resources that might help. Remember: reaching out is a sign of strength, not weakness. I'll be right here whenever you need me. 💙",
            userOptions = listOf(
                UserOption("View Resources", "show_resources_screen", 0)
            ),
            isLoopPoint = false
        ),
        "intervention_later" to ConversationNode(
            id = "intervention_later",
            mood = "intervention",
            baobaoLine = "That's completely okay. There's no rush, and no pressure. Just know that whenever you're ready, these resources will be here for you. And I'll always be here too. You matter, and your wellbeing matters. Take care of yourself, friend. 🌸",
            userOptions = listOf(
                UserOption("Thank you, BaoBao", "intervention_complete", 0),
                UserOption("Actually, show me the resources", "intervention_resources", 0)
            ),
            isLoopPoint = false
        ),
        "intervention_not_ready" to ConversationNode(
            id = "intervention_not_ready",
            mood = "intervention",
            baobaoLine = "I understand, and that's okay. This is your journey, and you get to decide the pace. Just please remember: you're not alone, even if it feels that way sometimes. Whenever you're ready to explore more support, I'll help you find it. Until then, I'm here. 💚",
            userOptions = listOf(
                UserOption("Thanks for understanding", "intervention_complete", 0),
                UserOption("Wait, let me see the resources", "intervention_resources", 0)
            ),
            isLoopPoint = false
        ),
        "intervention_complete" to ConversationNode(
            id = "intervention_complete",
            mood = "intervention",
            baobaoLine = "You've been incredibly brave today. Remember: reaching out for help is one of the strongest things you can do. I'm always here for you, friend. How are you feeling right now? 💙",
            userOptions = listOf(
                UserOption("Check in with my mood", "return_to_mood", 0)
            ),
            isLoopPoint = true
        )
    )

    /**
     * Get the conversation tree for a specific mood
     */
    fun getScriptPool(mood: String): Map<String, ConversationNode> {
        return when (mood.lowercase()) {
            "happy" -> happyNodes
            "sad" -> sadNodes
            "anxious" -> anxiousNodes
            "tired" -> tiredNodes
            "okay" -> okayNodes
            "intervention" -> interventionNodes
            else -> okayNodes
        }
    }

    /**
     * Get the starting node for a mood
     */
    fun getStartingNode(mood: String): ConversationNode {
        val scriptPool = getScriptPool(mood)
        return scriptPool["${mood.lowercase()}_start"]
            ?: throw IllegalStateException("No starting node found for mood: $mood")
    }

    /**
     * Get a specific node by ID from a mood's script pool
     */
    fun getNodeById(mood: String, nodeId: String): ConversationNode? {
        val scriptPool = getScriptPool(mood)
        return scriptPool[nodeId]
    }

    /**
     * Check if a node is a loop point
     */
    fun isLoopPoint(nodeId: String): Boolean {
        return nodeId.endsWith("_loop") || nodeId == "return_to_mood"
    }

    /**
     * Play audio for a conversation node (Future feature)
     * When implementing audio:
     * 1. Add audioResourceId: Int? to ConversationNode data class
     * 2. Store audio files in res/raw/ folder
     * 3. Use MediaPlayer to play the audio
     * 4. Example: playNodeAudio(context, node.audioResourceId)
     */
    fun playNodeAudio(nodeId: String) {
        // TODO: Implement audio playback
        // val audioResId = getAudioResourceForNode(nodeId)
        // if (audioResId != null) {
        //     val mediaPlayer = MediaPlayer.create(context, audioResId)
        //     mediaPlayer.start()
        // }
    }
}