# CS-499-Capstone-Project

This repo is my Capstone Project for my CS-499: Computer Science Capstone class at Southern New Hampsire University.

In this project, I plan to take existing code developed previously in my CS-360: Mobile Application Development class and rewrite it in Swift and SwiftUI for iOS and improve upon it in the following three categories:

1. Software Engineering and Design
2. Algorithms and Data Structures
3. Databases

## MariaDB Structure
For information on the database structure and schema, please see *inventory_db description.txt*.

### Requirements: MariaDB
This project assumes you have already installed MariaDB, and have configured it with a hostname, user, password, and a database name. Leave the database empty and do not add or configure any tables. 

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
This data is used by the application to make the connection to the existing SQL database. *install.sh* will generate the jwt_secret_key automatically before installation has completed. You can verify and change this information at any time by navigating to */inventory_api/auth/auth.json*

## Install
Clone the repository to the home directory of your system. Then perform the following:

```
cd inventory_api/
./install.sh
```

This will create the project structure and automatically download the required dependencies via pip. Near the end of the installation, you will be prompted for the database auth information. You can edit this data at any time by navigating to */inventory_api/auth/auth.json*

## Running inventory_api
To run the API, make sure you follow the installation steps. If *install.sh* completes successfully, then the Flask API should be running on port 5000. You can verify this with:

```
sudo systemctl status inventory_api.service
```

## Uninstall
To uninstall the inventory_api, perform the following:

```
deactivate
cd inventory_api/
./uninstall.sh
```
Once the uninstall has completed, you can then remove the project folder from your system using:

```
rm -r inventory_api/
```
Please note, this uninstall script does not remove or destroy any of the database data, as this is incredibly destructive. If you do not want this database on your system anymore, please refer to the MariaDB documentation to drop the data.




