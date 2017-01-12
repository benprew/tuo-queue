# tou queue

A queuing API for running tuo sims

## Requirements
* Ruby
* [tuo](https://sf.net/p/tyrant-unleashed-optimizer)

## Installation

After cloning the repo run:

1. `gem install bundler`
2. `bundle install`

## Starting the queue

In the root directory of the repo run:

1. `bundle exec bin/tuo_queue start`

## API

How to post a sim job programatically

`POST` to `/job/create`

| Param | Description |
|-------|-------------|
|`username`|Name of the user you're simming for|
|`your_deck`|cards separated by ',', Commander has to come first, min 3 cards in deck|
|`your_inventory`|list of cards in your inventory, separated by ','|
|`your_structs`|list of your structures, separated by ','|
|`ordered`|if present, will order deck (-r in tuo)|
|`mode`|if `surge` will sim in surge mode (-s in tuo)|
|`enemy_deck`|can be mission (ie Pandemonium Mutant-10) or string cards separated by ',', Commander has to come first, min 3 cards in deck|
|`enemy_structs`|list of enemy structures, separated by ','|
|`command`|what you want to do (sim, climb, reorder)|
|`cmd_count`|number of sim iterations (usually 5000 or 10000)|
|`fund`|if you're climbing the fund tuo has to upgrade cards|
|`bge`| Battle Ground Effect (ie Furiosity)|
