"""
Reddit Data Collector
=====================
Collects Reddit posts based on a keyword with configurable:
- Number of postings (random sampling)
- Date range (start and end dates)

No API credentials required — uses Reddit's public JSON endpoints.

Setup:
  pip install requests pandas
"""

import requests
import pandas as pd
import random
import time
from datetime import datetime, timezone


# ── Search parameters ────────────────────────────────────────────────────────

KEYWORD = "winter olympics"  # search keyword
SUBREDDIT = "all"                    # "all" for all of Reddit, or a specific subreddit
SAMPLE_SIZE = 200                    # number of posts to randomly sample
START_DATE = "2026-01-01"            # start date (YYYY-MM-DD), inclusive
END_DATE = "2026-02-20"              # end date (YYYY-MM-DD), inclusive
SORT_BY = "relevance"                # "relevance", "hot", "top", "new", "comments"
OUTPUT_FILE = "reddit_data.csv"      # output filename

# Maximum posts to fetch before sampling (increase for a larger pool, max ~250)
MAX_FETCH = 250

# ── Constants ────────────────────────────────────────────────────────────────

HEADERS = {
    "User-Agent": "reddit_collector/1.0 (research project)"
}
BASE_URL = "https://www.reddit.com"


# ── Functions ────────────────────────────────────────────────────────────────

def to_timestamp(date_str):
    """Convert a YYYY-MM-DD string to a UTC Unix timestamp."""
    dt = datetime.strptime(date_str, "%Y-%m-%d").replace(tzinfo=timezone.utc)
    return int(dt.timestamp())


def fetch_search_page(keyword, subreddit, sort_by, after=None, limit=100):
    """Fetch one page of Reddit search results as JSON."""
    url = f"{BASE_URL}/r/{subreddit}/search.json"
    params = {
        "q": keyword,
        "sort": sort_by,
        "t": "all",
        "limit": min(limit, 100),
        "restrict_sr": 0 if subreddit == "all" else 1,
    }
    if after:
        params["after"] = after

    resp = requests.get(url, headers=HEADERS, params=params, timeout=30)
    resp.raise_for_status()
    return resp.json()


def collect_posts(keyword, subreddit, start_date, end_date, sort_by, max_fetch):
    """
    Search Reddit for posts matching a keyword within a date range.
    Paginates through results using Reddit's 'after' token.
    """
    start_ts = to_timestamp(start_date)
    end_ts = to_timestamp(end_date) + 86400  # include the full end day

    print(f"Searching r/{subreddit} for '{keyword}'...")
    print(f"Date range: {start_date} to {end_date}")
    print(f"Fetching up to {max_fetch} posts (sort: {sort_by})...")

    posts = []
    after = None
    fetched = 0

    while fetched < max_fetch:
        batch_size = min(100, max_fetch - fetched)
        data = fetch_search_page(keyword, subreddit, sort_by,
                                 after=after, limit=batch_size)

        children = data.get("data", {}).get("children", [])
        if not children:
            break

        for child in children:
            post = child.get("data", {})
            created = post.get("created_utc", 0)

            # Filter by date range
            if start_ts <= created <= end_ts:
                posts.append({
                    "id": post.get("id"),
                    "title": post.get("title"),
                    "author": post.get("author", "[deleted]"),
                    "subreddit": post.get("subreddit"),
                    "score": post.get("score"),
                    "upvote_ratio": post.get("upvote_ratio"),
                    "num_comments": post.get("num_comments"),
                    "created_utc": created,
                    "created_date": datetime.fromtimestamp(created, tz=timezone.utc)
                                           .strftime("%Y-%m-%d %H:%M:%S"),
                    "url": post.get("url"),
                    "permalink": f"https://www.reddit.com{post.get('permalink', '')}",
                    "selftext": post.get("selftext"),
                    "link_flair_text": post.get("link_flair_text"),
                    "is_self": post.get("is_self"),
                    "domain": post.get("domain"),
                })

        fetched += len(children)
        after = data.get("data", {}).get("after")

        if not after:
            break

        print(f"  Fetched {fetched} posts so far, {len(posts)} within date range...")
        # Respect rate limits (Reddit allows ~10 requests/minute without auth)
        time.sleep(2)

    print(f"Found {len(posts)} posts within the date range.")
    return posts


def random_sample(posts, sample_size):
    """Randomly sample posts. Returns all posts if fewer than sample_size."""
    if len(posts) <= sample_size:
        print(f"Returning all {len(posts)} posts (fewer than requested {sample_size}).")
        return posts
    sampled = random.sample(posts, sample_size)
    print(f"Randomly sampled {sample_size} posts from {len(posts)} results.")
    return sampled


def save_to_csv(posts, output_file):
    """Save post data to a CSV file."""
    df = pd.DataFrame(posts)
    df.to_csv(output_file, index=False, encoding="utf-8-sig")
    print(f"Saved {len(df)} posts to {output_file}")
    return df


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    # Collect posts matching the keyword within the date range
    posts = collect_posts(
        keyword=KEYWORD,
        subreddit=SUBREDDIT,
        start_date=START_DATE,
        end_date=END_DATE,
        sort_by=SORT_BY,
        max_fetch=MAX_FETCH,
    )

    if not posts:
        print("No posts found. Try broadening the date range or keyword.")
        return

    # Random sampling
    sampled_posts = random_sample(posts, SAMPLE_SIZE)

    # Save results
    df = save_to_csv(sampled_posts, OUTPUT_FILE)

    # Print summary
    print("\n── Summary ─────────────────────────────────────")
    print(f"Keyword:      {KEYWORD}")
    print(f"Subreddit:    r/{SUBREDDIT}")
    print(f"Date range:   {START_DATE} to {END_DATE}")
    print(f"Total found:  {len(posts)}")
    print(f"Sampled:      {len(sampled_posts)}")
    print(f"Output file:  {OUTPUT_FILE}")
    print(f"\nColumns: {list(df.columns)}")
    print(f"\nTop 5 posts by score:")
    top5 = df.nlargest(5, "score")[["title", "subreddit", "score", "num_comments"]]
    print(top5.to_string(index=False))


if __name__ == "__main__":
    main()
