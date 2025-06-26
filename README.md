# Discourse Baseline Latest API

A Discourse plugin that provides an API endpoint for the EACM portal to fetch latest forum topics.

## Installation

Add this to your `app.yml` in the plugins section:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/eac-m/discourse-baseline-latest.git
```

Then rebuild: `./launcher rebuild app`

## Usage

### Endpoint
```
GET https://discourse.eacm.nl/baseline_latest
```

### Headers Required
- `Api-Key`: Your Discourse API key
- `Api-Username`: The username associated with the API key (optional but recommended)

### Parameters
- `limit`: Number of topics to return (default: 20)

### Example Request
```bash
curl -H "Api-Key: YOUR_API_KEY" \
     -H "Api-Username: portal_user" \
     https://discourse.eacm.nl/baseline_latest?limit=10
```

### Response Format
```json
{
  "topics": [
    {
      "id": 269,
      "title": "Topic Title",
      "slug": "topic-title",
      "posts_count": 5,
      "created_at": "2025-06-26T09:43:04.200Z",
      "last_posted_at": "2025-06-26T10:15:00.000Z",
      "category_name": "General",
      "tags": ["announcement", "news"],
      "url": "https://discourse.eacm.nl/t/topic-title/269",
      "like_count": 42,
      "views": 256,
      "reply_count": 4
    }
  ],
  "count": 10
}
```

## Security

The endpoint requires a valid Discourse API key. The topics returned are based on what the API user can see according to their permissions.

## License

MIT
