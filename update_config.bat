@echo off
echo ========================================
echo BudgetBuddy Supabase Configuration
echo ========================================
echo.
echo Please enter your Supabase credentials:
echo.
set /p SUPABASE_URL="Enter your Supabase URL (e.g., https://your-project.supabase.co): "
set /p SUPABASE_KEY="Enter your Supabase Anon Key: "
echo.
echo Updating config.dart...
echo.

powershell -Command "(Get-Content 'lib/config.dart') -replace 'YOUR_SUPABASE_URL', '%SUPABASE_URL%' -replace 'YOUR_SUPABASE_ANON_KEY', '%SUPABASE_KEY%' | Set-Content 'lib/config.dart'"

echo Configuration updated successfully!
echo.
echo Now restart your Flutter app to connect to Supabase.
echo.
pause 