# Status Board Widgets #

This [Sinatra][1] app can be used to pull traffic analytics from GitHub's [Gauges][2], feed analytics from [URI.LV][3] and website monitoring from [Vigil][4] and display them on your [Status Board][5].

## Configuration ##

The easiest (and free) way to deploy this app is [Heroku][6]. If you're not familiar with Heroku, it has an extensive [documentation][7]. Basically all you have to do is, fork this repo, create a Heroku account, create a Heroku app and push the code to it via git.

## Usage ##

Currently, there are four different endpoints supported:

### /traffic ###

The `/traffic` endpoint returns a graph with page views for one or multiple gauges. To use it, just add a Graph panel to your status board an point it to:

    http://your-app.herokuapp.com/traffic?api_key=<your-api-key>&gauge1=<your-first-gauge-id>&gauge2=<your-second-gauge-id>

For a single gauge it will display views + people and for multiple gauges it will only display the views. As a default the graph will be displayed as a linegraph. If you'd like a bargraph, just append `&type=bar` to the request URI.

### /subscribers/graph  ###

The `/subscribers/graph` endpoint returns a graph with subscriber counts for one or multiple feeds from URI.LV. To use it, just add a Graph panel to your status board an point it to:

    http://your-app.herokuapp.com/subscribers/graph?api_key=<your-api-key>&token=<your-api-token>&feed1=<your-first-feed-name>&feed2=<your-second-feed-name>

For a single page it will display more detailed statistiks (grader, other, direct) and for multiple pages it will only display the total subscribers. As a default the graph will be displayed as a linegraph. If you'd like a bargraph, just append `&type=bar` to the request URI.

### /subscribers/table  ###

The `/subscribers/table` endpoint returns a table with subscriber counts for one or multiple feeds from URI.LV. To use it, just add a DIY panel to your status board an point it to:

    http://your-app.herokuapp.com/subscribers/table?api_key=<your-api-key>&token=<your-api-token>&feed1=<your-first-feed-name>&feed2=<your-second-feed-name>

### /vigil ###

Vigil does already give you an [Status Board table][8], if you have an account. It uses, however, the standard Status Board table layout, which may be fine for the TV, but on the iPad alone I find it way to big. The `/vigil` endpoint retunrs a table, which is basically a remodelling the official Vigil table to make it a bit smaller. To use it, just add a DIY panel to your status board an point it to:

    http://your-app.herokuapp.com/vigil?user=<your-user-id>

If you look at the link Vigil gives you for your Status Board, it looks like this:
    
    panicboard://?url=http%3A%2F%2Fapi.vigil-app.com%2Fv1%2Fuser%2<some-hexadecimal-number-with-dashes>%2Fhost%3FpopulateHostMonitors%26output%3Dhtml&panel=table&sourceDisplayName=Vigil

This `<hexadecimal-number-with-dashes>` is `<your-user-id>`.


## License ##

This project is licensed under the terms of the MIT License.

[1]: http://www.sinatrarb.com
[2]: http://get.gaug.es
[3]: http://uri.lv
[4]: http://vigil-app.com
[5]: http://panic.com/statusboard/
[6]: http://heroku.com
[7]: http://devcenter.heroku.com/articles/ruby
[8]: http://status.vigil-app.com
