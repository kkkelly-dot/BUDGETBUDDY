# Supabase Setup Guide for BudgetBuddy

## 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign up/login
2. Click "New Project"
3. Choose your organization
4. Enter project details:
   - Name: `budgetbuddy` (or any name you prefer)
   - Database Password: Create a strong password
   - Region: Choose the closest region to you
5. Click "Create new project"

## 2. Get Your Project Credentials

1. In your Supabase dashboard, go to Settings → API
2. Copy the following values:
   - **Project URL** (looks like: `https://your-project-id.supabase.co`)
   - **Anon/Public Key** (starts with `eyJ...`)

## 3. Set Up the Database Schema

1. In your Supabase dashboard, go to SQL Editor
2. Copy and paste the contents of `supabase_schema.sql` into the editor
3. Click "Run" to execute the SQL

## 4. Update Your Flutter App

1. Open `lib/config.dart`
2. Replace the placeholder values with your actual Supabase credentials:
   ```dart
   static const String supabaseUrl = 'YOUR_ACTUAL_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_ACTUAL_SUPABASE_ANON_KEY';
   ```

## 5. Install Dependencies and Run

1. Run the following commands in your project directory:
   ```bash
   flutter pub get
   flutter run
   ```

## 6. Test the App

1. The app should now connect to Supabase
2. Try adding some transactions (income/expense)
3. Check your Supabase dashboard → Table Editor → transactions to see the data

## Troubleshooting

- If you get connection errors, double-check your URL and anon key
- Make sure you've run the SQL schema in your Supabase project
- Check the console for any error messages

## Security Notes

- The current setup allows all operations on the transactions table
- For production, you should implement proper Row Level Security (RLS) policies
- Consider adding user authentication if needed 