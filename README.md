# Status Board Widgets #

This [Sinatra][1] app can be used to pull traffic analytics from GitHub's [Gauges][2], feed analytics from [FeedPress][3], website monitoring from [Vigil][4] and user informations from [GitHub][5] and display them on your [Status Board][6].

## Configuration ##

The easiest (and free) way to deploy this app is [Heroku][7], for which instructions are provided, but Status Board Widgets can be deployed anywhere that supports Ruby.

If you [created an Heroku account][8] and have the [Heroku Toolbelt][9] installed, all you need to do is:

    $ git clone git@github.com:coding-chimp/status-board-widgets.git
    $ cd status-board-widgets
    $ heroku create
    $ git push heroku master

## Additional Configuration  ##

If you want to use the `/github/streak` endpoint, there are a few more things you need to do.
First you'll need to add a database:

    $ heroku addons:add heroku-postgresql:dev

Which will return something like: `Attached as HEROKU_POSTGRESQL_GOLD_URL`
The `HEROKU_POSTGRESQL_GOLD_URL` part can differ for you and is the important part for the next command:

    $ heroku pg:promote HEROKU_POSTGRESQL_GOLD
    $ heroku run rake db:migrate

Then you need create a [GitHub API access token][11] and add it and your username to your Heroku environment:
    
    $ heroku config:set GITHUB_USERNAME=<your-github-username>
    $ heroku config:set GITHUB_TOKEN=<your-github-api-token>

Now you'll add a task to ping GitHub's activity stream:

    $ heroku addons:add scheduler
    $ heroku addons:open scheduler

Add a task that runs `rake fetch_today` every 10 minutes.

This will make sure the app is up to date in the future. If you want the app to fetch some past data, you can run:

    $ heroku run rake fetch_history

## Usage ##

Currently, there are six different endpoints supported:

### /traffic ###

The `/traffic` endpoint returns a graph with page views for one or multiple gauges. To use it, just add a Graph panel to your status board an point it to:

    http://your-app.herokuapp.com/traffic?api_key=<your-api-key>&gauge1=<your-first-gauge-id>&gauge2=<your-second-gauge-id>

For a single gauge it will display views + people and for multiple gauges it will only display the views. As a default the graph will be displayed as a linegraph. If you'd like a bargraph, just append `&type=bar` to the request URI.

### /subscribers/graph  ###

The `/subscribers/graph` endpoint returns a graph with subscriber counts for one or multiple feeds from FeedPress. To use it, just add a Graph panel to your status board an point it to:

    http://your-app.herokuapp.com/subscribers/graph?api_key=<your-api-key>&token=<your-api-token>&feed1=<your-first-feed-name>&feed2=<your-second-feed-name>

For a single page it will display more detailed statistiks (greader, other, direct) and for multiple pages it will only display the total subscribers.

As a default the graph will be displayed as a linegraph. If you'd like a bargraph, just append `&type=bar` to the request URI.

The default date format is `day.month` (eg. `21.6.`). If you instead want your dates to be formatted as `month–day` (eg. `6–21`), just append `&dateformat=us` to the URI request.

You can also specify the min and max values of the y-axis by appending for example `&minValue=50` and `maxValue=150` to the URI request.

### /subscribers/table  ###

The `/subscribers/table` endpoint returns a table with subscriber counts for one or multiple feeds from FeedPress. To use it, just add a DIY panel to your status board an point it to:

    http://your-app.herokuapp.com/subscribers/table?api_key=<your-api-key>&token=<your-api-token>&feed1=<your-first-feed-name>&feed2=<your-second-feed-name>

### /vigil ###

Vigil does already give you an [Status Board table][10], if you have an account. It uses, however, the standard Status Board table layout, which may be fine for the TV, but on the iPad alone I find it way to big. The `/vigil` endpoint retunrs a table, which is basically a remodelling the official Vigil table to make it a bit smaller. To use it, just add a DIY panel to your status board an point it to:

    http://your-app.herokuapp.com/vigil?user=<your-user-id>

If you look at the link Vigil gives you for your Status Board, it looks like this:
    
    panicboard://?url=http%3A%2F%2Fapi.vigil-app.com%2Fv1%2Fuser%2<some-hexadecimal-number-with-dashes>%2Fhost%3FpopulateHostMonitors%26output%3Dhtml&panel=table&sourceDisplayName=Vigil

This `<hexadecimal-number-with-dashes>` is `<your-user-id>`.

### /github ###

The `/github` endpoint gives you a little GitHub dashboard with your followers, following, public repos and public gists counts. The easiest way to use it is, adding a DIY panel to your status board an point it to:

    http://your-app.herokuapp.com/github?username=<your-github-username>

If you also want to see how many unread notifications are waiting for you, you'll have to craeate an [API access token][11] and either add it to the url:

    http://your-app.herokuapp.com/github?username=<your-github-username>&token=<your-github-api-token>

or add your username and API token to your Heroku environment like discribed in the [additional configuration][12] and point the panel to:

    http://your-app.herokuapp.com/github

If you set your app up for using the `/github/streak` endpoint, you can, of course, just use the last url.

### /github/streak ###

The `/github/streak` endpoint shows you your current streak of days you commited code to GitHub. To use this endpoint, you have to set the app up like described in [additional configuration][12]. After that, you can just add a DIY panel to your status board and point it to:

    http://your-app.herokuapp.com/github/streak

## License ##

This project is licensed under the terms of the MIT License.

[1]: http://www.sinatrarb.com
[2]: http://get.gaug.es
[3]: http://feedpress.it
[4]: http://vigil-app.com
[5]: http://github.com
[6]: http://panic.com/statusboard/
[7]: http://heroku.com
[8]: https://id.heroku.com/signup/devcenter
[9]: https://toolbelt.heroku.com
[10]: http://status.vigil-app.com
[11]: https://github.com/settings/applications
[12]: #additionalconfiguration
