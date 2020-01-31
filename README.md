# Choosing what to do during your next vacation

It’s summertime and we have decided we are going to Madrid for our vacation! However, we don’t know what to do when we get there. Thankfully, we’ve got a list of activities, so all that’s left is to write a program to help us decide where to go.

The goal of this project is to write a web API to help select activities to do in Madrid. We’re ambitious, and we’re thinking of expanding it to include data about multiple cities in the future, and adding more complicated planning, e.g: taking into account the transportation between different activities. In this exercise we’ll focus in the first steps towards that goal, but think of it as the first milestone in a bigger project.

We don’t want to take too much of your time. We estimate this test should take you no longer than a three or four hours. Don’t worry if you finish faster, or if it takes you a little longer, as it can vary a lot depending on how you approach the project.

Keep in mind the following:
- Please include a document with your code explaining your thought process during the test. The more you explain the decisions that you made, the better. We want to know the way you think. This is especially important on tradeoffs.
- We are especially interested on how do you structure your code.
- You can use any programming language and framework you want, so choose something that you feel comfortable with. In CARTO, you’ll be writing Ruby, so we’d prefer if you chose a similar language (procedural, dynamically typed, object oriented), but we’ll read your test as long as it’s not written in something like Malbolge ;)
- Please, make it easy to run and test. It would be great if you provide an installation script, but a quick README is enough.
- Feel free to contact us for any questions about the test. We’ll do our best to answer as quickly as possible. You can reach us at gonzalor@carto.com and alrocar@carto.com (CC both of us)
- Your goal is to write a web API to show information about activities. Feel free to use any libraries you deem appropriate for the task, as long as they are available under an open source license.

Your program should:
1. Load the provided activities file (`madrid.json`). It’s structured as JSON file with the following attributes:
  - Name of the activity
  - Opening hours. For each time of the week, an array of intervals when the place is open to visits
  - The average time in hours spent in the place
  - Category, location and district
  - Coordinates, expressed as an array with latitude and longitude
2. Create an endpoint that returns all available activities
  - It should return all information about the available activities, in GeoJSON format
  - It should be able to filter by category, location or district. If no filter is provided, it should list all activities
3. Create an endpoint to recommend what to do at a given time
  - The endpoint will receive a time range that the vacation-goer has available to perform an activity and the preferred category
  - It should return a single activity and all its details, in GeoJSON format
  - The returned activity should belong to the specified category and be open to the public at the time of visit. Keep in mind that the user will spend some time doing the activity (as specified in the activity description)
  - If there are multiple options, choose the one with the longest visit time that fits in the time range

Additionally, we will want to extend the functionality in the future. There is no need to write code for the following part, but we’d like you to think about it and write some thoughts on how you would extend your program to add the following features:
- Do not recommend an outdoors activity on a rainy day
- Support getting information about activities in multiple cities
- Extend the recommendation API to fill the given time range with multiple activities

When you are done, please upload your code and documentation to a GitHub repository (or any other platform) and send us the link.