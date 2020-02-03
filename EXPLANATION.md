# Development process

First of all I read repeatedly what was required for this programming task. I started building an application using Ruby on Rails as it’s the framework I feel more comfortable working with at the moment. I used the last version and as it’s an API application I used this version so no views where created.

After that I created the models needed by the application to create the different activities whit their opening hours, and created a library in charge of loading and parsing the information in a file into actual information understandable by the rails application.

With this library code I though on a way to load the data in the app so it’s always as updated as possible. Also it needed to be prepared to other sources of information from other cities, so to do so I created an ActiveJob working with Sidekiq that is launched once a day that reads the activities from `madrid.json` file, but it could be a file from another city or mode than one file, also with some development could be a Job taking the information from a service for example.

With the data models and the actual information I started to read and inform myself about GeoJSON standard and how to work with it. Once it was understood I create an method in Activity model that converted the information of the model into a correct GeoJSON object.
Once I had that I created the endpoint in charge to return the collection of activities that matched a filter, and the method in the model in charge of creating the GeoJSON object containing the information of the collection of activities.

Once I had that endpoint I created the following one which should return the best activity for a date and some hours being the longest activity you could perform in those hours. I had to take into account that the available times can be less that the `hours_spent` to perform the activities. And also that the parameters can be in an incorrect order or not valid.

In order to make the requested improvements regarding recommendations system first for the weather we would need to connect to an API to get the prediction for the given date and in case it has bad weather use the `indoors` scope to filter the available activities for that date. And for the multiple recommendations we would have to remove `max_by` and from the resulting group select the combination of activities which sum of `hours_spent` was lesser or equal to the available hours to perform activities.

Apart from this there’s a `Makefile` with some useful commands to run and test the application. Also the application runs in dockers so it should work regarding the OS you are using as long as you have docker installed. Also it passes rubocop to ensure that some standards and good practices are implemented in the application.
 
