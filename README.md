CPMAD Mini Project Proposal
Name: Kaliraj Sanjana
Admin Number: 232100J
Module: CPMAD
Key Domain: Health and Enabled Aging
________________________________________
A. Project Title
ElderCare+ : A Smart Health Companion for Enabled Ageing
________________________________________
B. Background
Singapore’s population is ageing quickly, and more seniors now need regular access to affordable healthcare and easy-to-use tools for daily health management. Many older adults struggle to remember their medication schedules, keep track of health records, or find nearby subsidised clinics for primary care.
As more seniors use smartphones, a well-designed mobile app can help them age well by offering easy access to health features and reliable information. This project will use mobile technology and open government data to help older adults live more independently and stay connected to important healthcare services.
________________________________________
C. Objectives
The objectives of this application are to:
•	Assist elderly users in managing basic personal health information
•	Provide a simple and intuitive interface suitable for senior users
•	Enable users to locate nearby subsidised healthcare facilities easily
•	Promote independent and active ageing through the use of mobile technology
•	Support Singapore’s Smart Nation initiative under the Health & Enabled Ageing domain
________________________________________
D. Key Functional Features
Feature 1: User Login and Registration
•	Allow users to register and log in using email and password
•	Authentication implemented using Firebase Authentication
•	User authentication state is persisted across app restarts
Login, registration, and logout are treated as one functional feature.
________________________________________
Feature 2: Medication Reminder Management
•	Allow users to add medication details such as name, dosage, and reminder time
•	Display medication records using a dynamic list view
•	Enable users to update or remove existing medication entries
•	Medication data stored and retrieved from Cloud Firestore
________________________________________
Feature 3: Basic Health Log Tracking
•	Allow users to record basic health information such as blood pressure, heart rate, and notes
•	Display historical health logs in a structured list format
•	Support simple filtering by date
•	Health records stored securely in Cloud Firestore
________________________________________
Feature 4: Nearby Subsidised Clinics (Dataset-Driven Map)
•	Retrieve CHAS clinic location data from an open government dataset (data.gov.sg) in GeoJSON format
•	Display clinic locations on an interactive map using markers
•	Allow users to search clinics by name or area
•	Provide clinic details such as name, address, and contact information
________________________________________
E. Data Source & Data Storage
Data Sources
•	Open Government Data: CHAS Clinics GeoJSON dataset (data.gov.sg)
Data Storage Methods
•	Firebase Authentication – user login and authentication
•	Cloud Firestore – medication records, health logs, and user profile data
•	Firebase Storage – user profile images
•	SharedPreferences – theme preference (light/dark mode)
All application data is stored dynamically and no  data is hardcoded.
________________________________________
F. State Management
The application uses Provider for state management to handle:
•	Medication data state
•	Health log data state
•	User authentication state
•	Application theme state (light/dark mode)
________________________________________
G. References
•	Data.gov.sg – Open Government Data Portal
https://developers.data.gov.sg
•	Ministry of Health (MOH) – Community Health Assist Scheme (CHAS)
https://www.moh.gov.sg
•	Firebase Documentation
https://firebase.google.com/docs
