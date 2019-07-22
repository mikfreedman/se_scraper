# se_scraper

Small application that will accept Street Easy URLs as a post parameter at `/cards` like so:

```bash
curl -X POST \
  http://scraper.mjfreedman.com/cards \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://streeteasy.com/building/40-sullivan-street-new_york/house?featured=1"
}'
```

And creates a trello card in your nominated backlog
