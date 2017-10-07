# Ruby machine learning examples

## Language detection

It requires fetch samples from twitter.

```
$ ruby nbayes-words.rb "hi, my name is john"
LANG: en

{"es"=>0.1843430663505358,
 "en"=>0.24315534276967207,
 "fr"=>0.19032126018759724,
 "de"=>0.18715104247734474,
 "ja"=>0.19502928821485016}
```

## Fetch languages samples from twitter

```
$ CONSUMER_KEY=1234 CONSUMER_SECRET=ABCD ruby twitter-fetch.rb
```


## Text generator

It generates text from books downloaded from [Project Gutemberg](http://www.gutenberg.org/)

The repo has already some spanish books downloaded in txt, check how to [download more books](https://www.gutenberg.org/wiki/Gutenberg:Information_About_Robot_Access_to_our_Pages)

```
ruby generator-gutenberg.rb generate --books=15

Expected string default value for '--deep'; got 4 (numeric)
Expected string default value for '--words'; got 50 (numeric)
Expected string default value for '--books'; got 5 (numeric)
Generate text with options:
Deep: 4
Words: 50
Language: es
Books source: 15

= Indexing...
- 1 gutenberg/es/11047-8.txt
- 2 gutenberg/es/11081-8.txt
- 3 gutenberg/es/12368-8.txt
- 4 gutenberg/es/11529-8.txt
....


con su hija y a su madre, y que los chicos de la calle de las casas de las dos en el mismo punto en que me había dicho que no era lo que había hecho lo que no es otra cosa que de la noche en la cama
```
