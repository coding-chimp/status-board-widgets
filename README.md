# Status Board Widgets #

This [Sinatra][1] app can be used to pull traffic analytics from GitHub's [Gauges][2] and feed analytics from [URI.LV][3] and display them on your [Status Board][4].

## Configuration ##

The easiest (and free) way to deploy this app is [Heroku][5]. If you're not familiar with Heroku, it has an extensive [documentation][6]. Basically all you have to do is, fork this repo, create a Heroku account, create a Heroku app and push the code to it via git.

## Usage ##

Currently, there are three different endpoints supported:

### /traffic ###

The `/traffic` endpoint returns a graph with page views for one or multiple gauges. To use it, just add a Graph panel to your status board an point it to:

    http://your-app.herokuapp.com/traffic?api_key=<your-api-key>&gauge1=<your-first-gauge-id>&gauge2=<your-second-gauge-id>

### /subscribers/graph  ###

The `/subscribers/graph` endpoint returns a graph with subscriber counts for one or multiple feeds from URI.LV. To use it, just add a Graph panel to your status board an point it to:

    http://your-app.herokuapp.com/subscribers/graph?api_key=<your-api-key>&token=<your-api-token>&feed1=<your-first-feed-name>&feed2=<your-second-feed-name>

### /subscribers/table  ###

The `/subscribers/table` endpoint returns a table with subscriber counts for one or multiple feeds from URI.LV. To use it, just add a DIY panel to your status board an point it to:

    http://your-app.herokuapp.com/subscribers/table?api_key=<your-api-key>&token=<your-api-token>&feed1=<your-first-feed-name>&feed2=<your-second-feed-name>

## License ##

This project is licensed under the terms of the MIT License.

[1]: http://www.sinatrarb.com
[2]: http://get.gaug.es
[3]: http://uri.lv
[4]: http://panic.com/statusboard/
[5]: http://heroku.com
[6]: http://devcenter.heroku.com/articles/ruby