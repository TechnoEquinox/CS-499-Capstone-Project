# CS-499-Capstone-Project

This repo is my Capstone Project for my CS-499: Computer Science Capstone class at Southern New Hampsire University.

In this project, I plan to take existing code developed previously in my CS-360: Mobile Application Development class and rewrite it in Swift and SwiftUI for iOS and improve upon it in the following three categories:

1. Software Engineering and Design
2. Algorithms and Data Structures
3. Databases

## Table of Contents
- ePortfolio
    - [Professional Self-Assessment](#professional-self-assessment)
    - [Android Application Code Review](#android-application-code-review)
    - [Narratives](#narratives)
        - [Software Engineering and Design Narrative](#software-engineering-and-design-narrative)
        - [Algorithms and Data Structures Narrative](#algorithms-and-data-structures-narrative)
        - [Databases Narrative](#databases-narrative) 
- Setup
    - [MariaDB Setup](#mariadb-setup)
    - [Database and JWT Auth](#database-and-jwt-auth)
    - [Installing Inventory API](#install-inventory_api)
    - [Running Inventory API](#running-inventory_api)
- Uninstall
    - [Uninstalling Inventory API](#uninstall-inventory_api)  

## Professional Self-Assessment
Developing this ePortfolio has allowed me to consolidate and demonstrate the skills I developed throughout my time here at Southern New Hampshire University into a single, cohesive capstone project. Rather than focusing on isolated enhancements, I chose to perform all three enhancements on an existing application I developed in **CS-360: Mobile Application Arcitecture**. I was able to identified meaningful areas for improvement and apply software engineering best practices to enhance this application's design, functionality, and security. Through this process, I strengthened my ability to think about system architecture, data flow, and long-term maintainability while balancing technical requirements with user needs. The capstone also reinforced the importance of clear communication and professional documentation, as I was required to explain design decisions, justify enhancements, and present technical work in a way that would be understandable to both technical and nontechnical stakeholders. By completing this project, I gained confidence in my ability to independently plan, implement, and refine production-oriented software solutions, directly preparing me to transition into a professional computer science role.

The artifacts included in this ePortfolio collectively represent the culmination of this capstone project and demonstrate how my technical skills work together within a complete system. Each artifact contributes to a broader narrative of software enhancement, showcasing improvements in software engineering and design, the application of appropriate data structures and algorithms, and the integration of a secure, relational database backend. Together, these artifacts highlight my ability to refactor existing code, implement secure authentication mechanisms, manage persistent data effectively, and ensure that system components interact reliably and efficiently. As a unified portfolio, the artifacts in this repository illustrate my readiness to contribute to real-world software development efforts.

## Android Application Code Review
This is the link to my original code review I performed in Module Two. This code review is taken on my existing Android Application and details all of the improvements and changes I planned to make during my Capstone Project.

[Module Two Code Review - CS-499: Computer Science Capstone](https://www.youtube.com/watch?v=r7XucI1nc8A)

## Narratives

### Software Engineering and Design Narrative
In this Milestone, I completed the first enhancement for my capstone project by migrating my existing Inventory App from Java to Swift. I feel like this work confidently shows my ability to translate design elements between programming languages and mobile platforms. This showcases my ability to create useful applications for both the Google Play Store and Apple’s App Store. In order to complete this enhancement, I started by recreating the UI elements for each view in Swift by following the existing design pattern in my Android application. Once this was complete, I modified the code to allow the user to navigate between these different views. From here, I went and took a design pass over the application, improving the colors and adding visual elements that were not present in the Android application to help reduce the cognitive load on the user. I then began performing work to enhance the user experience by adding new useful attributes to our design pattern and tweaked the design language to create a more platform native experience while still retaining the core functionality present in the Android application. I then continued to add further improvements to the application, including the ability to delete items from the warehouse enmass, filtering options, and included SF symbols to fill blank space and add visual cues for the user.

I believe I successfully implemented most of the goals I had set out in Module One for this enhancement. The only pieces that I did not complete were pieces that directly involve other enhancements. For example, while I did recreate a login view that mirrors the view written for Android, I did not implement any kind of login validation. I felt that this work was unnecessary for this step, as any code I wrote to make it functional now would just be placeholder code that would end up being replaced in Enhancement 3. I also implemented a NotificationsView, but did not hook this up to anything currently. This work will be completed in Enhancement 2.

Due to my past experience creating iOS applications, I was very excited to get started with this enhancement. I did not face many significant challenges when implementing enhancement due to this experience. My structured approach to this work made completing this very logical and I never felt lost with where I should have been headed next. I feel like I was even able to enhance the user experience from my Android application. In the real world, I would take these enhancements and changes I implemented in my iOS application and provide another update to the Android application so the user experience is consistent across both platforms. 

### Algorithms and Data Structures Narrative
For enhancement two, I continued with my work on the Inventory App now that I had rewritten the foundation of the application in Swift. For this enhancement, I wanted to implement a proper notification system to notify the user when there is low stock for an item in the warehouse, and create an algorithm that can proactively notify the user about items that might go out of stock soon. To do this, I first implemented the UI for the NotificationView to allow the user to enable/disable notifications, display the current system permission for notifications, and created a subview that displays the notifications a user has received. I then began work on the NotificationSettingsViewModel that would manage all aspects of notifications to the user. I also implemented a InventoryNotification data model to reflect the structure of a notification.  The ViewModel was written to handle all aspects of the notifications, including the management of the data structure that persistently stores InventoryNotification data models to the device locally through the use of UserDefaults. The ViewModel also dispatches native Push Notifications so the user can still receive notifications outside the context of the app. I have also included a screen recording of the iOS simulator to show the Push Notification behavior with my submission. 

This item was selected for my ePortfolio because it will demonstrate my ability to integrate system native features (Push Notifications) with strong computer science principles. This enhancement shows how I can design software systems that analyze data to construct trends and insights that would otherwise either be too time consuming or simply not feasible to be done by a person. This enhancement improved the existing Android application by properly implementing a system native feature to deliver notifications, and provides more insight into the dynamic environment of a warehouse. The app has become more useful and user friendly to use. 

For this enhancement, I met most of the outcomes I had planned for this section. The one section I could not yet implement was the historical notification to the user just due to the fact that it needs the data from the database in Enhancement Three in order to be implemented. I plan to circle back on this before the final submission to connect the plumbing and finish the implementation of this feature. The push notification implementation is the foundation of this feature to come, and spending time making sure the notification delivery is polished will allow for easier implementation and debugging for the historical notifications. 

In this enhancement, I spent a lot of time debugging and learning how to both send a Push Notification, and how to properly store these notifications with the use of a reusable data model. I initially was taking a much more manual approach to implementing this feature, but it became clear early on that I wasn’t headed down the right path. After reading through a lot of the documentation on Apple’s Developer Site and experimenting with a dummy project, I was finally able to implement a solution that was much more “Swifty” and slotted into my existing project nicely. 

### Databases Narrative

In this artifact I created an SQL database for use in user authentication and for serving business critical inventory data from a central source in a cloud environment. To host this service, I selected Akamai Cloud due to my previous experience working with them and low hosting prices. I spun up a small droplet running Ubuntu Server 24.04 LTS to run this service. Once the host was setup with firewall rules, I then began working with MariaDB to create a SQL database with a Users table and a Inventory table. I took time and care to create a database schema that matched the expected structure of data in our iOS application. I then crafted a RESTful server written in Python with Flask to serve data for both of these functions to our clients. The endpoints included CRUD (Create, Read, Update, and Delete) functionality on our database and supports simultaneous access from multiple clients. Finally, I implemented these endpoints in my Swift app. This required reworking my View Model and writing asynchronous compatible code to handle the network requests and responses.

This artifact is the third major piece of my Inventory App. This enhancement shows my ability to create and manage a SQL database, and then stand up the infrastructure to securely serve this data to clients. This enhancement also shows how I can integrate a backend service into an existing frontend application, and highlights my ability to create API endpoints for an application. This improved my previous Android artifact by not storing business critical data on only one device. Considering the use case for this application in a busy and large warehouse environment, this on device storage solution is not practical to use. Hosting a centralized database that multiple clients can connect simultaneously too over a network makes much more sense in this application. Building the application like this allows for increased employee and manager awareness about inventory levels, and allows the ability to implement access control mechanisms to multiple users of different access levels. 

I think I nailed the course outcomes I planned to meet with this enhancement. Now that this work has been completed, I can take the remaining time before the final submission to finish up the final remaining task that required the database implementation. 

The biggest challenge I faced when working on this enhancement was a bug I was seeing on the Swift side in my initial development. I had misunderstood how to properly implement a network call in Swift, and as a result I was seeing a behavior where the Swift application was not properly making calls to my /get-all-items endpoint after initially loading. After a lot of debugging and going over the documentation, I discovered that because of how I initiated this async call in Swift, SwiftUI was cancelling my async task and refreshable context, which was also cancelling the underlying URLSession request before it could finish. Ultimately, by wrapping the function call in a task instead of making the call with async, I was able to solve this problem. This was a very simple solution, but was quite time consuming to debug and required me to learn a lot about how SwiftUI updates its views and how that interacts with the application as a whole. Additionally, I also needed a small refresher on my SQL skills. It has been a little while since I have worked with SQL and as a result I was making mistakes and forgetting common database commands. I had to pull up the MariaDB documentation and spend some time looking this over, and then even then I had to spend some time massaging my database commands to craft the tables and columns properly for this project. I was very comfortable standing up the RESTful endpoints and didn’t struggle much with this step other than learning how to use pymysql to interact with the database in Python. This was also where I spent some additional time reading the documentation and experimenting in small steps to understand how this library works. 

## MariaDB Setup
This project assumes you have already installed MariaDB, and have configured it with a hostname, user, password, and a database name. Leave the database empty and do not add or configure any tables. 

For more information on installing MariaDB, refer to the [documentation found here](https://mariadb.com/docs/server/server-management/install-and-upgrade-mariadb/installing-mariadb/compiling-mariadb-from-source/building-mariadb-on-ubuntu).

## Database and JWT Auth
This data is saved in the auth.json file not published here. This file is created when running the install.sh file. This JSON contains the following structure:

```
{
    "host": "[DB HOSTNAME GOES HERE]",
    "user": "[USERNAME GOES HERE]",
    "password": "[PASSWORD GOES HERE]",
    "database": "[NAME OF DB GOES HERE]",
    "jwt_secret_key": "72d839280208ec4c81d5b4f25572c5941fabf99c2d9d7f0becf25f047f8b988384c33a516d484f1b8d3b87f621eadf2ffc40c1c33726cb5722374432ea726a66"
}
```
This data is used by the application to make the connection to the existing SQL database. *install.sh* will generate the jwt_secret_key automatically before installation has completed. You can verify and change this information at any time by navigating to */inventory_api/auth/auth.json*.

This JWT token is required for all of the end-points that provide CRUD (Create, Read, Update, Destroy) functionality to our database, ensuring only authorized users are able to make changes and view the warehouse inventory. When a new client device authenticates successfully, the login end-points return a newly generated JWT token that is valid for 15 minutes, or until the client closes the application. The client use this token to verify the CRUD request is from an authenticated user.

During installation, the script uses the auth information provided to test the connection to MariaDB and if successful, creates the following tables in the database using *install.py*:

```
+------------------------+
| Tables_in_inventory_db |
+------------------------+
| inventory_items        |
| user_types             |
| users                  |
+------------------------+
```

### inventory_items
```
+--------------+------------------+------+-----+---------------------+-------------------------------+
| Field        | Type             | Null | Key | Default             | Extra                         |
+--------------+------------------+------+-----+---------------------+-------------------------------+
| id           | int(10) unsigned | NO   | PRI | NULL                | auto_increment                |
| uuid         | char(36)         | NO   | UNI | NULL                |                               |
| name         | varchar(100)     | NO   |     | NULL                |                               |
| quantity     | int(11)          | NO   |     | NULL                |                               |
| max_quantity | int(11)          | NO   |     | NULL                |                               |
| location     | varchar(100)     | NO   |     | NULL                |                               |
| symbol_name  | varchar(100)     | NO   |     | shippingbox         |                               |
| created_at   | datetime         | NO   |     | current_timestamp() |                               |
| updated_at   | datetime         | NO   |     | current_timestamp() | on update current_timestamp() |
+--------------+------------------+------+-----+---------------------+-------------------------------+
```

### user_types
```
+-------------+---------------------+------+-----+---------+-------+
| Field       | Type                | Null | Key | Default | Extra |
+-------------+---------------------+------+-----+---------+-------+
| id          | tinyint(3) unsigned | NO   | PRI | NULL    |       |
| name        | varchar(50)         | NO   | UNI | NULL    |       |
| description | varchar(255)        | YES  |     | NULL    |       |
+-------------+---------------------+------+-----+---------+-------+
```

This table is seeded with 3 user types that are required for the application. 

        (1, 'Employee',   'Standard warehouse employee')
        (2, 'Manager', 'Warehouse manager')
        (3, 'Admin',    'Full administrative privileges')

### users
```
+---------------+---------------------+------+-----+---------------------+----------------+
| Field         | Type                | Null | Key | Default             | Extra          |
+---------------+---------------------+------+-----+---------------------+----------------+
| id            | int(10) unsigned    | NO   | PRI | NULL                | auto_increment |
| username      | varchar(50)         | NO   | UNI | NULL                |                |
| password_hash | varchar(255)        | NO   |     | NULL                |                |
| user_type_id  | tinyint(3) unsigned | NO   | MUL | NULL                |                |
| last_login_at | datetime            | YES  |     | NULL                |                |
| created_at    | datetime            | NO   |     | current_timestamp() |                |
+---------------+---------------------+------+-----+---------------------+----------------+
```

## Install inventory_api
Clone the repository to the home directory of your system. The Inventory API is found under *CS-499-Capstone-Project/InventoryApp - iOS/inventory_api/*. Then, follow these instructions to move the API to your home directory.

```
cd CS-499-Capstone-Project/InventoryApp - iOS
cp -r inventory_api/ ~/
cd ~/inventory_api
./install.sh
```

This will create the project structure and automatically download the required dependencies via pip. Near the end of the installation, you will be prompted for the database auth information. You can edit this data at any time by navigating to */inventory_api/auth/auth.json*

If you are not interested in the client code, then you can remove the *CS-499-Capstone-Project/* from your device at this point:
```
rm -r CS-499-Capstone-Project/
```

## Running inventory_api
To run the API, make sure you follow the installation steps. If *install.sh* completes successfully, then the Flask API should be running on port 5000. You can verify this with:

```
sudo systemctl status inventory_api.service
```

## Uninstall inventory_api
To uninstall the inventory_api, perform the following:

```
cd inventory_api/
./uninstall.sh
```
Once the uninstall has completed, you can then remove the project folder from your system using:

```
rm -r inventory_api/
```
Please note, this uninstall script does not remove or destroy any of the database data, as this is incredibly destructive. If you do not want this database on your system anymore, please refer to the MariaDB documentation to drop the data.




