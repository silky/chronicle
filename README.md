# chronicle

Chronicle allows you to form reliable memories. It keeps track of a **tree of memories** that are, ultimately, linked to the factual records recorded at the very moment they happened.

<!-- TOC generated using https://github.com/jonschlinkert/markdown-toc
-->
  * [Why do this?](#why-do-this-)
  * [Chronicle explained in detail](#chronicle-explained-in-detail)
  * [How is the data represented?](#how-is-the-data-represented)
    + [Moment](#moment)
    + [Story](#story)
    + [Marks](#marks)
    + [Folds](#folds)
  * [Tech](#tech)
    + [Future use](#future-use)
  * [HACKING](#hacking)
    + [Database notes](#database-notes)
    + [Elm package ideas](#elm-package-ideas)

## Why do this?

Humans are adept at denialism. The author therefore presumes that only a [data-centric approach](http://www.theatlantic.com/business/archive/2013/10/how-google-uses-data-to-build-a-better-worker/280347/) can be effective at improving human well-being and productivity.

Over a period of data collection, one can't help but gain insights into what *actually* causes — as opposed to what one [remembers](https://en.wikipedia.org/wiki/List_of_memory_biases) or
is [taught](https://en.wikipedia.org/wiki/Social_conditioning) to be causing — one's happiness and unhappiness.

## Chronicle explained in detail

The basic idea is to keep track of a **tree of memories**. Accumulation of data occurs at the level of leaf nodes (individual moments), from which we "fold" the memories up to summarize at the ancestries. Specifically, we fold all moments of the day to summarize for that day, and then fold all days to summarize for that week, then month, year and so on.

All level of summarizations are ultimately linked to the specific moments (thus forming a tree) that can be consulted at any time. We thus create reliable "memories" that are recorded at individual moments (the very moment they happened) without the bias of faulty recall.

There is also the notion of "story" (yet to be implemented) which some moments can belong to. A story is thus linked to the individual moments, and can be consulted when "telling" (to oneself or others) the story later on, and with little bias.

## How is the data represented

Chronicle stores all of its data in PostgreSQL. There are 4 concepts (tables):

### Moment

This is what the "feelings" table currently contains. It is just the individual moments recording how things were at that very moment.

### Story

This, as the word indicates, is a string of moments forming a "story" to be recalled (or re-told) later. Examples:

* Work
* Work at $company
* India trip 2015
* Chronicle development

Each moment can belong to at most one story. Some stories, like "India trip 2015", are **smart stories** in that they are specified using time ranges (thus moments can't explicitly belong to them).

### Marks

These are analogous to the colored shapes in my blackboard (cf. Seinfeld productivity hack). The idea is to have basic (SVG?) shapes defined somewhere – in Elm, or database — and let the user specify a list of them to be rendered ultimately in the calendar view. Fields:

* Shapes: list of shapes
* Value: numeric value of this mark (used for aggregating in outter folds)

### Folds

Each day, week, month, year are summarized as folds. Stories may have their own folds (eg: work fold). Fields:

* Summary
* Time range
* Marks (list of marks, as described above).

The calendar view of folds will be showing these marks (usually just the default one), thus emulating what we have in the blackboard. The user can define custom marks in the Marks table and refer to them in the folds.

Fold can also enable habit tracking (eg: contemplate XYZ every day; with value=0 or 1, accumulating over week/month/etc).

## Tech

* [spas](https://github.com/srid/spas) (via [PostgREST](https://github.com/begriffs/postgrest)) - automatic REST API for PostgreSQL
* [Elm](http://elm-lang.org/) - client-side language using FRP
* [Bootstrap](http://getbootstrap.com/) - HTML/CSS framework

### Future use

* For calendar UI: http://bootstrap-calendar.azurewebsites.net/index-bs3.html

## HACKING

Please note that chronicle is not yet ready for public use.

```
make run  # requires spas cloned and compiled in parent repo
make compile # rebuild Elm sources
```


### Database notes

Use `\d+ 1.feelings` to inspect the view.

Use `ALTER ROLE <username> SET timezone = 'America/Vancouver';` to set database timezone. This however doesn't automatically change the day end marker from 12am to something custom (like 3am).

TODO: dump schema into git repo.

```
CREATE TABLE feelings_dev (
    how feelingkind DEFAULT 'meh'::feelingkind NOT NULL,
    what text,
    trigger text,
    notes text,
    at timestamp with time zone DEFAULT now() NOT NULL
);

create or replace view "1".feelings as
SELECT *  FROM feelings
 ORDER BY feelings.at DESC;
```


### Elm package ideas

Some new packages I can create by extracing code from this repo:

* Date formatter
* Time ago (eg.: `23 secs ago`)
* Search query parser (see `src/Search.elm`)
* Bootstrap.elm (maybe [use this](https://github.com/circuithub/elm-bootstrap-html)?)
