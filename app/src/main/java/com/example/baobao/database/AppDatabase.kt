package com.example.baobao.database

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@Database(entities = [UserData::class, Purchase::class], version = 3, exportSchema = false)
abstract class AppDatabase : RoomDatabase() {
    abstract fun userDao(): UserDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "baobao_database"
                )
                .fallbackToDestructiveMigration() // For development - handles schema changes
                .build()

                // Initialize default user data if first time
                CoroutineScope(Dispatchers.IO).launch {
                    val userData = instance.userDao().getUserDataOnce()
                    if (userData == null) {
                        instance.userDao().insertUserData(UserData())
                    }
                }

                INSTANCE = instance
                instance
            }
        }
    }
}
