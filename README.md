*A sweet suite of text extraction tools.*

# Premise
This project aims to bring together different text parsing techniques to provide simple answers to simple questions. This is all done using a mixture of regex, natural language parsing (NLP), machine learning, and statistical analysis. The typical use case is document or article analysis.

* What email addresses are available?
* What phone numbers are available?
* What people are mentioned?
* What email belongs to which person?
* What ISBN numbers are available?

## Dependencies
Textract currently relies on a couple important gems to be available in your project, including the [Stanford Core NLP package](http://nlp.stanford.edu/software/corenlp.shtml) for language processing, and [amatch](http://flori.github.com/amatch/) which exposes some advanced text matching techniques.

```shell
gem install stanford-core-nlp
gem install amatch
```

I ran into some issues getting the Stanford Core NLP library working, but they were pretty easily resolved. Give me a shout (email address below) if you have problems.

**Find them on Github as well**
* [stanford-core-nlp](https://github.com/louismullie/stanford-core-nlp)
* [amatch](https://github.com/flori/amatch)

## Using the client
The included `client.rb` file is a simple way to test the class using the `simple.txt` example. To run all of the methods, simple use the following in the terminal:

```shell
ruby client.rb
```

This should provide you with a nice color-enhanced output in the term

## Known issues
* For text documents larger than a paragraph, the Java heap stack runs out of memory
* Some obscure names are not caught, but could be using intelligent parsing
* Some abbreviations like Mon (Monday) are included as names

If you have any questions, please do not hesistate to get in touch with me [matt@syllabuster.com](mailto:matt@syllabuster.com)
