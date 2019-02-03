# Minidown

Minimalist markup language previwer

## Introduction

Minidown is a markup language previewer for minimalists.
This doesn't require complex settings but only [pandoc](http://pandoc.org/) (and other processors for some document formats) on your PATH.
This doesn't have live-preview feature and you should reload the browser page manually to update the content - but you really need it ?

## Requirements

+ [pandoc](http://pandoc.org/)
+ [asciidoctor](https://asciidoctor.org/) (if you write AsciiDoc)
+ java (if you write PlantUML)
+ xdg-open (if you are on Linux)

## Usage

Just run `:Minidown` command on your preferred buffer and you can see its
content on your primary browser.

## Credit

Thanks to [andyferra](https://gist.github.com/andyferra/2554919), the default
css in Minidown is largely based on it.
