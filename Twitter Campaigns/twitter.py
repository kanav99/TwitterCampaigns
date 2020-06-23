import os
import tweepy
import datetime
import json
from dateutil.parser import parse

ConsumerKey = os.environ["TCConsumerKey"]
ConsumerSecret = os.environ["TCConsumerSecret"]
AccessKey = os.environ["TCAccessKey"]
AccessSecret = os.environ["TCAccessSecret"]

auth = tweepy.OAuthHandler(ConsumerKey, ConsumerSecret)
auth.set_access_token(AccessKey, AccessSecret)

api = tweepy.API(auth, wait_on_rate_limit=True,
    wait_on_rate_limit_notify=True)

try:
    print(json.dumps(api.me()._json))
except:
    print(-1)
