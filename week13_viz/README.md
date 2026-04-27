# Week 13 — Visualization

Hands-on examples for the visualization lecture. Mix of in-browser (Plotly, D3) and Python (matplotlib, seaborn, plotly.express, networkx) so you can pick the right tool for the job.

## What's here

```
week13_viz/
├── README.md                  ← you are here
├── ex1.html                   Plotly: time series, one line per hashtag
├── ex2.html                   Plotly: box plot + scatter w/ regression line
├── ex3.html                   Plotly: dropdown filter, dual y-axis
├── d3.html                    D3 v7: force-directed Twitter follower network
├── viz_python.ipynb           Jupyter notebook covering all of the above in Python,
│                              plus data cleaning and figure export for papers
└── data/
    ├── data.js                Tweet rows + network as JS globals
    │                          (CORONA_TWEETS, TWITTER_NETWORK).
    │                          Loaded by every HTML file.
    ├── corona_tweets.csv      Same tweet rows in CSV (used by the notebook)
    ├── corona_tweets_raw.csv  Same data with intentional defects (mixed timestamps,
    │                          missing values, dupes) for the cleaning exercise
    └── twitter_network.json   Same network in JSON (used by the notebook)
```

## How to run

### HTML examples — just double-click

The HTML files load data through a `<script src="data/data.js">` tag, so the browser allows it on `file://` URLs (unlike `fetch()`, which it blocks). **No web server, no install, no setup.** Just open any `.html` in your browser:

- `ex1.html` — Plotly time series
- `ex2.html` — Plotly box plot + regression
- `ex3.html` — Plotly dropdown filter
- `d3.html` — D3 force-directed network

Tested in Chrome and Safari from `file://`. If you hit a CDN block on a campus network, run the lab locally with `python3 -m http.server` from this folder.

### Python notebook

```bash
pip install pandas matplotlib seaborn plotly networkx jupyter
jupyter notebook viz_python.ipynb
```

The notebook reads from the **CSV/JSON** files (not `data.js`) — that's the kind of dirty data students will actually start with in their own projects.

## Suggested order

1. **`viz_python.ipynb`** — start here. It walks through the *workflow* you'll use for your own research projects: load → clean → explore → publish.
2. **`ex1.html`** — same time series as the notebook, but in the browser. Smallest possible Plotly example.
3. **`ex2.html`** — distributions and relationships. The two charts that show up in almost every empirical paper.
4. **`ex3.html`** — interactivity: a dropdown that redraws the chart, dual y-axes for two units on one plot.
5. **`d3.html`** — when you need full control over the visual: force-directed graph of a real Twitter follower subgraph (data from `week10_twitter_network/`).

## Choosing a tool

| You want… | Use |
|---|---|
| A figure for a conference/journal paper | **matplotlib + seaborn**, save as PDF/SVG |
| Quick exploration on a fresh dataset | **seaborn** or **plotly.express** in a notebook |
| Hover/zoom/filter in the browser | **Plotly** (high-level) |
| Pixel-perfect custom visual | **D3** (low-level, more code) |
| Network analysis *and* viz | **networkx** in Python; **Gephi** for very large graphs |
| Geospatial | `geopandas`, `folium`, `kepler.gl` (not covered here) |

## Updating the data

If you change `data/corona_tweets.csv` or `data/twitter_network.json`, regenerate `data/data.js` so the HTML examples pick up the changes:

```bash
python3 - << 'PY'
import csv, json
rows = []
with open("data/corona_tweets.csv") as f:
    for r in csv.DictReader(f):
        rows.append({"timestamp": r["timestamp"], "hashtag": r["hashtag"],
                     "tweet_count": int(r["tweet_count"]),
                     "avg_sentiment": float(r["avg_sentiment"])})
network = json.load(open("data/twitter_network.json"))
with open("data/data.js", "w") as f:
    f.write("window.CORONA_TWEETS = " + json.dumps(rows, indent=2) + ";\n\n")
    f.write("window.TWITTER_NETWORK = " + json.dumps(network, indent=2) + ";\n")
PY
```

## Notes on the data

- `corona_tweets.csv` is **synthetic** — generated to give the examples enough structure (multiple hashtags, sentiment, several hours of timestamps) to demonstrate non-trivial visualization techniques. The shape (volume rises and falls, sentiment varies by hashtag) is realistic but the numbers aren't real measurements.
- `twitter_network.json` is **derived from real data** in `../week10_twitter_network/data/`, collected in Feb 2020 around `@fairfaxhealth`'s followers. Only the top-60 most-connected nodes are included so the graph is readable.

## Common pitfalls

- **Plotly chart appears blank** → check the browser DevTools console (Cmd+Opt+J in Chrome). Usually a typo in `data/data.js` after you've edited it, or a CDN that's been blocked by a network filter.
- **`pd.to_datetime` warnings about ambiguous formats** in the notebook → the cleaning cell uses `format='mixed'` deliberately; the warnings are informational.
- **Network looks like one giant blob** → too many edges. Filter to a subgraph (top-N by degree, single community, etc.) before drawing.
