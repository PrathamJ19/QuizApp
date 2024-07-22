Hello there,

This is my Full-Stack Quiz app for IOS Devices. Here I have made a multi-view interface for giving quizzes for students and making new quiz & updating them for staff members. 
All the quizes are stored in Firebase in a JSON format.

1. To make this file work, you will need to add a GoogleService-Info.plist which you can get when adding a new Firebase Project. 
2. Login into Firebase and create a new project.
3.  Select IOS App on Project Overview Home Page and register the app by providing necessary information (just the Bundle Identifier in Xcode Project Details). 
4. Download your configuration file and add/drag it to the project.
5. Add Firebase SDK in the XCode by Selecting 'File > Add Package Depedencies > Search > 🔍 Firebase-ios-sdk'.
6. Select 'Add package' and select QuizApp under following : FirebaseAuth, FirebaseDatabase and FirebaseFirestore.
8. Try building. Enjoy!
9. Check if it performs CRUD Operations on your Firebase Firestore. Also check authentication page for monitoring users, if they are added properly and displayed.

Hopefully the app works as intended. You will se data update in realtime as you make any changes in the Quizzes.

Thank You.
