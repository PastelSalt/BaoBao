package com.example.baobao

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.example.baobao.databinding.ActivityAuthBinding

class AuthActivity : AppCompatActivity() {
    private lateinit var binding: ActivityAuthBinding
    private var isSignUp = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityAuthBinding.inflate(layoutInflater)
        setContentView(binding.root)

        updateUI()

        binding.signupButton.setOnClickListener {
            isSignUp = !isSignUp
            updateUI()
        }

        binding.loginButton.setOnClickListener {
            // Keep Auth to Main transition at 1.5s (1500L)
            LoadingActivity.startWithTarget(this, MainActivity::class.java, 1500L)
            finish()
        }
    }

    private fun updateUI() {
        if (isSignUp) {
            binding.nicknameInputLayout.visibility = View.VISIBLE
            binding.loginButton.text = "Sign Up"
            binding.signupButton.text = "Already have an account? Login"
            binding.bubbleText.text = ConversationManager.getRandomSignup()
        } else {
            binding.nicknameInputLayout.visibility = View.GONE
            binding.loginButton.text = "Login"
            binding.signupButton.text = "Don't have an account? Sign Up"
            binding.bubbleText.text = ConversationManager.getRandomLogin()
        }
    }
}