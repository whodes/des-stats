# des-stats


simple Sinatra app that provides stats to my personal site. 

It currently just pulls in my streak data from duolingo and nytimes. Since neither provides an actual 
API, this is very much hack city. 

uses redis for caching because im extra✨. 

# To run 
``` 
bundle install 
```

set environment variables 

```
export REDIS_URL="redis://localhost:6379"
export DUOLINGO_USER_ID="your_duolingo_user_id"
export NYTIMES_COOKIE="your_nytimes_cookie"
``` 

start the app 

```bundle exec puma -C app.rb ``` 