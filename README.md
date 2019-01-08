## Survey Stack
### Description
Survey Stack exists to solve data problems for organizations who anywhere along the 3 stage human-data-collection-via-paper-survey journey. Organizations may struggle with data input, data management, and data analysis. This solution was designed to run on lower specification

Survey Stack helps by providing automation in:
1. Form Generation
2. Data Input
3. Data Management
4. Data Analysis
5. Advanced Data Analysis

### Table of Contents


### Why?
Survey Stack allows for the creation, ingestion, and analysis of surveys.

While digital data collection permeates every aspect of modern life, many organizations gain significant value from pen and pencil populated data. A paper survey can empower human-data collection.  Natural disasters can leave populations without access to internet resources. Many organizations find that their survey completion rate declines when surveys are only offered electronically. True or False and multiple choice questions of frequently fail to collect and present both the information that the client wishes to express and the organization can be empowered by knowing. Survey Stack provides a way to connect the critical data flow between the client and organization over a mutually acceptable median; paper surveys, without requiring a tedious and expensive investment of human-hours on the organization's side.

The ability to collect written responses doesn't necessarily empower the organization in the same way that quantitative data can. Typically, advanced analysis must be performed on the short responses and then categorized and notated by a human. Survey Stack empowers organizations by providing a way to perform sentiment analysis on participants responses to categorize.

### Installation
Installation on debian-based distributions is currently as easy as running the following command:
```
bash install_survey.sh
```
On other distributions, simply install docker and git, clone the repository, then use install_survey.sh as a guide to build the docker image.

### Usage
Survey Stack allows you to create a form that can then be printed, distributed, completed and recollected. The documents can then be scanned and uploaded to Survey Stack. Survey Stack can then ingest the quantitative and qualitative responses and empower the organization with advanced analysis

### Requirements
Host capable of running Docker.

### Credits
Creators: Tom Gleason, Tom Fowler, Josh Lee, Christian Taillon

Libraries: Shiny, ShinyDashboard, dplyr, exams, rmarkdown
