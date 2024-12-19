# Set the working directory for the project and logs
$projectDir = "D:\ASU\Mobile Programming\hedieatyfinalproject"  
$logDir = "D:\ASU\Mobile Programming\hedieatyfinalproject\test_logs" 

Set-Location -Path $projectDir

# Start the screen recording for the first test in the background
$screenRecordingJob1 = Start-Job {
    adb shell screenrecord /sdcard/test_recording_1.mp4
}

# Run the first Flutter test
flutter test .\integration_test\Hediaty_app_test.dart
Start-Sleep -Seconds 30


# Stop the screen recording after test completes
adb shell pkill -l 2  # Sends SIGINT (Ctrl+C) to stop the screen recording
# Pull the screen recording file to your local machine
adb pull /sdcard/test_recording_1.mp4 $logDir

# Start the screen recording for the second test in the background
$screenRecordingJob2 = Start-Job {
    adb shell screenrecord /sdcard/test_recording_2.mp4
}

# Run the second Flutter test
flutter test .\integration_test\my_event_list_test.dart
Start-Sleep -Seconds 30

# Stop the second screen recording after test completes
adb shell pkill -l 2  # Sends SIGINT (Ctrl+C) to stop the screen recording

# Pull the second screen recording file to your local machine
adb pull /sdcard/test_recording_2.mp4 $logDir

# Optionally, you can also pull logs or any other output from the device
adb logcat -d > "$logDir\logcat_output.txt"

# Clean up background jobs
$screenRecordingJob1 | Wait-Job | Remove-Job
$screenRecordingJob2 | Wait-Job | Remove-Job
